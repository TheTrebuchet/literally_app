# literally app

A minimal Flutter productivity app with three simple sections.

## What it does

- **literally text** - Write notes (personal + shared)
- **literally tasks** - Track todos (personal + shared)  
- **literally money** - Log expenses (personal + shared)

## Why it's good

- Super clean and simple
- Light theme only (no dark mode bloat)
- Everything saves automatically
- Works on any platform Flutter supports
- No complicated features or dependencies

## How to use it

1. Install Flutter
2. Clone this repo
3. Run `flutter pub get`
4. Run `flutter run`
5. Pick your platform and go

## What's inside

```
lib/
├── main.dart           # All the screens and UI
├── design_system.dart  # Colors and styling
├── todo_models.dart    # Data models and storage
└── todo_widgets.dart   # Reusable UI components
```

## Building

```bash
# Android
flutter build apk

# Desktop  
flutter build linux    # or windows/macos

# Web
flutter build web
```

That's it. Simple app, simple setup.
```
├── todo_models.dart    # Data models and persistence logic
└── todo_widgets.dart   # Reusable UI components
```
## Technical Details

- **State Management**: Simple setState() - no complex state management
- **Persistence**: Local JSON files using path_provider
- **Animations**: Custom AnimationController with staggered letter effects
- **Platform Support**: Cross-platform Flutter app

## Contributing

This is a personal productivity app focused on simplicity. Feel free to fork and modify for your own needs.

## License

MIT License - feel free to use and modify as needed.
