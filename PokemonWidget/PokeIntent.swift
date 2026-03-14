import ActivityKit
import AppIntents

@available(iOSApplicationExtension 17.0, *)
struct PokeTapIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Poke Tap"
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        guard let activity = Activity<PokemonActivityAttributes>.activities.first else {
            return .result()
        }

        var state = activity.content.state
        state.isReacting = true
        await activity.update(ActivityContent(state: state, staleDate: nil))

        try? await Task.sleep(nanoseconds: 260_000_000)
        state.isReacting = false
        await activity.update(ActivityContent(state: state, staleDate: nil))

        return .result()
    }
}
