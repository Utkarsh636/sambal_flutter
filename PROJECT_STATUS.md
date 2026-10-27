# Sambal (संबल) — Project Completion Status

**Last updated:** 2026-10-27

---

## Overall Progress: ~45%

| Phase | Status | Details |
|-------|--------|---------|
| 1A — Bug fixes, API config, onboarding overhaul | Done | API config extracted, dark mode fixed, deprecated APIs replaced, bilingual onboarding with API-driven state/district selection |
| 1B — Verified government data | Done | 245 districts across 5 states, RBD Act fee tiers, circumstance-based document checklists, official portal links |
| 1C — Persistence & polish | Done | SharedPreferences for case data/theme/language, privacy screen, bottom navigation, rate limiting, request logging |
| 2B — Theme audit, animations, accessibility, offline caching | Done | Theme-aware colors, fade transitions, Semantics labels, tooltips, API response caching with offline banner, Cache-Control headers |
| 2 — Document scanner & PDF pack | Not started | Camera capture, OCR, PDF generation, print/share |

---

## What Works Today

### Flutter App (sambal_flutter)
- Compiles and installs on Android (tested on RMX3868)
- Light and dark themes — warm Cosmic Latte / Cerulean+Neon Rose
- Hindi/English toggle on every screen
- Splash screen with fade transition to onboarding or home
- Onboarding wizard: state selection from API, district dropdown from API, circumstance picker
- Home screen with bottom navigation (Home / Certificate / Documents / Assistant)
- Certificate guide: documents checklist, fee tiers with applicable tier highlighted, official portal link
- Documents screen: add/remove documents manually
- Roadmap screen: step-by-step progress tracker
- Assistant chat: Groq-powered AI with safety guardrails
- Offline mode: cached API responses served with offline banner
- Privacy screen: view stored data, delete all data
- Persistent state: case data, theme, language, onboarding flag survive app restart

### Backend API (sambal_api)
- Node + Express 5, Groq SDK
- `GET /health` — health check
- `GET /certificate/coverage` — 5 states with district counts
- `GET /certificate/districts?state=...` — official district lists (LGD import)
- `GET /certificate/guide?state=...&district=...&circumstance=...&deathDate=...` — full guide with fees, documents, route, sources
- `POST /assistant/chat` — AI chat with PII blocking, legal-question refusal, government-fact guardrails
- Rate limiting: 30 req/min general, 10 req/min chat
- Request logging (method, path, status, duration — no PII)
- Cache-Control headers on GET endpoints

### Data Coverage
- **States:** Uttar Pradesh (75 districts), Bihar (38), Madhya Pradesh (55), Rajasthan (41), Maharashtra (36)
- **District source:** India Local Government Directory (lgdirectory.gov.in)
- **Fee tiers:** 4 tiers per RBD Act 1969 — free (verified nationally), late/delayed (verified for UP, Bihar, MP, Rajasthan from state RBD rules), magistrate (court-dependent), Maharashtra (conditional by local body)
- **Documents:** Common + circumstance-specific (hospital/home/accident) + late-registration extras
- **Sources:** Every verified fact has official URL, title, and last-checked date

---

## Git History

### Flutter (sambal_flutter)
| Commit | Description |
|--------|-------------|
| `855ae5e` | Phase 1B — app through onboarding, certificate, documents, assistant |
| `5affaed` | Phase 1C — persistence, privacy screen, bottom navigation |
| `8d10131` | Phase 2B — theme audit, animations, accessibility, offline caching |
| `a534157` | Build fix — remove CupertinoPageTransitionsBuilder (Android-only) |

### Backend (sambal_api)
| Commit | Description |
|--------|-------------|
| `73dd2d7` | Phase 1B — verified data, 245 districts, certificate guide endpoints |
| `5b89ea0` | Rate limiting and request logging |
| `ff73740` | Cache-Control headers on GET endpoints |

---

## Remaining for 60% Prototype

### Phase 2 — Document Scanner & PDF Pack
- [ ] Camera capture for multiple document pages
- [ ] On-device OCR text detection (google_mlkit_text_recognition)
- [ ] Suggested checklist matching (local keyword matching, no AI)
- [ ] User confirmation before marking any document ready
- [ ] Generate combined local PDF (cover page + document pages)
- [ ] Print and share PDF
- [ ] Keep scans local unless user explicitly shares

### Future Improvements
- [ ] Verified fee amounts for Maharashtra local bodies
- [ ] District-specific office addresses (requires per-district research)
- [ ] Push notifications for deadline reminders
- [ ] Multi-language support beyond Hindi/English
- [ ] Tablet layout optimization

---

## Safety Rules (from AGENTS.md)
- Never invent a fee, deadline, document requirement, office address, or official URL
- Show "Not verified yet" when a district-specific fact is unavailable
- Every verified government fact has: official source URL, source title, last checked date, state applicability
- AI may explain verified information but must not manufacture missing facts
- Maharashtra fees are conditional — local-body by-laws vary
- All scans stay local unless user explicitly shares
