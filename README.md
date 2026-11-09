<div align="center">

<img src="assets/launcher.png" alt="Quiz-It logo" width="96" height="96" />

# Quiz-It

[![License: MIT](https://img.shields.io/badge/License-MIT-3DA639?logo=opensourceinitiative&logoColor=white)](LICENSE) [![Flutter](https://img.shields.io/badge/Flutter-3.47-02569B?logo=flutter&logoColor=white)](https://flutter.dev/) [![Dart](https://img.shields.io/badge/Dart-3.13-0175C2?logo=dart&logoColor=white)](https://dart.dev/) [![Riverpod](https://img.shields.io/badge/Riverpod-3.5-00B4AB?logo=flutter&logoColor=white)](https://pub.dev/packages/flutter_riverpod)

**A clean, fast trivia quiz app built with Flutter.**

A cross-platform quiz application built with [Flutter](https://flutter.dev/)
that pulls trivia questions from the [Open Trivia
Database](https://opentdb.com/) — pick a topic, play a round, and review your
answers. Runs on Android, iOS, and Web.

</div>

---

## Screenshots

> These screenshots are from v1 and will be refreshed for the v2 redesign.

<table>
  <tr>
    <td width="33%"><img src="screenshots/HomeScreen.png" alt="Home screen listing quiz questions"></td>
    <td width="33%"><img src="screenshots/FilterBottomSheet.png" alt="Filter bottom sheet with category, difficulty, and amount"></td>
    <td width="33%"><img src="screenshots/QuestionCard.png" alt="Question card with multiple choice answers"></td>
  </tr>
</table>

## Features

- **Cross-platform** — runs on Android, iOS, and Web from a single codebase.
- **Material 3 design** — light and dark themes that follow the system
  setting, and a centred layout that scales from phones to desktop browsers.
- **Quiz setup** — choose from 24 categories, a difficulty, multiple choice or
  true / false questions, and a round of 5–20 questions.
- **Focused quiz flow** — one question at a time with a progress bar, instant
  right / wrong feedback, and a running score and streak.
- **Results and review** — an animated score, round stats, and a review of
  every question with the correct answer.
- **Lifetime stats** — quizzes played, accuracy, and best streak, saved on the
  device along with your last quiz settings.
- **Friendly errors** — clear, retryable messages when you're offline, the API
  is rate limited, or a category doesn't have enough questions.

## How It Works

1. **Set up a round** — pick options and a category on the home screen.
2. **Fetch the quiz** — `QuizNotifier.start()` asks the `TriviaApi` client for
   questions from the Open Trivia Database.
3. **Answer and score** — each answer is locked in on the current
   `QuizSession`; finishing the round records it in your lifetime stats.

> There is no backend of its own — the app talks directly to the public Open
> Trivia Database API, and nothing is stored off-device.

## Project Structure

```text
lib/
├── main.dart           # Opens storage and starts the app
├── app.dart            # MaterialApp and themes
├── data/               # Open Trivia DB client and category catalog
├── models/             # Immutable models: question, session, settings, stats
├── state/              # Riverpod notifiers and persistent storage
├── screens/            # home/, quiz/ and results/, each with its own widgets
├── widgets/            # Widgets shared between screens
└── theme/              # Material 3 theme and extra semantic colours
```

## Tech Stack

| Area           | Tools                                                                                                                       |
| -------------- | --------------------------------------------------------------------------------------------------------------------------- |
| **Framework**  | [Flutter](https://flutter.dev/) · [Dart](https://dart.dev/)                                                                 |
| **State**      | [flutter_riverpod](https://pub.dev/packages/flutter_riverpod)                                                               |
| **Networking** | [http](https://pub.dev/packages/http)                                                                                       |
| **Storage**    | [shared_preferences](https://pub.dev/packages/shared_preferences)                                                           |
| **Data**       | [Open Trivia Database](https://opentdb.com/)                                                                                |
| **Testing**    | [flutter_test](https://docs.flutter.dev/testing)                                                                            |
| **Tooling**    | [Flutter CLI](https://flutter.dev/docs/get-started/install) · [flutter_lints](https://pub.dev/packages/flutter_lints)       |

## Getting Started

These instructions will get you a copy of the project up and running on your
local machine for development purposes.

### Requirements

To install and run this project you need:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.47 or newer
  (Dart 3.13+)
- [git](https://git-scm.com/downloads) (only to clone this repository)
- Optional: [Chrome](https://www.google.com/chrome/) (for web debugging)
- Optional: an IDE with Flutter support —
  [Android Studio](https://developer.android.com/studio),
  [IntelliJ IDEA](https://www.jetbrains.com/idea/), or
  [Visual Studio Code](https://code.visualstudio.com/) with the
  [Flutter and Dart plugins](https://flutter.dev/docs/get-started/editor)

### Installation

To set up everything on your local machine, follow these steps:

1. Clone this repo and then change directory to the `quiz-it` folder:

```bash
git clone https://github.com/kaushalmeena/quiz-it.git
cd quiz-it
```

2. Install project dependencies using the Flutter CLI:

```bash
flutter pub get
```

### Running

To run the app on a connected device or simulator:

```bash
flutter run
```

To run it in the browser instead:

```bash
flutter run -d chrome
```

### Testing

To run the unit and widget tests (no network needed):

```bash
flutter test
```

To analyze the project for lint and type issues:

```bash
flutter analyze
```

### Building

To create a production build for a specific platform:

```bash
flutter build apk      # Android
flutter build ios      # iOS
flutter build web      # Web
```

The build output is written to the `build/` folder — `build/app/outputs` for
Android and `build/web` for the web bundle.

## Credits

- Trivia questions provided by the [Open Trivia
  Database](https://opentdb.com/), licensed under
  [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).

## Contributing

Contributions are welcome! If you find a bug or have a feature request, please
[open an issue](https://github.com/kaushalmeena/quiz-it/issues/new/choose)
first to discuss it. For code changes, fork the repository, create a branch,
and open a pull request.

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE)
file for details.
