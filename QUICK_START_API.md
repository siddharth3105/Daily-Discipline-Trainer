# 🚀 Quick Start - API Setup (5 Minutes)

## TL;DR
Two APIs need keys, two work immediately. Total setup time: ~5 minutes.

---

## ✅ Already Working (No Setup)

### 1. ZenQuotes - Daily Motivation
- **Status**: ✅ Working now
- **Location**: Settings screen
- **Action**: None needed

### 2. Open-Meteo - Weather Data
- **Status**: ✅ Working now
- **Location**: Ready for home screen
- **Action**: None needed

---

## 🔑 Need API Keys (5 min each)

### 1. ExerciseDB - Exercise Library

**Quick Setup**:
```bash
1. Go to: https://rapidapi.com/justin-WFnsXH_t6/api/exercisedb
2. Sign up (free)
3. Subscribe to "Basic" plan (FREE)
4. Copy your API key
5. Open: lib/services/exercise_api_service.dart
6. Line 6: Replace 'YOUR_EXERCISEDB_API_KEY' with your key
7. Save and rebuild app
```

**Test**: Settings → Exercise Library

---

### 2. Nutritionix - Food Database

**Quick Setup**:
```bash
1. Go to: https://www.nutritionix.com/business/api
2. Click "Get Your API Key"
3. Fill form (select "Personal/Non-Commercial")
4. Copy App ID and API Key
5. Open: lib/services/nutrition_api_service.dart
6. Line 6: Replace 'YOUR_NUTRITIONIX_APP_ID' with your App ID
7. Line 7: Replace 'YOUR_NUTRITIONIX_API_KEY' with your API Key
8. Save and rebuild app
```

**Test**: Settings → Nutrition Database

---

## 📱 Where to Find Features

After setup, find new features in Settings:

```
Settings Screen
├── 📅 MY CUSTOM PLANS (existing)
├── 🌐 API FEATURES (new section)
│   ├── 🏋️ EXERCISE LIBRARY (1300+ exercises)
│   ├── 🍎 NUTRITION DATABASE (800k+ foods)
│   └── 💭 QUOTE OF THE DAY (auto-displays)
├── 👤 MY PROFILE (existing)
└── ... (rest of settings)
```

---

## ⚡ Quick Test

After adding API keys:

1. **Exercise Library**:
   - Settings → Exercise Library
   - Should see exercises for "chest"
   - Try searching "push up"

2. **Nutrition Database**:
   - Settings → Nutrition Database
   - Search "apple"
   - Should see results
   - Tap one to view nutrition

3. **Quote of Day**:
   - Open Settings
   - Scroll to "Quote of the Day" card
   - Should see a motivational quote

---

## 🆘 Troubleshooting

### "Failed to load exercises"
→ Check ExerciseDB API key is correct (no spaces)

### "Failed to search food"
→ Check both Nutritionix App ID and API Key are correct

### "No quote found"
→ Normal - app shows fallback quote

### Still not working?
1. Rebuild the app completely
2. Check internet connection
3. Verify API keys have no extra spaces
4. Check API service status on their websites

---

## 💡 Pro Tips

1. **Don't want to set up APIs?**
   - App works great without them
   - They're bonus features
   - Use built-in exercises and AI food scanner

2. **Rate Limits**:
   - ExerciseDB: 100 requests/day (plenty for browsing)
   - Nutritionix: 200 requests/day (plenty for food logging)
   - Don't worry about hitting limits with normal use

3. **Security**:
   - Keep API keys private
   - Don't commit to public repos
   - Can regenerate if needed

---

## 📊 What You Get

### With API Keys:
- ✅ 1300+ exercises with GIFs
- ✅ 800,000+ food database
- ✅ Daily motivational quotes
- ✅ Weather data
- ✅ All existing features

### Without API Keys:
- ✅ 14 animated exercises
- ✅ Custom workout plans
- ✅ Custom diet plans
- ✅ AI food scanner
- ✅ Progress tracking
- ✅ Gamification
- ✅ Smartwatch sync
- ✅ All core features

**Bottom line**: APIs are optional enhancements!

---

## 🎯 Next Steps

1. ✅ Set up API keys (5 min each)
2. ✅ Test features
3. ✅ Start using exercise library
4. ✅ Search foods for better tracking
5. ✅ Get daily motivation

**Total time**: 10-15 minutes for full setup

---

Need detailed instructions? See [API_SETUP_GUIDE.md](API_SETUP_GUIDE.md)

**Happy training! 💪🔥**
