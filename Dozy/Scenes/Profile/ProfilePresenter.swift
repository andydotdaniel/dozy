//
//  ProfilePresenter.swift
//  Dozy
//
//  Created by Andrew Daniel on 12/15/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation

protocol ProfileViewPresenter {}

class ProfilePresenter: ProfileViewPresenter {
    
    private weak var viewModel: ProfileViewModel?
    
    private let userDefaults: ProfileUserDefaults
    private let networkService: NetworkRequesting
    private let keychain: SecureStorable
    
    init(
        userDefaults: ProfileUserDefaults,
        viewModel: ProfileViewModel,
        networkService: NetworkRequesting,
        keychain: SecureStorable
    ) {
        self.userDefaults = userDefaults
        self.viewModel = viewModel
        self.networkService = networkService
        self.keychain = keychain
        
        if let profile = userDefaults.load() {
            showProfileText(from: profile)
        } else {
            fetchUserProfile()
        }
    }
    
    private func showProfileText(from profile: Profile) {
        self.viewModel?.fullNameText = profile.name
        self.viewModel?.emailText = profile.email
    }
    
    private func fetchUserProfile() {
        guard let accessTokenData = keychain.load(key: "slack_access_token") else { return }
        let accessToken = String(decoding: accessTokenData, as: UTF8.self)
        let headers = ["Authorization": "Bearer \(accessToken)"]
        
        let url = "https://slack.com/api/users.profile.get"
        guard let networkRequest = NetworkRequest(url: url, httpMethod: .get, headers: headers, contentType: .urlEncodedForm) else { return }
        networkService.peformNetworkRequest(networkRequest, completion: { [weak self] (result: Result<UserProfileRespone, NetworkService.RequestError>) -> Void  in
            guard let self = self else { return }
            
            Current.dispatchQueue.async {
                switch result {
                case .success(let object):
                    let profile = Profile(name: object.name, email: object.email)
                    self.showProfileText(from: profile)
                    self.saveProfile(profile)
                case .failure:
                    self.viewModel?.isShowingError = true
                }
            }
        })
    }
    
    private func saveProfile(_ profile: Profile) {
        userDefaults.save(profile)
    }
    
}

private struct UserProfileRespone: Decodable {
    
    let name: String
    let email: String
    
    enum ProfileCodingKeys: String, CodingKey {
        case name = "real_name"
        case email = "email"
    }
    
    enum MainCodingKey: String, CodingKey {
        case profile = "profile"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MainCodingKey.self)
        let profileContainer = try container.nestedContainer(keyedBy: ProfileCodingKeys.self, forKey: .profile)
        
        self.name = try profileContainer.decode(String.self, forKey: .name)
        self.email = try profileContainer.decode(String.self, forKey: .email)
    }
    
}
