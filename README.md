# 🔥 Daily Discipline Trainer

Complete fitness companion app built with Flutter - workouts, AI food scanner, smartwatch sync, and progress tracking.

## ✨ Features

- **14 Animated Exercises** - Form guides for HIIT, strength, bodyweight, and flexibility
- **AI Food Scanner** - Photo → instant nutrition data powered by Claude
- **Smartwatch Sync** - Apple Watch + Wear OS support via HealthKit/Health Connect
- **Smart Reminders** - Workout, water, meal, and streak protection notifications
- **Progress Tracking** - 35-day heatmap, body stats, and achievement badges
- **Gamification** - Streaks, points, multipliers, and unlockable badges
- **Works Offline** - No internet needed (except AI scanner)
- **Cross-Platform** - iOS, Android, and Web

## 🚀 Live Demo

**Web App:** [https://siddharth3105.github.io/Daily-Discipline-Trainer/](https://siddharth3105.github.io/Daily-Discipline-Trainer/)

## 📱 Installation

### Web (iPhone/Android)
1. Visit the live demo URL
2. Tap Share → "Add to Home Screen"
3. App icon appears on your home screen!

### Android APK
Coming soon...

### iOS TestFlight
Coming soon...

## 🛠️ Development Setup

```bash
# Clone the repository
git clone https://github.com/siddharth3105/Daily-Discipline-Trainer.git
cd Daily-Discipline-Trainer

# Install dependencies
flutter pub get

# Run on your device
flutter run

# Build for web
flutter build web --release --base-href "/Daily-Discipline-Trainer/"
```

## 📦 Tech Stack

- **Framework:** Flutter 3.22.0
- **State Management:** Provider
- **Local Storage:** SharedPreferences
- **Charts:** fl_chart
- **Notifications:** flutter_local_notifications
- **Health Integration:** health package
- **AI:** Anthropic Claude API

## 🎯 Project Structure

```
lib/
├── screens/          # UI screens (home, workout, diet, progress, settings)
├── widgets/          # Reusable widgets (animations, shared components)
├── services/         # Platform services (health, notifications, storage, AI)
├── providers/        # State management
├── models/           # Data models
├── data/             # Static data (exercises, diet plans, badges)
└── theme/            # App colors and styling
```

## 🔧 Configuration

### AI Food Scanner
To enable the AI food scanner, add your Anthropic API key:

```dart
// lib/services/ai_food_service.dart
static const _apiKey = 'YOUR_ANTHROPIC_API_KEY';
```

Get your API key at: [https://console.anthropic.com/](https://console.anthropic.com/)

## 📸 Screenshots

Coming soon...

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is open source and available under the MIT License.

## 👨‍💻 Author

**Siddharth Parmar**
- GitHub: [@siddharth3105](https://github.com/siddharth3105)

## 🙏 Acknowledgments

- Built with Flutter
- AI powered by Anthropic Claude
- Icons from Material Design
- Animations custom-built with CustomPainter

---

Made with 🔥 and discipline
