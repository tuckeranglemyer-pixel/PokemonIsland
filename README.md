# 🏝️ Pokemon Island

**Bring your favorite Pokemon to life on your iPhone's Dynamic Island and Lock Screen!**

Pokemon Island is a cutting-edge iOS app that leverages Apple's ActivityKit framework to create immersive Live Activities featuring animated Pokemon sprites. Select your legendary partner and watch them roam freely across your island with smooth walking animations, physics-based movement, and interactive behaviors.

![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![Xcode](https://img.shields.io/badge/Xcode-15.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
[![CI](https://github.com/tuckeranglemyer-pixel/PokemonIsland/actions/workflows/ci.yml/badge.svg)](https://github.com/tuckeranglemyer-pixel/PokemonIsland/actions/workflows/ci.yml)

## ✨ Features

- **🎮 Pokemon Selection**: Choose from 6 iconic Pokemon (Charmander, Pikachu, Bulbasaur, Squirtle, Eevee, Mewtwo)
- **🏃‍♂️ Live Walking Animation**: Smooth 2-frame walking cycles with realistic bobbing motion
- **🗺️ Island Exploration**: Pokemon traverse the full width of your Dynamic Island, bouncing off edges
- **🎭 Dynamic Behaviors**: Breathing animations, hopping, and directional turning
- **📱 Multi-Platform Display**: Optimized for Dynamic Island, Lock Screen, and Live Activities
- **⚡ Real-time Updates**: ActivityKit-powered live updates with minimal battery impact
- **🎨 Beautiful UI**: Dark theme with gradient backgrounds and glassmorphism effects

## 🚀 Tech Stack

- **SwiftUI** - Modern declarative UI framework
- **ActivityKit** - iOS 17+ Live Activities framework
- **WidgetKit** - Widget extension for Live Activity presentation
- **TimelineView** - Smooth animation timing
- **Python** - Sprite processing and asset management
- **PIL/Pillow** - Image processing for sprite extraction

## 📸 Screenshots

*Coming soon - Screenshots will showcase the Pokemon selection interface and Live Activity displays on Dynamic Island and Lock Screen.*

## 🛠️ Installation & Setup

### Prerequisites
- **iOS 17.0+** (Required for ActivityKit)
- **Xcode 15.0+**
- **macOS Ventura 13.0+**

### Building from Source

1. **Clone the repository**
   ```bash
   git clone https://github.com/tuckeranglemyer-pixel/PokemonIsland.git
   cd PokemonIsland
   ```

2. **Open in Xcode**
   ```bash
   open PokemonIsland.xcodeproj
   ```
   *Note: The project uses Xcode's multi-target setup with the main app and widget extension.*

3. **Build and Run**
   - Select your target device/simulator
   - Press `Cmd + R` to build and run
   - For Live Activities, you need a physical iOS 17+ device

### Sprite Processing

The project includes a Python script for processing Pokemon sprites:

```bash
cd PokemonIsland
python3 process_sprites.py
```

This script:
- Downloads spritesheets from The Spriters Resource
- Extracts individual frames using color analysis
- Generates XCAssets for both app and widget targets
- Handles background removal and optimization

## 🏗️ Architecture

### Core Components

- **`PokemonIslandApp.swift`** - Main app entry point
- **`ContentView.swift`** - Pokemon selection interface
- **`ActivityManager.swift`** - Live Activity lifecycle management
- **`WalkingSpriteView.swift`** - Core animation engine with physics
- **`PokemonWidgetLiveActivity.swift`** - Widget extension for Live Activity display

### Animation System

The animation system uses a hybrid approach:
- **TimelineView** for frame-perfect timing
- **ActivityKit updates** for state synchronization
- **GeometryReader** for responsive layout
- **Physics-based movement** with collision detection

### Live Activity Flow

1. User selects Pokemon in main app
2. `ActivityManager` requests Live Activity with initial state
3. Widget displays animated Pokemon using `WalkingSpriteView`
4. Background updates push animation ticks every 4 seconds
5. Activity ends when user taps "Shutdown Link"

## 🎯 Key Technical Highlights

### Advanced Animation Techniques
- **Multi-frame sprite animation** with seamless looping
- **Traversal physics** with edge bouncing and direction changes
- **Bobbing motion** synchronized with walking cycle
- **Breathing effects** with scale transformations
- **Timeline-based updates** for consistent 60fps animation

### ActivityKit Integration
- **Push updates** for real-time animation state
- **Stale date handling** for activity lifecycle
- **Content state management** with Codable structs
- **Background execution** with minimal power consumption

### WidgetKit Optimization
- **Compact design** for Dynamic Island constraints
- **Responsive scaling** across different widget sizes
- **Memory-efficient** sprite loading and caching
- **Timeline scheduling** for smooth animations

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details on:
- Development setup
- Code style guidelines
- Testing procedures
- Areas for contribution

## 📖 Documentation

- [Code of Conduct](CODE_OF_CONDUCT.md)
- [Contributing Guide](CONTRIBUTING.md)
- [License](LICENSE)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Pokemon sprites** courtesy of [The Spriters Resource](https://www.spriters-resource.com)
- **ActivityKit** framework by Apple
- **SwiftUI** and **WidgetKit** communities for inspiration

---

*Built with ❤️ using SwiftUI and ActivityKit*
