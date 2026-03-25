# 💪 Daily Discipline Trainer

> AI-Powered Fitness & Nutrition Tracking App - Built with Flutter

[![Deploy Web](https://github.com/siddharth3105/Daily-Discipline-Trainer/actions/workflows/deploy-web.yml/badge.svg)](https://github.com/siddharth3105/Daily-Discipline-Trainer/actions/workflows/deploy-web.yml)
[![Build Release](https://github.com/siddharth3105/Daily-Discipline-Trainer/actions/workflows/build-release.yml/badge.svg)](https://github.com/siddharth3105/Daily-Discipline-Trainer/actions/workflows/build-release.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.24.0-blue.svg)](https://flutter.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A complete fitness tracking app with AI-powered coaching, 1300+ exercises, 800k+ food database, and smart health integration - all powered by free APIs!

[🌐 Live Demo](https://siddharth3105.github.io/Daily-Discipline-Trainer/) | [📱 Download APK](https://github.com/siddharth3105/Daily-Discipline-Trainer/releases) | [📚 Documentation](./ALL_APIS_COMPLETE.md)

---

## ✨ Features

### 🤖 AI-Powered Features
- **AI Fitness Coach** - Chat with AI for personalized advice (Groq + Gemini)
- **AI Workout Generator** - Generate custom workout plans based on your goals
- **AI Diet Generator** - Create personalized meal plans
- **AI Food Scanner** - Scan food photos for instant nutrition data

### 🏋️ Exercise Features
- **1300+ Exercise Library** - Professional GIF demonstrations
- **Real Human Animations** - All 14 built-in exercises with proper form
- **Search by Body Part** - Chest, back, legs, arms, etc.
- **Search by Equipment** - Barbell, dumbbell, bodyweight, etc.

### 🍎 Nutrition Features
- **800k+ Food Database** - Search any food for complete nutrition
- **Photo Food Scanner** - Take a photo, get instant nutrition data
- **Meal Logging** - Track calories, protein, carbs, fat
- **Custom Diet Plans** - Create your own meal plans

### 📊 Tracking & Progress
- **35-Day Heatmap** - Visual progress tracking
- **Body Stats** - Weight, BMI, measurements
- **Workout History** - Complete exercise logs
- **Gamification** - Points, streaks, badges

### ⌚ Health Integration
- **Apple Watch Sync** - Steps, heart rate, calories, sleep
- **Wear OS Sync** - Android smartwatch integration
- **Health Platform** - HealthKit (iOS) & Health Connect (Android)

### 🎯 Smart Features
- **Custom Plans** - Create your own workouts and diets
- **Weekly Schedules** - Mix auto-generated and custom plans
- **Smart Reminders** - Workout, water, meals, motivation
- **Daily Quotes** - Motivational messages

---

## 🚀 Quick Start

### Prerequisites
- Flutter 3.24.0 or higher
- Dart 3.0.0 or higher
- Android Studio / Xcode (for mobile)
- Chrome (for web)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/YOUR_USERNAME/daily-discipline-trainer.git
cd daily-discipline-trainer
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
# Web
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios
```

---

## 🔑 API Keys Setup

This app uses 4 free APIs. Get your keys here:

### 1. Groq AI (AI Coach)
- **Get Key**: https://console.groq.com/
- **Free Tier**: 14,400 requests/day
- **Add to**: `lib/services/groq_ai_service.dart` line 7

### 2. Gemini AI (AI Coach + Food Scanner)
- **Get Key**: https://makersuite.google.com/app/apikey
- **Free Tier**: 60 requests/minute
- **Add to**: 
  - `lib/services/gemini_ai_service.dart` line 7
  - `lib/services/ai_food_service.dart` line 10

### 3. ExerciseDB (Exercise Library)
- **Get Key**: https://rapidapi.com/justin-WFnsXH_t6/api/exercisedb
- **Free Tier**: 100 requests/day
- **Add to**: `lib/services/exercise_api_service.dart` line 7

### 4. FatSecret (Nutrition Database)
- **Get Key**: https://platform.fatsecret.com/api/
- **Free Tier**: 5,000 requests/day
- **Add to**: `lib/services/nutrition_api_service.dart` lines 6-7

See [GET_FREE_API_KEYS.md](./GET_FREE_API_KEYS.md) for detailed setup instructions.

---

## 📱 Deployment

### Web (GitHub Pages)
```bash
flutter build web --release
gh-pages -d build/web
```

Or use GitHub Actions (automatic on push to main)

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

See [GITHUB_DEPLOYMENT_GUIDE.md](./GITHUB_DEPLOYMENT_GUIDE.md) for complete deployment instructions.

---

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # Main app widget
├── models/                   # Data models
├── providers/                # State management
├── screens/                  # UI screens
│   ├── home_screen.dart
│   ├── workout_screen.dart
│   ├── diet_screen.dart
│   ├── progress_screen.dart
│   ├── settings_screen.dart
│   ├── ai_coach_screen.dart
│   ├── exercise_browser_screen.dart
│   └── nutrition_search_screen.dart
├── services/                 # API services
│   ├── groq_ai_service.dart
│   ├── gemini_ai_service.dart
│   ├── exercise_api_service.dart
│   ├── nutrition_api_service.dart
│   ├── ai_food_service.dart
│   ├── health_service.dart
│   └── notification_service.dart
├── widgets/                  # Reusable widgets
└── theme/                    # App theme
```

---

## 💰 Cost Breakdown

| Feature | Monthly Value | Actual Cost |
|---------|---------------|-------------|
| AI Fitness Coach | $20-30 | $0 |
| Exercise Library | $10-20 | $0 |
| Nutrition Database | $10-15 | $0 |
| Food Scanner | $10-15 | $0 |
| Custom Plans | $5-10 | $0 |
| Health Sync | $5-10 | $0 |
| **TOTAL** | **$60-100** | **$0** |

**ROI**: Infinite! 🚀

---

## 🛠️ Built With

- [Flutter](https://flutter.dev/) - UI framework
- [Provider](https://pub.dev/packages/provider) - State management
- [Groq AI](https://groq.com/) - Ultra-fast AI inference
- [Google Gemini](https://ai.google.dev/) - Google's AI
- [ExerciseDB](https://rapidapi.com/justin-WFnsXH_t6/api/exercisedb) - Exercise database
- [FatSecret](https://platform.fatsecret.com/) - Nutrition database
- [Health](https://pub.dev/packages/health) - Health data integration
- [FL Chart](https://pub.dev/packages/fl_chart) - Beautiful charts

---

## 📚 Documentation

- [Complete API Setup Guide](./ALL_APIS_COMPLETE.md)
- [Get Free API Keys](./GET_FREE_API_KEYS.md)
- [GitHub Deployment Guide](./GITHUB_DEPLOYMENT_GUIDE.md)
- [Food Scanner Guide](./FOOD_SCANNER_GUIDE.md)
- [AI Features Guide](./GOOGLE_GROQ_API_GUIDE.md)
- [Custom Plans Guide](./CUSTOM_PLANS_GUIDE.md)

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Groq** for ultra-fast AI inference
- **Google** for Gemini AI
- **ExerciseDB** for comprehensive exercise database
- **FatSecret** for nutrition data
- **Flutter** team for amazing framework
- All open-source contributors

---

## 📞 Support

- 🐛 Issues: [GitHub Issues](https://github.com/YOUR_USERNAME/daily-discipline-trainer/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/YOUR_USERNAME/daily-discipline-trainer/discussions)

---

## ⭐ Star History

If you find this project useful, please consider giving it a star!

---

**Made with ❤️ and Flutter**

**Now go build that discipline!** 💪🔥
