//
//  GamesListViewModelTests.swift
//  BoardGameAtlasTestTests
//
//  Created by Phetsana PHOMMARINH on 08/09/2020.
//

import XCTest
@testable import BoardGameAtlasTest
import Combine

enum GamesListViewModelTestsError: Error {
    case error
}

class GamesListViewModelTests: XCTestCase {

    var sut: GamesListViewModel!
    
    var cancellables = Set<AnyCancellable>()
    
    static var deinitCalled = false
    
    override func setUp() {
        let apiClientMock = NetworkingServiceMock(file: "api_search")
        sut = GamesListViewModel(apiService: apiClientMock)
        GamesListViewModelTests.deinitCalled = false
    }
    
    override func tearDown() {
        cancellables.removeAll()
    }
    
    private func test_reduce(state: GamesListViewModel.State,
                             event: GamesListViewModel.Event,
                             expectedState: GamesListViewModel.State) {
        let newState = GamesListViewModel.reduce(state, event)
        XCTAssertEqual(newState, expectedState)
    }
    
    func test_reduce_state_idle_event_onAppear() {
        test_reduce(state: .idle,
                    event: .onAppear,
                    expectedState: .loading)
    }
    
    func test_reduce_state_idle_event_onMoviesLoaded() {
        test_reduce(state: .idle,
                    event: .onGamesLoaded([]),
                    expectedState: .idle)
    }

    func test_reduce_state_idle_event_onFailedToLoadMovies() {
        test_reduce(state: .idle,
                    event: .onFailedToLoadGames(GamesListViewModelTestsError.error),
                    expectedState: .idle)
    }
    
    func test_reduce_state_loading_event_onAppear() {
        test_reduce(state: .loading,
                    event: .onAppear,
                    expectedState: .loading)
    }
    
    private func games() -> [GamesListViewModel.GameItem] {
        let gameDTO1 = GameDTO(id: "testid 1", name: "testname 1", imageUrl: nil)
        let game1 = GamesListViewModel.GameItem(game: gameDTO1)
        
        let gameDTO2 = GameDTO(id: "testid 2", name: "testname 2", imageUrl: nil)
        let game2 = GamesListViewModel.GameItem(game: gameDTO2)
        
        return [game1, game2]
    }
    
    func test_reduce_state_loading_event_onMoviesLoaded() {
        let games = self.games()
        test_reduce(state: .loading,
                    event: .onGamesLoaded(games),
                    expectedState: .loaded(games))
    }

    func test_reduce_state_loading_event_onFailedToLoadMovies() {
        test_reduce(state: .loading,
                    event: .onFailedToLoadGames(GamesListViewModelTestsError.error),
                    expectedState: .error(GamesListViewModelTestsError.error))
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
                    event: .onGamesLoaded(games),
                    expectedState: .loaded(games))
    }

    func test_reduce_state_loaded_event_onFailedToLoadMovies() {
        let games = self.games()
        test_reduce(state: .loaded(games),
                    event: .onFailedToLoadGames(GamesListViewModelTestsError.error),
                    expectedState: .loaded(games))
    }
    
    func test_reduce_state_error_event_onAppear() {
        test_reduce(state: .error(GamesListViewModelTestsError.error),
                    event: .onAppear,
                    expectedState: .error(GamesListViewModelTestsError.error))
    }
    
    func test_reduce_state_error_event_onMoviesLoaded() {
        let games = self.games()
        test_reduce(state: .error(GamesListViewModelTestsError.error),
                    event: .onGamesLoaded(games),
                    expectedState: .error(GamesListViewModelTestsError.error))
    }

    func test_reduce_state_error_event_onFailedToLoadMovies() {
        test_reduce(state: .error(GamesListViewModelTestsError.error),
                    event: .onFailedToLoadGames(GamesListViewModelTestsError.error),
                    expectedState: .error(GamesListViewModelTestsError.error))
    }
    
    func test_whenLoading_gamesLoaded() {
        let apiClientMock = NetworkingServiceMock(file: "api_search")
        let feedback = GamesListViewModel.whenLoading(apiService: apiClientMock)
        let publisher = CurrentValueSubject<GamesListViewModel.State, Never>(.idle)
        let loadingExpectation = expectation(description: "loading")

        feedback
            .run(publisher.eraseToAnyPublisher())
            .sink { (event) in
                if case let .onGamesLoaded(games) = event {
                    XCTAssertEqual(games.isEmpty, false)
                    loadingExpectation.fulfill()
                } else {
                    XCTFail()
                }
            }
            .store(in: &cancellables)
        publisher.value = .loading
        
        wait(for: [loadingExpectation], timeout: 1)
    }
    
    func test_whenLoading_error() {
        enum APIError: Error {
            case loading
        }
        let apiClientMock = NetworkingServiceMock(file: "api_search", error: APIError.loading)
        let feedback = GamesListViewModel.whenLoading(apiService: apiClientMock)
        let publisher = CurrentValueSubject<GamesListViewModel.State, Never>(.idle)
        let loadingExpectation = expectation(description: "loading")

        feedback
            .run(publisher.eraseToAnyPublisher())
            .sink { (event) in
                if case let .onFailedToLoadGames(error) = event {
                    XCTAssertNotNil(error)
                    loadingExpectation.fulfill()
                } else {
                    XCTFail()
                }
            }
            .store(in: &cancellables)
        publisher.value = .loading
        
        wait(for: [loadingExpectation], timeout: 1)
    }
    
    func test_deinit() {
        let apiClientMock = NetworkingServiceMock(file: "api_search")
        var sut: GameboardsListViewModelMock? = GameboardsListViewModelMock(apiService: apiClientMock)
        XCTAssertNotNil(sut)
        sut = nil
        XCTAssertNil(sut)
        XCTAssertEqual(GamesListViewModelTests.deinitCalled, true)
    }
}

fileprivate class GameboardsListViewModelMock: GamesListViewModel {
    deinit {
        GamesListViewModelTests.deinitCalled = true
    }
}
