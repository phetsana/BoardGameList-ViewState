//
//  GameDetailViewModel+InnerTypes.swift
//  BoardGameAtlasTest
//
//  Created by Phetsana PHOMMARINH on 20/09/2020.
//

import Foundation

// MARK: - Inner Types
extension GameDetailViewModel {
    enum State {
        case idle
        case loading
        case loaded(GameItem)
    }

    enum Event {
        case idle
        case onAppear
        case onGameLoaded(GameItem)
    }

    struct GameItem: Identifiable, Equatable {
        let id: String
        let name: String?
        let imageURL: URL?
        let description: String?
        let minPlayers: Int
        let maxPlayers: Int
        
        init(game: GamesListViewModel.GameItem) {
            id = game.id
            name = game.name
            imageURL = game.imageURL
            description = game.description
            minPlayers = game.minPlayers
            maxPlayers = game.maxPlayers
        }
    }
}

extension GameDetailViewModel.State: AutoEquatable {}
extension GameDetailViewModel.Event: AutoEquatable {}
