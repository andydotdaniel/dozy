//
//  Toast.swift
//  Dozy
//
//  Created by Andrew Daniel on 6/17/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI

struct Toast: View {
    
    struct MessageSegment: Hashable {
        let text: String
        let color: Color
    }

    let messageSegments: [MessageSegment]
    
    @Binding var isShowing: Bool
    
    var body: some View {
        if isShowing {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.isShowing = false
            }
        }
        
        return HStack(alignment: .center, spacing: 4) {
            ForEach(messageSegments, id: \.self) { segment in
                Text(segment.text)
                .font(.headline)
                .bold()
                    .foregroundColor(segment.color)
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .foregroundColor(Color.charcoal)
        )
        .disabled(self.isShowing)
        .shadow(radius: 8)
        .offset(y: self.isShowing ? 0 : 60)
        .opacity(self.isShowing ? 1.0 : 0.0)
        .animation(.easeOut(duration: 0.15))
    }
}

extension Toast {
    
    static func createErrorToast(isShowing: Binding<Bool>) -> Toast {
        let messageSegments = [
            Toast.MessageSegment(text: "Oops.", color: Color.alertRed),
            Toast.MessageSegment(text: "Please try again.", color: Color.white)
        ]
        
        return Toast(messageSegments: messageSegments, isShowing: isShowing)
    }
    
}

struct Toast_Previews: PreviewProvider {
    static var previews: some View {
        let messageSegments = [
            Toast.MessageSegment(text: "Some Green.", color: Color.green),
            Toast.MessageSegment(text: "With white text.", color: Color.white)
        ]
        
        return Toast(messageSegments: messageSegments, isShowing: .constant(true))
    }
}
