//
//  ProfileViewBuilder.swift
//  Dozy
//
//  Created by Andrew Daniel on 12/9/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI
import UIKit

struct ProfileViewBuilder: ViewControllerBuilder {
    
    func buildViewController() -> UIViewController {
        let view = ProfileView(viewModel: ProfileViewModel())
        return UIHostingController(rootView: view)
    }
    
}
