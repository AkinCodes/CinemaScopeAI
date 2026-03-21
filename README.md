# 🎬 CinemaScopeAI

[![Platform](https://img.shields.io/badge/Platform-iOS_17+-blue?logo=apple)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange?logo=swift)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-blue?logo=swift)](https://developer.apple.com/swiftui/)
[![Architecture](https://img.shields.io/badge/Architecture-MVVM-green)](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel)
[![Backend](https://img.shields.io/badge/Backend-Live_on_Render-purple)](https://cinemascope-api.onrender.com)
[![License](https://img.shields.io/badge/License-MIT-lightgrey)](LICENSE)
[![No Dependencies](https://img.shields.io/badge/Dependencies-Zero-brightgreen)]()

An iOS app with two different ways to get movie recommendations. **Form mode** talks to a deep learning backend I trained and deployed myself. **Chat mode** lets you describe what you want in plain English and gets picks from OpenAI. Both show posters, ratings, plot summaries, and full detail views — no third-party iOS libraries anywhere.

<p align="center">
<img src="https://github.com/user-attachments/assets/d47ece97-8548-4fff-bb13-4732793e61c0" width="300" />
<img src="https://github.com/user-attachments/assets/0fc556dd-65b4-49c9-8d13-d21c9c02572a" width="300" />
</p>

---

## Try It Right Now

The backend is live. You can hit it from your terminal without cloning anything:

```bash
curl -X POST https://cinemascope-api.onrender.com/predict/ \
  -H "Content-Type: application/json" \
  -d '{"release_year": 2010, "duration_text": "120", "type": "Movie", "rating": "PG-13"}'
```

> **Note:** The Render free tier spins down after inactivity. If the first request takes ~30 seconds, that's the cold start — subsequent requests are fast.

---

## Features

### Two Recommendation Engines

**Form Mode** — Pick a release year, duration, content type (Movie or TV Show), and rating from a structured form. The app sends this to a FastAPI + PyTorch backend running a deep learning model trained on MovieLens data. You get back 5 recommendations with posters, scores, directors, and summaries.

**Chat Mode** — Type anything you want in natural language: *"give me 90s horror movies that aren't too gory"* or *"something like Interstellar but more emotional"*. The app sends a structured prompt to OpenAI's GPT-3.5 Turbo API, parses the JSON response, and displays results in the same card format.

Both modes share the same `Recommendation` model, the same `MovieCardView`, and the same detail screen. A segmented control at the top lets you switch between them with a smooth slide animation.

### Polished UX

- **Skeleton loading** — While the backend responds, you see placeholder cards with the `.redacted(reason: .placeholder)` modifier instead of a blank screen or a spinner
- **Pull to refresh** — Swipe down on the results list to re-fetch with the same criteria
- **Search and filter** — A search bar appears above results so you can filter by title, genre, or director without making another API call
- **Haptic feedback** — Success triggers a medium impact; errors trigger the error notification pattern
- **Smooth transitions** — Switching between Manual and GPT modes uses asymmetric move + opacity transitions
- **Error recovery** — Every error state has both a "Retry" button (re-sends the last request) and a "Start Over" button (resets the form). Errors that happen while results are on screen show as alerts instead of replacing the content
- **VoiceOver support** — Every interactive element has `accessibilityLabel`, `accessibilityHint`, and `accessibilityIdentifier`. Cards announce title, genre, and director. The skeleton view announces "Loading recommendations"

### Clean Architecture

- **Protocol-based dependency injection** — `MovieRecommendationServiceProtocol` and `GPTServiceProtocol` define what the ViewModels need. The real implementations (`CinemaScopeAIService`, `GPTClient`) are injected through initializers with defaults, so you can swap in mocks for testing
- **Custom error types** — `CinemaScopeError` is a typed enum with cases for network errors, decoding errors, invalid responses, API errors, and empty data. Each case carries context (the underlying error or message) and conforms to `LocalizedError`
- **Centralised configuration** — `AppConfiguration` holds the backend URL, OpenAI endpoint, and model name in one place
- **Actor-based concurrency** — `GPTClient` is an `actor`, which means its mutable state is protected from data races without manual locking. ViewModels are `@MainActor` so UI updates always happen on the main thread
- **`@Observable` macro** — Both ViewModels use Swift 5.9's `@Observable` instead of `ObservableObject` + `@Published`. This means fewer property wrappers, automatic fine-grained observation, and views only re-render when the specific properties they read actually change

---

## Architecture

```
┌──────────────────────────────────────────────────────────┐
│                        SwiftUI Views                      │
│                                                           │
│  ViewModelSwitcherView ─── segmented control ───┐         │
│        │                                        │         │
│  CinemaScopeAIView                        GPTChatView     │
│  CinemaScopeAIInputForm                                   │
│  CinemaScopeAIDetailView    (shared)    MovieCardView     │
└──────────────┬──────────────────────────────┬─────────────┘
               │                              │
┌──────────────▼──────────┐   ┌───────────────▼─────────────┐
│ CinemaScopeAIViewModel  │   │    GPTChatViewModel         │
│   @Observable           │   │    @Observable               │
│   @MainActor            │   │    @MainActor                │
│                         │   │                              │
│  - Input sanitisation   │   │  - Prompt building           │
│  - Payload construction │   │  - Message history           │
│  - Haptic feedback      │   │  - Haptic feedback           │
│  - Retry / Reset        │   │  - Retry logic               │
└──────────────┬──────────┘   └───────────────┬─────────────┘
               │                              │
     ┌─────────▼─────────┐         ┌──────────▼──────────┐
     │ MovieRecommendation│         │  GPTServiceProtocol │
     │ ServiceProtocol    │         │                     │
     └─────────┬─────────┘         └──────────┬──────────┘
               │                              │
     ┌─────────▼─────────┐         ┌──────────▼──────────┐
     │ CinemaScopeAI     │         │   GPTClient (actor)  │
     │ Service           │         │                      │
     │ URLSession + POST │         │   URLSession + POST  │
     └─────────┬─────────┘         └──────────┬──────────┘
               │                              │
               ▼                              ▼
   FastAPI + PyTorch               OpenAI Chat Completions
   (Render)                        (api.openai.com)
```

**Views** handle layout and user interaction. They don't know about networking.

**ViewModels** own the state, sanitise input, call services, and manage loading/error states. They're isolated to the main actor so every property change is safe for SwiftUI to observe.

**Service protocols** define the contract. The ViewModels only depend on the protocol, never the concrete class.

**Services** handle the actual HTTP calls and JSON parsing. `GPTClient` is an actor because it could be called from multiple contexts. `CinemaScopeAIService` is a plain `Sendable` class with a shared singleton.

**Shared model** — Both engines produce `[Recommendation]`, which is what `MovieCardView` and `CinemaScopeAIDetailView` render. This means the two modes feel identical to the user even though their backends are completely different.

---

## Tech Stack

| What | Why |
|---|---|
| **SwiftUI** | Declarative UI, less code than UIKit, and it handles the list diffing and animation for free |
| **`@Observable` (Swift 5.9)** | Replaces `ObservableObject` + `@Published` — less boilerplate, and SwiftUI only re-renders views that actually read the changed property |
| **`actor` (GPTClient)** | Thread-safe by design — no locks, no `DispatchQueue`, the compiler enforces isolation |
| **`@MainActor` ViewModels** | Guarantees all state mutations happen on the main thread without manual dispatching |
| **`async/await`** | Structured concurrency instead of completion handlers or Combine chains |
| **`AsyncImage`** | Built-in image loading from URLs with loading/error states — no need for Kingfisher or SDWebImage |
| **Zero third-party dependencies** | Everything is built on Apple frameworks. No CocoaPods, no SPM packages, nothing to keep updated |
| **FastAPI + PyTorch (backend)** | Python for ML is hard to beat. FastAPI gives you automatic docs and async support out of the box |

---

## Getting Started

### Prerequisites

- **Xcode 15+** (for Swift 5.9 and the `@Observable` macro)
- **iOS 17+ simulator or device**
- An **OpenAI API key** if you want to use Chat mode (Form mode works without one)

### Setup

**1. Clone the repo**

```bash
git clone https://github.com/AkinCodes/CinemaScopeAI.git
cd CinemaScopeAI
```

**2. Open in Xcode**

```bash
open CinemaScopeAI.xcodeproj
```

**3. (Optional) Add your OpenAI API key for Chat mode**

Go to **Product > Scheme > Edit Scheme > Run > Environment Variables** and add:

| Variable | Value |
|---|---|
| `OPENAI_API_KEY` | `sk-your-key-here` |

If you skip this, Form mode still works fine. Chat mode will show an error telling you the key is missing.

**4. Build and run**

Press `Cmd+R`. Pick an iOS 17+ simulator (iPhone 15 Pro works well).

**What you should see:**
- The app opens to the Form mode with fields for release year, duration, type, and rating
- Fill them in, tap "Get Recommendations", and you should see 5 movie cards appear with posters
- Switch the segmented control to "GPT", type something like "fun comedies from the 2000s", and tap "Ask GPT & Recommend"
- Tap any movie card to see the full detail view with a large poster, metadata, and summary

---

## Project Structure

```
CinemaScopeAI/
├── CinemaScopeAI.xcodeproj
└── CinemaScopeAI/
    ├── Model/
    │   ├── Recommendation.swift          # Recommendation and RecommendationResponse models
    │   ├── ServiceProtocols.swift         # MovieRecommendationServiceProtocol, GPTServiceProtocol
    │   ├── CinemaScopeError.swift         # Typed error enum with 5 cases
    │   └── AppConfiguration.swift         # Base URLs and OpenAI model config
    │
    ├── View/
    │   ├── ViewModelSwitcherView.swift    # Root view — segmented control + navigation
    │   └── MovieCardView.swift            # Reusable card with poster, title, genre, director
    │
    ├── Cinema_Recommender/                # Form-based deep learning mode
    │   ├── CinemaScopeAIApp.swift         # @main entry point
    │   ├── CinemaScopeAIService.swift     # HTTP client for the PyTorch backend
    │   ├── CinemaScopeAIViewModel.swift   # Form state, input sanitisation, fetch logic
    │   ├── CinemaScopeAIInputForm.swift   # The form UI (year, duration, type, rating)
    │   ├── CinemaScopeAIView.swift        # Results list, skeleton loading, error states
    │   └── CinemaScopeAIDetailView.swift  # Full-screen movie detail page
    │
    └── GPT_Recommender/                   # Chat-based OpenAI mode
        ├── ChatMessage.swift              # Simple message model (role + content)
        ├── GPTClient.swift                # Actor that calls OpenAI API + parses JSON
        ├── GPTChatViewModel.swift         # Chat state, prompt building, retry logic
        └── GPTChatView.swift              # Text input, results list, skeleton loading
```

---

## How the Backend Works

The form mode connects to a **FastAPI** server running a **PyTorch** deep learning model. The model was trained on the [MovieLens](https://grouplens.org/datasets/movielens/) dataset to learn patterns between user preferences and movie attributes.

**Live URL:** [https://cinemascope-api.onrender.com](https://cinemascope-api.onrender.com)

The app sends a POST to `/predict/` with a JSON body like:

```json
{
  "release_year": 2010,
  "duration_text": "120",
  "type": "Movie",
  "rating": "PG-13"
}
```

And gets back:

```json
{
  "recommendations": [
    {
      "title": "Inception",
      "genre": "Sci-Fi",
      "rating": "PG-13",
      "score": 0.94,
      "poster_url": "https://image.tmdb.org/t/p/w500/...",
      "director": "Christopher Nolan",
      "release_year": 2010,
      "summary": "A thief who steals corporate secrets..."
    }
  ]
}
```

The backend repo with full training code and API implementation: **[RecommenderSystem](https://github.com/AkinCodes/RecommenderSystem)**

---

## What I'd Improve Next

- **Unit and UI tests** — Mock both service protocols and test the ViewModels in isolation. Add XCUITest flows for both recommendation modes using the accessibility identifiers that are already in place
- **Image caching** — `AsyncImage` doesn't cache across view reloads. A small `NSCache`-backed image loader would make scrolling and navigation snappier
- **Offline mode** — Cache the last set of recommendations locally so the app isn't useless without a connection
- **Streaming responses in Chat mode** — Use OpenAI's streaming API so recommendations appear one at a time instead of all at once after a wait
- **Pagination** — Right now the backend returns a fixed set. Supporting "show me more like these" would make it feel more like a real product

---

## Related Projects

| Project | Description |
|---|---|
| [**RecommenderSystem**](https://github.com/AkinCodes/RecommenderSystem) | The Python backend that powers Form mode — FastAPI, PyTorch, trained on MovieLens |
| [**MoviePosterAI**](https://github.com/AkinCodes/MoviePosterAI) | AI-powered movie poster analysis |

---

## Author

**Akin Olusanya**

[![GitHub](https://img.shields.io/badge/GitHub-AkinCodes-181717?logo=github)](https://github.com/AkinCodes)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-akindeveloper-0A66C2?logo=linkedin)](https://www.linkedin.com/in/akindeveloper)
[![Email](https://img.shields.io/badge/Email-workwithakin@gmail.com-EA4335?logo=gmail)](mailto:workwithakin@gmail.com)
