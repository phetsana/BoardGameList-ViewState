//
//  GameDetailViewModel.swift
//  BoardGameAtlasTest
//
//  Created by Phetsana PHOMMARINH on 20/09/2020.
//

import Foundation
import Combine

class GameDetailViewModel: ObservableObject {
    @Published private(set) var state: State = .idle
    private(set) var game: GameItem

    private var subscriptions = Set<AnyCancellable>()

    private let input = PassthroughSubject<Event, Never>()

    init(previewState: State? = nil,
         game: GamesListViewModel.GameItem) {
        self.game = GameItem(game: game)

        Publishers.system(initial: state,
                          previewState: previewState,
                          reduce: Self.reduce,
                          scheduler: RunLoop.main,
                          feedbacks: [
                            Self.whenLoading(game: self.game),
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

// MARK: - State Machine
extension GameDetailViewModel {
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
            case .onGameLoaded(let game):
                return .loaded(game)
            case .idle:
                return .idle
            default:
                return state
            }
        case .loaded:
            return state
        }
    }

    static func whenLoading(game: GameItem) -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard case .loading = state else { return Empty().eraseToAnyPublisher() }
            return Just(Event.onGameLoaded(game)).eraseToAnyPublisher()
        }
    }

    static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
        Feedback { _ in input }
    }
}
