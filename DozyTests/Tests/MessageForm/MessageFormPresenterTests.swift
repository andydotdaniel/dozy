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
    
    override func setUpWithError() throws {
        Current = .mock
        setupPresenter(channelFetchResult: try JSONLoader.load(fileName: "Channels"))
    }
    
    private final func setupPresenter(channelFetchResult: URLSessionMockResult) {
        viewModel = MesssageFormViewModel(navigationBarTitle: "Some navigation title", message: nil)
        delegateMock = MessageFormDelegateMock()
        
        urlSessionMock = URLSessionMock()
        keychainMock = KeychainMock()
        
        urlSessionMock.results.append(channelFetchResult)
        let networkService = NetworkService(urlSession: urlSessionMock)
        
        keychainMock.dataToLoad = Data("SOME_ACCESS_TOKEN".utf8)
        
        presenter = MessageFormPresenter(
            viewModel: viewModel,
            networkService: networkService,
            keychain: keychainMock,
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
        setupPresenter(channelFetchResult: .init(data: nil, urlResponse: nil, error: URLSessionMock.NetworkError.someError))
        XCTAssertEqual(viewModel.filteredChannelItems.count, 0, "Channels fetching failed")
    }
    
    func testRetryChannelFetch() throws {
        urlSessionMock.results.append(try JSONLoader.load(fileName: "Channels"))
        presenter.onChannelFetchRetryButtonTapped()
        
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
        
        let expectedMessage = Message(image: nil, imageUrl: nil, bodyText: bodyText, channel: channel)
        XCTAssertEqual(delegateMock.messageSaved, expectedMessage)
    }
    
    func testDidTapSaveWithImageAndConfirmedImageUpload() throws {
        let channel = viewModel.filteredChannelItems.first!
        presenter.didTapChannelItem(id: channel.id)
        
        let image = UIImage(named: "LogoGray", in: Bundle.main, with: nil)!
        viewModel.selectedImage = image
        
        presenter.didTapSave()
        
        XCTAssertTrue(viewModel.isShowingImageUploadConfirmation)
        
        urlSessionMock.results.append(try JSONLoader.load(fileName: "FileUpload"))
        urlSessionMock.results.append(try JSONLoader.load(fileName: "FileSharePublic"))
        
        presenter.onImageUploadConfirmed()
        
        XCTAssertTrue(viewModel.isSaving)
        
        let expectedMessage = Message(image: image.pngData(), imageUrl: "https://somedomain.com/dramacat.gif?pub_secret=8004f909b1", bodyText: nil, channel: channel)
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
        
        urlSessionMock.results.append(.init(data: nil, urlResponse: nil, error: URLSessionMock.NetworkError.someError))
        
        presenter.onImageUploadConfirmed()
        
        XCTAssertFalse(viewModel.isSaving)
        XCTAssertTrue(viewModel.isShowingSaveError)
    }
    
}
