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
    let cancelButtonAction: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Button(action: cancelButtonAction, label: {
                    Text("Cancel")
                })
                Spacer()
                Button(action: doneButtonAction, label: {
                    Text("Done")
                })
            }
            .padding(.horizontal, 20)
            
            DatePicker("Select awake confirmation time", selection: $dateSelection, displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .padding(.bottom, 16)
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(Color.secondaryGray)
                .environment(\.locale, Locale(identifier: "en_US_POSIX"))
        }
        .padding(.top, 16)
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(Color.fadedWhite)
        .cornerRadius(10)
    }
}

struct TimePicker_Previews: PreviewProvider {
    static var previews: some View {
        TimePicker(dateSelection: .constant(Date()), doneButtonAction: {}, cancelButtonAction: {})
    }
}
