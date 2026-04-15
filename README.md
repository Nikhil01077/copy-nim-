# MedQuantum-NIN

[![CI](https://github.com/YourUser/MedQuantum-NIN/actions/workflows/ci.yml/badge.svg)](https://github.com/YourUser/MedQuantum-NIN/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Python 3.11](https://img.shields.io/badge/python-3.11-blue.svg)](https://python.org)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.111-009688.svg)](https://fastapi.tiangolo.com)
[![React 18](https://img.shields.io/badge/React-18-61dafb.svg)](https://react.dev)

> **Rule-based ECG analysis platform with explainable AI reasoning, clinical-grade signal processing, and transparent diagnostic traces.**

---

## Table of Contents

- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Quick Start](#quick-start)
- [Backend API](#backend-api)
- [Frontend](#frontend)
- [Docker](#docker)
- [Testing](#testing)
- [Contributing](#contributing)
- [License](#license)

---

## Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                     React Frontend (Vite)                     │
│  Upload → Preview → Analyze → Report → PDF Export             │
└───────────────────────────┬──────────────────────────────────┘
                            │ REST API (JSON)
┌───────────────────────────▼──────────────────────────────────┐
│                    FastAPI Backend                             │
│                                                               │
│  ┌──────────┐  ┌──────────────────┐  ┌──────────────────┐    │
│  │  Signal   │  │  Preprocessing   │  │  Feature          │    │
│  │  I/O      │→ │  (notch, band-   │→ │  Extraction       │    │
│  │  (WFDB,   │  │   pass, baseline │  │  (HR, RR, PR,     │    │
│  │   CSV)    │  │   correction)    │  │   QRS, QT, HRV)   │    │
│  └──────────┘  └──────────────────┘  └────────┬───────────┘    │
│                                                │               │
│  ┌──────────────────┐  ┌──────────────────────▼────────────┐  │
│  │  Explainability   │← │  Clinical Rule Engine             │  │
│  │  Engine           │  │  (7 rules, sex-specific QT,       │  │
│  │  (reasoning,      │  │   AFib detection, risk scoring)   │  │
│  │   counterfactual) │  └──────────────────────────────────┘  │
│  └──────────────────┘                                         │
│                                                               │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │  Report Generator (SOAP note, clinician + patient summary)│ │
│  └──────────────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────────────┘
```

## Tech Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| **Frontend** | React + TypeScript | 18.x |
| **Build** | Vite | 5.x |
| **State** | Zustand | 4.x |
| **Charts** | Recharts | 2.x |
| **Animation** | Framer Motion | 11.x |
| **Styling** | Tailwind CSS | 3.x |
| **Backend** | FastAPI | 0.111.0 |
| **Signal Processing** | NeuroKit2 + SciPy | 0.2.7 / 1.13.0 |
| **WFDB** | wfdb-python | 4.1.2 |
| **Validation** | Pydantic v2 | 2.7.0 |
| **Logging** | Loguru | 0.7.2 |
| **Deploy (Frontend)** | Vercel | — |
| **Deploy (Backend)** | Render | — |

## Project Structure

```
MedQuantum-NIN/
├── backend/
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── app/
│   │   ├── main.py                  # FastAPI application factory
│   │   ├── core/
│   │   │   ├── config.py            # Pydantic BaseSettings
│   │   │   └── logging.py           # Loguru structured logging
│   │   ├── models/
│   │   │   └── schemas.py           # Pydantic v2 request/response models
│   │   ├── routers/
│   │   │   ├── ecg.py               # Upload, WFDB loading, signal mgmt
│   │   │   ├── analysis.py          # Full analysis pipeline
│   │   │   └── report.py            # SOAP note + report generation
│   │   ├── services/
│   │   │   ├── preprocessing.py     # Notch, bandpass, baseline correction
│   │   │   ├── feature_extraction.py # HR, RR, PR, QRS, QT, HRV
│   │   │   ├── rule_engine.py       # 7 clinical rules + risk scoring
│   │   │   ├── ml_placeholder.py    # Future ML model integration
│   │   │   └── explainability.py    # Reasoning traces + counterfactuals
│   │   └── utils/
│   │       └── signal_io.py         # WFDB/CSV loading, validation
│   └── tests/
│       ├── test_preprocessing.py
│       ├── test_feature_extraction.py
│       └── test_rule_engine.py
├── src/                             # React frontend
│   ├── api/ecgApi.ts                # Backend API client
│   ├── components/                  # UI components
│   ├── hooks/                       # Custom React hooks
│   ├── pages/                       # Route pages
│   ├── store/                       # Zustand state management
│   └── types/                       # TypeScript type definitions
├── docker-compose.yml
├── .github/workflows/ci.yml         # CI/CD pipeline
└── vite.config.ts
```

## Quick Start

### Prerequisites

- Python 3.11+
- Node.js 20+
- npm 9+

### Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env      # Edit .env as needed
uvicorn app.main:app --reload --port 8000
```

API docs available at `http://localhost:8000/docs`

### Frontend

```bash
npm install
npm run dev
```

Open `http://localhost:5173`

## Backend API

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/ecg/upload` | Upload ECG file (.csv, .dat, .hea, .edf, .ecg) |
| `GET` | `/api/ecg/samples` | List available PhysioNet sample records |
| `POST` | `/api/ecg/load-sample` | Load a WFDB sample record |
| `DELETE` | `/api/ecg/signal/{id}` | Delete stored signal |
| `POST` | `/api/analysis/analyze` | Run full ECG analysis pipeline |
| `GET` | `/api/analysis/result/{id}` | Get cached analysis result |
| `GET` | `/api/analysis/features/{id}` | Extract features only |
| `POST` | `/api/report/generate` | Generate SOAP note + report |
| `GET` | `/api/health` | Health check |

### Analysis Pipeline

1. **Signal I/O** — Load WFDB or CSV with format detection
2. **Preprocessing** — Notch filter (50/60Hz), bandpass (0.5–40Hz), baseline correction, Savitzky-Golay smoothing
3. **Feature Extraction** — R-peak detection, heart rate, RR intervals, PR/QRS/QT intervals, QTc (Bazett), HRV (SDNN, RMSSD, pNN50)
4. **Clinical Rules** — 7 evidence-based rules with sex-specific QT thresholds
5. **Explainability** — Natural language reasoning, confidence calibration, feature importance, counterfactual explanations
6. **Report** — SOAP note, clinician summary, patient-friendly explanation

## Docker

```bash
docker compose up --build
```

Backend: `http://localhost:8000` | Frontend: `http://localhost:5173`

## Testing

### Backend

```bash
cd backend
python -m pytest tests/ -v
```

20 tests covering preprocessing, feature extraction, and clinical rule engine.

### Frontend

```bash
npx tsc --noEmit  # Type checking
npm run build     # Production build
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -m 'Add my feature'`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Open a Pull Request

## License

[MIT](LICENSE)

---

> **Disclaimer:** MedQuantum-NIN is a research and educational tool. AI-generated ECG analysis requires clinical validation before any medical decisions. Always consult a qualified healthcare professional.
