//
//  DiscoverGameDetailView.swift
//  Arcadia
//
//  Created by Davide Andreoli on 28/08/24.
//

import SwiftUI

struct DiscoverGameDetailView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(ArcadiaFileManager.self) var fileManager: ArcadiaFileManager
    @State private var showLoadingSuccess: Bool = false
    
    private var game: ArcadiaFeaturedContent
    init(game: ArcadiaFeaturedContent) {
        self.game = game
    }
    
    var body: some View {
        List {
            VStack(alignment: .leading) {
                HStack {
                    if game.game.coverImageAssetName != "" {
                        Image(game.game.coverImageAssetName)
                            .resizable()
                            .frame(width: 80, height: 80)
                    } else {
                        Image(systemName: "photo.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                    }
                    VStack(alignment: .leading) {
                        Text(game.game.name)
                            .font(.headline)
                        Text(game.game.shortDescription)
                            .font(.caption)
                    }
                    Spacer()
                    Button(action: {
                        if let gameURL = Bundle.main.url(forResource: game.game.name, withExtension: game.game.bundledFileExtension) {
                            Task {
                                await fileManager.saveGame(gameURL: gameURL, gameType: game.game.gameType)
                            }
                            showLoadingSuccess.toggle()
                        }
                        
                    }) {
                        Text("Add to library")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(5)
                    .font(.subheadline)
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                }
            }
            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    NavigationLink(destination: DiscoverDeveloperDetailView(developer: game.author)) {
                        VStack {
                            Text(game.author.name)
                                .font(.subheadline)
                            Image(systemName: "person.fill")
                                .resizable()
                                .frame(width: 25, height: 25)
                            
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    Divider()
                    ForEach(game.author.socials, id: \.self) { social in
                        Link(destination: social.link!) {
                            VStack {
                                Text(social.name)
                                    .font(.subheadline)
                                Image(colorScheme == .dark ? social.whiteLogoAssetName : social.blackLogoAssetName)
                                    .resizable()
                                    .frame(width: 25, height: 25)
                            }
                        }
                        .foregroundStyle(.foreground)
                        Divider()
                    }
                    
                    Spacer()
                }
                .padding()
            }
            ScrollView(.horizontal) {
                HStack {
                    if !game.game.screenshotsAssetName.isEmpty {
                        ForEach(game.game.screenshotsAssetName, id: \.self) { screenshotName in
                            if screenshotName != "" {
                                Image(screenshotName)
                                    .resizable()
                                    .frame(width: 200, height: 200)
                            }
                        }
                    } else {
                        Text("No screenshots available")
                    }
                }
            }
            Text(game.game.longDescription)
            if let itchURL = game.game.itchURL {
                Link(destination: itchURL) {
                    VStack(alignment: .leading) {
                        Text("Find out more on the game's page")
                        Image(colorScheme == .dark ? "ItchLogoTextWhite" : "ItchLogoTextBlack")
                            .resizable()
                            .frame(width: 100, height: 25)
                    }
                }
                .foregroundStyle(.foreground)
            }
            if let githubURL = game.game.githubURL {
                Link(destination: githubURL) {
                    VStack(alignment: .leading) {
                        Text("This game is open source, if you're interested you can find the game's code in its repository")
                        Image(colorScheme == .dark ? "GitHubLogoTextWhite" : "GitHubLogoTextBlack")
                            .resizable()
                            .frame(width: 100, height: 25)
                    }
                }
                .foregroundStyle(.foreground)
            }
            Text("This game was provided for free by its author, but if you want to support their work you should consider following them on social media and donating through the links on this page.")
            .alert("Game loaded!", isPresented: $showLoadingSuccess) {
                Button("Ok", action: {})
            } message: {
                Text("You will find the game in the console's collection.")
            }
            .navigationTitle("Game")
        }
    }
}

#Preview {
    DiscoverGameDetailView(game: ArcadiaFeaturedContent(game: ArcadiaFeaturedGame(id: 0, name: "Awesome game", bundledFileExtension: "", gameType: .gameBoyGame, shortDescription: "This game is awesome", genres: [], longDescription: """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent ac dolor luctus, mollis enim congue, venenatis dui. Nunc tincidunt diam nec dui elementum viverra. Pellentesque bibendum bibendum justo. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Curabitur in est lectus. Vestibulum mauris justo, dignissim quis nisi sit amet, sodales varius est. Nunc sed blandit mauris, vitae finibus sapien. Aliquam feugiat ligula eget rhoncus eleifend. Morbi et bibendum dui. Ut sit amet neque in diam maximus commodo. Integer ut venenatis eros. Praesent ipsum enim, aliquam sed turpis non, pellentesque tempor urna. Maecenas a lectus vel sem luctus iaculis. Phasellus leo sapien, semper a ante id, molestie euismod sem. Nunc convallis gravida sodales. Nulla facilisi.

        Integer bibendum gravida suscipit. Vestibulum in felis ornare, dapibus sapien ac, consequat ligula. Fusce in tristique diam. Sed pharetra, nisi id blandit dignissim, urna ex condimentum tortor, nec sodales purus augue ac enim. Aliquam sit amet varius sem. In eu luctus ante, sed feugiat justo. Quisque sapien nisl, condimentum sit amet semper et, lacinia sit amet felis. Sed molestie lacus eu est finibus, et dapibus mauris tincidunt. Donec vitae purus ut risus suscipit sodales.

        Quisque vel urna in sapien aliquam semper. Fusce dapibus neque pharetra, accumsan metus quis, pulvinar nulla. Nam tristique ultricies pellentesque. Nulla ac tellus et dolor hendrerit rhoncus. Sed a ex mi. Suspendisse potenti. Nunc dapibus a massa id porttitor. Cras scelerisque massa sed felis auctor finibus. Curabitur at condimentum augue, sit amet interdum purus. Donec ornare ante tortor, quis tincidunt augue rutrum vel. Nulla tincidunt vitae magna non pellentesque. Aenean aliquam sapien eu risus commodo scelerisque. Maecenas vitae erat sodales eros aliquam pharetra eu porttitor lectus. Nullam sed efficitur dolor, id congue urna.

        Donec nisl mi, pharetra sit amet lacinia quis, efficitur in dui. Suspendisse consequat id nisl id luctus. Maecenas vitae sem laoreet, cursus sapien a, condimentum ligula. In eu volutpat arcu. Pellentesque egestas quam sed urna aliquam pellentesque. Donec metus tortor, varius vel tortor nec, bibendum pulvinar ante. Ut posuere lacinia risus non cursus. Morbi viverra, nunc sit amet sodales vehicula, ex leo dignissim risus, venenatis pharetra tellus sapien varius tortor. Sed felis sem, elementum quis turpis id, ullamcorper posuere velit. Praesent id pharetra massa. Curabitur vitae urna vel orci malesuada molestie sit amet sit amet nunc.

""", developerId: 0, coverImageAssetName: "gbc_icon", itchURL: URL(string: "http://instagram.com")!, githubURL: URL(string: "http://instagram.com")!, screenshotsAssetName: []), author: ArcadiaGameDeveloper(id: 0, name: "Awesome developer", bio: "", socials: [ArcadiaDeveloperSocialLink(name: "Instagram", link: URL(string: "http://")), ArcadiaDeveloperSocialLink(name: "Itch", link: URL(string: "http://")), ArcadiaDeveloperSocialLink(name: "X", link: URL(string: "http://")), ArcadiaDeveloperSocialLink(name: "Threads", link: URL(string: "http://"))])))
    .environment(ArcadiaFileManager.shared)
    .frame(height: 700)
}
