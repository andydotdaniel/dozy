//
//  LoginViewModel.swift
//  Dozy
//
//  Created by Andrew Daniel on 6/16/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Combine
import SwiftUI

enum PostLoginNavigation: String {
    case onboarding = "onboarding"
    case schedule = "schedule"
}

class LoginViewModel: ObservableObject {
    
    @Published var isFetchingAccessToken: Bool = false
    @Published var isShowingError: Bool = false
    @Published var navigationSelection: PostLoginNavigation?
    
}
