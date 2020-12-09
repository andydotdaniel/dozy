//
//  RootViewBuilder.swift
//  Dozy
//
//  Created by Andrew Daniel on 8/7/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation
import SwiftUI

class RootViewBuilder: ViewBuilder, ViewControllerBuilder {
    
    private let keychain: SecureStorable
    private let userDefaults: ScheduleUserDefaultable
    
    private weak var navigationControllable: NavigationControllable?
    
    init(keychain: SecureStorable = Keychain(), userDefaults: ScheduleUserDefaultable = UserDefaults.standard, navigationControllable: NavigationControllable) {
        self.keychain = keychain
        self.userDefaults = userDefaults
        self.navigationControllable = navigationControllable
    }
    
    func build() -> AnyView {
//        if self.keychain.load(key: "slack_access_token") == nil {
//            let builder = LoginViewBuilder(navigationControllable: navigationControllable)
//            return AnyView(builder.build())
//        }
        
        if let schedule = self.userDefaults.loadSchedule() {
            return AnyView(ScheduleViewBuilder(schedule: schedule).build())
        }
        
        return AnyView(OnboardingViewBuilder().build())
    }
    
    func buildViewController() -> UIViewController {
        if self.keychain.load(key: "slack_access_token") == nil {
            let builder = LoginViewBuilder(navigationControllable: navigationControllable)
            return builder.buildViewController()
        }
        
        return UIViewController()
    }
    
}
