//
//  MessageFormPresenterTests.swift
//  DozyTests
//
//  Created by Andrew Daniel on 7/12/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import XCTest
@testable import Dozy

class MessageFormPresenterTests: XCTestCase {

    var presenter: MessageFormPresenter!
    var viewModel: MesssageFormViewModel!
    var delegateMock: MessageFormDelegateMock!
    
    var urlSessionMock: URLSessionMock!
    var keychainMock: KeychainMock!
    var remoteStorageableMock: RemoteStorageableMock!
    var fileManagerMock: FileManagerMock!
    
    override func setUpWithError() throws {
        Current = .mock
        let now = Date()
        Current.now = { now }
        
        let channelFetchResults = [try JSONLoader.load(fileName: "Channels"), try JSONLoader.load(fileName: "ChannelsNoCursor")]
        setupPresenter(channelFetchResults: channelFetchResults)
    }
    
    private final func setupPresenter(channelFetchResults: [URLSessionMockResult]) {
        viewModel = MesssageFormViewModel(navigationBarTitle: "Some navigation title", message: nil)
        delegateMock = MessageFormDelegateMock()
        
        urlSessionMock = URLSessionMock()
        keychainMock = KeychainMock()
        
        urlSessionMock.results.append(contentsOf: channelFetchResults)
        let networkService = NetworkService(urlSession: urlSessionMock)
        
        keychainMock.dataToLoad = Data("SOME_ACCESS_TOKEN".utf8)
        
        remoteStorageableMock = RemoteStorageableMock()
        fileManagerMock = FileManagerMock()
        
        presenter = MessageFormPresenter(
            viewModel: viewModel,
            networkService: networkService,
            keychain: keychainMock,
            dataStorageble: remoteStorageableMock,
            fileManager: fileManagerMock,
            delegate: delegateMock,
            message: nil
        )
        presenter.didTapChannelDropdown()
    }

    override func tearDownWithError() throws {
        presenter = nil
        urlSessionMock = nil
        keychainMock = nil
    }
    
    func testDidTapChannelDropdown() {
        XCTAssertTrue(viewModel.isShowingChannelDropdown)
    }

    func testChannelsFetched() {
        XCTAssertEqual(viewModel.filteredChannelItems.count, 3, "Channels have been fetched and are displayed")
    }
    
    func testChannelsFetchedFailed() {
        setupPresenter(channelFetchResults: [.init(data: nil, urlResponse: nil, error: URLSessionMock.NetworkError.someError)])
        XCTAssertEqual(viewModel.filteredChannelItems.count, 0, "Channels fetching failed")
    }
    
    func testRetryChannelFetch() throws {
        viewModel.isShowingChannelFetchError = true
        
        urlSessionMock.results.append(try JSONLoader.load(fileName: "ChannelsNoCursor"))
        presenter.onChannelFetchRetryButtonTapped()
        
        XCTAssertFalse(viewModel.isShowingChannelFetchError)
        XCTAssertEqual(viewModel.filteredChannelItems.count, 3, "Channels have been fetched and are displayed")
    }
    
    func testDidTapChannelItem() throws {
        let channel = viewModel.filteredChannelItems.first!
        presenter.didTapChannelItem(id: channel.id)
        
        XCTAssertEqual(viewModel.channelNameTextFieldText, channel.text, "Selected channel name should be visible in channel text field")
    }
    
    func testDidTapSaveWithoutImage() {
        let channel = viewModel.filteredChannelItems.first!
        presenter.didTapChannelItem(id: channel.id)
        
        let bodyText = "Some body text"
        viewModel.bodyText = bodyText
        
        presenter.didTapSave()
        
        let expectedMessage = Message(imageName: nil, imageUrl: nil, bodyText: bodyText, channel: channel)
        XCTAssertEqual(delegateMock.messageSaved, expectedMessage)
    }
    
    func testDidTapSaveWithImageAndConfirmedImageUpload() throws {
        let channel = viewModel.filteredChannelItems.first!
        presenter.didTapChannelItem(id: channel.id)
        
        let image = UIImage(named: "LogoGray", in: Bundle.main, with: nil)!
        viewModel.selectedImage = image
        
        presenter.didTapSave()
        
        XCTAssertTrue(viewModel.isShowingImageUploadConfirmation)
        
        presenter.onImageUploadConfirmed()
        
        XCTAssertTrue(viewModel.isSaving)
    
        let imageFileName = "\(Current.now().timeIntervalSinceReferenceDate).jpg"
        let expectedFileCreatedAtPath = fileManagerMock.documentsDirectoryURL.absoluteString + "/\(imageFileName)"
        XCTAssertEqual(fileManagerMock.fileCreatedAtPath, expectedFileCreatedAtPath)
        
        let expectedMessage = Message(
            imageName: imageFileName,
            imageUrl: remoteStorageableMock.referenceMock.downloadURLString,
            bodyText: nil,
            channel: channel
        )
        XCTAssertEqual(delegateMock.messageSaved, expectedMessage)
    }
    
    func testOnImageUploadCancelled() {
        viewModel.isShowingImageUploadConfirmation = true
        presenter.onImageUploadCancelled()
        
        XCTAssertFalse(viewModel.isShowingImageUploadConfirmation)
    }
    
    func testNetworkFailureAfterDidTapSaveWithImageAndConfirmedImageUpload() throws {
        let channel = viewModel.filteredChannelItems.first!
        presenter.didTapChannelItem(id: channel.id)
        
        let image = UIImage(named: "LogoGray", in: Bundle.main, with: nil)!
        viewModel.selectedImage = image
        
        presenter.didTapSave()
        
        XCTAssertTrue(viewModel.isShowingImageUploadConfirmation)
        
        remoteStorageableMock.referenceMock.error = RemoteStorageReferencingMock.StorageReferenceError.someError
        
        presenter.onImageUploadConfirmed()
        
        XCTAssertEqual(remoteStorageableMock.pathStringsCalled.first, "/images/\(Current.now().timeIntervalSinceReferenceDate).jpg")
        XCTAssertFalse(viewModel.isSaving)
        XCTAssertTrue(viewModel.isShowingSaveError)
    }
    
}

class MessageFormPresenterRemoveOldImageTests: XCTestCase {

    private var presenter: MessageFormPresenter!
    private var viewModel: MesssageFormViewModel!
    private var fileManagerMock: FileManagerMock!
    private var remoteStorageableMock: RemoteStorageableMock!
    private var delegateMock: MessageFormDelegateMock!
    
    private var message: Message {
        let channel = Channel(id: "SOME_CHANNEL_NAME", isPublic: true, text: "SOME_TEXT")
        return Message(imageName: "image.jpg", imageUrl: "https://some.com/image.jpg", bodyText: "SOME_BODY_TEXT", channel: channel)
    }
    
    override func setUpWithError() throws {
        Current = .mock
        let now = Date()
        Current.now = { now }
        
        viewModel = MesssageFormViewModel(navigationBarTitle: "Some navigation title", message: nil)
        delegateMock = MessageFormDelegateMock()
                
        let keychainMock = KeychainMock()
        keychainMock.dataToLoad = Data("SOME_ACCESS_TOKEN".utf8)
        
        let urlSessionMock = URLSessionMock()
        let channelFetchResults = [try JSONLoader.load(fileName: "Channels"), try JSONLoader.load(fileName: "ChannelsNoCursor")]
        urlSessionMock.results.append(contentsOf: channelFetchResults)
        let networkService = NetworkService(urlSession: urlSessionMock)
        
        remoteStorageableMock = RemoteStorageableMock()
        fileManagerMock = FileManagerMock()
        
        presenter = MessageFormPresenter(
            viewModel: viewModel,
            networkService: networkService,
            keychain: keychainMock,
            dataStorageble: remoteStorageableMock,
            fileManager: fileManagerMock,
            delegate: delegateMock,
            message: message
        )
    }
    
    func testRemoveOldMessageImageOnNewImageSave() {
        presenter.didTapChannelDropdown()
        let channel = viewModel.filteredChannelItems.first!
        presenter.didTapChannelItem(id: channel.id)
        
        let image = UIImage(named: "LogoGray", in: Bundle.main, with: nil)!
        viewModel.selectedImage = image
        
        presenter.didTapSave()
        presenter.onImageUploadConfirmed()
        
        let expectedItemRemovedAtPath = fileManagerMock.documentsDirectoryURL.absoluteString + "/\(message.imageName!)"
        XCTAssertEqual(fileManagerMock.itemRemovedAtPath, expectedItemRemovedAtPath)
        
        let newImageFileName = "\(Current.now().timeIntervalSinceReferenceDate).jpg"
        let expectedFileCreatedAtPath = fileManagerMock.documentsDirectoryURL.absoluteString + "/\(newImageFileName)"
        XCTAssertEqual(fileManagerMock.fileCreatedAtPath, expectedFileCreatedAtPath)
        
        XCTAssertEqual(remoteStorageableMock.pathStringsCalled.first, "/images/\(newImageFileName)")
        XCTAssertEqual(remoteStorageableMock.pathStringsCalled.last, "/images/\(message.imageName!)")
        XCTAssertTrue(remoteStorageableMock.referenceMock.deleteCalled)
    }
    
    func testRemoveOldMessageImageOnImageSaveWithoutNewImage() {
        presenter.didTapChannelDropdown()
        let channel = viewModel.filteredChannelItems.first!
        presenter.didTapChannelItem(id: channel.id)
        
        viewModel.selectedImage = nil
        
        presenter.didTapSave()
        
        let expectedItemRemovedAtPath = fileManagerMock.documentsDirectoryURL.absoluteString + "/\(message.imageName!)"
        XCTAssertEqual(fileManagerMock.itemRemovedAtPath, expectedItemRemovedAtPath)
        
        XCTAssertEqual(remoteStorageableMock.pathStringsCalled.first, "/images/\(message.imageName!)")
        XCTAssertTrue(remoteStorageableMock.referenceMock.deleteCalled)
        
        let expectedMessageSaved = Message(imageName: nil, imageUrl: nil, bodyText: viewModel.bodyText, channel: channel)
        XCTAssertEqual(delegateMock.messageSaved, expectedMessageSaved)
    }
    
}
