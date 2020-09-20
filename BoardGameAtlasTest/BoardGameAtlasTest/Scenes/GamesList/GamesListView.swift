//
//  GameboardsListView.swift
//  BoardGameAtlasTest
//
//  Created by Phetsana PHOMMARINH on 08/09/2020.
//

import SwiftUI
import Combine

struct GamesListView: View {
    @EnvironmentObject
    var viewModel: GamesListViewModel
    
    var body: some View {
        NavigationView {
            content
                .navigationBarTitle("Popular game board")
        }
        .onAppear { self.viewModel.send(event: .onAppear) }
    }
    
    private var content: some View {
        switch viewModel.state {        
        case .idle:
            return Color.clear.eraseToAnyView()
        case .loading:
            return Spinner(isAnimating: true, style: .medium).eraseToAnyView()
        case .error(let error):
            return Text(error.localizedDescription).eraseToAnyView()
        case .loaded(let games):
            return list(of: games).eraseToAnyView()
        }
    }
    
    private func list(of games: [GamesListViewModel.GameItem]) -> some View {
        return List(games) { game in
            GameListItemView(game: game)
        }
    }
}

struct GameListItemView: View {
    let game: GamesListViewModel.GameItem
    @Environment(\.imageCache) var cache: ImageCache
    
    var body: some View {
        HStack {
            image.frame(width: 100, height: 100, alignment: .center)
            name
        }
    }
    
    private var name: some View {
        Text(game.name ?? "")
            .font(.title)
            .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
    }
    
    private var image: some View {
        return game.imageURL.map { url in
            AsyncImage(
                url: url,
                cache: cache,
                placeholder: spinner,
                configuration: { $0.resizable().renderingMode(.original) }
            )            
        }
    }
    
    private var spinner: some View {
            Spinner(isAnimating: true, style: .medium)
        }
}

struct GamesListView_Previews: PreviewProvider {

    static let gamesDTO = [
        GameDTO(id: "Game 1", name: "The game", imageUrl: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTFGmhr7szv9Ifeg3xBiZEznvNSx7fDZww0UNHav222WcWGpyuVIguKihOQGRJtczSY5rrHCSPDGA&usqp=CAc")),
        GameDTO(id: "Game 2", name: "Detective Club", imageUrl: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQw71ksfWx6nRCU32a5VAdBuMmURsOCD6U9xQ&usqp=CAU"))
    ]
    static let games = Self.gamesDTO.map(GamesListViewModel.GameItem.init)
    
    static var viewModelIdle = GamesListViewModel(initialState: .idle)
    static var viewModelLoading = GamesListViewModel(initialState: .loading)
    static var viewModelError = GamesListViewModel(initialState: .error(NSError(domain: "Error", code: 11, userInfo: nil)))
    static var viewModelLoaded = GamesListViewModel(initialState: .loaded(Self.games))
    
    static var previews: some View {
        Group {
            GamesListView()
                .environmentObject(Self.viewModelIdle)
                .previewDisplayName("Default")
            GamesListView()
                .environmentObject(Self.viewModelIdle)
                .previewDisplayName("Idle state")
                .onAppear { Self.viewModelIdle.send(event: .idle) }
            GamesListView()
                .previewDisplayName("Loading state")
                .environmentObject(Self.viewModelLoading)
            GamesListView()
                .previewDisplayName("Error state")
                .environmentObject(Self.viewModelError)
            GamesListView()
                .previewDisplayName("Loaded state")
                .environmentObject(Self.viewModelLoaded)
        }
    }
}
