# 🚀 GitHub Deployment Guide

## Complete Guide to Deploy Your App via GitHub

---

## 📋 What We'll Deploy

Your Daily Discipline Trainer can be deployed to:
1. **GitHub Pages** (Web version - FREE)
2. **Google Play Store** (Android)
3. **Apple App Store** (iOS)

This guide covers all three!

---

## 🌐 Option 1: Deploy Web Version to GitHub Pages (FREE & Easy)

### Step 1: Prepare Your Repository

1. **Initialize Git** (if not already done):
```bash
git init
git add .
git commit -m "Initial commit - Daily Discipline Trainer with all APIs"
```

2. **Create GitHub Repository**:
   - Go to https://github.com/new
   - Name: `daily-discipline-trainer`
   - Description: "AI-Powered Fitness & Nutrition Tracking App"
   - Public or Private (your choice)
   - Don't initialize with README (we have one)
   - Click "Create repository"

3. **Connect and Push**:
```bash
git remote add origin https://github.com/YOUR_USERNAME/daily-discipline-trainer.git
git branch -M main
git push -u origin main
```

### Step 2: Build Web Version

```bash
flutter build web --release
```

This creates optimized files in `build/web/`

### Step 3: Deploy to GitHub Pages

**Option A: Using GitHub Actions (Automatic)**

I'll create a workflow file that automatically deploys on every push!

**Option B: Manual Deployment**

```bash
# Install gh-pages package (one time)
npm install -g gh-pages

# Deploy
gh-pages -d build/web
```

Your app will be live at:
```
https://YOUR_USERNAME.github.io/daily-discipline-trainer/
```

---

## 📱 Option 2: Deploy Android App to Google Play Store

### Step 1: Prepare Android Build

1. **Update App Info** in `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        applicationId "com.dailydiscipline.trainer"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

2. **Create Keystore** (for signing):
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

3. **Configure Signing** in `android/key.properties`:
```properties
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=upload
storeFile=C:/Users/YOUR_USER/upload-keystore.jks
```

4. **Build Release APK**:
```bash
flutter build apk --release
```

Or **Build App Bundle** (recommended):
```bash
flutter build appbundle --release
```

### Step 2: Upload to Google Play Console

1. Go to https://play.google.com/console
2. Create new app
3. Fill in app details
4. Upload APK/Bundle from `build/app/outputs/`
5. Submit for review

---

## 🍎 Option 3: Deploy iOS App to Apple App Store

### Step 1: Prepare iOS Build

1. **Update App Info** in `ios/Runner/Info.plist`

2. **Open in Xcode**:
```bash
open ios/Runner.xcworkspace
```

3. **Configure Signing**:
   - Select Runner in Xcode
   - Go to Signing & Capabilities
   - Select your Team
   - Set Bundle Identifier

4. **Build Archive**:
```bash
flutter build ios --release
```

### Step 2: Upload to App Store Connect

1. Open Xcode
2. Product → Archive
3. Distribute App
4. Upload to App Store Connect
5. Submit for review

---

## 🤖 Automatic Deployment with GitHub Actions

I'll create workflows for automatic deployment!

### What GitHub Actions Will Do:
1. **On every push to main**:
   - Build web version
   - Deploy to GitHub Pages
   - Run tests

2. **On version tag** (e.g., v1.0.0):
   - Build Android APK/Bundle
   - Build iOS IPA
   - Create GitHub Release
   - Attach build files

---

## 🔐 Securing Your API Keys

**IMPORTANT**: Never commit API keys to public repositories!

### Option 1: Environment Variables (Recommended)

1. **Create `.env` file** (add to .gitignore):
```env
GROQ_API_KEY=your_groq_key_here
GEMINI_API_KEY=your_gemini_key_here
EXERCISEDB_API_KEY=your_exercisedb_key_here
FATSECRET_CLIENT_ID=your_fatsecret_id_here
FATSECRET_CLIENT_SECRET=your_fatsecret_secret_here
```

2. **Add to .gitignore**:
```
.env
*.env
```

3. **Use flutter_dotenv package** to load keys at runtime

### Option 2: GitHub Secrets (For CI/CD)

1. Go to your repo → Settings → Secrets and variables → Actions
2. Add each API key as a secret
3. Reference in GitHub Actions workflows

### Option 3: Keep Keys in Code (For Private Repos Only)

If your repo is private, you can keep keys in code (current setup).

---

## 📦 What to Commit

### ✅ DO Commit:
- All source code (`lib/`, `android/`, `ios/`, `web/`)
- Configuration files (`pubspec.yaml`, `analysis_options.yaml`)
- Documentation (all `.md` files)
- Assets (if any)
- `.gitignore`

### ❌ DON'T Commit:
- `build/` folder
- `.dart_tool/` folder
- `.idea/` folder
- `*.iml` files
- API keys (if public repo)
- `android/key.properties`
- `*.jks` keystore files

---

## 🎯 Quick Deployment Commands

### Deploy Web to GitHub Pages:
```bash
# Build
flutter build web --release

# Deploy (if using gh-pages)
gh-pages -d build/web
```

### Build Android:
```bash
# APK
flutter build apk --release

# App Bundle (recommended)
flutter build appbundle --release
```

### Build iOS:
```bash
flutter build ios --release
```

---

## 🌟 Recommended Workflow

### For Development:
```bash
git checkout -b feature/new-feature
# Make changes
git add .
git commit -m "Add new feature"
git push origin feature/new-feature
# Create Pull Request on GitHub
```

### For Release:
```bash
# Update version in pubspec.yaml
# version: 1.0.1+2

git add .
git commit -m "Release v1.0.1"
git tag v1.0.1
git push origin main --tags
```

GitHub Actions will automatically:
- Build web version
- Deploy to GitHub Pages
- Create release with APK/Bundle

---

## 📊 Deployment Checklist

### Before First Deployment:
- [ ] Update app name and description
- [ ] Add app icon
- [ ] Add splash screen
- [ ] Test all features
- [ ] Check API keys are working
- [ ] Update version number
- [ ] Write release notes

### For Web Deployment:
- [ ] Build web version
- [ ] Test locally (`flutter run -d chrome`)
- [ ] Deploy to GitHub Pages
- [ ] Test live site
- [ ] Share URL

### For Android Deployment:
- [ ] Create keystore
- [ ] Configure signing
- [ ] Build release APK/Bundle
- [ ] Test on real device
- [ ] Upload to Play Console
- [ ] Submit for review

### For iOS Deployment:
- [ ] Configure signing in Xcode
- [ ] Build archive
- [ ] Test on real device
- [ ] Upload to App Store Connect
- [ ] Submit for review

---

## 🔧 Troubleshooting

### Web Build Issues:
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build web --release
```

### Android Build Issues:
```bash
# Clean
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --release
```

### iOS Build Issues:
```bash
# Clean
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
flutter build ios --release
```

---

## 🎉 After Deployment

### Web Version:
- Share your GitHub Pages URL
- Add to your portfolio
- Share on social media

### Mobile Apps:
- Wait for review (1-7 days)
- Respond to any review feedback
- Celebrate when approved! 🎊

---

## 📱 Your App URLs

After deployment, your app will be available at:

**Web**: `https://YOUR_USERNAME.github.io/daily-discipline-trainer/`

**Android**: `https://play.google.com/store/apps/details?id=com.dailydiscipline.trainer`

**iOS**: `https://apps.apple.com/app/daily-discipline-trainer/idXXXXXXXXX`

---

## 💡 Pro Tips

1. **Use GitHub Releases** for version management
2. **Enable GitHub Pages** in repo settings
3. **Add status badges** to README
4. **Set up CI/CD** with GitHub Actions
5. **Use semantic versioning** (1.0.0, 1.0.1, etc.)
6. **Write good commit messages**
7. **Tag releases** for easy tracking
8. **Keep a CHANGELOG.md**

---

## 🚀 Ready to Deploy?

Let me know which deployment you want to do first:
1. **Web (GitHub Pages)** - Easiest, 5 minutes
2. **Android (Play Store)** - Medium, 1-2 hours
3. **iOS (App Store)** - Advanced, 2-3 hours

I'll guide you through step by step! 🎯
