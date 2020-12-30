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
        case off
    }

    @Binding var switchState: (position: Position, isLoading: Bool)
    weak var delegate: SwitchViewDelegate?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .foregroundColor(switchState.position == .on ? Color.primaryBlue : Color.alertRed)
                .frame(width: 75, height: 44)
                .offset(x: switchState.position == .on ? -38 : 36)
                .animation(.easeOut(duration: 0.25))
            HStack(alignment: .center, spacing: 44) {
                getOnComponent()
                getOffComponent()
            }
            .font(.system(size: 18))
        }
        .padding(.horizontal, 30)
        .frame(height: 60)
        .background(Color.white)
        .cornerRadius(30)
        .shadow(radius: 5)
    }
    
    private func getOnComponent() -> AnyView {
        if switchState.position == .on, switchState.isLoading {
            return AnyView(Spinner(strokeColor: Color.white))
        } else {
            return AnyView(
                Text("On".uppercased())
                    .bold()
                    .foregroundColor(switchState.position == .on ? .white : .secondaryGray)
                    .onTapGesture {
                        guard switchState.position == .off else { return }
                        self.delegate?.onSwitchPositionChangedTriggered()
                    }
            )
        }
    }
    
    private func getOffComponent() -> AnyView {
        if switchState.position == .off, switchState.isLoading {
            return AnyView(Spinner(strokeColor: Color.white))
        } else {
            return AnyView(
                Text("Off".uppercased())
                    .bold()
                    .foregroundColor(switchState.position == .off ? .white : .secondaryGray)
                    .onTapGesture {
                        guard switchState.position == .on else { return }
                        self.delegate?.onSwitchPositionChangedTriggered()
                    }
            )
        }
    }
    
}

struct Switch_Previews: PreviewProvider {
    static var previews: some View {
        Switch(switchState: .constant((.off, true)), delegate: nil)
    }
}
