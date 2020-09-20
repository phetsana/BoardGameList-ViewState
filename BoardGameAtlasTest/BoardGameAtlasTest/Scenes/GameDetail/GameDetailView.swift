//
//  GameDetailView.swift
//  BoardGameAtlasTest
//
//  Created by Phetsana PHOMMARINH on 20/09/2020.
//

import SwiftUI
import Combine

struct GameDetailView: View {
    @EnvironmentObject
    var viewModel: GameDetailViewModel
    
    var body: some View {        
        NavigationView {
            content
                .navigationBarTitle(self.viewModel.game.name ?? "")
        }
        .onAppear { self.viewModel.send(event: .onAppear) }
    }

    private var content: some View {
        switch viewModel.state {
        case .idle:
            return Color.clear.eraseToAnyView()
        case .loading:
            return Spinner(isAnimating: true, style: .medium).eraseToAnyView()
        case .loaded(let game):
            return list(of: [game]).eraseToAnyView()
        }
    }
    
    private func list(of games: [GameDetailViewModel.GameItem]) -> some View {
        return List(games) { game in
            GameDetailItemView(game: game)
        }
    }
}

struct GameDetailItemView: View {
    let game: GameDetailViewModel.GameItem
    @Environment(\.imageCache) var cache: ImageCache
    
    var body: some View {
        VStack {
            image
            players
            description
        }
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
    
    private var players: some View {
        HStack {
            Text("Players:")
                .bold()
            Text("\(game.minPlayers) - \(game.maxPlayers)")
        }
    }
    
    private var description: some View {
        if let description = game.description {
            return VStack {
                Text("Description:")
                    .bold()
                Text(description)
            }.eraseToAnyView()
        }
        return EmptyView().eraseToAnyView()
    }
}

struct GameDetailView_Previews: PreviewProvider {
    static let gameDTO =
        GameDTO(id: "game id",
                name: "Detective Club",
                imageUrl: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQw71ksfWx6nRCU32a5VAdBuMmURsOCD6U9xQ&usqp=CAU"),
                thumbUrl: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQw71ksfWx6nRCU32a5VAdBuMmURsOCD6U9xQ&usqp=CAU"),
                yearPublished: 2007,
                minPlayers: 3, maxPlayers: 6,
                description: "Description ablabla",
                primaryPublisher: "Publisher",
                rank: 2, trendingRank: 4)       
    static let gameListItem = GamesListViewModel.GameItem(game: gameDTO)
    static let game = GameDetailViewModel.GameItem(game: gameListItem)
    
    static var viewModel = GameDetailViewModel(game: gameListItem)
    static var viewModelIdle = GameDetailViewModel(previewState: .idle, game: gameListItem)
    static var viewModelLoading = GameDetailViewModel(previewState: .loading, game: gameListItem)
    static var viewModelLoaded = GameDetailViewModel(previewState: .loaded(game), game: gameListItem)
    
    static var previews: some View {
        Group {
            GameDetailView()
                .environmentObject(Self.viewModel)
                .previewDisplayName("Default")
            GameDetailView()
                .environmentObject(Self.viewModelIdle)
                .previewDisplayName("Idle state")
            GameDetailView()
                .previewDisplayName("Loading state")
                .environmentObject(Self.viewModelLoading)
                .onAppear { Self.viewModelIdle.send(event: .idle) }
            GameDetailView()
                .previewDisplayName("Loaded state")
                .environmentObject(Self.viewModelLoaded)
                .onAppear { Self.viewModelIdle.send(event: .idle) }
        }
    }
}
