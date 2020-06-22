//
//  LoginHeaderView.swift
//  Dozy
//
//  Created by Andrew Daniel on 6/14/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

struct LoginHeaderView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 80) {
            Image("LogoDark")
                .padding(.horizontal, 20)
                .scaledToFit()
                .opacity(0.20)
            VStack(alignment: .center, spacing: 16) {
                Text("Time to wake up sleepyhead.")
                    .font(.largeTitle)
                    .bold()
                    .fixedSize(horizontal: false, vertical: true)
                Text("Get that boost to get out of bed by having people notified on Slack when you oversleep.")
                    .fixedSize(horizontal: false, vertical: true)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
            .foregroundColor(Color.white)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        .background(Color.primaryBlue)
    }
}

struct LoginHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        LoginHeaderView()
    }
}
