//
//  OnboardingViewBuilder.swift
//  Dozy
//
//  Created by Andrew Daniel on 8/2/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation
import SwiftUI

private class OnboardingViewController: UIHostingController<OnboardingView> {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
}

struct OnboardingViewBuilder: ViewControllerBuilder, ViewBuilder {
    
    func build() -> OnboardingView {
        let viewModel = OnboardingViewModel()
        let presenter = OnboardingPresenter(viewModel: viewModel)
        
        return OnboardingView(viewModel: viewModel, presenter: presenter)
    }
    
    func buildViewController() -> UIViewController {
        let view = build()
        return OnboardingViewController(rootView: view)
    }
    
}
