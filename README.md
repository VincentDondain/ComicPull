# ComicPull 🦸‍♂️📚

An iOS app for tracking weekly comic book releases, managing your collection, reading reviews, and getting AI-powered recommendations for new series.

## Features

- **Weekly Releases** — Browse this week's new comics via Comic Vine API
- **Collection Tracking** — Mark comics as Want → Acquired → Reading → Read
- **Reviews** — View community ratings and add your own 1-10 scores
- **AI Recommendations** — Claude-powered engine suggests new #1 issues based on your taste
- **Search** — Find any comic, series, or character

## Tech Stack

| Component | Technology |
|---|---|
| UI | SwiftUI |
| Architecture | MVVM + @Observable |
| Persistence | SwiftData |
| Comic Data | Comic Vine API |
| AI Engine | Anthropic Claude API |
| Web Search | Brave Search API |
| Min iOS | 17.0 |

## Setup

```bash
# Clone the repo
git clone https://github.com/VincentDondain/ComicPull.git
cd ComicPull

# Install xcodegen (if needed)
brew install xcodegen

# Run setup (configures git hooks + generates Xcode project)
./Scripts/setup-hooks.sh

# Open in Xcode
open ComicPull.xcodeproj
```

### API Keys

The app requires API keys stored in Keychain (never hardcoded):

1. **Comic Vine API** — [Get a free key](https://comicvine.gamespot.com/api/)
2. **Anthropic API** — [Get a key](https://console.anthropic.com/)
3. **Brave Search API** — [Get a key](https://brave.com/search/api/)

Configure keys in the app's settings screen or via `APIKeyManager`.

## Development

```bash
# Build
make build

# Run all tests
make test

# Run unit tests only
make test-unit

# Run UI tests only
make test-ui

# Regenerate Xcode project after changing project.yml
make generate

# Lint
make lint
```

### Git Hooks

A pre-push hook automatically runs build + unit tests before allowing pushes.
If tests fail, the push is blocked. Configure with:

```bash
make setup
```

## Project Structure

```
ComicPull/
├── App/           — App entry point, configuration
├── Models/        — SwiftData @Model classes
├── Services/      — API clients (Comic Vine, Claude, Web Search)
├── ViewModels/    — @Observable view models
├── Views/         — SwiftUI views organized by feature
└── Utilities/     — Keychain manager, formatters, cache
```

## Architecture

- **MVVM** — ViewModels contain business logic; Views are pure UI
- **Protocol-based services** — All API clients conform to protocols for easy mocking
- **async/await** — No Combine; all networking is async/await
- **SwiftData** — Native persistence with automatic iCloud sync potential

## License

MIT
