import WidgetKit
import SwiftUI

@main
struct PokemonWidgetBundle: WidgetBundle {
    var body: some Widget {
        PokemonWidget()
        PokemonWidgetControl()
        PokemonWidgetLiveActivity()
    }
}
