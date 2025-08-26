# 🎰 Spin Dinner Dish

A beautiful Flutter app that helps you decide what to eat for dinner using an interactive spinning wheel! Add your favorite dishes and let the wheel choose your meal with style.

## ✨ Features

### 🎨 Modern UI Design
- **Glassmorphism Effects**: Beautiful frosted glass containers with blur effects
- **Gradient Backgrounds**: Stunning multi-color gradients (Purple, Blue, Cyan, Green)
- **Smooth Animations**: Micro-animations and transitions throughout the app
- **Responsive Design**: Optimized for both mobile phones and tablets

### 🎡 Interactive Spin Wheel
- **Custom Wheel Painter**: Colorful segmented wheel displaying dish names
- **Pointer Indicator**: Clear triangular pointer to show selected dish
- **10-Second Spinning**: Extended spinning animation for suspense
- **Haptic Feedback**: Tactile feedback during interactions

### 🎉 Celebration System
- **Confetti Animations**: Particle effects when a dish is selected
- **Auto-cleanup**: Confetti automatically disappears after 3 seconds
- **Smooth Integration**: Seamless celebration effects

### 📱 User Experience
- **Easy Dish Management**: Add and remove dishes with simple interface
- **Centered Spin Button**: Premium glassmorphism button with dynamic icons
- **Result Display**: Beautiful result card showing selected dish
- **Touch Interactions**: Smooth InkWell effects and ripple animations

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- Android Emulator or Physical Device

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd spin
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📖 How to Use

1. **Add Dishes**: Enter dish names in the text field and tap "Add"
2. **Manage List**: View your dishes in the scrollable list below
3. **Start Spinning**: Tap the "🎯 Start Spinning!" button
4. **Enjoy**: Watch the wheel spin for 10 seconds and see your result!
5. **Celebrate**: Enjoy the confetti animation when your dish is selected

## 🛠️ Technical Details

### Architecture
- **Flutter Framework**: Cross-platform mobile development
- **Custom Painters**: Hand-drawn wheel and pointer components
- **Animation Controllers**: Smooth 10-second spinning animations
- **State Management**: StatefulWidget with proper lifecycle management

### Key Components
- `SpinAndDareApp`: Main application widget
- `ChallengeListScreen`: Home screen for managing dishes
- `SpinWheelScreen`: Spinning wheel interface
- `WheelPainter`: Custom painter for the segmented wheel
- `PointerPainter`: Custom painter for the selection pointer
- `ConfettiWidget`: Particle animation system

### Dependencies
- `flutter/material.dart`: Material Design components
- `flutter/services.dart`: Haptic feedback
- `dart:ui`: Blur effects and advanced graphics
- `dart:math`: Mathematical calculations for wheel segments

## 🎨 Design Features

### Color Scheme
- **Primary Gradient**: Purple (#6366F1) to Violet (#8B5CF6)
- **Secondary Gradient**: Cyan (#06B6D4) to Green (#10B981)
- **Glassmorphism**: White opacity overlays with blur effects
- **Shadows**: Multi-layered shadows for depth

### Typography
- **Font Weights**: Bold headings, regular body text
- **Font Sizes**: Responsive sizing for tablets and phones
- **Letter Spacing**: Enhanced readability
- **Color**: White text for contrast against gradients

### Animations
- **Spin Duration**: 10 seconds for suspenseful experience
- **Easing**: Smooth deceleration curve
- **Haptic Timing**: Medium impact on start, heavy impact on result
- **Confetti**: 3-second particle celebration

## 📱 Platform Support

- ✅ **Android**: Fully supported
- ✅ **iOS**: Fully supported
- ✅ **Web**: Supported (with some limitations)
- ✅ **Desktop**: Windows, macOS, Linux

## 🔧 Development

### Project Structure
```
lib/
└── main.dart          # Main application code
android/               # Android-specific files
ios/                   # iOS-specific files
web/                   # Web-specific files
assets/                # App assets and icons
```

### Building for Release

**Android APK:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

## 🎯 Future Enhancements

- [ ] Sound effects for spinning
- [ ] Custom dish categories
- [ ] Wheel themes and colors
- [ ] Save/load dish lists
- [ ] Multiple wheel configurations
- [ ] Social sharing features

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design for UI guidelines
- Community contributors and testers

---

**Made with ❤️ using Flutter**

*Spin the wheel, taste the surprise!* 🍽️✨
