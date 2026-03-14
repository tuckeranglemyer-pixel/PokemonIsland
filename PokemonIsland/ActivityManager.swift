import ActivityKit
import Combine
import SwiftUI

@available(iOS 17.0, *)
@MainActor
final class ActivityManager: ObservableObject {
    @Published var currentActivity: Activity<PokemonActivityAttributes>?
    @Published var activePokemonName: String?
    private var animationTask: Task<Void, Never>?

    func startActivity(pokemon: Pokemon) {
        Task {
            await startActivityInternal(pokemon: pokemon)
        }
    }

    private func startActivityInternal(pokemon: Pokemon) async {
        await endAllPokemonActivities()

        let attributes = PokemonActivityAttributes(pokemonName: pokemon.name)
        let state = PokemonActivityAttributes.ContentState(
            pokemonName: pokemon.name,
            pokemonImage: pokemon.imageName,
            walkStartDate: Date(),
            isReacting: false,
            animationTick: 0
        )
        let content = ActivityContent(state: state, staleDate: nil)

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            currentActivity = activity
            activePokemonName = pokemon.name
            startAnimationTicker(for: activity)
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }

    func stopActivity() {
        animationTask?.cancel()
        animationTask = nil
        Task {
            await endAllPokemonActivities()
        }
        currentActivity = nil
        activePokemonName = nil
    }

    private func endAllPokemonActivities() async {
        animationTask?.cancel()
        animationTask = nil
        for activity in Activity<PokemonActivityAttributes>.activities {
            let endedState = activity.content.state
            let endedContent = ActivityContent(state: endedState, staleDate: nil)
            await activity.end(endedContent, dismissalPolicy: .immediate)
        }
    }

    private func startAnimationTicker(for activity: Activity<PokemonActivityAttributes>) {
        animationTask?.cancel()
        animationTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 4_000_000_000)
                guard !Task.isCancelled else { break }
                await self?.pushAnimationTick(for: activity)
            }
        }
    }

    private func pushAnimationTick(for activity: Activity<PokemonActivityAttributes>) async {
        guard currentActivity?.id == activity.id else { return }
        var state = activity.content.state
        state.animationTick = (state.animationTick + 1) % 10_000
        await activity.update(ActivityContent(state: state, staleDate: nil))
    }
}
