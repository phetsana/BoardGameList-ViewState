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
                .navigationBarTitle("Popular game board", displayMode: .inline)
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
            NavigationLink(
                destination: GameDetailView().environmentObject(GameDetailViewModel(game: game)),
                label: {
                    GameListItemView(game: game)
                })
        }
    }
}

struct GameListItemView: View {
    let game: GamesListViewModel.GameItem

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
        return game.thumbURL.map { url in
            RemoteImage(url: url)
        }
    }
}

struct GamesListView_Previews: PreviewProvider {

    static let gamesDTO = [
        GameDTO(id: "game id 1",
                name: "The game",
                imageUrl: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTFGmhr7szv9Ifeg3xBiZEznvNSx7fDZww0UNHav222WcWGpyuVIguKihOQGRJtczSY5rrHCSPDGA&usqp=CAc"),
                thumbUrl: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTFGmhr7szv9Ifeg3xBiZEznvNSx7fDZww0UNHav222WcWGpyuVIguKihOQGRJtczSY5rrHCSPDGA&usqp=CAc"),
                yearPublished: 2007,
                minPlayers: 3, maxPlayers: 6,
                description: "Description ablabla",
                primaryPublisher: "Publisher",
                rank: 1, trendingRank: 3),
        GameDTO(id: "game id 2",
                name: "Detective Club",
                imageUrl: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQw71ksfWx6nRCU32a5VAdBuMmURsOCD6U9xQ&usqp=CAU"),
                thumbUrl: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQw71ksfWx6nRCU32a5VAdBuMmURsOCD6U9xQ&usqp=CAU"),
                yearPublished: 2007,
                minPlayers: 3, maxPlayers: 6,
                description: "Description ablabla",
                primaryPublisher: "Publisher",
                rank: 2, trendingRank: 4)
    ]
    static let games = Self.gamesDTO.map(GamesListViewModel.GameItem.init)

    static var viewModel = GamesListViewModel()
    static var viewModelIdle = GamesListViewModel(previewState: .idle)
    static var viewModelLoading = GamesListViewModel(previewState: .loading)
    static var viewModelError = GamesListViewModel(previewState: .error(NSError(domain: "Error",
                                                                                code: 11,
                                                                                userInfo: nil)))
    static var viewModelLoaded = GamesListViewModel(previewState: .loaded(Self.games))

    static var previews: some View {
        Group {
            GamesListView()
                .environmentObject(Self.viewModel)
                .previewDisplayName("Default")
            GamesListView()
                .environmentObject(Self.viewModelIdle)
                .previewDisplayName("Idle state")
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
