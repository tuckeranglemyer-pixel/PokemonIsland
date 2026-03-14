# Contributing to Pokemon Island

Thank you for your interest in contributing to Pokemon Island! This document provides guidelines and information for contributors.

## 🚀 Quick Start

1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/PokemonIsland.git`
3. Create a feature branch: `git checkout -b feature/amazing-feature`
4. Make your changes
5. Test on a physical iOS 17+ device (Live Activities require physical hardware)
6. Commit your changes: `git commit -m 'Add amazing feature'`
7. Push to your branch: `git push origin feature/amazing-feature`
8. Open a Pull Request

## 🛠️ Development Setup

### Prerequisites
- iOS 17.0+ device for testing Live Activities
- Xcode 15.0+
- Swift 5.9+

### Building
```bash
cd PokemonIsland
open PokemonIsland.xcodeproj
# Build and run in Xcode
```

### Sprite Processing
```bash
cd PokemonIsland
python3 process_sprites.py
```

## 📋 Guidelines

### Code Style
- Follow Swift API Design Guidelines
- Use SwiftLint configuration (`.swiftlint.yml`)
- Write self-documenting code with clear variable names
- Add comments for complex logic

### Commit Messages
- Use conventional commits: `feat:`, `fix:`, `docs:`, `style:`, `refactor:`, `test:`, `chore:`
- Keep first line under 50 characters
- Provide detailed description for complex changes

### Pull Requests
- Provide clear description of changes
- Reference any related issues
- Include screenshots for UI changes
- Test on multiple device sizes
- Ensure Live Activities work correctly

## 🎯 Areas for Contribution

### High Priority
- [ ] Additional Pokemon sprites and animations
- [ ] Enhanced animation behaviors (flying, swimming, special attacks)
- [ ] Sound effects and haptic feedback
- [ ] Localization support

### Medium Priority
- [ ] Widget customization options
- [ ] Multiple Pokemon in same activity
- [ ] Activity history and statistics
- [ ] Background music integration

### Future Ideas
- [ ] Pokemon battles in Live Activities
- [ ] Evolution animations
- [ ] Item interactions
- [ ] Multiplayer features

## 🧪 Testing

### Manual Testing Checklist
- [ ] Pokemon selection works on all devices
- [ ] Live Activity starts correctly
- [ ] Animation is smooth (60fps)
- [ ] Pokemon traversal works in Dynamic Island
- [ ] Activity ends properly
- [ ] No crashes or memory leaks

### Performance Considerations
- Live Activities should minimize battery usage
- Sprite loading should be optimized
- Memory usage should be monitored

## 📞 Getting Help

- Open an issue for bugs or feature requests
- Join discussions in Pull Requests
- Check existing issues before creating new ones

## 📄 License

By contributing, you agree that your contributions will be licensed under the same MIT License that covers the project.

Thank you for contributing to Pokemon Island! 🎮