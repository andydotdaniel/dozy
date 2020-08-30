//
//  Switch.swift
//  Dozy
//
//  Created by Andrew Daniel on 7/18/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

protocol SwitchViewDelegate: class {
    func onSwitchPositionChangedTriggered()
}

struct Switch: View {
    
    enum Position {
        case on
        case loading
        case off
    }

    @Binding var position: Position
    weak var delegate: SwitchViewDelegate?
    
    var body: some View {
        ZStack {
            if position == .loading {
                Spinner(strokeColor: Color.primaryBlue)
            } else {
                RoundedRectangle(cornerRadius: 22)
                    .foregroundColor(position == .on ? Color.primaryBlue : Color.alertRed)
                    .frame(width: 75, height: 44)
                    .offset(x: position == .on ? -38 : 36)
                    .animation(.easeOut(duration: 0.25))
                HStack(alignment: .center, spacing: 44) {
                    Text("On".uppercased())
                        .bold()
                        .foregroundColor(position == .on ? .white : .secondaryGray)
                        .onTapGesture {
                            self.delegate?.onSwitchPositionChangedTriggered()
                        }
                    Text("Off".uppercased())
                        .bold()
                        .foregroundColor(position == .off ? .white : .secondaryGray)
                        .onTapGesture {
                            self.delegate?.onSwitchPositionChangedTriggered()
                        }
                }
                .font(.system(size: 18))
            }
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
        Switch(position: .constant(.on), delegate: nil)
    }
}
