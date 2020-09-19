//
//  GameboardsListViewModel.swift
//  BoardGameAtlasTest
//
//  Created by Phetsana PHOMMARINH on 08/09/2020.
//

import Foundation
import Combine

class GameboardsListViewModel: ObservableObject {
    @Published private(set) var state = State.idle
    
    private var subscriptions = Set<AnyCancellable>()
        
    private let input = PassthroughSubject<Event, Never>()
    
    private let apiService: NetworkingService
    init(apiService: NetworkingService = BoardGameAtlasNetworkingServiceImpl()) {
        self.apiService = apiService

        Publishers.system(initial: state,
                          reduce: Self.reduce,
                          scheduler: RunLoop.main,
                          feedbacks: [
                            Self.whenLoading(apiService: self.apiService),
                            Self.userInput(input: input.eraseToAnyPublisher())
                          ]
        )
        .sink(receiveValue: { [weak self] (state) in
            self?.state = state
        })
        .store(in: &subscriptions)
    }
    
    deinit {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
    }
    
    func send(event: Event) {
        input.send(event)
    }
}

// MARK: - Inner Types
extension GameboardsListViewModel {
    enum State: AutoEquatable {
        case idle
        case loading
        case loaded([GameItem])
        case error(Error)
    }

    enum Event: AutoEquatable {
        case onAppear
        case onGamesLoaded([GameItem])
        case onFailedToLoadGames(Error)
    }

    struct GameItem: Identifiable, Equatable {
        let id: String
        let name: String?
        let imageURL: URL?
        
        init(game: GameDTO) {
            id = game.id
            name = game.name
            imageURL = game.imageUrl
        }
    }
}

// MARK: - State Machine
extension GameboardsListViewModel {
    static func reduce(_ state: State, _ event: Event) -> State {
        switch state {
        case .idle:
            switch event {
            case .onAppear:
                return .loading
            default:
                return state
            }
        case .loading:
            switch event {
            case .onFailedToLoadGames(let error):
                return .error(error)
            case .onGamesLoaded(let movies):
                return .loaded(movies)
            default:
                return state
            }
        case .loaded:
            return state
        case .error:
            return state
        }
    }
    
    static func whenLoading(apiService: NetworkingService) -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard case .loading = state else { return Empty().eraseToAnyPublisher() }
            let request = GetGamesRequest()
            return apiService
                .send(request)
                .map { $0.games.map(GameItem.init) }
                .map(Event.onGamesLoaded)
                .catch { Just(Event.onFailedToLoadGames($0)) }                    
                .eraseToAnyPublisher()
        }
    }
    
    static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
        Feedback { _ in input }
    }
}
