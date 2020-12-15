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
    
    func buildViewController() -> UIViewController {
        let view = ProfileView(viewModel: ProfileViewModel())
        return ProfileViewController(rootView: view)
    }
    
}
