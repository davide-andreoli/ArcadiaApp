//
//  HelpView.swift
//  Arcadia
//
//  Created by Davide Andreoli on 25/05/24.
//

import SwiftUI
import ArcadiaCore

struct ArcadiaButtonMapping: Identifiable {
    let id: Int
    let systemImageName: String
    let explanation: String
}

struct HelpView: View {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isCompact: Bool { horizontalSizeClass == .compact }
    #else
    private let isCompact = false
    #endif
    var body: some View {
        List {
            Section {
                Text("""
                In this section, you'll find various tips to help you navigate the interface and make the most of the app.
                
                """)
            }
            Section(header: Text("Introduction")) {
                Text("""
                Arcadia is a frontend for multiple emulators (also called cores), each corresponding to a different game system. Specifically, Arcadia is a frontend for the Libretro API, using the libretro versions of the cores. It aims to provide a simple and accessible way to enjoy retro game systems, not to replace RetroArch. If you are tech-savvy and want more control, consider using the RetroArch app.
                
                In Arcadia, you'll find only one core per game system, selected by me based on various criteria. Customization of core options is not available (though this may change in future versions).
                
                """)
            }
            Section(header: Text("Games")) {
                Section(header: Text("Organization")) {
                    Text("""
                    The first time Arcadia starts, it will create a folder to store all documents. On a Mac, you can find this inside the Documents folder, and on an iPhone, in the Files app.
                    
                    Inside, you'll find a Games folder, a Saves folder, and a States folder. The app's game library will display all files in the Games folder with their respective names. Each game has one save and one state, and all files should share the same name. If you rename the games through the app, everything will be managed for you. If you rename them manually, ensure you also rename the saves and states.
                    
                    """)
                }
                Section(header: Text("Synchronization")) {
                    Text("""
                    By default, iCloud synchronization is disabled, but you can enable it in the settings. Once activated, all your local content will be uploaded to iCloud. If the local files have a more recent modification date than those in iCloud, they will overwrite the existing files in the cloud. For example, if you have a recent save file for a game and enable iCloud sync, that save file will be uploaded and replace the existing file in iCloud.
                    If you decide to turn off iCloud synchronization, all files stored in iCloud will be downloaded to your local folder.
                    When iCloud sync is enabled, the iCloud Drive Arcadia folder is updated through two processes: periodic syncs and specific actions.
                    During periodic syncs, the iCloud Drive Arcadia folder acts as the master. If the iCloud folder contains a file that the local folder does not, it will be downloaded. Conversely, if the local folder contains a file not present in the iCloud folder, it will be deleted. All files that exist in both locations will be kept in sync, with the most recent versions replacing older ones.
                    Specific actions, such as loading or deleting a game, will update the master reference each time they are performed.
                    """)
                }
                Section(header: Text("Where to Find Games?")) {
                    Text("""
                    In the featured games section you'll find some game provided by some developers who decided to partner with Arcadia to distribute their games through the app.
                    Aside from those, there are many online resources to guide you in dumping game cartridges into ROMs, acquiring ROMs, or finding homebrew games.
                    
                    """)
                }
            }
            
            Section(header: Text("Controls")) {
                Text("""
                I considered whether to create a customized interface for each system, mimicking the original buttons, or to use a standard interface common to all cores. I chose the latter for two reasons:
                
                • Developing a custom interface for each system is time-consuming, as each asset would need to be manually created in Inkscape or SwiftUI.
                • A standardized button appearance makes the app more cohesive and easier to adapt to different systems.
                
                This choice required some general decisions for button appearance. Below are the mappings for all systems.
                """)
                Table(ArcadiaCoreButton.allCases) {
                    TableColumn("Button Image") { item in
                        if isCompact {
                            HStack {
                                Image(systemName: item.systemImageName)
                                Text(item.buttonName)
                            }
                        } else {
                            Image(systemName: item.systemImageName)
                        }
                    }
                    TableColumn("Name", value: \.buttonName)
                    TableColumn("Mapping", value: \.mappingExplanation)
                }
                .frame(minWidth: 100, minHeight: 400)
                Text("""
                     I might explore custom interfaces in the future, but not right now.
                     
                     Arcadia supports local multiplayer for games designed for more than two players. In the settings or from the in-game menu (accessible by clicking the Arcadia button), you can see the player mapped for touch input and each game controller, if connected. By default, touch input controls player one, the first controller controls player one, and each additional controller controls the next available player.
                     
                     """)
            }
            Section(header: Text("Saves and States")) {
                Text("""
                Arcadia and its emulators allow you to save your progress in two ways:
                
                • Saves: This is the standard way of saving your game progress, similar to the save files in game cartridges. These are generated and updated automatically by the app. Each game can have only one save file. This format is usually portable, and you can find these save files in Arcadia/Saves if you want to switch emulator apps.
                • States: This is a non-standard way of saving your game progress, enabled by the emulation process. It creates a snapshot of the game's exact state when you hit the save button. Each game can have up to three state files. This format is usually not portable as it depends on the emulator, but you can find these state files in Arcadia/States.
                """)
            }
        }
        .navigationTitle("Help")
    }
}

#Preview {
    HelpView()
}
