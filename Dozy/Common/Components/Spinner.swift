//
//  Spinner.swift
//  Dozy
//
//  Created by Andrew Daniel on 6/16/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

struct Spinner: View {
    @State private var animating = false
    let strokeColor: Color
    
    var body: some View {
        Circle()
            .trim(from: animating ? 1/12 : 1, to: 1)
            .stroke(strokeColor, lineWidth: 3)
            .frame(width: 24, height: 24)
            .rotationEffect(.degrees(animating ? 0 : 360), anchor: .center)
            .animation(Animation.easeOut(duration: 1.20).repeatForever(autoreverses: false))
            .onAppear {
                self.animating.toggle()
            }
    }
}

struct Spinner_Previews: PreviewProvider {
    static var previews: some View {
        Spinner(strokeColor: Color.primaryBlue)
    }
}
