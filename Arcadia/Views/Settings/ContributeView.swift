//
//  ContributeView.swift
//  Arcadia
//
//  Created by Davide Andreoli on 20/06/24.
//

import SwiftUI
import StoreKit

struct ContributeView: View {
    var body: some View {
        List {
            VStack {
                Text("""
                Arcadia is a labor of love, born from my passion for Apple and my desire to learn new things. As such, it is an imperfect product developed in my free time. If you enjoy the app and would like to contribute to its development, here are some ways you can help:
                • Report any bugs you find, including steps to reproduce them.
                • Share any ideas for new features or improvements to enhance the user experience.
                • I am not a designer, so if you'd like to submit a custom app icon, I would love to include it in the app with credits to you.
                • If you are a retro game developer and would like for your game to be featured in the app, I'd love to include it.
                • Currently, Arcadia is closed source, but I plan to make it open source once I organize the repository better. When that happens, you'll be able to contribute directly to the code if you wish.
                """)

            }
        }
        .navigationTitle("Contribute")
    }
}

#Preview {
    ContributeView()
}
