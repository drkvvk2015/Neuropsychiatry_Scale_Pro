# 🧠 NeuroScale Pro — AI Psychiatry Clinical System

NeuroScale Pro is a **production-grade psychiatry clinical assistant** designed for real-world hospital use.

It combines:

* 📊 Standardized psychiatric scoring systems
* 🤖 Offline AI clinical assistant
* 🎤 Voice-based input (Tamil + English)
* 🚨 Risk detection (suicide / severity)
* 📈 Analytics & research tools

---

# 🚀 Features

## 🧠 Psychiatry Scales

* BPRS (24 items)
* PHQ-9
* GAD-7
* HAM-D
* YMRS
* Y-BOCS
* MMSE
* C-SSRS (Suicide Risk)

---

## ⚡ ICU Mode (Ultra Fast)

* Tap-based scoring
* One-screen workflow
* Designed for emergency / ward use

---

## 🤖 Offline AI Assistant

* Runs locally (no internet required)
* Generates:

  * Clinical summary
  * Severity interpretation
  * Risk assessment
  * Treatment suggestions

---

## 🚨 Smart Alerts

* Suicide risk detection
* Severe case flagging
* Visual emergency warnings

---

## 🎤 Voice Input

* Offline speech recognition
* Tamil + English support
* Converts speech → scoring inputs

---

## 📊 Analytics & Research

* Patient trend graphs
* Ward-level analytics
* CSV export for research (SPSS / R)

---

## 💊 Drug Suggestion Engine

* Guideline-based suggestions
* Diagnosis-driven recommendations

---

# 🏗️ Architecture

```
Flutter App
   ↓
Clinical Engine (Scales + Rules)
   ↓
AI Layer (Local LLM via llama.cpp)
   ↓
Voice Layer (Vosk)
   ↓
Storage (SQLite / Firebase optional)
```

---

# 📁 Project Structure

```
lib/
 ├── core/
 ├── models/
 ├── services/
 │    ├── scoring_engine.dart
 │    ├── drug_engine.dart
 │    ├── ai_engine.dart
 ├── ai/
 │    ├── local_ai.dart
 │    ├── prompt_engine.dart
 ├── voice/
 │    ├── speech_service.dart
 ├── screens/
 │    ├── dashboard.dart
 │    ├── patient_screen.dart
 │    ├── scale_screen.dart
 │    ├── icu_mode.dart
 ├── widgets/
 └── main.dart
```

---

# ⚙️ Setup Instructions

## 1. Install Flutter

https://docs.flutter.dev/get-started/install

---

## 2. Clone Repo

```
git clone https://github.com/your-username/neuroscale-pro.git
cd neuroscale-pro
```

---

## 3. Install Dependencies

```
flutter pub get
```

---

## 4. Add AI Model (IMPORTANT)

Download GGUF model (TinyLlama recommended)

Place here:

```
android/app/src/main/assets/model.gguf
```

---

## 5. Add Voice Models

Download Vosk models:

```
assets/models/en
assets/models/ta
```

---

## 6. Run App

```
flutter run
```

---

# 📦 Build APK / AAB

## Debug APK

```
flutter build apk
```

## Release (Play Store)

```
flutter build appbundle --release
```

---

# 🧠 AI Integration

## Engine

* llama.cpp (on-device inference)
* GGUF quantized models

## Prompt Example

```
You are a psychiatrist.

Patient:
Diagnosis: Schizophrenia
BPRS: 82

Provide:
- Severity
- Risk
- Plan
- Clinical note
```

---

# 🚨 Clinical Safety

⚠️ This app is a **clinical support tool only**

* Does NOT replace psychiatrist judgment
* Always verify AI outputs
* Use alerts as guidance, not diagnosis

---

# 🔐 Privacy

* Data stored locally by default
* No cloud required
* Optional Firebase sync

---

# 💰 Business Model (Optional)

* Free: basic scoring
* Pro:

  * AI assistant
  * Analytics
  * Cloud sync

---

# 🏥 Hospital Deployment

## Workflow

1. Add patient
2. Score using ICU mode
3. Review AI summary
4. Check alerts
5. Track progress

---

# 📈 Roadmap

* SaaS hospital platform
* Web dashboard
* Predictive AI
* Multi-hospital system

---

# 🤝 Contributing

Pull requests are welcome.

---

# 📄 License

MIT License

---

# 🧠 Vision

> “To become the operating system for psychiatry.”

---

# 🚀 Status

✅ Production-ready
✅ Hospital deployable
✅ AI-powered
✅ Offline capable

---

# 📞 Contact

Email: [your@email.com](mailto:your@email.com)
Website: yourdomain.com

---
