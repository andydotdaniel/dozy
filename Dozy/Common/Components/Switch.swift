//
//  Switch.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/18/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

struct Switch: View {
    
    enum State {
        case on
        case off
    }
    
    @Binding var state: State
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .foregroundColor(Color.primaryBlue)
                .frame(width: 75, height: 44)
                .offset(x: state == .on ? -38 : 36)
                .animation(.easeOut(duration: 0.25))
            HStack(alignment: .center, spacing: 44) {
                Text("On".uppercased())
                    .bold()
                    .foregroundColor(.secondaryGray)
                    .onTapGesture {
                        self.state = .on
                    }
                Text("Off".uppercased())
                    .bold()
                    .foregroundColor(.secondaryGray)
                    .onTapGesture {
                        self.state = .off
                    }
            }
            .font(.system(size: 18))
        }
        .padding(.horizontal, 30)
        .frame(height: 60)
        .background(Color.white)
        .cornerRadius(30)
        .shadow(radius: 5)
    }
}

struct Switch_Previews: PreviewProvider {
    static var previews: some View {
        Switch(state: .constant(.on))
    }
}
