import ActivityKit
import AppIntents
import WidgetKit
import SwiftUI

@available(iOSApplicationExtension 17.0, *)
struct PokemonWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PokemonActivityAttributes.self) { context in
            let quote = StartupQuoteProvider.quote(for: context.state.walkStartDate)

            // ── Lock Screen Banner ──────────────────────────────
            VStack(spacing: 10) {
                Text("TODAY'S STARTUP QUOTE")
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .tracking(1.6)
                    .foregroundStyle(.white.opacity(0.52))

                Text("“\(quote.text)”")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.95))
                    .fixedSize(horizontal: false, vertical: true)

                Text(quote.authorInitials)
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .tracking(2.2)
                    .foregroundStyle(.white.opacity(0.68))
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .activityBackgroundTint(.black.opacity(0.75))
            .activitySystemActionForegroundColor(.white)

        } dynamicIsland: { context in
            DynamicIsland {

                // ── Expanded: Leading ────────────────────────────
                DynamicIslandExpandedRegion(.leading) {
                    EmptyView()
                }

                // ── Expanded: Trailing ───────────────────────────
                DynamicIslandExpandedRegion(.trailing) {
                    EmptyView()
                }

                // ── Expanded: Center (label) ─────────────────────
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.pokemonName.uppercased())
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .tracking(1.6)
                        .foregroundStyle(.white.opacity(0.65))
                }

                // ── Expanded: Bottom (full-width walk) ───────────
                DynamicIslandExpandedRegion(.bottom) {
                    Button(intent: PokeTapIntent()) {
                        WalkingSpriteView(
                            pokemonName: context.state.pokemonName,
                            walkStartDate: context.state.walkStartDate,
                            spriteSize: 56,
                            enableTraversal: false
                        )
                        .scaleEffect(context.state.isReacting ? 1.15 : 1.0)
                        .animation(
                            .spring(response: 0.25, dampingFraction: 0.55),
                            value: context.state.isReacting
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                }

            } compactLeading: {

                // ── Compact Leading (~60 pt wide) ────────────────
                Button(intent: PokeTapIntent()) {
                    WalkingSpriteView(
                        pokemonName: context.state.pokemonName,
                        walkStartDate: context.state.walkStartDate,
                        spriteSize: 120,
                        enableTraversal: false,
                        forceTimerDrivenUpdates: true,
                        useBaseSprite: false,
                        useTightFrames: true,
                        activityTick: context.state.animationTick
                    )
                    .frame(width: 38, height: 38)
                    .scaleEffect(context.state.isReacting ? 1.12 : 1.0)
                    .animation(
                        .spring(response: 0.25, dampingFraction: 0.55),
                        value: context.state.isReacting
                    )
                }
                .buttonStyle(.plain)

            } compactTrailing: {

                // ── Compact Trailing ─────────────────────────────
                EmptyView()

            } minimal: {

                // ── Minimal (~36 pt circle) ──────────────────────
                WalkingSpriteView(
                    pokemonName: context.state.pokemonName,
                    walkStartDate: context.state.walkStartDate,
                    spriteSize: 120,
                    enableTraversal: false,
                    forceTimerDrivenUpdates: true,
                    useBaseSprite: false,
                    useTightFrames: true,
                    activityTick: context.state.animationTick
                )
                .frame(width: 30, height: 30)
                .scaleEffect(context.state.isReacting ? 1.12 : 1.0)
                .animation(
                    .spring(response: 0.25, dampingFraction: 0.55),
                    value: context.state.isReacting
                )
            }
        }
    }
}

// MARK: - Legacy views (kept for optional use)

struct PokemonSpriteView: View {
    let imageName: String
    let pokemonName: String
    let isReacting: Bool
    let size: CGFloat
    let showAura: Bool
    @State private var breathe = false

    var body: some View {
        let idle = idleStyle(for: pokemonName.lowercased())

        ZStack {
            if showAura && pokemonName.lowercased() == "mewtwo" {
                Circle()
                    .fill(Color.purple.opacity(0.28))
                    .frame(width: size * 0.9, height: size * 0.9)
                    .scaleEffect(breathe ? 1.06 : 0.96)
                    .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: breathe)
            }

            Image(imageName)
                .interpolation(.none)
                .resizable()
                .antialiased(false)
                .scaledToFit()
                .frame(width: size, height: size)
                .rotationEffect(.degrees(idle.rotation))
                .rotation3DEffect(.degrees(breathe ? 4 : -4), axis: (x: 0, y: 1, z: 0))
                .scaleEffect((breathe ? idle.maxScale : idle.minScale) * (isReacting ? 1.08 : 1.0))
                .shadow(color: idle.glowColor, radius: idle.glowRadius)
                .animation(.easeInOut(duration: idle.breatheDuration).repeatForever(autoreverses: true), value: breathe)
                .animation(.spring(response: 0.28, dampingFraction: 0.62), value: isReacting)
        }
        .onAppear {
            breathe = true
        }
    }

    private func idleStyle(for pokemon: String) -> IdleStyle {
        switch pokemon {
        case "mewtwo":
            return IdleStyle(
                glowColor: .purple.opacity(0.7),
                glowRadius: 7,
                minScale: 0.98,
                maxScale: 1.04,
                breatheDuration: 1.9
            )
        case "pikachu":
            return IdleStyle(
                glowColor: .yellow.opacity(0.75),
                glowRadius: 5,
                minScale: 0.99,
                maxScale: 1.03,
                breatheDuration: 1.4
            )
        case "charmander":
            return IdleStyle(
                glowColor: .orange.opacity(0.55),
                glowRadius: 5,
                minScale: 0.98,
                maxScale: 1.05,
                breatheDuration: 1.2
            )
        case "bulbasaur":
            return IdleStyle(rotation: 2, glowColor: .green.opacity(0.42), glowRadius: 4, minScale: 0.99, maxScale: 1.03, breatheDuration: 1.8)
        case "eevee":
            return IdleStyle(rotation: -2, glowColor: .brown.opacity(0.45), glowRadius: 4, minScale: 0.99, maxScale: 1.02, breatheDuration: 1.7)
        default:
            return IdleStyle()
        }
    }
}

struct ExpandedPokemonPod: View {
    let imageName: String
    let pokemonName: String
    let isReacting: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.45))
                .frame(width: 90, height: 90)

            Circle()
                .stroke(Color.purple.opacity(0.5), lineWidth: 1)
                .frame(width: 90, height: 90)
                .shadow(color: .purple.opacity(0.4), radius: 8)

            PokemonSpriteView(
                imageName: imageName,
                pokemonName: pokemonName,
                isReacting: isReacting,
                size: 75,
                showAura: pokemonName.lowercased() == "mewtwo"
            )
        }
        .padding(.top, 20)
    }
}

struct IdleStyle {
    var rotation: Double = 0
    var glowColor: Color = .clear
    var glowRadius: CGFloat = 0
    var minScale: CGFloat = 0.99
    var maxScale: CGFloat = 1.03
    var breatheDuration: Double = 1.6
}

struct StartupQuote: Sendable {
    let text: String
    let author: String

    var authorInitials: String {
        author
            .split(separator: " ")
            .compactMap { $0.first }
            .prefix(2)
            .map { String($0) }
            .joined()
            .uppercased()
    }
}

enum StartupQuoteProvider {
    private static let quotes: [StartupQuote] = [
        StartupQuote(text: "Competition is for losers.", author: "Peter Thiel"),
        StartupQuote(text: "Stay hungry, stay foolish.", author: "Steve Jobs"),
        StartupQuote(text: "Make something people want.", author: "Paul Graham"),
        StartupQuote(text: "Done is better than perfect.", author: "Sheryl Sandberg"),
        StartupQuote(text: "If you are not embarrassed by your first version, you launched too late.", author: "Reid Hoffman"),
        StartupQuote(text: "When something is important enough, you do it even if the odds are not in your favor.", author: "Elon Musk"),
        StartupQuote(text: "The way to get started is to quit talking and begin doing.", author: "Walt Disney"),
        StartupQuote(text: "Move fast and be bold in your bets.", author: "Jeff Bezos"),
    ]

    static func quote(for date: Date) -> StartupQuote {
        let day = Calendar.current.ordinality(of: .day, in: .era, for: date) ?? 0
        let idx = abs(day) % quotes.count
        return quotes[idx]
    }
}
