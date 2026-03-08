# Legal Directory

A professional, feature-rich Flutter application designed for legal practitioners to efficiently manage client records, legal documents, and case-related information.

## 🚀 Features

- **Client Management:** Easily add, edit, and organize legal client profiles with detailed records.
- **OCR Integration:** Extract text from documents and images using `Google ML Kit Text Recognition`.
- **PDF Generation & Printing:** Convert records into professional PDF documents for sharing or physical filing.
- **Local Notifications:** Set reminders for important dates and court hearings with `Flutter Local Notifications`.
- **Offline First:** Reliable data persistence using `sqflite` for local database management.
- **Direct Communication:** Call or email clients directly from the app using `url_launcher`.
- **Modern UI/UX:** A clean, responsive interface powered by `Google Fonts` and `Flutter Animate`.

## 🛠️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev/) (SDK ^3.11.0)
- **Database:** [sqflite](https://pub.dev/packages/sqflite)
- **AI/ML:** [Google ML Kit](https://pub.dev/packages/google_mlkit_text_recognition)
- **State/Services:** Custom service-based architecture for PDF, Notifications, and Database operations.

## 📦 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio / VS Code
- Android SDK 21 or higher (required for OCR/Notifications)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/legal_directory.git
   cd legal_directory
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   ```bash
   flutter run
   ```

## 📱 Screenshots

| Home Screen | Add Record | OCR Scanning |
| :---: | :---: | :---: |
| ![Home](https://via.placeholder.com/200x400?text=Home+Screen) | ![Add](https://via.placeholder.com/200x400?text=Add+Record) | ![OCR](https://via.placeholder.com/200x400?text=OCR+Scan) |

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---
*Developed with ❤️ by Talha Jutt*
