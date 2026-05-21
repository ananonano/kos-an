# Quick Start Guide - Kos Terpadu

Panduan cepat untuk menjalankan aplikasi Kos Terpadu dalam 5 menit.

## ⚡ Prerequisites

- Flutter SDK installed
- Android Studio / VS Code
- Firebase account
- Backend API running

## 🚀 Quick Setup

### 1. Clone & Install

```bash
# Clone repository
git clone <repository-url>
cd kos_terpadu

# Install dependencies
flutter pub get
```

### 2. Firebase Setup (Minimal)

1. Create Firebase project
2. Download `google-services.json`
3. Place in `android/app/google-services.json`
4. Enable Authentication, Firestore, Storage

### 3. Configure API

Edit `lib/core/config/app_config.dart`:
```dart
static const String apiBaseUrl = 'http://10.0.2.2:3000/api';
```

### 4. Run App

```bash
flutter run
```

## 📱 Test Login

**Admin:**
- Email: `admin@kosterpadu.com`
- Password: `admin123`

**Penghuni:**
- Email: `user@kosterpadu.com`
- Password: `user123`

## 🎯 Main Features to Test

1. **Login** → Home Dashboard
2. **Kamar List** → View rooms
3. **Keluhan** → Create complaint (realtime)
4. **Chat** → Send message (realtime)

## 📚 Full Documentation

For detailed setup, see:
- [SETUP_GUIDE.md](SETUP_GUIDE.md) - Complete setup
- [README.md](README.md) - Full documentation
- [ARCHITECTURE.md](ARCHITECTURE.md) - Architecture details

## 🐛 Common Issues

### Firebase not connecting
```bash
flutter clean
flutter pub get
flutter run
```

### API not reachable
- Check backend is running
- Use `10.0.2.2` for Android emulator
- Use `localhost` for iOS simulator

### Build errors
```bash
flutter doctor
flutter clean
flutter pub get
```

## 💡 Tips

- Use hot reload: Press `r` in terminal
- Use hot restart: Press `R` in terminal
- Check logs: `flutter logs`
- Debug mode: Run from IDE

## 🆘 Need Help?

- Check [SETUP_GUIDE.md](SETUP_GUIDE.md)
- Open issue on GitHub
- Email: support@kosterpadu.com

---

Happy coding! 🎉
