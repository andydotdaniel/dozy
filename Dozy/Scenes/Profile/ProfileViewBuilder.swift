//
//  ProfileViewBuilder.swift
//  Dozy
//
//  Created by Andrew Daniel on 12/9/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI
import UIKit

class ProfileViewController: UIHostingController<ProfileView> {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
}

struct ProfileViewBuilder: ViewControllerBuilder {
    
    private weak var navigationControllable: NavigationControllable?
    
    init(navigationControllable: NavigationControllable?) {
        self.navigationControllable = navigationControllable
    }
    
    func buildViewController() -> UIViewController {
        let viewModel = ProfileViewModel()
        let presenter = ProfilePresenter(
            profileUserDefaults: ProfileUserDefaults(),
            scheduleUserDefaults: ScheduleUserDefaults(),
            viewModel: viewModel,
            networkService: NetworkService(),
            keychain: Keychain(),
            navigationControllable: navigationControllable
        )
        let view = ProfileView(viewModel: viewModel, presenter: presenter)
        
        return ProfileViewController(rootView: view)
    }
    
}
