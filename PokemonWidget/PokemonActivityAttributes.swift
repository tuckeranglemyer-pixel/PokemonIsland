import Foundation
@preconcurrency import ActivityKit

nonisolated struct PokemonActivityAttributes: ActivityAttributes, Sendable {
    nonisolated struct ContentState: Codable, Hashable, Sendable {
        var pokemonName: String
        var pokemonImage: String
        var walkStartDate: Date
        var isReacting: Bool
        var animationTick: Int
    }

    var pokemonName: String
}
