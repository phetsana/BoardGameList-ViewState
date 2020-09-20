//
//  GamesListViewModel+Model.swift
//  BoardGameAtlasTest
//
//  Created by Phetsana PHOMMARINH on 20/09/2020.
//

import Foundation

// MARK: - Inner Types
extension GamesListViewModel {
    enum State {
        case idle
        case loading
        case loaded([GameItem])
        case error(Error)
    }

    enum Event {
        case onAppear
        case onGameSelected(GameItem)
        case onGamesLoaded([GameItem])
        case onFailedToLoadGames(Error)
    }

    struct GameItem: Identifiable, Equatable {
        let id: String
        let name: String?
        let imageURL: URL?
        let thumbURL: URL?
        let description: String?
        let minPlayers: Int
        let maxPlayers: Int
        
        init(game: GameDTO) {
            id = game.id
            name = game.name
            imageURL = game.imageUrl
            thumbURL = game.thumbUrl
            description = game.description
            minPlayers = game.minPlayers
            maxPlayers = game.maxPlayers
        }
    }
}

extension GamesListViewModel.State: AutoEquatable {}
extension GamesListViewModel.Event: AutoEquatable {}
