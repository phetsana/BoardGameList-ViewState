//
//  GameboardsListViewModelTests.swift
//  BoardGameAtlasTestTests
//
//  Created by Phetsana PHOMMARINH on 08/09/2020.
//

import XCTest
@testable import BoardGameAtlasTest

class GameboardsListViewModelTests: XCTestCase {

    var sut: GameboardsListViewModel!
    
    override func setUp() {
        sut = GameboardsListViewModel()
    }
    
    private func test_reduce(state: GameboardsListViewModel.State,
                             event: GameboardsListViewModel.Event,
                             expectedState: GameboardsListViewModel.State) {
        let newState = GameboardsListViewModel.reduce(state, event)
        XCTAssertEqual(newState, expectedState)
    }
    
    func test_reduce_state_idle_event_onAppear() {
        test_reduce(state: .idle,
                    event: .onAppear,
                    expectedState: .loading)
    }
    
    func test_reduce_state_idle_event_onMoviesLoaded() {
        test_reduce(state: .idle,
                    event: .onMoviesLoaded([]),
                    expectedState: .idle)
    }

    func test_reduce_state_idle_event_onFailedToLoadMovies() {
        test_reduce(state: .idle,
                    event: .onFailedToLoadMovies(TestError.testError),
                    expectedState: .idle)
    }
    
    func test_reduce_state_loading_event_onAppear() {
        test_reduce(state: .loading,
                    event: .onAppear,
                    expectedState: .loading)
    }
    
    private func games() -> [GameboardsListViewModel.GameItem] {
        let gameDTO1 = GameDTO(id: "testid 1", name: "testname 1", imageUrl: nil)
        let game1 = GameboardsListViewModel.GameItem(game: gameDTO1)
        
        let gameDTO2 = GameDTO(id: "testid 2", name: "testname 2", imageUrl: nil)
        let game2 = GameboardsListViewModel.GameItem(game: gameDTO2)
        
        return [game1, game2]
    }
    
    func test_reduce_state_loading_event_onMoviesLoaded() {
        let games = self.games()
        test_reduce(state: .loading,
                    event: .onMoviesLoaded(games),
                    expectedState: .loaded(games))
    }

    func test_reduce_state_loading_event_onFailedToLoadMovies() {
        test_reduce(state: .loading,
                    event: .onFailedToLoadMovies(TestError.testError),
                    expectedState: .error(TestError.testError))
    }
    
    func test_reduce_state_loaded_event_onAppear() {
        let games = self.games()
        test_reduce(state: .loaded(games),
                    event: .onAppear,
                    expectedState: .loaded(games))
    }
    
    func test_reduce_state_loaded_event_onMoviesLoaded() {
        let games = self.games()
        test_reduce(state: .loaded(games),
                    event: .onMoviesLoaded(games),
                    expectedState: .loaded(games))
    }

    func test_reduce_state_loaded_event_onFailedToLoadMovies() {
        let games = self.games()
        test_reduce(state: .loaded(games),
                    event: .onFailedToLoadMovies(TestError.testError),
                    expectedState: .loaded(games))
    }
    
    func test_reduce_state_error_event_onAppear() {
        test_reduce(state: .error(TestError.testError),
                    event: .onAppear,
                    expectedState: .error(TestError.testError))
    }
    
    func test_reduce_state_error_event_onMoviesLoaded() {
        let games = self.games()
        test_reduce(state: .error(TestError.testError),
                    event: .onMoviesLoaded(games),
                    expectedState: .error(TestError.testError))
    }

    func test_reduce_state_error_event_onFailedToLoadMovies() {
        test_reduce(state: .error(TestError.testError),
                    event: .onFailedToLoadMovies(TestError.testError),
                    expectedState: .error(TestError.testError))
    }
}

fileprivate enum TestError: Error {
    case testError
}
