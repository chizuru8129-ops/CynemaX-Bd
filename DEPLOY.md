# CynemaX Bd — Deploy Guide
**Developer:** Shouko Nishimiya  
**API Backend:** https://web-production-61c05b.up.railway.app  

---

## Netlify তে Deploy করার Steps

### Option 1 — Manual (Drag & Drop, সহজ)

```bash
# Step 1: Flutter web build করো
flutter build web --release --dart-define=WEB_BUILD=true

# Step 2: build/web folder টা Netlify তে drag & drop করো
# https://app.netlify.com/drop
```

### Option 2 — GitHub Connect (Auto Deploy)

1. এই project GitHub এ push করো
2. Netlify → "New site from Git" → repo select করো
3. Build settings:
   - **Build command:** `flutter build web --release --dart-define=WEB_BUILD=true`
   - **Publish directory:** `build/web`
4. Deploy!

---

## Railway API

Base URL: `https://web-production-61c05b.up.railway.app`

Config file: `lib/core/config/app_config.dart`

**Important:** Railway backend এ CORS enable করতে হবে।  
`api.py` তে এটা add করো:

```python
from flask_cors import CORS
# অথবা যদি FastAPI হয়:
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Netlify domain দিলে আরো secure
    allow_methods=["*"],
    allow_headers=["*"],
)
```

---

## Flutter Web Support Enable করা

যদি project এ web support না থাকে:

```bash
flutter create --platforms=web .
flutter run -d chrome  # test করতে
```

---

## File Changes Summary

| File | Change |
|------|--------|
| `pubspec.yaml` | name → `cynemaX`, description updated |
| `android/app/src/main/AndroidManifest.xml` | label → `CynemaX Bd` |
| `android/app/build.gradle.kts` | applicationId → `com.shouko.cynemaXbd` |
| `assets/icon/icon.svg` | নতুন CynemaX Bd লোগো |
| `assets/icon/logo_app.svg` | same নতুন লোগো |
| `lib/core/config/app_config.dart` | Railway API config (নতুন file) |
| `netlify.toml` | Netlify deploy config (নতুন file) |
