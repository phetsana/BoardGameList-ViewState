//
//  GameboardsListViewModel.swift
//  BoardGameAtlasTest
//
//  Created by Phetsana PHOMMARINH on 08/09/2020.
//

import Foundation
import Combine

final class GameboardsListViewModel: ObservableObject {
    @Published private(set) var state = State.idle
    
    private var bag = Set<AnyCancellable>()
        
    private let input = PassthroughSubject<Event, Never>()
    
    init() {
        Publishers.system(initial: state,
                          reduce: Self.reduce,
                          scheduler: RunLoop.main,
                          feedbacks: [
                            Self.whenLoading(),
                            Self.userInput(input: input.eraseToAnyPublisher())
                          ]
        )
        .assign(to: \.state, on: self)
        .store(in: &bag)
    }
    
    deinit {
        bag.removeAll()
    }
    
    func send(event: Event) {
        input.send(event)
    }
}

// MARK: - Inner Types
extension GameboardsListViewModel {
    enum State {
        case idle
        case loading
        case loaded([GameItem])
        case error(Error)
    }

    enum Event {
        case onAppear
        case onMoviesLoaded([GameItem])
        case onFailedToLoadMovies(Error)
    }

    struct GameItem: Identifiable {
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
            case .onFailedToLoadMovies(let error):
                return .error(error)
            case .onMoviesLoaded(let movies):
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
    
    static func whenLoading() -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard case .loading = state else { return Empty().eraseToAnyPublisher() }
            let apiService = APIClientImpl()
            let request = GetGamesRequest()
            return apiService
                    .send(request)
                    .map { $0.games.map(GameItem.init) }
                    .map(Event.onMoviesLoaded)
                    .catch { Just(Event.onFailedToLoadMovies($0)) }
                    .eraseToAnyPublisher()
        }
    }
    
    static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
        Feedback { _ in input }
    }
}
