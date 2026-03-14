import SwiftUI

struct Pokemon: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    let color: Color
}

struct ContentView: View {
    @StateObject var activityManager = ActivityManager()
    @State private var selectedPokemonName: String?

    private let pokemon: [Pokemon] = [
        Pokemon(name: "Charmander", imageName: "charmander", color: .orange),
        Pokemon(name: "Pikachu", imageName: "pikachu", color: .yellow),
        Pokemon(name: "Bulbasaur", imageName: "bulbasaur", color: .green),
        Pokemon(name: "Squirtle", imageName: "squirtle", color: .blue),
        Pokemon(name: "Eevee", imageName: "eevee", color: .brown),
        Pokemon(name: "Mewtwo", imageName: "mewtwo", color: .purple),
    ]

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(red: 0.03, green: 0.03, blue: 0.05), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text("The Pokemon Lab")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(.white)
                    Text("Select your legendary partner.")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.top, 24)
                .padding(.bottom, 18)

                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(pokemon) { p in
                            PokemonCard(
                                pokemon: p,
                                isSelected: selectedPokemonName == p.name,
                                isActive: activityManager.activePokemonName == p.name
                            )
                            .onTapGesture {
                                selectedPokemonName = p.name
                            }
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 20)
                }

                Button {
                    guard let selected = selectedPokemon else { return }
                    activityManager.startActivity(pokemon: selected)
                } label: {
                    Text("Launch to Island")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.purple, Color.blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.white.opacity(0.35), lineWidth: 0.8)
                        )
                        .shadow(color: .purple.opacity(0.85), radius: 18, x: 0, y: 10)
                        .shadow(color: .blue.opacity(0.55), radius: 28, x: 0, y: 12)
                }
                .disabled(selectedPokemon == nil)
                .opacity(selectedPokemon == nil ? 0.45 : 1)
                .padding(.horizontal, 24)
                .padding(.top, 6)
                .padding(.bottom, 20)

                if activityManager.currentActivity != nil {
                    Button("Shutdown Link") {
                        activityManager.stopActivity()
                    }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.75))
                    .padding(.bottom, 10)
                }
            }
        }
    }

    private var selectedPokemon: Pokemon? {
        pokemon.first { $0.name == selectedPokemonName }
    }
}

struct PokemonCard: View {
    let pokemon: Pokemon
    let isSelected: Bool
    let isActive: Bool
    @State private var pulse = false

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
    }

    private var glowPower: Double {
        guard isActive else { return isSelected ? 0.45 : 0.0 }
        return pulse ? 0.95 : 0.55
    }

    var body: some View {
        ZStack {
            cardShape
                .fill(.ultraThinMaterial)
                .overlay {
                    cardShape
                        .stroke(
                            LinearGradient(
                                colors: [
                                    pokemon.color.opacity(0.95),
                                    Color.white.opacity(0.55),
                                    pokemon.color.opacity(0.95),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isActive ? 2.4 : 1
                        )
                }
                .shadow(color: pokemon.color.opacity(glowPower), radius: isActive ? 22 : 10, x: 0, y: 0)
                .shadow(color: pokemon.color.opacity(glowPower * 0.8), radius: isActive ? 36 : 0, x: 0, y: 0)

            VStack(spacing: 10) {
                Spacer(minLength: 8)
                Image(pokemon.imageName)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 96)
                    .shadow(color: pokemon.color.opacity(0.35), radius: 8, x: 0, y: 0)
                Text(pokemon.name.uppercased())
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .tracking(2.2)
                    .foregroundStyle(.white)
                Spacer(minLength: 8)
            }
            .padding(.horizontal, 10)
        }
        .frame(height: 170)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.95).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

#Preview {
    ContentView()
}
