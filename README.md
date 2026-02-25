<div align="center">

# 🩺 DOCTOR RX

**Next-Generation Prescription Management System**

![Flutter](https://img.shields.io/badge/Built_with-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Linux Support](https://img.shields.io/badge/Platform-Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Windows Support](https://img.shields.io/badge/Platform-Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)

*A high-performance desktop application engineered for medical professionals to generate, manage, and print clinical prescriptions with precision.*

</div>

---

## 📑 Table of Contents
- [Overview](#-overview)
- [Core Features](#-core-features)
- [Technical Architecture](#-technical-architecture)
- [Screenshots](#-screenshots)
- [Installation & Setup](#-installation--setup)
- [Dependencies](#-dependencies)
- [Roadmap](#-roadmap)
- [Developer](#-developer)

---

## 🔭 Overview

**DOCTOR RX** replaces traditional, error-prone handwritten prescriptions with a streamlined digital workspace. Designed specifically for desktop environments (Linux & Windows), it allows doctors to rapidly input patient vitals, medical history, and medication regimens, instantly compiling them into a beautiful, legally compliant PDF document.

The system features advanced auto-pagination, intelligent data caching, and dynamic PDF rendering to handle complex, multi-page prescriptions effortlessly.

---

## ✨ Core Features

### 🏥 Clinical Workspace
* **Comprehensive Patient Profiling:** Record vitals (BP, Weight), demographics, and detailed clinical notes (Primary Diagnosis, Past History, Diet, and Investigations).
* **Advanced Medication Logic:** * Add highly specific dosages, frequencies, timings, and durations.
    * **Smart Sorting:** Automatically segregates "Empty Stomach" medications to the top of the prescription for patient safety.
* **Auto-Suggest Database:** Built-in local caching engine remembers previously entered patient names, diseases, and medicines, drastically reducing typing time for returning patients.

### 📄 Premium PDF Engine
* **Dynamic Partitions:** Utilizes advanced side-by-side rendering (`pw.Partitions`) to separate clinical notes from the medication list.
* **Infinite Pagination:** Automatically generates new pages if the medication list exceeds a single page, carrying over professional headers, footers, and watermarks.
* **Branded Export:** Embeds customized background watermarks, doctor credentials, clinic locations, and legally required disclaimers directly into the PDF.

### 💻 System & Workflow
* **Live Preview:** Real-time PDF rendering pane alongside the input form.
* **One-Click Print & Save:** Direct integration with native OS printing dialogues and local file system saving.
* **Responsive Desktop UI:** Ultra-modern, responsive layout optimized for ultrawide and standard desktop monitors.

---

## 🏗️ Technical Architecture

The application is built on the Flutter framework, utilizing Dart for all business logic.

**Key Technical Implementations:**
* **PDF Rendering:** Heavily utilizes the `pdf` package, specifically `pw.MultiPage` and `pw.Partitions` for complex, asynchronous document generation.
* **State Management:** Uses localized state management with debounced input listeners to prevent UI stuttering during real-time PDF generation.
* **Local Persistence:** Custom `LocalDb` utility manages intelligent text-completion arrays for rapid data entry.
* **Build System:** Custom CMake configurations ensure native compilation on both Linux and MSVC/Windows toolchains.

---

## 📸 Screenshots

*(Add screenshots of your application here to make the repository visually appealing)*

| Workspace Interface | Generated PDF Output |
| :---: | :---: |
| `<img src="assets/workspace_placeholder.png" width="400"/>` | `<img src="assets/pdf_placeholder.png" width="400"/>` |

*(Replace `workspace_placeholder.png` and `pdf_placeholder.png` with actual screenshots placed in your assets folder)*

---

## 🚀 Installation & Setup

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable channel recommended)
* C++ build tools (GCC/Clang for Linux, Visual Studio for Windows)
* CMake & Ninja

### Build Instructions

1. **Clone the repository**
   ```bash
   git clone [https://github.com/yourusername/prescription.git](https://github.com/yourusername/prescription.git)
   cd prescription