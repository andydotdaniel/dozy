//
//  TimePicker.swift
//  Dozy
//
//  Created by Andrew Daniel on 10/3/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

struct TimePicker: View {
    
    @Binding var dateSelection: Date
    let doneButtonAction: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: doneButtonAction, label: {
                    Text("Done")
                })
            }
            .padding(.horizontal, 20)
            DatePicker("", selection: $dateSelection, displayedComponents: [.date, .hourAndMinute])
            .labelsHidden()
            .padding(.bottom, 16)
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(Color.secondaryGray)
        }
        .padding(.top, 16)
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(Color.fadedWhite)
        .cornerRadius(16)
    }
}

struct TimePicker_Previews: PreviewProvider {
    static var previews: some View {
        TimePicker(dateSelection: .constant(Date()), doneButtonAction: {})
    }
}
