//
//  HeaderMain.swift
//  Dozy
//
//  Created by Andrew Daniel on 12/9/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

protocol HeaderMainDelegate: class {
    func onSettingsIconTapped()
}

struct HeaderMain: View {
    
    private let height: CGFloat
    private weak var delegate: HeaderMainDelegate?
    
    init(height: CGFloat, delegate: HeaderMainDelegate?) {
        self.height = height
        self.delegate = delegate
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            Image("LogoGray")
            HStack {
                Spacer()
                Image("ProfileIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .onTapGesture {
                        self.delegate?.onSettingsIconTapped()
                    }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: height)
    }
}

struct HeaderMain_Previews: PreviewProvider {
    static var previews: some View {
        HeaderMain(height: 60, delegate: nil)
    }
}
