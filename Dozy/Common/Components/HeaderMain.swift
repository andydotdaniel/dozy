//
//  HeaderMain.swift
//  Dozy
//
//  Created by Andrew Daniel on 12/9/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

struct HeaderMain: View {
    
    private let height: CGFloat
    private var didTapSettingsAction: () -> Void
    
    init(height: CGFloat, didTapSettingsAction: @escaping () -> Void) {
        self.height = height
        self.didTapSettingsAction = didTapSettingsAction
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            Image("LogoGray")
            HStack {
                Spacer()
                Image("SettingsIcon")
                    .frame(width: 24, height: 24)
                    .onTapGesture {
                        self.didTapSettingsAction()
                    }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: height)
    }
}

struct HeaderMain_Previews: PreviewProvider {
    static var previews: some View {
        HeaderMain(height: 60, didTapSettingsAction: {})
    }
}
