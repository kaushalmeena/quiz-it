<div align="center">

# Quiz-It

**A Flutter quiz app powered by Redux for state management.**

A cross-platform quiz application built with [Flutter](https://flutter.dev/)
that uses [Redux](https://redux.js.org/) for predictable quiz state management
— supporting Android, iOS, and Web.

[![License: MIT](https://img.shields.io/badge/License-MIT-3DA639?logo=opensourceinitiative&logoColor=white)](LICENSE) [![Flutter](https://img.shields.io/badge/Flutter-latest-02569B?logo=flutter&logoColor=white)](https://flutter.dev/) [![Dart](https://img.shields.io/badge/Dart-latest-0175C2?logo=dart&logoColor=white)](https://dart.dev/) [![Redux](https://img.shields.io/badge/Redux-5-764ABC?logo=redux&logoColor=white)](https://redux.js.org/)

</div>

---

## Screenshots

<table>
  <tr>
    <td><img src="screenshots/HomeScreen.png" alt="Home Screen" width="200"/></td>
    <td><img src="screenshots/FilterBottomSheet.png" alt="Filter" width="200"/></td>
    <td><img src="screenshots/QuestionCard.png" alt="Question Card" width="200"/></td>
  </tr>
  <tr>
    <td align="center"><b>Home Screen</b></td>
    <td align="center"><b>Filter</b></td>
    <td align="center"><b>Question Card</b></td>
  </tr>
</table>

## Features

- **Cross-platform** — runs on Android, iOS, and Web from a single codebase.
- **Redux state management** — predictable, testable state for quiz progress
  and results.
- **Category filtering** — browse quizzes by topic or category.
- **Clean card UI** — questions presented in swipeable cards.

## Tech Stack

| Area          | Tools                                                                 |
| ------------- | --------------------------------------------------------------------- |
| **Framework** | [Flutter](https://flutter.dev/) · [Dart](https://dart.dev/)           |
| **State**     | [Redux](https://redux.js.org/)                                        |
| **Tooling**   | [Flutter CLI](https://flutter.dev/docs/get-started/install)            |

## Getting Started

These instructions will get you a copy of the project up and running on your
local machine for development purposes.

### Requirements

To install and run this project you need:

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [git](https://git-scm.com/downloads) (only to clone this repository)
- Optional: [Chrome](https://www.google.com/chrome/) (for web debugging)
- Optional: an IDE with Flutter support —
  [Android Studio](https://developer.android.com/studio),
  [IntelliJ IDEA](https://www.jetbrains.com/idea/), or
  [Visual Studio Code](https://code.visualstudio.com/) with the
  [Flutter and Dart plugins](https://flutter.dev/docs/get-started/editor)

### Installation

To set up everything on your local machine, follow these steps:

1. Clone this repo onto your computer:

```bash
git clone https://github.com/kaushalmeena/quiz-it.git
```

2. Install dependencies for the app:

```bash
flutter pub get
```

### Running

To run the app on Android or iOS:

```bash
flutter run
```

To build for a specific platform:

```bash
flutter build apk      # Android
flutter build ios      # iOS
flutter build web      # Web
```

## Contributing

Contributions are welcome! If you find a bug or have a feature request, please
[open an issue](https://github.com/kaushalmeena/quiz-it/issues/new/choose)
first to discuss it. For code changes, fork the repository, create a branch,
and open a pull request.

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE)
file for details.
