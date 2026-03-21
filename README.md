# CinemaScopeAI

An iOS app that recommends movies. You can either fill out a quick form — pick a genre, era, mood — or just chat with it like you would with a friend ("give me sci-fi thrillers from the 2000s") and it comes back with suggestions, posters and all.

<p>
<img src="https://github.com/user-attachments/assets/d47ece97-8548-4fff-bb13-4732793e61c0" width="300" />
<img src="https://github.com/user-attachments/assets/0fc556dd-65b4-49c9-8d13-d21c9c02572a" width="300" />
</p>

## What it does

- Two ways to get recommendations — pick from dropdowns or just type what you want
- Shows movie posters, ratings, plot summaries, and director info
- Tap any movie for a full detail view
- Search and filter results by title, genre, or director
- Pull to refresh for new picks
- Loading skeletons so nothing feels janky while it fetches
- Works with VoiceOver if you care about accessibility (you should)

## How it's built

Swift, SwiftUI, iOS 17+. MVVM with async/await and actors. No third-party libraries — everything is built on top of what Apple gives you. The form mode hits a deep learning backend I built separately. The chat mode talks to OpenAI's API directly.

A few things worth noting if you're reading the code: ViewModels use the new `@Observable` macro instead of `ObservableObject`, services are injected through protocols so everything is testable, and errors are handled with a custom typed enum instead of string messages.

## Getting started

1. Clone it — `git clone https://github.com/AkinCodes/CinemaScopeAI.git`
2. Open `CinemaScopeAI.xcodeproj` in Xcode
3. If you want chat mode, add your `OPENAI_API_KEY` in **Product > Scheme > Edit Scheme > Run > Environment Variables** (form mode works without it)
4. Hit Cmd+R. Needs iOS 17+ simulator or device.

## Project structure

```
CinemaScopeAI/
├── Model/              # Data models, service protocols, error types, config
├── View/               # Root navigation view, reusable card component
├── Cinema_Recommender/ # Form-based mode — app entry, service, viewmodel, views
└── GPT_Recommender/    # Chat mode — OpenAI client (actor), viewmodel, views
```

## The backend

The form mode talks to a FastAPI + PyTorch backend I deployed on Render. It runs a deep learning recommendation model trained on MovieLens data. The backend lives in a separate repo: [RecommenderSystem](https://github.com/AkinCodes/RecommenderSystem). Live at [cinemascope-api.onrender.com](https://cinemascope-api.onrender.com).

## Other projects

- [RecommenderSystem](https://github.com/AkinCodes/RecommenderSystem) — the Python backend that powers the form mode
- [MoviePosterAI](https://github.com/AkinCodes/MoviePosterAI) — AI movie poster analysis

## Author

**Akin Olusanya**

[GitHub](https://github.com/AkinCodes) · [LinkedIn](https://www.linkedin.com/in/akindeveloper) · workwithakin@gmail.com
