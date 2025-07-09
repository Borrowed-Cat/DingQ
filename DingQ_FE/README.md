# DingQ - Flutter Web Drawing App

DingQ is a modern Flutter Web application that allows users to draw freely on a canvas and receive real-time icon (dingbat) recommendations based on their drawing. The app leverages Clean Architecture, Riverpod for state management, and a similarity search API to provide an interactive and intelligent drawing experience.

---

## ✨ Features

- **Free Drawing Canvas**: Draw with your mouse; each stroke is tracked and rendered smoothly.
- **Real-time Icon Recommendations**: After each stroke, your drawing is cropped, converted to PNG, and sent to a backend API. The app displays the top 5 most similar dingbat icons with their names and similarity scores.
- **Undo & Clear**: Remove the last stroke or clear the entire canvas. Undo also updates recommendations based on the remaining strokes.
- **Responsive UI**: The layout adapts for both wide (desktop) and narrow (mobile/tablet) screens.
- **User Guidance**: Friendly empty state messages and loading indicators guide the user.
- **State Management**: All drawing and recommendation state is managed with Riverpod.
- **Clean Architecture**: The codebase is modular, testable, and easy to extend.

---

## 🏗️ Architecture Overview

DingQ follows Clean Architecture principles:

```
lib/
├── domain/         # Entities and repository interfaces
├── data/           # Data sources, repository implementations, API/image services
├── application/    # Use cases (business logic)
└── presentation/   # UI, state providers, widgets, pages
```

- **Entities**: Core data models (`Stroke`, `Dingbat`)
- **Repositories**: Abstract interfaces and concrete implementations for data access
- **Use Cases**: Application-specific business logic (add/undo/clear strokes, fetch recommendations)
- **Services**: API and image processing logic
- **Providers**: Riverpod state management for strokes and recommendations
- **Widgets**: Modular UI components (canvas, controls, recommendations, etc.)

---

## 🚀 Getting Started

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the app**
   ```bash
   flutter run -d chrome
   ```

3. **Open in your browser**
   - Visit the local address shown in your terminal (e.g., `http://localhost:xxxx`)

---

## 🖌️ How to Use

1. **Draw**: Use your mouse to draw on the canvas.
2. **Get Recommendations**: After each stroke, the app automatically sends your drawing to the backend and shows the top 5 recommended dingbat icons.
3. **Undo**: Click the Undo button to remove the last stroke. If strokes remain, recommendations update automatically.
4. **Clear**: Click the Clear button to erase all strokes and reset recommendations.
5. **Responsive Layout**: On wide screens, recommendations appear beside the canvas; on narrow screens, they appear below.

---

## 🧩 Main Components

- **DrawingCanvas**: The interactive drawing area.
- **FloatingUndoButton / FloatingClearButton**: Controls for undoing or clearing strokes.
- **RecommendedDingbatsDisplay**: Shows recommended icons, their names, and similarity scores.
- **DingbatGrid**: Displays all available dingbat icons.
- **StrokeCounter**: Shows the current number of strokes.
- **Providers**: `strokesProvider`, `recommendedDingbatsProvider` manage app state.

---

## 🔗 API Integration

The app integrates with a similarity search API to provide real-time icon recommendations:

- **Method**: POST with multipart/form-data
- **Payload**: Cropped PNG image of the current drawing
- **Response**: JSON with top 5 similar dingbat icons, their names, scores, and SVG URLs

Example response format:
```json
{
  "processing_time": 0.21,
  "total_results": 5,
  "top100": [
    {
      "label": "icon_name",
      "score": 0.7822,
      "url": "https://example.com/icon.svg"
    }
    // ... more results
  ]
}
```

---

## 📁 Project Structure

```
lib/
├── domain/
│   ├── entities/           # stroke.dart, dingbat.dart, etc.
│   └── repositories/       # Abstract repository interfaces
├── data/
│   ├── datasources/        # Data source implementations
│   ├── repositories/       # Repository implementations
│   └── services/           # api_service.dart, image_service.dart
├── application/
│   └── usecases/           # Business logic (add/undo/clear strokes, etc.)
└── presentation/
    ├── providers/          # Riverpod state providers
    ├── widgets/            # UI components (canvas, controls, recommendations, etc.)
    └── pages/              # Main page (home_page.dart)
```

---

## 🛠️ Tech Stack

- **Flutter Web**
- **Riverpod** (state management)
- **CustomPainter** (drawing)
- **HTTP** (API calls)
- **flutter_svg** (SVG rendering)
- **Clean Architecture**

---

## 🧪 Testing

Run all tests:
```bash
flutter test
```

---

## 📝 License

This project is licensed under the MIT License.

---

**Enjoy drawing and discovering new dingbats with DingQ!**
