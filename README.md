# SkyPulse

SkyPulse is a production-ready, clean-architecture Flutter application that combines real-time weather information and global news updates. This application is built as part of a developer assessment home assignment.

---

## Architecture Overview

SkyPulse follows a structured, modular clean-architecture pattern designed to separate concerns and ensure high maintainability, testability, and SOLID principle compliance:

```
UI (Views & Widgets) ──> GetX Controller ──> Repository ──> API Provider (Remote) / Hive (Local Cache)
```

1. **UI Layer (Views & Widgets)**: The presentation layer contains purely stateless/state-driven UI components. No business logic or API calls occur here. Widgets observe reactive variables in GetX controllers and trigger actions in response to user inputs.
2. **GetX Controller**: Manages state, handles pull-to-refresh events, orchestrates geocoding/location fetching, coordinates pagination for infinite scroll, and uses GetX workers (`debounce`) to throttle search input.
3. **Repository Layer**: Coordinates data sourcing. It acts as the mediator between the remote network and the local cache. If the network call fails, it automatically retries with exponential backoff before loading cached data from Hive.
4. **API Providers / Storage Services**: Low-level clients. Providers handle network configurations (timeouts, endpoints) using Dio, and the StorageService initializes Hive boxes and manages custom object schemas.
5. **GetX Bindings**: Facilitates lazy dependency injection (`lazyPut`), ensuring that repositories, providers, and controllers are only instantiated when the respective route is loaded, conserving device memory.

---

## Folder Structure

```
lib/
├── core/
│   ├── constants/       # Global constants, API keys, and configurations
│   ├── network/         # Central network clients and configurations
│   ├── services/        # StorageService (Hive) and LocationService (Geolocator)
│   ├── theme/           # LightTheme and DarkTheme definitions
│   └── utils/           # Helper classes (e.g., WeatherHelper mapping WMO codes)
├── data/
│   ├── models/          # WeatherModel, ForecastModel, NewsModel, BookmarkModel + TypeAdapters
│   ├── providers/       # Pure API providers fetching raw responses via Dio
│   └── repositories/    # Repositories coordinating caching, retries, and offline fallback
├── modules/
│   ├── dashboard/       # Dashboard module containing views, bindings, controllers, and widgets
│   ├── news_details/    # NewsDetails module containing views, bindings, controllers, and widgets
│   ├── bookmarks/       # Bookmarks module containing views, bindings, controllers, and widgets
│   └── settings/        # Settings module containing views, bindings, controllers, and widgets
├── routes/
│   ├── app_pages.dart   # Binds route paths to specific pages and bindings
│   └── app_routes.dart  # Defines application route constants
└── main.dart            # Root entry point of the Flutter application
```

---

## Getting Started

### Prerequisites
- Flutter SDK (latest stable channel)
- Dart SDK

### Installation & API Key Setup
1. Clone this repository to your local machine.
2. Duplicate the `.env.example` file and rename it to `.env`:
   ```bash
   cp .env.example .env
   ```
3. Register for a free API key at [NewsAPI.org](https://newsapi.org).
4. Paste your API key in the `.env` file:
   ```env
   NEWS_API_KEY=your_actual_api_key_here
   ```
5. Fetch Flutter dependencies:
   ```bash
   flutter pub get
   ```
6. Generate the local database Hive adapters:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

### Running the App
To run the app on an emulator, simulator, or connected device:
```bash
flutter run
```

---

## Design Decisions Write-Up

### 1. What happens in your app if both the Weather and News APIs fail at the same time? Walk through it screen by screen.
- **Dashboard Screen**:
  - The `DashboardView` displays cached data gracefully.
  - **Weather Card**: Shows the last successfully cached weather info with a warning banner at the top: `"Showing offline data from [Time]"`.
  - **Forecast Section**: Shows the 5-day daily forecast retrieved from the cached weather object.
  - **News Section**: Loads and displays the first page of news articles cached during the last successful sync, accompanied by an information banner: `"Showing offline data from [Time]"`.
  - **Banner Indicators**: Warn users that they are viewing cached info rather than rendering blank error screens. If no cache is present, custom error panels appear with a "Retry" button.
- **News Details Screen**:
  - Opens the article details successfully since the article data (title, body, description, source, image URL) is passed via GetX route arguments from the parent dashboard.
  - **Full Article Link**: If the user clicks "Read Full Article," it opens the browser. If the device has no internet, the browser itself will show its offline message, but the app details remain readable.
- **Bookmarks Screen**:
  - Functions completely normally and remains fully responsive. Since bookmarked articles are persisted locally in a dedicated Hive box (`bookmarks_box`), they can be read, searched, and deleted entirely offline without any API dependencies.
- **Settings Screen**:
  - Works fully. The user can toggle theme modes (persisted in Hive settings box), configure a default city, and view app information.

### 2. Why did you choose your specific local persistence option (Hive/SQLite/Isar), and what would change if bookmarks needed to sync across a user's devices?
- **Why Hive?**:
  - **Performance**: Hive is a lightweight, pure-Dart key-value store that reads/writes directly to binary format. It is much faster than SQLite for simple document storage and caching.
  - **Simplicity**: No complex boilerplate code is required compared to SQLite, and it doesn't require setting up native schema migrations for simple features.
  - **No Native Dependencies**: Hive is written in pure Dart, making it highly cross-platform, robust, and extremely easy to set up on mock testing environments.
- **What would change if Bookmarks needed to sync across devices?**:
  - We would replace the standalone local Hive repository with a synchronized database. We would introduce a cloud database provider (e.g., Firebase Firestore, Supabase, or a custom WebSockets sync server).
  - The repository layer would adopt an **Offline-First Synchronization Pattern**:
    1. Write bookmark actions to local storage immediately (with a syncing status flag).
    2. Try to sync changes to the cloud database in the background when connectivity becomes available.
    3. Implement a conflict resolution policy (e.g., using timestamps or Last-Write-Wins) to merge bookmarks modified concurrently on different devices.

### 3. If you had one more day, what's the first thing you'd refactor or add, and why?
- **Unit & Widget Testing**:
  - I would write unit tests for the controllers (using `mockito` to mock `WeatherRepository` and `NewsRepository`) to verify geocoding, search debouncing, and pagination triggers under high load.
  - I would write widget tests for the Dashboard to ensure that loading skeletons, error panels, and offline banners display under correct states.
- **Advanced Geocoding**:
  - Geocoding can sometimes be slow. I would cache geocoding searches (city name to coordinate map) in a Hive box to make city switches instantaneous for previously searched locations.
- **Dynamic Backgrounds & Custom Animations**:
  - Add smooth transitions and dynamic weather background effects (like rain falling or cloud animations using Rive) to make the UI look even more premium.
