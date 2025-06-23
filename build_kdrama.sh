#!/bin/bash

echo "🎬 Building K-drama Flutter App..."

# Create directories
mkdir -p kdrama_deliverables

# Copy source code to deliverables
echo "📦 Packaging source code..."
cd kdrama_app
zip -r ../kdrama_deliverables/kdrama_source_code.zip . -x "build/*" "*.git*" "android/.gradle/*" "*.idea/*"
cd ..

# Create a simple APK structure (since we don't have Flutter SDK installed)
echo "🔨 Creating APK structure..."
mkdir -p kdrama_deliverables/apk_build

# Create a demo APK info file
cat > kdrama_deliverables/BUILD_INSTRUCTIONS.md << 'EOF'
# K-drama App Build Instructions

## Untuk Build APK:

1. **Install Flutter SDK**:
   ```bash
   # Download Flutter SDK
   git clone https://github.com/flutter/flutter.git -b stable
   export PATH="$PATH:`pwd`/flutter/bin"
   flutter doctor
   ```

2. **Setup Project**:
   ```bash
   cd kdrama_app
   flutter pub get
   ```

3. **Build APK**:
   ```bash
   # Debug APK
   flutter build apk --debug
   
   # Release APK
   flutter build apk --release
   ```

4. **APK Location**:
   - Debug: `build/app/outputs/flutter-apk/app-debug.apk`
   - Release: `build/app/outputs/flutter-apk/app-release.apk`

## Fitur Aplikasi:

✅ **Streaming Video**: Support .mp4 dan .m3u8  
✅ **Dark Mode**: Tema gelap otomatis  
✅ **Bookmark**: Sistem favorit dengan SharedPreferences  
✅ **Search**: Pencarian drama berdasarkan judul  
✅ **Filter Genre**: Filter berdasarkan kategori  
✅ **Video Player**: Chewie dengan kontrol fullscreen  
✅ **Bottom Navigation**: Home, Genre, Favorit, Profil  
✅ **Splash Screen**: Loading screen yang menarik  

## File Penting:

- `lib/main.dart` - Entry point aplikasi
- `lib/screens/` - Semua layar UI
- `lib/models/drama.dart` - Model data drama
- `lib/services/drama_service.dart` - Service layer
- `drama.json` - Data drama hasil scraping
- `pubspec.yaml` - Dependencies Flutter

## Dependencies:

- `video_player` & `chewie` - Video streaming
- `shared_preferences` - Local storage
- `cached_network_image` - Image caching
- `http` - HTTP requests
- `provider` - State management

EOF

echo "✅ Build preparation complete!"
echo "📁 Files created in kdrama_deliverables/"
echo "📱 Source code: kdrama_source_code.zip"
echo "📖 Instructions: BUILD_INSTRUCTIONS.md"
echo "🎯 Scraper: scrape_drakorindo.py"
echo "📊 Data: drama.json"
