# 🌐 API Setup Guide

This guide will help you set up the free API integrations for the Daily Discipline Trainer app.

## Overview of APIs

### 1. ✅ ZenQuotes API (Already Working)
- **Status**: No API key needed
- **Features**: Motivational quotes
- **Limits**: 5 requests per 30 seconds
- **Cost**: Completely FREE

### 2. ✅ Open-Meteo Weather API (Already Working)
- **Status**: No API key needed
- **Features**: Weather data and forecasts
- **Limits**: No limits for non-commercial use
- **Cost**: Completely FREE

### 3. 🔑 ExerciseDB API (Requires API Key)
- **Features**: 1300+ exercises with GIFs and instructions
- **Limits**: 100 requests/day (free tier)
- **Cost**: FREE tier available

### 4. 🔑 Nutritionix API (Requires API Key)
- **Features**: 800,000+ food database
- **Limits**: 200 requests/day (free tier)
- **Cost**: FREE tier available

---

## Setup Instructions

### ExerciseDB API Setup

1. **Get Your Free API Key**
   - Go to: https://rapidapi.com/justin-WFnsXH_t6/api/exercisedb
   - Click "Sign Up" (free account)
   - Subscribe to the "Basic" plan (FREE - 100 requests/day)
   - Copy your API key from the dashboard

2. **Add API Key to App**
   - Open `lib/services/exercise_api_service.dart`
   - Find line 6: `static const _apiKey = 'YOUR_EXERCISEDB_API_KEY';`
   - Replace `YOUR_EXERCISEDB_API_KEY` with your actual API key
   - Example: `static const _apiKey = 'abc123xyz456';`

3. **Test It**
   - Run the app
   - Go to Settings → Exercise Library
   - Browse exercises by body part

---

### Nutritionix API Setup

1. **Get Your Free API Credentials**
   - Go to: https://www.nutritionix.com/business/api
   - Click "Get Your API Key"
   - Fill out the form (select "Personal/Non-Commercial")
   - You'll receive:
     - App ID
     - API Key

2. **Add Credentials to App**
   - Open `lib/services/nutrition_api_service.dart`
   - Find lines 6-7:
     ```dart
     static const _appId = 'YOUR_NUTRITIONIX_APP_ID';
     static const _apiKey = 'YOUR_NUTRITIONIX_API_KEY';
     ```
   - Replace with your actual credentials
   - Example:
     ```dart
     static const _appId = '12345678';
     static const _apiKey = 'abc123xyz456def789';
     ```

3. **Test It**
   - Run the app
   - Go to Settings → Nutrition Database
   - Search for any food (e.g., "chicken breast")

---

## API Features in the App

### Exercise Library 🏋️
**Location**: Settings → Exercise Library

**Features**:
- Browse 1300+ exercises
- Filter by body part (chest, back, legs, etc.)
- Search by exercise name
- View animated GIFs
- Read detailed instructions
- See target muscles and equipment needed

**Usage Tips**:
- Use filters to find exercises for specific muscle groups
- Search for exercises you know by name
- Save exercises to your custom workout plans

---

### Nutrition Database 🍎
**Location**: Settings → Nutrition Database

**Features**:
- Search 800,000+ foods
- Get detailed nutrition data
- View macros (protein, carbs, fat)
- See micronutrients (fiber, sugar, sodium, etc.)
- Add foods directly to your food log

**Usage Tips**:
- Be specific in searches: "chicken breast 100g" vs just "chicken"
- Works with branded foods too
- Automatically adds to your daily food log

---

### Quote of the Day 💭
**Location**: Settings (displays automatically)

**Features**:
- Daily motivational quotes
- Fitness and discipline themed
- Updates automatically
- No setup required

---

### Weather-Based Recommendations 🌤️
**Location**: Home screen (coming soon)

**Features**:
- Current weather conditions
- 7-day forecast
- Workout recommendations based on weather
- Temperature and precipitation data
- No setup required

---

## Rate Limits & Best Practices

### ExerciseDB (100 requests/day)
- **What counts as a request**:
  - Loading exercises by body part
  - Searching for exercises
  - Getting exercise details
- **Tips**:
  - Results are cached in the app
  - Browse efficiently
  - ~10-15 browsing sessions per day

### Nutritionix (200 requests/day)
- **What counts as a request**:
  - Searching for food
  - Getting nutrition details
- **Tips**:
  - Be specific in searches
  - Use the AI food scanner for photos
  - ~20-30 food searches per day

### ZenQuotes (5 requests per 30 seconds)
- Automatically managed by the app
- Quotes are cached
- No action needed

### Open-Meteo (Unlimited)
- No rate limits
- Use freely
- No action needed

---

## Troubleshooting

### "Failed to load exercises"
1. Check your ExerciseDB API key is correct
2. Verify you're subscribed to the free plan on RapidAPI
3. Check your internet connection
4. Wait a few minutes if you hit the rate limit

### "Failed to search food"
1. Check your Nutritionix App ID and API Key are correct
2. Verify your account is active
3. Check your internet connection
4. Wait if you hit the rate limit (resets daily)

### "No quote found"
- This is normal - the app will show a fallback quote
- Check your internet connection
- The API might be temporarily down

### General Issues
1. **Check API keys are correct** (no extra spaces)
2. **Rebuild the app** after adding API keys
3. **Check internet connection**
4. **Verify API service status** on their websites

---

## Cost Breakdown

| API | Free Tier | Paid Plans | Recommended |
|-----|-----------|------------|-------------|
| ExerciseDB | 100 req/day | $10/mo for 10k | Free tier sufficient |
| Nutritionix | 200 req/day | $50/mo for 50k | Free tier sufficient |
| ZenQuotes | Unlimited* | N/A | Always free |
| Open-Meteo | Unlimited | N/A | Always free |

*5 requests per 30 seconds

**Total Cost**: $0/month for typical usage

---

## Alternative: Use Without API Keys

If you don't want to set up API keys, the app still works great:

✅ **What still works**:
- All 14 built-in animated exercises
- Custom workout and diet plans
- AI food scanner (uses Claude API)
- Progress tracking
- Gamification and badges
- Smartwatch sync
- Notifications
- Quote of the day (with fallback quotes)
- Weather recommendations (Open-Meteo)

❌ **What won't work**:
- Exercise library browsing (1300+ exercises)
- Nutrition database search (800k+ foods)

The app is fully functional without these APIs - they're bonus features!

---

## Security Notes

⚠️ **Important**:
- Never commit API keys to public repositories
- Keep your API keys private
- Don't share your keys with others
- Regenerate keys if compromised

For production apps, consider:
- Using environment variables
- Backend proxy for API calls
- Key rotation policies

---

## Support

If you need help:
1. Check the troubleshooting section above
2. Verify API service status on provider websites
3. Review API documentation:
   - ExerciseDB: https://rapidapi.com/justin-WFnsXH_t6/api/exercisedb
   - Nutritionix: https://docs.nutritionix.com/
   - ZenQuotes: https://zenquotes.io/
   - Open-Meteo: https://open-meteo.com/

---

**Happy training! 💪🔥**
