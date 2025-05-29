# 🪣 Bucket Collect Balls – Flutter Game

**Exercise 3 – CS5450 Mobile Programming**
Dr. Sabah Mohammed, Lakehead University
Developed by: *\Kathan Suthar*
Date: *\[28 May, 2025]*

---

## 🎮 Overview

**Bucket Collect Balls** is an engaging mobile game built using Flutter for Android and iOS devices. Players control a colorful bucket to catch as many falling balls as possible, aiming for the highest score before missing three balls. Features include a smooth player experience, customizable name entry, responsive controls, and a persistent leaderboard.

---

## ✨ Key Features

* **Player Name Entry**: Prompt at the start to personalize your session.
* **Modern UI**: Gradient background, vibrant visuals, and fluid animations.
* **Intuitive Controls**: Move the bucket left/right by dragging or tapping.
* **Leaderboard**: Top 5 scores stored on-device, displayed after game over.
* **One-File Source**: All logic and UI in a single `main.dart` for easy review.
* **No Asset Hassles**: Cartoon bucket is rendered using Flutter's `CustomPainter`—no image files needed.

---

## 🧑‍💻 Tech Stack

* **Flutter SDK** (3.7.x or higher)
* **Dart**
* **shared\_preferences** (for leaderboard storage)

---

## 📂 Project Structure

```
bucket_collect_balls/
├── lib/
│   └── main.dart        # All game logic and UI
├── assets/              # (Optional) Screenshots for report
├── pubspec.yaml         # Project metadata and dependencies
├── android/             # Platform configs (no manual edits needed)
├── ios/                 # Platform configs (no manual edits needed)
└── README.md            # This file
```

---

## 🚀 How to Run

### **Requirements**

* [Flutter SDK](https://flutter.dev/docs/get-started/install)
* IntelliJ IDEA / Android Studio / VS Code (with Flutter plugin)
* Android emulator or real device

### **Steps**

1. **Clone the Project**

   ```bash
   git clone https://github.com/YOUR_GITHUB_USERNAME/bucket_collect_balls.git
   cd bucket_collect_balls
   ```
2. **Install Dependencies**

   ```bash
   flutter pub get
   ```
3. **Run the App**

   * Launch your emulator or connect your device.
   * In terminal:

     ```bash
     flutter run
     ```
   * Or click the **Run** button in your IDE.

---

## 🕹 Gameplay Instructions

1. **Enter Your Name**
   On launch, input your player name.

2. **Start the Game**
   Tap the green "Start Game" button.

3. **Control the Bucket**

   * **Drag** the bucket left/right with your finger
   * **Tap** anywhere along the bottom to move the bucket instantly

4. **Catch the Balls**
   Score points by catching as many falling balls as possible!

5. **Game Over & Leaderboard**
   Missing 3 balls ends the game. Your score and the top 5 scores are displayed.

6. **Restart**
   Tap "Restart" to play again.

---

## 🖼 Screenshots

*(Replace with your own game images for your report or submission!)*

|         Player Name Prompt        |             Gameplay             |      Game Over & Leaderboard     |
| :-------------------------------: | :------------------------------: | :------------------------------: |
| ![name](assets/screens/start.png) | ![game](assets/screens/game.png) | ![over](assets/screens/over.png) |

---

## 💡 Customization

* **Change background**: Edit the gradient in `main.dart`'s background container.
* **Change bucket look**: Adjust the `CartoonBucketPainter` code for colors/shapes.
* **Ball speed/difficulty**: Tweak variables at the top of `main.dart`.
* **Add sound or effects**: Integrate audio plugins if desired.

---

## 🏆 Learning Outcomes

* Flutter UI and state management
* Gesture handling (drag/tap)
* Drawing custom widgets with `CustomPainter`
* Persistent storage using `shared_preferences`
* Best practices for single-file, mobile-first app design

---

## 👤 Author & Submission

* **Name:** *\[Your Full Name]*
* **Course:** CS5450 Mobile Programming
* **Instructor:** Dr. Sabah Mohammed
* **Date:** *\[Submission Date]*

---

## 📢 Notes

* For best results, use on a real device or up-to-date emulator.
* Screenshots and this README are required for submission (export to PDF if needed).
* No external bucket assets required—pure Flutter code!

---

**Enjoy the game and good luck!**
*— \[Your Name], COMP54 Mobile Programming*

---

Let me know if you want this in **Word, PDF, or with even more visuals**!
You can paste screenshots directly, or keep the file Markdown/Plain Text for your instructor’s review.
