import SwiftUI
import WidgetKit

/// Displays a walking Pokémon sprite that cycles between walk frames and
/// optionally traverses the full width of its container, bouncing off edges.
///
/// Designed for WidgetKit Live Activities & Lock Screen widgets.
/// Uses `TimelineView(.periodic)` for frame updates — no app-side timer needed.
struct WalkingSpriteView: View {
    let pokemonName: String
    let walkStartDate: Date
    let spriteSize: CGFloat
    let enableTraversal: Bool
    var forceTimerDrivenUpdates: Bool = false
    var useBaseSprite: Bool = false
    var useTightFrames: Bool = false
    var activityTick: Int? = nil

    private static let frameDuration: TimeInterval = 0.22
    private static let frameCount = 2
    private static let walkSpeed: Double = 52 // points per second
    private static let bobAmplitude: CGFloat = 3.6

    var body: some View {
        if forceTimerDrivenUpdates {
            TimelineView(.animation) { context in
                ZStack {
                    // Keep a timer text in-tree for compact Dynamic Island refresh behavior.
                    Text(timerInterval: walkStartDate...Date.distantFuture, countsDown: false)
                        .font(.caption2.monospacedDigit())
                        .opacity(0.015)
                        .frame(width: 1, height: 1)
                    content(elapsed: max(0, context.date.timeIntervalSince(walkStartDate)))
                }
            }
        } else {
            TimelineView(.periodic(from: walkStartDate, by: Self.frameDuration)) { context in
                content(elapsed: max(0, context.date.timeIntervalSince(walkStartDate)))
            }
        }
    }

    @ViewBuilder
    private func content(elapsed: TimeInterval) -> some View {
        let timerDrivenInPlace = forceTimerDrivenUpdates && !enableTraversal
        let tickOffset = Double(activityTick ?? 0) * 0.27
        let animTime = elapsed + tickOffset
        let timelineFrameIdx = Int(elapsed / Self.frameDuration) % Self.frameCount
        let frameIdx = timerDrivenInPlace ? (Int(animTime / Self.frameDuration) % Self.frameCount) : timelineFrameIdx
        let frameName = useBaseSprite
            ? pokemonName.lowercased()
            : (useTightFrames
                ? "\(pokemonName.lowercased())_walk_tight_\(frameIdx)"
                : "\(pokemonName.lowercased())_walk_\(frameIdx)")
        let bob: CGFloat = timerDrivenInPlace
            ? sin(animTime * 7.2) * 0.9
            : sin(elapsed * 8) * Self.bobAmplitude

        if enableTraversal {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                // Prevent clipping in very tight Dynamic Island regions.
                let effectiveSize = max(14, min(spriteSize, w, h))
                let travel = max(0, w - effectiveSize)
                let halfCycle = travel / Self.walkSpeed
                let fullCycle = max(0.8, halfCycle * 2)
                let phase = elapsed.truncatingRemainder(dividingBy: fullCycle) / fullCycle

                let goingRight = phase < 0.5
                let linear = goingRight ? phase * 2 : 1.0 - (phase - 0.5) * 2
                let xPos = linear * travel + effectiveSize / 2

                sprite(frameName, facingRight: goingRight, size: effectiveSize)
                    .position(x: xPos, y: h / 2 + bob)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            GeometryReader { geo in
                let viewport = max(16, min(spriteSize, geo.size.width, geo.size.height))
                // Production balance: render as large as possible with minimal safety margin.
                let maxScale: CGFloat = 1.02
                let edgeInset: CGFloat = 1
                let safeW = max(12, geo.size.width - edgeInset * 2)
                let safeH = max(12, geo.size.height - edgeInset * 2)
                let drawSize = min(viewport, safeW / maxScale, safeH / maxScale)
                // Smooth compact/minimal motion: continuous turn + breathe + hop.
                let turnWave = sin(animTime * 1.45)
                let facingRight = turnWave >= 0
                let breathScale: CGFloat = 1.0 + 0.02 * sin(animTime * 2.35)
                let hopPulse = max(0.0, sin(animTime * 1.95))
                let jumpNudge: CGFloat = -1.1 * hopPulse + bob * 0.25
                let turnTilt: Double = Double(turnWave) * 3.2
                let turnXNudge: CGFloat = CGFloat(turnWave) * 0.85
                let verticalHeadroom = max(0, (geo.size.height - (drawSize * breathScale)) / 2 - 0.4)
                let safeY = min(max(jumpNudge, -verticalHeadroom), verticalHeadroom)
                let horizontalHeadroom = max(0, (geo.size.width - (drawSize * breathScale)) / 2 - 0.4)
                let safeX = min(max(turnXNudge, -horizontalHeadroom), horizontalHeadroom)
                sprite(frameName, facingRight: facingRight, size: drawSize)
                    .scaleEffect(breathScale)
                    .rotationEffect(.degrees(turnTilt))
                    .position(
                        x: geo.size.width / 2 + safeX,
                        y: geo.size.height / 2 + safeY
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private func sprite(_ name: String, facingRight: Bool, size: CGFloat) -> some View {
        Image(name)
            .interpolation(.none)
            .resizable()
            .antialiased(false)
            .scaledToFit()
            .frame(width: size, height: size)
            .scaleEffect(x: facingRight ? 1 : -1, y: 1, anchor: .center)
    }
}
