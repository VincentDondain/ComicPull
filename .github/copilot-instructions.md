# ComicPull — iOS Comic Book Tracker

SwiftUI + MVVM app. iOS 17+, SwiftData for persistence, Comic Vine API for data, Claude API for recommendations.

## Architecture
- Models: `ComicPull/Models/` — SwiftData `@Model` classes
- Services: `ComicPull/Services/` — API clients, all async/await, protocol-based for testability
- ViewModels: `ComicPull/ViewModels/` — `@Observable` classes, inject services via init
- Views: `ComicPull/Views/` — pure SwiftUI, no business logic

## Testing
- Unit tests: `ComicPullTests/` — uses Swift Testing framework (`@Test`, `#expect`)
- UI tests: `ComicPullUITests/` — XCTest-based
- Run all: `make test`
- Run units only: `make test-unit`
- Run UI only: `make test-ui`

## Conventions
- All services conform to a protocol (e.g., `ComicVineServiceProtocol`) for mocking
- Use `async/await`, never Combine for new code
- API keys stored via `APIKeyManager` (Keychain), never hardcoded
- Errors are typed enums conforming to `LocalizedError`

## Git
- Pre-push hook runs `make test-unit`; fix failures before pushing
- Run `make setup` after cloning to configure hooks
