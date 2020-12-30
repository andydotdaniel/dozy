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
    
    private weak var navigationControllable: NavigationControllable?
    
    init(navigationControllable: NavigationControllable?) {
        self.navigationControllable = navigationControllable
    }
    
    func build() -> OnboardingView {
        let presenter = OnboardingPresenter(userDefaults: ScheduleUserDefaults())
        let messageFormViewBuilder = MessageFormViewBuilder(message: nil, delegate: presenter)
        let router = OnboardingViewRouter(navigationControllable: navigationControllable, messageFormViewBuilder: messageFormViewBuilder)
        presenter.router = router
        
        return OnboardingView(presenter: presenter)
    }
    
    func buildViewController() -> UIViewController {
        let view = build()
        return OnboardingViewController(rootView: view)
    }
    
}
