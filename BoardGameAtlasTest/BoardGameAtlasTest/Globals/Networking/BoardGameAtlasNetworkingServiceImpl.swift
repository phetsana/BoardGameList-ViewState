//
//  BoardGameAtlasNetworkingServiceImpl.swift
//  BoardGameAtlasTest
//
//  Created by Phetsana PHOMMARINH on 19/09/2020.
//

import Foundation

struct BoardGameAtlasConstants {
    static var baseURL = URL(string: "https://api.boardgameatlas.com/")!
    static var clientID = "4ESSA0yrVW"
}

final class BoardGameAtlasNetworkingServiceImpl: NetworkingServiceImpl {
    init() {
        super.init(baseURL: BoardGameAtlasConstants.baseURL)
    }
    
    override func endpoint<T: NetworkingRequest>(for request: T) throws -> URL {
        return try super.endpoint(for: request).addClientID()
    }
}

fileprivate extension URL {
    func addClientID() -> URL {
        guard var urlComponents = URLComponents(string: absoluteString) else { return absoluteURL }
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []
        let queryItem = URLQueryItem(name: "client_id", value: BoardGameAtlasConstants.clientID)
        queryItems.append(queryItem)
        urlComponents.queryItems = queryItems
        return urlComponents.url!
    }
}
