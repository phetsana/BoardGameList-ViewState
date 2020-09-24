//
//  GameDetailViewModelTests.swift
//  BoardGameAtlasTestTests
//
//  Created by Phetsana PHOMMARINH on 20/09/2020.
//

import Foundation

import XCTest
@testable import BoardGameAtlasTest
import Combine

class GameDetailViewModelTests: XCTestCase {

    var sut: GameDetailViewModel!
    
    var cancellables = Set<AnyCancellable>()

    static var deinitCalled = false

    override func setUp() {
        let gameListItem = Self.gameListItem()
        sut = GameDetailViewModel(game: gameListItem)
        GameDetailViewModelTests.deinitCalled = false
    }
        
    override func tearDown() {
        cancellables.removeAll()
    }
    
    static func gameListItem() -> GamesListViewModel.GameItem {
        let gameDTO =
            GameDTO(id: "game id",
                    name: "Detective Club",
                    imageUrl: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQw71ksfWx6nRCU32a5VAdBuMmURsOCD6U9xQ&usqp=CAU"),
                    thumbUrl: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQw71ksfWx6nRCU32a5VAdBuMmURsOCD6U9xQ&usqp=CAU"),
                    yearPublished: 2007,
                    minPlayers: 3, maxPlayers: 6,
                    description: "Description ablabla",
                    primaryPublisher: "Publisher",
                    rank: 2, trendingRank: 4)
        let gameListItem = GamesListViewModel.GameItem(game: gameDTO)
        return gameListItem
    }
    
    static func gameItem() -> GameDetailViewModel.GameItem {
        return GameDetailViewModel.GameItem(game: Self.gameListItem())
    }
    
    private func test_reduce(state: GameDetailViewModel.State,
                             event: GameDetailViewModel.Event,
                             expectedState: GameDetailViewModel.State) {
        let newState = GameDetailViewModel.reduce(state, event)
        XCTAssertEqual(newState, expectedState)
    }
    
    func test_reduce_state_idle_event_onAppear() {
        test_reduce(state: .idle,
                    event: .onAppear,
                    expectedState: .loading)
    }
    
    func test_reduce_state_idle_event_onGameLoaded() {
        test_reduce(state: .idle,
                    event: .onGameLoaded(Self.gameItem()),
                    expectedState: .idle)
    }

    func test_reduce_state_loading_event_onAppear() {
        test_reduce(state: .loading,
                    event: .onAppear,
                    expectedState: .loading)
    }
    
    func test_reduce_state_loading_event_onGameLoaded() {
        let game = Self.gameItem()
        test_reduce(state: .loading,
                    event: .onGameLoaded(game),
                    expectedState: .loaded(game))
    }

    func test_reduce_state_loaded_event_onAppear() {
        let game = Self.gameItem()
        test_reduce(state: .loaded(game),
                    event: .onAppear,
                    expectedState: .loaded(game))
    }
    
    func test_reduce_state_loaded_event_onGameLoaded() {
        let game = Self.gameItem()
        test_reduce(state: .loaded(game),
                    event: .onGameLoaded(game),
                    expectedState: .loaded(game))
    }
    
    func test_whenLoading_gameLoaded() {
        let game = Self.gameItem()
        let feedback = GameDetailViewModel.whenLoading(game: game)
        let publisher = CurrentValueSubject<GameDetailViewModel.State, Never>(.idle)
        let loadingExpectation = expectation(description: "loading")

        feedback
            .run(publisher.eraseToAnyPublisher())
            .sink { (event) in
                if case let .onGameLoaded(resultGame) = event {
                    XCTAssertEqual(game, resultGame)
                    loadingExpectation.fulfill()
                } else {
                    XCTFail("game should be loaded")
                }
            }
            .store(in: &cancellables)
        publisher.value = .loading
        
        wait(for: [loadingExpectation], timeout: 1)
    }

    func test_deinit() {
        let gameItem = Self.gameListItem()
        var sut: GameDetailViewModelMock? = GameDetailViewModelMock(game: gameItem)
        XCTAssertNotNil(sut)
        sut = nil
        XCTAssertNil(sut)
        XCTAssertEqual(GameDetailViewModelTests.deinitCalled, true)
    }
}

private class GameDetailViewModelMock: GameDetailViewModel {
    deinit {
        GameDetailViewModelTests.deinitCalled = true
    }
}
