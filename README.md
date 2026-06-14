# MoodLoom

> Track your mood, weave your wellness.

MoodLoom is an offline-first Flutter mood-tracking and wellness journal. Log how you feel, write journal entries, and watch patterns emerge through rich insights — with optional cloud sync via Supabase. It goes well beyond a simple tracker, adding AI-assisted sentiment analysis, face-based mood detection, dream journaling, breathing exercises, mood prediction, time capsules, achievements, and an app lock for privacy.





https://github.com/user-attachments/assets/6ed23629-0ba0-405a-baa9-4301ba07151f


## ✨ Features

- **Mood Logging** — quick 1–5 mood entries with emoji, optional notes, journal text, tags, and location.
- **Journal** — long-form journal entries attached to moods, with full-text search and detail views.
- **Calendar** — browse and revisit your mood history day by day.
- **Insights** — charts and analytics (`fl_chart`) surfacing trends, averages, and streaks.
- **Mood Map** — see where your moods happen via geolocation and reverse geocoding.
- **Mood Prediction & Patterns** — predicts likely mood and detects recurring patterns from your history.
- **Sentiment Analysis** — analyzes journal text to infer emotional tone.
- **Face Mood Detection** — estimates mood from a camera selfie using ML Kit face detection.
- **Speech-to-Text** — dictate journal entries and notes by voice.
- **Dream Journal** — log dreams with sleep quality, recall, and tags.
- **Time Capsules** — write a message to your future self that unlocks on a chosen date.
- **Breathing Exercises** — guided breathing for calming and focus.
- **Achievements** — unlock badges for entry counts, streaks, and journaling milestones.
- **Mood Avatar / Ripple / Tree** — playful, generative visualizations of your emotional state.
- **Custom Moods & Tags** — define your own moods and organize entries with tags.
- **Discover** — community/inspiration tab with sign-in gating.
- **Cloud Sync** — optional Supabase auth + sync; the app is fully usable offline as a guest.
- **App Lock** — PIN protection on launch for private journals.
- **Dark Mode & Onboarding** — themeable UI with a first-launch onboarding flow.
- **Export & Share** — export entries to CSV and share mood cards.

## 🛠️ Tech Stack

| Area | Packages |
|------|----------|
| Framework | Flutter (Dart SDK `^3.10.7`) |
| State Management | `provider` |
| Local Database | `sqflite`, `path`, `path_provider` |
| Cloud / Auth / Sync | `supabase_flutter` |
| Charts | `fl_chart` |
| Camera & ML | `camera`, `google_mlkit_face_detection` |
| Voice | `speech_to_text` |
| Location | `geolocator`, `geocoding` |
| Connectivity | `connectivity_plus` |
| Export / Share | `csv`, `share_plus` |
| Networking | `http`, `translator` |
| UI / UX | `google_fonts`, `flutter_animate`, `twemoji`, `cupertino_icons` |
| Utilities | `intl`, `uuid`, `shared_preferences` |

## 📁 Project Structure

```
lib/
├── main.dart              # App entry: providers, DB/sync bootstrap, lock & onboarding gates
├── models/               # MoodEntry, DreamEntry, TimeCapsule, Achievement
├── providers/            # ChangeNotifier state (mood, settings, tags)
├── services/             # DB, Supabase, sync, sentiment, face mood, prediction,
│                         #   patterns, speech, location, breathing, export, app lock
├── screens/              # Feature screens (home, calendar, insights, dream journal, ...)
│   ├── auth/             # Login / signup
│   └── onboarding/       # First-launch onboarding
├── widgets/              # Reusable widgets (bottom nav, emoji pickers, painters, gates)
├── theme/                # Light/dark theming
└── utils/                # Date helpers, ID generation, mood colors, quotes, transitions
```

The app shell ([lib/screens/shell_screen.dart](lib/screens/shell_screen.dart)) hosts five tabs: **Home · Calendar · Discover · Insights · Settings**.

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart `^3.10.7`)
- A configured Android/iOS toolchain (Android Studio / Xcode)
- A [Supabase](https://supabase.com) project (optional — only needed for cloud sync & auth)

### Setup

1. **Clone & install dependencies**
   ```bash
   git clone <repo-url>
   cd moodloom
   flutter pub get
   ```

2. **Configure Supabase** (optional)

   MoodLoom works fully offline as a guest. To enable cloud sync and accounts, set up
   a Supabase project and provide its URL and anon key to `SupabaseService.initialize()`
   in [lib/services/supabase_service.dart](lib/services/supabase_service.dart) (e.g. via
   constants or `--dart-define`).

3. **Run**
   ```bash
   flutter run
   ```

### Permissions

Depending on the features you use, the app requests:

- **Camera** — face-based mood detection
- **Microphone** — speech-to-text journaling
- **Location** — mood map / location-tagged entries

### App Icons

Launcher icons are generated by `flutter_launcher_icons`:
```bash
flutter pub run flutter_launcher_icons
```

## 🧱 Architecture

MoodLoom follows an offline-first, provider-based architecture:

- **Models** (`models/`) — typed entities (`MoodEntry`, `DreamEntry`, `TimeCapsule`, `Achievement`).
- **Providers** (`providers/`) — `ChangeNotifier` state for moods, settings, and tags.
- **Services** (`services/`) — the heavy lifting: a local SQLite store (`DatabaseService`),
  Supabase auth/sync (`SupabaseService`, `SyncService`), and feature services for sentiment,
  face mood, prediction, patterns, speech, location, breathing, export, and app lock.
- **Screens / Widgets** (`screens/`, `widgets/`) — UI that observes providers.

Data is written locally first and synced to Supabase when signed in and online — so the app
stays fully functional offline, and guests can use it without an account.

## 📦 Supported Platforms

Android · iOS · 



