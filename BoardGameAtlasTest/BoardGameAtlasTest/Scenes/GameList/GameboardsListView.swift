//
//  GameboardsListView.swift
//  BoardGameAtlasTest
//
//  Created by Phetsana PHOMMARINH on 08/09/2020.
//

import SwiftUI
import Combine

struct GameboardsListView: View {
    @ObservedObject var viewModel: GameboardsListViewModel
    
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
            return Spinner(isAnimating: true, style: .large).eraseToAnyView()
        case .error(let error):
            return Text(error.localizedDescription).eraseToAnyView()
        case .loaded(let games):
            return list(of: games).eraseToAnyView()
        }
    }
    
    private func list(of games: [GameboardsListViewModel.GameItem]) -> some View {
        return List(games) { game in
            GameListItemView(game: game)
        }
    }
}

struct GameListItemView: View {
    let game: GameboardsListViewModel.GameItem
    @Environment(\.imageCache) var cache: ImageCache
    
    var body: some View {
        VStack {
            name
            image
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

struct GameboardsListView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
