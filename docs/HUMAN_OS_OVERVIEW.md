# Human OS: overview

Also called **Human Health OS** or **Longevity App** in earlier handoffs. All three names refer to the same product.

## Kısa anlatım (TR, kullanıcının kendi tarifi)

Human OS, insanın sağlık verilerini tek yerde toplayan bir "kişisel sağlık işletim sistemi". Laboratuvar sonuçları, kilo ve vücut ölçümleri, uyku, spor, beslenme, ilaçlar, takviyeler, aşılar, hastalıklar, semptomlar, psikolojik durum, wearable verileri ve sağlık geçmişi ayrı uygulamalara dağılmıyor, aynı sistemde birleşiyor.

Amaç sadece veri depolamak değil. Sistem bu verileri zaman içinde takip eder, değişimleri gösterir, karşılaştırır, açıklar ve gerektiğinde günlük görevler ya da takip planları oluşturur.

**Longevity** sağlıklı yaşamı destekleyen faktörleri gösterir. **Shortevity** ise riskleri, hastalık yükünü, zararlı alışkanlıkları ve olumsuz trendleri ayrı ayrı gösterir.

Hedef platformlar Android, iPhone, Web, Windows ve Mac. Windows'ta iki sürüm olacak: Rufus gibi ZIP'i açıp doğrudan EXE'den çalışan portable sürüm ve normal `Setup.exe` kurulumu.

Ayrı bir **Build Lab** da var. Orada sentetik insanlar oluşturup yaş, kilo, uyku, laboratuvar, beslenme ve spor değerlerini değiştirerek sistemin nasıl tepki verdiğini deneyebilirsin.

Özetle Human OS şunları tek çatı altında birleştiriyor: fitness uygulaması, lab takibi, ilaç takibi, sağlık zaman çizelgesi, koruyucu bakım, longevity modelleri, kişisel sağlık arşivi ve dijital ikiz mantığı.

## What it is

Human OS is a local-first, offline-capable, deterministic personal health operating system. "Operating system" here means one system that represents a person's health and life state over time. It does not mean a kernel.

Most health apps cover one slice: calories, workouts, a lab PDF, or sleep. Human OS treats all of these as observations of the **same person**, kept on **one timeline** in **one data model**:

body measurements · vitals · labs and biomarkers · conditions and symptoms · subjective state (1–10 check-ins) · sleep · activity and exercise · wearables · nutrition and food composition · medications, actual intake and supplements · vaccinations · procedures and treatments (including chemotherapy and radiotherapy) · skin · preventive care and screening · goals, daily missions and care pathways · documents and attachments · comparisons, synthetic profiles and digital twins · longevity and Shortevity analysis · education.

## The loop

```
ENTER / SELECT / IMPORT / MEASURE
  → preserve the original source
  → normalize carefully (never destroying the original)
  → canonical record with provenance
  → deterministic, versioned calculation
  → longitudinal tracking
  → compare (people, scenarios, baselines)
  → explain and teach
  → optional task / mission (a plan, never a completion)
```

## Longevity ↔ Shortevity

These are two analytical perspectives. Neither is one magic score.

- **Longevity:** protective factors, functional reserve, preventive state, healthspan-supporting patterns.
- **Shortevity:** harmful exposures, disease burden, functional loss, adverse trajectories.

Lifespan and healthspan figures appear only as **MODELLED** results from a named, versioned model. Each one shows its inputs, missing data, uncertainty and limitations. The app never shows a "date of death".

Spelling: the canonical term is **Shortevity** (v0.24 handoff). "Shortgevity" in later prose is an alias with the same meaning.

## Product surfaces, one core (five from the master prompt + Linux, added by the user)

| Surface | Distribution | Platform-only adapters |
|---|---|---|
| Android | APK (direct and test), AAB (Play) | Health Connect, notifications, Keystore, background jobs, camera and documents |
| iOS | Xcode archive → TestFlight / App Store | HealthKit, notifications, Keychain |
| Web / installable web app | Static web build, optionally a PWA | Browser storage and export. This surface has no HealthKit, no Health Connect, no OS keychain and no native background work, and it says so. |
| Windows | Portable ZIP (`HumanHealthOS.exe` + DLLs + `data/` + `UserData/` vault) and `HumanHealthOS-Setup-x64.exe` | Encrypted portable vault, file picking, notifications, updater |
| macOS | `HumanHealthOS.app` in a DMG or PKG | Keychain, sandboxed app-support storage (never inside the `.app`) |
| Linux (Fedora/Nobara, Ubuntu/Debian) | Portable tar.gz, AppImage, .deb, .rpm, Flatpak | XDG data directory or portable `UserData/`, optional Secret Service |

The **Human OS Build Lab** is an auxiliary synthetic laboratory and teaching surface, not a sixth platform. It holds synthetic humans A, B, C… with adjustable parameters and side-by-side results. It never mixes synthetic subjects with a real person's data.

## Non-negotiables

The full list is in `CLAUDE.md`. In short:

- planned ≠ completed, missing ≠ zero, unknown ≠ false
- model ≠ observation, scenario ≠ observation
- reference interval ≠ optimal target ≠ decision limit
- self-report ≠ diagnosis
- no interaction found ≠ safe
- unknown history ≠ zero history
- every result carries its model or rule ID, version, inputs, missing inputs and limitations
- no generative AI is needed for core functions
- health data is never committed, never logged in plain text, and never deleted by an uninstall
