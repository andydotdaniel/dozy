//
//  OnboardingViewBuilder.swift
//  Dozy
//
//  Created by Andrew Daniel on 8/2/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import Foundation

struct OnboardingViewBuilder: ViewBuilder {
    
    func build() -> OnboardingView {
        let viewModel = OnboardingViewModel()
        let presenter = OnboardingPresenter(viewModel: viewModel)
        let view = OnboardingView(viewModel: viewModel, presenter: presenter)
        
        return view
    }
    
}
