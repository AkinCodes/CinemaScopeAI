# 🎬 CinemaScopeAI (iOS App)

CinemaScopeAI is a SwiftUI-powered iOS app that delivers **real-time AI-driven movie recommendations** via two powerful engines:
- A deployed **machine learning API** (DLRM + FastAPI + PyTorch)
- A **GPT-based movie prompt system** for natural-language recommendations

This project is also a **purely a frontend client** designed to interface with the [CinemaScopeAI backend](https://github.com/AkinCodes/RecommenderSystem). It acts as a lightweight, visually engaging mobile interface that sends feature vectors to the ML API and renders live movie recommendations based on real-time predictions.

Built with clean MVVM architecture, URLSession, and modular SwiftUI components, the app showcases how machine learning and iOS development can seamlessly integrate in a production-ready setup.

A SwiftUI-powered iOS app that fetches real-time AI-driven movie recommendations from a deployed machine learning API built with FastAPI, PyTorch, OpenAI.


---

## Two Recommendation Engines

### 1. **Manual (DLRM-based)**
Consumes a FastAPI ML backend that predicts movies based on structured user features.

- **Backend:** PyTorch + FastAPI
- **Model:** Deep Learning Recommendation Model (DLRM)
- **Input:** Categorical + continuous vectors
- **Output:** Top 5 movie recommendations

### 2. **GPT-Powered**
Let users ask for recommendations using natural language (e.g. _"Give me sci-fi thrillers like Inception"_). GPT parses the prompt and returns movie titles via the TMDB API.

- **Backend:** OpenAI GPT-4
- **Frontend:** Chat-style SwiftUI interface
- **Flow:** User → GPT prompt → TMDB fetch → Display with posters & summaries

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

- Toggle between **Manual** and **GPT** recommendation modes
- Displays movie posters, summaries, and prediction scores
- Clean SwiftUI app with modern `async/await` networking
- Consumes a PyTorch + FastAPI ML API
- Presents real movie data (fetched from TMDB API)
- Displays titles, summaries, poster images, and scores
- Real-time API integration via `URLSession`
- GPT-based chat UI with fallback handling
- .gitignore protects API keys and private schemes

---

## Backend AI Model

- DLRM (Deep Learning Recommendation Model) architecture
- Trained on categorical and continuous user features
- Movie candidates fetched via TMDB API
- Scores generated using a PyTorch model, sorted by prediction closeness

🔗 **Backend Repo:**  
[GitHub - RecommenderSystem (Python/FastAPI)](https://github.com/AkinCodes/RecommenderSystem)

---

## Architecture

- Clean MVVM structure
- Separate modules: `Cinema_Recommender` and `GPT_Recommender`
- Modular SwiftUI views
- Shared model layer

---

## 📱 iOS Requirements

- macOS Ventura or later
- **Xcode 15+**
- iOS Simulator or physical device (iOS 16+)

---

## OpenAI API Key Setup

To use the GPT-powered recommendation feature, you’ll need to provide your own OpenAI API key:
Update the GPTService.swift file directly (only for local testing):

 ```private let openAIKey = "your_openai_api_key_here" ```



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
- Type a custom prompt in **GPT mode** (e.g., "funny action movies from the 90s")
- Or switch to **Manual mode** to see recommendations from structured input
- Enjoy the top 5 movie suggestions with full metadata
- App sends a `POST` request to `/predict/` with mock feature input.
- The backend returns 5 recommended movies.
- The app displays the result with posters, summaries, and scores.

---

## Screenshot

<img src="https://github.com/user-attachments/assets/d47ece97-8548-4fff-bb13-4732793e61c0" width="300" />
<img src="https://github.com/user-attachments/assets/0fc556dd-65b4-49c9-8d13-d21c9c02572a" width="300" />


https://github.com/user-attachments/assets/09c49cf9-cc31-4fdf-aa6e-49573a228279



---

## Built By

**Akin Olusanya**  
iOS Engineer | ML Enthusiast | Full-Stack Creator  
workwithakin@gmail.com  
[LinkedIn](https://www.linkedin.com/in/akindeveloper)  
[GitHub](https://github.com/AkinCodes)
