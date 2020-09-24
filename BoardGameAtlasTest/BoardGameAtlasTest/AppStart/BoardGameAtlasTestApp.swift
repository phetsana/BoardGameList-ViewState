//
//  BoardGameAtlasTestApp.swift
//  BoardGameAtlasTest
//
//  Created by Phetsana PHOMMARINH on 07/09/2020.
//

import SwiftUI

@main
struct BoardGameAtlasTestApp: App {

    init() {
        URLCache.shared.removeAllCachedResponses()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
