//
//  System.swift
//  BoardGameAtlasTest
//
//  Created by Phetsana PHOMMARINH on 08/09/2020.
//

import Combine

extension Publishers {

    /// System publisher
    ///
    /// Initialize finite state machine (FSM)
    ///
    /// - Parameter initial: The initial state of state machine
    /// - Parameter previewState: The state for previews
    /// - Parameter reduce: Reducer function transforming a couple State/Event to a new State
    /// - Parameter state: The state of reducer function
    /// - Parameter event: The event of reducer function
    /// - Parameter scheduler: The scheduler in which receive elements from publishers
    /// - Parameter feedbacks: The list of side effects
    /// - Returns Publisher of a new state
    static func system<State, Event, Scheduler: Combine.Scheduler>(
        initial: State,
        previewState: State? = nil,
        reduce: @escaping (_ state: State, _ event: Event) -> State,
        scheduler: Scheduler,
        feedbacks: [Feedback<State, Event>]
    ) -> AnyPublisher<State, Never> {

        if let previewState = previewState {
            return Just(previewState).eraseToAnyPublisher()
        }

        let state = CurrentValueSubject<State, Never>(initial)
        let events = feedbacks.map { feedback in feedback.run(state.eraseToAnyPublisher()) }

        return Deferred {
            Publishers.MergeMany(events)
                .receive(on: scheduler)
                .scan(initial, reduce)
                .handleEvents(receiveOutput: state.send)
                .receive(on: scheduler)
                .prepend(initial)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
