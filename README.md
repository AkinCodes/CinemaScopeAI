# 🎬 CinemaScopeAI (iOS App)

A SwiftUI-powered iOS app that fetches real-time AI-driven movie recommendations from a deployed machine learning API built with FastAPI and PyTorch.

This project is **purely a frontend client** designed to interface with the [CinemaScopeAI backend](https://github.com/AkinCodes/RecommenderSystem). It acts as a lightweight, visually engaging mobile interface that sends feature vectors to the ML API and renders live movie recommendations based on real-time predictions.

Built with clean MVVM architecture, URLSession, and modular SwiftUI components, the app showcases how machine learning and iOS development can seamlessly integrate in a production-ready setup.


---

## 🔗 Live Backend API

**Base URL:**  
[https://cinemascope-api.onrender.com](https://cinemascope-api.onrender.com)

**Example Endpoint:**
```http
POST /predict/
```

**Sample Payload:**
```json
{
  "continuous_features": [0.6, 0.8],
  "categorical_features": [1, 7]
}
```

Returns 5 recommended movies based on user features and prediction scores.

---

## Features

- Clean SwiftUI app with modern `async/await` networking
- Consumes a PyTorch + FastAPI ML API
- Presents real movie data (fetched from TMDB API)
- Displays titles, summaries, poster images, and scores

---

## Backend AI Model

- DLRM (Deep Learning Recommendation Model) architecture
- Trained on categorical and continuous user features
- Movie candidates fetched via TMDB API
- Scores generated using a PyTorch model, sorted by prediction closeness

🔗 **Backend Repo:**  
[GitHub - RecommenderSystem (Python/FastAPI)](https://github.com/AkinCodes/RecommenderSystem)

---

## 📱 iOS Requirements

- macOS Ventura or later
- **Xcode 15+**
- iOS Simulator or physical device (iOS 16+)

---

## 🛠 How to Run

1. Clone this repo:
   ```bash
   git clone https://github.com/AkinCodes/CinemaScopeAI.git
   ```

2. Open the project:
   ```bash
   open CinemaScopeAI.xcodeproj
   ```

3. Check `CinemaScopeAIService.swift` and ensure:
   ```swift
   let baseURL = "https://cinemascope-api.onrender.com"
   ```

4. Run the app on iPhone simulator or real device.

---

## Try It Out

After launching the app:

- App sends a `POST` request to `/predict/` with mock feature input.
- The backend returns 5 recommended movies.
- The app displays the result with posters, summaries, and scores.

---

## Screenshot

![simulator_screenshot](https://github.com/user-attachments/assets/d47ece97-8548-4fff-bb13-4732793e61c0)

---

## Built By

**Akin Olusanya**  
iOS + ML Engineer  
🔗 [LinkedIn → @akindeveloper](https://www.linkedin.com/in/akindeveloper/)
