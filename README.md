# Daily Discipline Trainer

A Flutter fitness app I built to track workouts, diet, and progress. Started as a personal project to stay consistent with training.

Live demo: https://siddharth3105.github.io/Daily-Discipline-Trainer/

## What it does

- 14 animated exercises with form guides (HIIT, strength, bodyweight, flexibility)
- AI food scanner using Claude API - snap a photo, get nutrition info
- Syncs with Apple Watch and Wear OS via HealthKit/Health Connect
- Smart reminders for workouts, water, meals
- Progress tracking with 35-day heatmap and stats
- Gamification with streaks, points, badges
- Works offline except for the AI scanner
- Runs on iOS, Android, and Web

## Running locally

```bash
git clone https://github.com/siddharth3105/Daily-Discipline-Trainer.git
cd Daily-Discipline-Trainer
flutter pub get
flutter run
For web build:

flutter build web --release --base-href "/Daily-Discipline-Trainer/"
Stack
Flutter 3.22.0
Provider for state management
SharedPreferences for local storage
fl_chart for graphs
flutter_local_notifications
health package for smartwatch integration
Anthropic Claude API for food recognition
Project structure
lib/
├── screens/      # Main UI screens
├── widgets/      # Reusable components and animations
├── services/     # Health, notifications, storage, AI
├── providers/    # State management
├── models/       # Data models
├── data/         # Exercise data, diet plans, badges
└── theme/        # Colors and styling
Setup notes
To use the AI food scanner, add your Anthropic API key in 
ai_food_service.dart
:

static const _apiKey = 'YOUR_ANTHROPIC_API_KEY';
Get one at https://console.anthropic.com/

Contributing
Feel free to open issues or PRs if you find bugs or have ideas.

License
MIT

Built with Flutter | Suraj Shrivas (@siddharth3105)
