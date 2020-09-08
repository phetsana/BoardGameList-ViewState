//
//  Game.swift
//  BoardGameAtlasTest
//
//  Created by Phetsana PHOMMARINH on 07/09/2020.
//

import Foundation

struct GamesDTO: Codable {
    let games: [GameDTO]
}

struct GameDTO: Codable {
    let id: String
    let name: String?
    let imageUrl: URL?
}
