# Contributing to Socketation

Thank you for your interest in contributing to Socketation! This document provides guidelines and information for contributors.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.8.1)
- Dart SDK
- Git
- A code editor (VS Code, Android Studio, or IntelliJ)

### Development Setup
1. Fork the repository
2. Clone your fork: `git clone https://github.com/yourusername/socketation.git`
3. Create a new branch: `git checkout -b feature/your-feature-name`
4. Install dependencies: `flutter pub get`
5. Run the app: `flutter run`

## 📋 Code Standards

### Architecture Guidelines
This project follows a strict **GetX + Services** architecture:

- **Controllers**: Handle business logic and state management using GetX
- **Services**: Manage network operations and external API calls
- **Models**: Define immutable data structures with JSON serialization
- **Views**: Contain only UI widgets with no business logic

### Naming Conventions
- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Functions & Variables**: `camelCase`
- **Constants**: `SCREAMING_SNAKE_CASE`

### Documentation Requirements
- All public classes and methods must have `///` documentation
- Explain what the function does, its parameters, and return values
- Include usage examples for complex functions

### Example Code Structure
```dart
/// Controller managing WebSocket functionality
/// 
/// Handles connection state, message sending, and event listener management
class WebsocketController extends GetxController {
  /// Current connection status
  final Rx<ConnectionStatus> connectionStatus = ConnectionStatus.disconnected.obs;
  
  /// Connects to the specified WebSocket server
  /// 
  /// [url] - The WebSocket server URL to connect to
  /// Returns [Future<void>] that completes when connection attempt finishes
  Future<void> connectToWebSocket() async {
    // Implementation...
  }
}
```

## 🔍 Code Review Process

### Before Submitting
- [ ] Run `flutter analyze` and fix all issues
- [ ] Run `flutter test` and ensure all tests pass
- [ ] Test your changes on both Android and iOS (if possible)
- [ ] Update documentation if adding new features
- [ ] Follow the existing code style and patterns

### Pull Request Guidelines
1. **Title**: Use clear, descriptive titles
2. **Description**: Explain what changes you made and why
3. **Testing**: Describe how you tested your changes
4. **Screenshots**: Include screenshots for UI changes
5. **Breaking Changes**: Clearly mark any breaking changes

## 🐛 Bug Reports

When reporting bugs, please include:
- Flutter version (`flutter --version`)
- Device/platform information
- Steps to reproduce the issue
- Expected vs actual behavior
- Screenshots or error logs if applicable

## 💡 Feature Requests

For new features:
- Check existing issues to avoid duplicates
- Clearly describe the feature and its use case
- Explain how it fits with the current architecture
- Consider backward compatibility

## 🚫 What Not to Contribute

- **Breaking changes** without prior discussion
- **Renaming** existing functions or classes
- **Deleting** existing functionality
- **Logic in UI widgets** (keep views logic-free)
- **Direct console logging** (use UI messages instead)

## 🏗️ Architecture Rules

### Controllers (GetX)
- Use reactive variables (`Rx<Type>`, `.obs`) for state management
- Keep business logic in controllers, not in views
- Use `onInit()` for initialization
- Dispose resources properly in `onClose()`

### Services
- Handle all external API calls and WebSocket operations
- Use callbacks to communicate with controllers
- Implement proper error handling
- No direct UI updates from services

### Models
- Make models immutable when possible
- Include `fromJson()` and `toJson()` methods
- Add `copyWith()` for immutable updates
- Use proper typing and null safety

### Views
- Only contain UI widgets and layout code
- Use `Obx()` or `GetBuilder()` for reactive updates
- Call controller methods for user interactions
- No business logic in widgets

## 🧪 Testing Guidelines

### Manual Testing
- Test on both Android and iOS
- Test different screen sizes
- Verify WebSocket connections work with real servers
- Test error scenarios (connection failures, invalid URLs)

### Automated Testing
- Write unit tests for controllers and services
- Add widget tests for complex UI components
- Integration tests for critical user flows

## 📝 Documentation

### Code Documentation
- Document all public APIs with `///` comments
- Include parameter descriptions and return types
- Add usage examples for complex functions

### README Updates
- Update the README.md for new features
- Add new dependencies to the installation section
- Update the roadmap/TODO section

## 🎯 Priority Areas

We're especially looking for contributions in:
- 🔐 Authentication support for secured WebSocket connections
- 🔍 Message filtering and search functionality
- 💾 Connection profiles and history
- 🎨 Dark mode theme support
- 📊 Performance metrics and statistics
- 🧪 Additional testing coverage

## 💬 Communication

- **GitHub Issues**: For bug reports and feature requests
- **GitHub Discussions**: For questions and general discussion
- **Pull Requests**: For code contributions

## 🏆 Recognition

Contributors will be:
- Listed in the README.md contributors section
- Credited in release notes for significant contributions
- Given appropriate GitHub repository permissions for regular contributors

Thank you for contributing to Socketation! 🚀
