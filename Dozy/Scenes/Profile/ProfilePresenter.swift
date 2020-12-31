//
//  ProfilePresenter.swift
//  Dozy
//
//  Created by Andrew Daniel on 12/15/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation
import UserNotifications

protocol ProfileViewPresenter {
    func onLogoutButtonTapped()
    func onDismissAlertTapped()
    func onLogoutConfirmed()
}

class ProfilePresenter: ProfileViewPresenter {
    
    private weak var viewModel: ProfileViewModel?
    
    private let profileUserDefaults: ProfileUserDefaults
    private let scheduleUserDefaults: ScheduleUserDefaults
    
    private let networkService: NetworkRequesting
    private let keychain: SecureStorable
    
    private weak var navigationControllable: NavigationControllable?
    
    init(
        profileUserDefaults: ProfileUserDefaults,
        scheduleUserDefaults: ScheduleUserDefaults,
        viewModel: ProfileViewModel,
        networkService: NetworkRequesting,
        keychain: SecureStorable,
        navigationControllable: NavigationControllable?
    ) {
        self.profileUserDefaults = profileUserDefaults
        self.scheduleUserDefaults = scheduleUserDefaults
        self.viewModel = viewModel
        self.networkService = networkService
        self.keychain = keychain
        self.navigationControllable = navigationControllable
        
        if let profile = profileUserDefaults.load() {
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
        networkService.performNetworkRequest(networkRequest, completion: { [weak self] (result: Result<UserProfileRespone, NetworkService.RequestError>) -> Void  in
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
        profileUserDefaults.save(profile)
    }
    
    func onLogoutButtonTapped() {
        if let schedule = scheduleUserDefaults.load(), schedule.isActive {
            self.viewModel?.shouldShowLogoutAlert = false
        } else {
            self.viewModel?.shouldShowLogoutAlert = true
        }
        
        self.viewModel?.isShowingAlert = true
    }
    
    func onDismissAlertTapped() {
        self.viewModel?.isShowingAlert = false
    }
    
    func onLogoutConfirmed() {
        func clearUserDefaults() {
            let userDefaults: [UserDefaultsDeletable] = [profileUserDefaults, scheduleUserDefaults]
            userDefaults.forEach { $0.delete() }
        }
        
        func clearAccessToken() {
            try? keychain.delete(key: Keychain.Keys.slackAccessToken)
        }
        
        func navigateToLogin() {
            guard let navigationControllable = self.navigationControllable else { return }
            
            let loginViewController = LoginViewBuilder(navigationControllable: navigationControllable).buildViewController()
            navigationControllable.pushViewController(loginViewController, animated: true)
            navigationControllable.viewControllers.removeSubrange(0..<navigationControllable.viewControllers.count - 1)
        }
        
        self.viewModel?.isShowingAlert = false
        
        clearAccessToken()
        clearUserDefaults()
        navigateToLogin()
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
