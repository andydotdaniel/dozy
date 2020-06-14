//
//  SafariView.swift
//  Dozy
//
//  Created by Andrew Daniel on 6/14/20.
//  Copyright © 2020 Andrew Daniel. All rights reserved.
//

import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
    
}
