//
//  CreditsView.swift
//  Arcadia
//
//  Created by Davide Andreoli on 25/05/24.
//

import SwiftUI

struct CreditsView: View {
    var body: some View {
        List {
            Section {
                Text("""
                This application is merely a frontend to the Libretro API, and it wouldn't be possible without the incredible work done by the [Libretro Team](https://www.libretro.com). Special thanks also go to [Retroreversing](https://www.retroreversing.com) for their invaluable resources, which have made the entire process much easier.
                """)
            }
            
            Section(header: Text("Cores")) {
                //Text("Cores").font(.title)
                Text("""
                Arcadia is built on numerous cores developed by extraordinary developers who have made it possible to relive classic console experiences on other devices. In Arcadia, you will find the following cores:
                """)
                ForEach(ArcadiaGameType.allCases) { gameType in
                    Text("• \(gameType.name): \(gameType.credits)")
                }

            }
            
            Section(header: Text("Other")) {
                //Text("Other").font(.title)
                Text("""
                • Game matching and cover downloading are provided thanks to [OpenVGDB](https://github.com/OpenVGDB/OpenVGDB)
                """)
            }
            
        }
        .navigationTitle("Credits")
    }
}

#Preview {
    CreditsView()
}
