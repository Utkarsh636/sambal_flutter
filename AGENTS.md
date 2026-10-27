# Sambal — Project Handover and Tracker

## Product

**Sambal (संबल)**  
Tagline: **हर कदम पर साथ**  
A Hindi-first, privacy-conscious support app for bereaved Indian families. It guides users through death-certificate registration, documents, fees, offices, and official portals.

Do not present Sambal as a lawyer, government authority, or replacement for emergency services.

---

## Project folders

```text
/Users/utkarsh060/projects/sambal_flutter
/Users/utkarsh060/projects/sambal_api
- sambal_flutter: Flutter Android app
- sambal_api: Node + Express + Groq backend
- Never copy API keys into Flutter, Git, screenshots, or chat.
Run commands
Start backend
Run in the API VS Code window:
cd /Users/utkarsh060/projects/sambal_api
node server.js
Expected output:
Sambal AI API running at http://127.0.0.1:3000
Run Flutter on USB Android device
cd /Users/utkarsh060/projects/sambal_flutter
flutter run -d WCKZX8LROB5XAY59
Connect Android phone to local backend
Run once after reconnecting the phone:
/Users/utkarsh060/Library/Android/sdk/platform-tools/adb -s WCKZX8LROB5XAY59 reverse tcp:3000 tcp:3000
Flutter accesses the local backend at:
http://127.0.0.1:3000
Current working status
Flutter
- Flutter app successfully compiles and installs on RMX3868.
- SambalScope is now correctly placed above MaterialApp.
- App starts through SplashScreen.
- Splash screen should transition automatically to OnboardingScreen.
- Existing screens include onboarding, home, certificate, documents, roadmap, and assistant.
Backend
- Groq integration works through POST /assistant/chat.
- Backend health route:
GET /health
- Assistant must never receive names, phone numbers, Aadhaar numbers, document images, or other personal details.
- Existing data/rules.js contains demo rules only. Demo facts must never be called verified.
Certificate guide backend
The next backend version adds:
GET /certificate/coverage
GET /certificate/districts?state=...
GET /certificate/guide?state=...&district=...&circumstance=...
Initial confirmed state coverage target:
1. Uttar Pradesh
2. Bihar
3. Madhya Pradesh
4. Rajasthan
5. Maharashtra
Important: these five states are the coverage target. Do not claim every district is live until official district data has been imported and reviewed.
Design system
Light theme
- Cosmic Latte: #FFF8E7
- Mocha Cream: #D6B38C
- Deep Burgundy: #5A1D2C
- Rich Burgundy: #3E0F1C
Use for a warm, dignified, calm experience.
Dark theme
- Jet Black: #0A0A0A
- Dark Surface: #15171D
- Cerulean Blue: #007BA7
- Neon Rose: #FF2D95
Dark theme rule: Cerulean is the main action colour. Neon Rose is a restrained accent for focus, highlights, and gentle glow—not a full-screen dominant colour.
UI direction
- Rounded cards: about 24px
- Soft shadows and subtle gradients
- No harsh red error-like surfaces for normal content
- Calm animation only: fade, gentle rise, page transition, leaf movement
- Respect reduced motion where added later
Planned user journey
Start certificate
        ↓
Documents
        ↓
Fees
        ↓
Where to apply
        ↓
Official portal
        ↓
Print/share preparation pack
Every step must include:
- Previous button
- Next button
- Saved progress
- Clear verification status
- Source link where a government fact is shown
Users may also open Documents, Fees, or Roadmap directly from Home.
Data accuracy and safety rules
1. Never invent a fee, deadline, document requirement, office address, or official URL.
2. Show Not verified yet when a district-specific fact is unavailable.
3. Every verified government fact needs:
   - Official source URL
   - Source title
   - Last checked date
   - State and district applicability
4. State-wide facts may not apply to every municipal corporation or gram panchayat.
5. Maharashtra fees are especially conditional because local-body by-laws can vary.
6. AI may explain verified information but must not manufacture missing facts.
7. Legal inheritance, property share, or dispute questions must be refused and redirected to a lawyer or relevant authority.
Official source starting points
- India Local Government Directory:
  https://lgdirectory.gov.in/demo/downloadDirectory.do
- Uttar Pradesh e-District information:
  https://services.india.gov.in/service/detail/uttar-pradesh-e-district-services
- Bihar RTPS / ServicePlus:
  https://serviceonline.bihar.gov.in/
- Madhya Pradesh eService:
  https://services.mp.gov.in/eservice/eServices?srvs=21
- Rajasthan Pehchan Civil Registration System:
  https://pehchan.rajasthan.gov.in/pehchan3/P_DeathEntry.aspx
- Maharashtra Aaple Sarkar:
  https://aaplesarkar.mahaonline.gov.in/
- National CRS information:
  https://services.india.gov.in/service/detail/civil-registration-system-birth-and-death-certificate
Next implementation phase
Phase 1 — Guided certificate journey and verified data foundation
- [ ] Add the new certificate-guide backend endpoints.
- [ ] Import official district lists for all five target states.
- [ ] Create verified state and district records.
- [ ] Build linked Previous/Next certificate journey in Flutter.
- [ ] Show fee, route, source, and verification state.
- [ ] Add official portal launch button.
- [ ] Test backend from Flutter phone through USB forwarding.
Phase 2 — Document scanner and PDF pack
- [ ] Camera capture for multiple document pages.
- [ ] OCR document-text detection.
- [ ] Suggested checklist matching only.
- [ ] Require user confirmation before marking any document ready.
- [ ] Generate combined local PDF.
- [ ] Print and share PDF.
- [ ] Keep scans local unless the user explicitly shares them.
Update log
2026-10-24
- Flutter app compiled successfully after fixing the missing SambalScope.
- Splash screen route and onboarding transition were configured.
- Groq assistant backend was confirmed working.
- Five-state certificate coverage target was confirmed.
- Verified-data architecture started.