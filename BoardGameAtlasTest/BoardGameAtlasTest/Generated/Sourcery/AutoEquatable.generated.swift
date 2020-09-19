// Generated using Sourcery 0.18.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable file_length

// MARK: - AutoEquatable for Enums
// MARK: - GameboardsListViewModel.Event AutoEquatable
extension GameboardsListViewModel.Event: Equatable {}
func == (lhs: GameboardsListViewModel.Event, rhs: GameboardsListViewModel.Event) -> Bool {
    switch (lhs, rhs) {
    case (.onAppear, .onAppear):
        return true
    case (.onGamesLoaded(let lhs), .onGamesLoaded(let rhs)):
        return lhs == rhs
    case (.onFailedToLoadGames(let lhs), .onFailedToLoadGames(let rhs)):
        return lhs.isEqual(to: rhs)
    default: return false
    }
}
// MARK: - GameboardsListViewModel.State AutoEquatable
extension GameboardsListViewModel.State: Equatable {}
func == (lhs: GameboardsListViewModel.State, rhs: GameboardsListViewModel.State) -> Bool {
    switch (lhs, rhs) {
    case (.idle, .idle):
        return true
    case (.loading, .loading):
        return true
    case (.loaded(let lhs), .loaded(let rhs)):
        return lhs == rhs
    case (.error(let lhs), .error(let rhs)):
        return lhs.isEqual(to: rhs)
    default: return false
    }
}
