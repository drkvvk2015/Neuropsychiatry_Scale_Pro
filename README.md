# 🧠 NeuroScale Pro — AI Psychiatry Clinical System

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Production--Ready-brightgreen)]()
[![Offline](https://img.shields.io/badge/AI-Offline--Capable-blue)]()

> **"To become the operating system for psychiatry."**

NeuroScale Pro is a production-grade psychiatry clinical assistant designed for real-world hospital use. It combines standardized psychiatric scoring, offline AI, Tamil/English voice input, suicide risk detection, and ward-level analytics — all running on a single Android/iOS device without internet.

---

## 🚀 Features

### 🧠 Psychiatry Scales (8 validated instruments)

| Scale | Items | Range | Purpose |
|-------|-------|-------|---------|
| **BPRS** | 24 | 24–168 | Brief Psychiatric Rating Scale |
| **PHQ-9** | 9 | 0–27 | Depression screening |
| **GAD-7** | 7 | 0–21 | Anxiety screening |
| **HAM-D** | 17 | 0–52 | Hamilton Depression Rating |
| **YMRS** | 11 | 0–60 | Young Mania Rating Scale |
| **Y-BOCS** | 10 | 0–40 | OCD severity |
| **MMSE** | 11 | 0–30 | Cognitive assessment |
| **C-SSRS** | 10 | — | Columbia Suicide Severity Rating |

---

### ⚡ ICU Mode (Ultra Fast)

- Tap-based scoring — no typing required
- 3-step workflow: Select Patient → Select Scale → Tap Score
- Dark theme optimized for ward / emergency lighting
- Designed for bedside use

---

### 🤖 Offline AI Assistant

- Runs **100% locally** — no internet or cloud required
- Generates structured clinical output per patient:
  - Severity interpretation
  - Risk stratification
  - Treatment recommendations
  - Clinical note (copy-paste ready)
- Architecture: **llama.cpp** on-device inference with GGUF quantized models

---

### 🚨 Smart Alerts

- **Critical / High risk** banners automatically surface at top of patient list
- **C-SSRS suicide risk** triggers a mandatory emergency acknowledgement dialog
- Color-coded severity across all screens (green → yellow → orange → red)

---

### 🎤 Voice Input

- Offline speech recognition via **Vosk**
- **Tamil + English** language models
- Converts spoken scores to numeric inputs automatically
- No microphone data ever leaves the device

---

### 📊 Analytics & Research

- Per-patient score **trend line charts** over time
- Ward-level **severity distribution** pie chart
- **Scale usage** bar chart
- **CSV export** compatible with SPSS, R, and Excel

---

### 💊 Drug Suggestion Engine

Guideline-based pharmacotherapy suggestions for:

| Diagnosis | First-line Examples |
|-----------|-------------------|
| Schizophrenia / Psychosis | Risperidone, Olanzapine, Aripiprazole |
| Bipolar Disorder / Mania | Lithium, Valproate, Olanzapine |
| Major Depression | Sertraline, Escitalopram, Fluoxetine |
| Generalized Anxiety | Escitalopram, Sertraline, Duloxetine |
| OCD | Fluoxetine, Sertraline, Fluvoxamine |
| Dementia | Donepezil, Rivastigmine, Galantamine |
| PTSD | Sertraline, Paroxetine + Trauma CBT |
| ADHD | Methylphenidate, Atomoxetine |

> ⚠️ Suggestions are guideline-based only. Always verify dosing and contraindications.

---

## 🏗️ Architecture

```
Flutter App (Material 3)
      ↓
Clinical Engine (Scales + Severity Rules)
      ↓
AI Layer (Local LLM via llama.cpp / GGUF)
      ↓
Voice Layer (Vosk offline ASR)
      ↓
Storage (SQLite local — Firebase optional)
```

---

## 📁 Project Structure

```
lib/
 ├── core/
 │    ├── constants.dart       # App-wide constants, scale names, severity levels
 │    └── theme.dart           # Material 3 theme, severity/risk colors
 ├── models/
 │    ├── patient.dart         # Patient entity + SQLite serialization
 │    └── scale_result.dart    # Assessment result entity
 ├── services/
 │    ├── scoring_engine.dart  # All 8 scale definitions + scoring thresholds
 │    ├── drug_engine.dart     # Guideline-based drug suggestions
 │    ├── ai_engine.dart       # Offline clinical summary generator
 │    └── database_service.dart # SQLite CRUD + CSV export
 ├── voice/
 │    └── speech_service.dart  # Vosk offline ASR integration
 ├── screens/
 │    ├── dashboard.dart       # Patient list, ward stats, alerts
 │    ├── patient_screen.dart  # Per-patient scales, AI summary, drugs
 │    ├── scale_screen.dart    # Item-by-item scale assessment
 │    ├── icu_mode.dart        # Ultra-fast tap workflow
 │    └── analytics_screen.dart # Charts and CSV export
 ├── widgets/
 │    ├── alert_banner.dart    # Risk/severity alert banner
 │    └── scale_card.dart      # Scale result summary card
 └── main.dart
```

---

## ⚙️ Setup Instructions

### 1. Install Flutter

Follow the official guide: https://docs.flutter.dev/get-started/install

Minimum requirements:
- Flutter SDK **≥ 3.0**
- Dart SDK **≥ 3.0**
- Android SDK target **34**, minSdk **21**

---

### 2. Clone Repository

```bash
git clone https://github.com/drkvvk2015/Neuropsychiatry_Scale_Pro.git
cd Neuropsychiatry_Scale_Pro
```

---

### 3. Install Dependencies

```bash
flutter pub get
```

---

### 4. Add AI Model *(IMPORTANT)*

Download a GGUF quantized model (TinyLlama recommended for mobile):

```
https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF
```

Place the model file at:

```
android/app/src/main/assets/model.gguf
```

> ⚠️ The model file is large (1–4 GB). It is excluded from git via `.gitignore`.

---

### 5. Add Voice Models

Download Vosk offline models:

| Language | URL |
|----------|-----|
| English | https://alphacephei.com/vosk/models |
| Tamil | https://alphacephei.com/vosk/models |

Extract and place at:

```
assets/models/en/   ← English Vosk model files
assets/models/ta/   ← Tamil Vosk model files
```

---

### 6. Run the App

```bash
flutter run
```

---

## 📦 Build APK / AAB

**Debug APK** (testing):
```bash
flutter build apk
```

**Release AAB** (Google Play Store):
```bash
flutter build appbundle --release
```

---

## 🧠 AI Integration Details

### Engine
- **llama.cpp** — optimized C++ inference engine for mobile
- **GGUF** quantized models (Q4_K_M recommended for balance of speed/quality)

### Prompt Format

The AI engine constructs structured prompts like:

```
You are a psychiatrist.

Patient: John Doe, 45Y Male
Diagnosis: Schizophrenia
Ward: Psychiatry Ward A

Assessments:
  BPRS = 82 (Very Severe)
  C-SSRS = High Risk

Provide:
- Severity interpretation
- Risk assessment
- Management plan
- Clinical note
```

### Output
The AI generates a structured clinical summary including severity narrative, risk stratification, treatment recommendations, and a copy-paste-ready clinical note.

---

## 🚨 Clinical Safety

> ⚠️ **This app is a clinical decision support tool only.**

- Does **NOT** replace psychiatrist clinical judgment
- Always verify AI-generated outputs before acting
- Drug suggestions are guideline-based — confirm dosing/contraindications
- Use alerts as guidance, not as definitive diagnosis
- C-SSRS High/Critical risk requires **immediate human review**

---

## 🔐 Privacy & Data

- All patient data stored **locally on device** by default (SQLite)
- No data transmitted to any server without explicit configuration
- Microphone input processed **offline** by Vosk — never sent to cloud
- Optional Firebase sync can be configured for multi-device hospital use

---

## 🏥 Hospital Deployment Workflow

```
1. Register patient (name, age, gender, ward, diagnosis)
       ↓
2. Score using ICU Mode (tap-based, bedside-ready)
       ↓
3. Review AI clinical summary (offline, instant)
       ↓
4. Check risk alerts (color-coded, mandatory C-SSRS acknowledgement)
       ↓
5. View drug suggestions (guideline-based, diagnosis-driven)
       ↓
6. Track progress over time (Analytics → trend charts)
       ↓
7. Export data for research (CSV → SPSS / R)
```

---

## 📈 Roadmap

- [ ] SaaS hospital platform (multi-hospital dashboard)
- [ ] Web dashboard for ward-level oversight
- [ ] Predictive AI (relapse risk, treatment response)
- [ ] Firebase multi-device sync
- [ ] ICD-10 / DSM-5 diagnostic code integration
- [ ] PDF report generation
- [ ] Nurse/doctor role-based access control

---

## 💰 Business Model *(Optional)*

| Tier | Features |
|------|----------|
| **Free** | Basic scoring (all 8 scales), patient management |
| **Pro** | + AI assistant, advanced analytics, CSV export |
| **Hospital** | + Cloud sync, multi-user, ward dashboard, SaaS |

---

## 🧪 Testing

Run unit tests:

```bash
flutter test
```

Tests cover:
- All 8 scale scoring thresholds (40+ test cases)
- Drug engine suggestion content
- AI engine summary generation
- Patient/ScaleResult model serialization

---

## 🤝 Contributing

Pull requests are welcome. For major changes, please open an issue first.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -m 'Add my feature'`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

## 📞 Contact

- **Email:** your@email.com
- **Website:** yourdomain.com

---

## 🚀 Status

| Item | Status |
|------|--------|
| Core scoring engine | ✅ Production-ready |
| All 8 psychiatric scales | ✅ Clinically validated thresholds |
| ICU Mode | ✅ Complete |
| Offline AI summary | ✅ Complete |
| Drug suggestion engine | ✅ 8 diagnoses covered |
| Smart alerts + C-SSRS | ✅ Complete |
| SQLite storage | ✅ Complete |
| Analytics & charts | ✅ Complete |
| CSV export | ✅ Complete |
| Voice input (Vosk) | 🔧 Framework ready — model setup required |
| llama.cpp AI model | 🔧 Framework ready — model file required |
| Firebase sync | 📋 Roadmap |