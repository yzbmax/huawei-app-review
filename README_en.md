<p align="right">
  <a href="./README.md"><strong>简体中文</strong></a> | <strong>English</strong>
</p>

# 🛡️ huawei-app-review

**Huawei AppGallery Review & Compliance Skill for AI Coding Assistants**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)](LICENSE)
[![HarmonyOS](https://img.shields.io/badge/HarmonyOS-NEXT%20%2F%205.x%20%2F%206.x-c0272d?style=flat-square)](https://developer.huawei.com/)
[![Language](https://img.shields.io/badge/Language-ArkTS%20%2F%20Stage%20Model-007acc?style=flat-square)](https://developer.huawei.com/)
[![API](https://img.shields.io/badge/API-12%20--%2026-orange?style=flat-square)](https://developer.huawei.com/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](https://github.com/yzbmax/huawei-app-review/pulls)

> **Ensure AI coding assistants avoid all Huawei AppGallery review rejections on day one of writing HarmonyOS code.**
> A production-ready compliance skill and code template library for Claude Code, Cursor, Gemini CLI, Antigravity, and other AI agents.
>
> 📅 **Last Updated**: 2026-11-24

---

## 🎯 Why This Skill Is Essential

In HarmonyOS NEXT (pure HarmonyOS) app development, **more than 60% of new applications fail their initial review on Huawei AppGallery**. When AI assistants lack domain-specific compliance awareness, they frequently introduce critical compliance hazards:

- ❌ **Premature Data Collection**: Initializing third-party SDKs or fetching device identifiers (OAID/AAID/Clipboard) before explicit user agreement to the privacy policy, triggering automated security audit rejections.
- ❌ **Over-Requesting Permissions instead of Security Components**: Requesting coarse/fine-grained permissions when official system security components (`SaveButton`, `PhotoViewPicker`, `PasteButton`, `LocationButton`) could achieve the task without permission popups.
- ❌ **Missing Privacy "Double-Checklists" & Revocation**: Omitting mandatory "Collected Personal Information List" and "Third-Party Data Sharing List" in secondary menus, or lacking a simple "Revoke Privacy Consent" mechanism.
- ❌ **Recent Tasks List Inconsistency**: App icon or name displaying default package name, placeholder icon, or blank space when running in the background/recent tasks overview.
- ❌ **Cross-Platform Feature Degradation**: Releasing a severely reduced or placeholder version on HarmonyOS when full-featured versions exist on Android/iOS.
- ❌ **Third-Party Login Without Huawei ID**: Integrating WeChat or QQ login without simultaneously providing Huawei Account Kit login.
- ❌ **Submitting Debuggable Packages**: Failing to disable `debuggable: true` or failing to enable code obfuscation in Release builds.

**With this Skill enabled**: Your AI assistant proactively validates code against the official *Huawei AppGallery Review Guidelines* across architecture, UI design, permission declarations, and release packaging—guaranteeing 100% rejection-free builds.

---

## ✨ Key Features

- 🚨 **TOP 10 Review Red Lines**: High-frequency rejection points including MIIT HarmonyOS ICP filing, Privacy Dialog 3-Elements, Security Component prioritization, Zero-Invocation Rule, and auto-renewal disclosures.
- 📖 **Complete 13-Section Audit Scope**: Metadata (annual 2-change name limit, recent tasks consistency), security rules (zero hot-reloading/hot-fixing, clipboard probe interception), quality standards, UGC moderation, ad interactions (splash screen skip buttons & anti-misclick shake settings), generative AI dual-marking (explicit watermark + implicit metadata), and prohibited categories.
- 💻 **Production-Ready ArkTS Templates**:
  - Fully compliant **First-Launch Privacy Agreement Dialog** with strict non-agreement lifecycle gating.
  - **Privacy Consent Revocation Manager (`PrivacyConsentManager`)** for clean state rollback.
  - Drop-in **System Security Components** (`SaveButton`, `PhotoViewPicker`, `PasteButton`, `LocationButton`).
  - Drop-in **Personal Information Double-Checklist Component (`PersonalInfoDoubleList`)**.
  - Standardized **Permission `reason` specifications** for `module.json5` and `string.json`.
  - Release-ready **`obfuscation-rules.txt`** that protects NAPI/Native bindings from symbol mangling.
- 📋 **Pre-Flight Release Checklist**: 16 essential check items to verify before clicking "Submit for Review".

---

## 🚀 Quick Installation

### Method 1: Automated One-Line Install (Recommended)

* **Linux / macOS**:
  ```bash
  curl -fsSL https://raw.githubusercontent.com/yzbmax/huawei-app-review/main/install.sh | bash
  ```
* **Windows (PowerShell)**:
  ```powershell
  irm https://raw.githubusercontent.com/yzbmax/huawei-app-review/main/install.ps1 | iex
  ```

### Method 2: Manual Clone & Setup

```bash
# 1. Clone the repository
git clone https://github.com/yzbmax/huawei-app-review.git ~/.local/share/huawei-app-review

# 2. Run the installer
cd ~/.local/share/huawei-app-review
bash install.sh
```

### Method 3: Direct Symlink per Tool

* **Claude Code**:
  ```bash
  mkdir -p ~/.claude/skills && ln -s ~/.local/share/huawei-app-review ~/.claude/skills/huawei-app-review
  ```
* **Antigravity / Gemini CLI**:
  ```bash
  mkdir -p ~/.gemini/config/skills && ln -s ~/.local/share/huawei-app-review ~/.gemini/config/skills/huawei-app-review
  ```
* **Cursor**:
  ```bash
  mkdir -p ~/.cursor/skills && ln -s ~/.local/share/huawei-app-review ~/.cursor/skills/huawei-app-review
  ```
* **Standard Agent Skills Spec (`~/.agents/skills`)**:
  ```bash
  mkdir -p ~/.agents/skills && ln -s ~/.local/share/huawei-app-review ~/.agents/skills/huawei-app-review
  ```

---

## 📁 Repository Structure

```text
huawei-app-review/
├── SKILL.md                  ← Master guideline: review rules, red-lines, and checklist
├── install.sh                ← Linux/macOS multi-CLI one-click installer script
├── install.ps1               ← Windows PowerShell multi-CLI one-click installer script
├── LICENSE                   ← MIT License
├── README.md                 ← Simplified Chinese documentation
├── README_en.md              ← English documentation
└── references/
    └── privacy-and-permissions-template.md  ← Production ArkTS patterns (Security components, Privacy dialog, Revocation, Double list, Obfuscation)
```

---

## 🛡️ TOP 10 Review Red Lines Preview

| No. | Rejection Cause | Core Rule & Avoidance Guide |
|---|---|---|
| **1** | **App ICP Unapproved** | Complete MIIT ICP filing early; native HarmonyOS apps must select "HarmonyOS" platform. |
| **2** | **Privacy Dialog Violation** | Explicit Agree and Disagree buttons required; no default pre-checks; strictly zero SDK data collection before user agreement. |
| **3** | **Excessive Permissions / Missing Security Components** | Dynamic on-demand permission requests only. **Always prioritize system Security Components (`SaveButton`/`PhotoViewPicker`/`PasteButton`/`LocationButton`)**; provide demo video when applying for restricted ACL permissions. |
| **4** | **Missing Privacy "Double-Checklists"** | Mandatory "Collected Personal Information List" & "Third-Party Data Sharing List" in secondary menus. |
| **5** | **Missing Account Deletion or Consent Revocation** | Provide clear revocation and deletion entry points with processing within 15 business days; handle post-revocation states gracefully. |
| **6** | **Third-Party Login Without Huawei ID** | Must offer Huawei Account Kit login if third-party login (WeChat/QQ) is supported. |
| **7** | **Uncloseable / Misleading Ads** | Clear "Ad" tag; effective splash skip button auto-advancing after timer; strictly no simultaneous "shake + swipe" on the same ad slot. |
| **8** | **Deceptive Auto-Renewal** | Explicit pricing and intervals; provide single-purchase option; notify user at least 5 days prior to auto-renewal. |
| **9** | **Functional Defects & Feature Degradation** | No launch crashes/white screens; submit signed Release packages; HarmonyOS version functionality must not be inferior to Android/iOS counterparts. |
| **10** | **Homogenized / Saturated Shell Apps** | Pure web wrappers or single-image apps prohibited; saturated categories without unique innovative experience will be directly rejected. |

---

## 🤝 Contributing

Huawei AppGallery review specifications evolve alongside regulations and HarmonyOS system releases. PRs and Issues sharing real-world compliance insights and code templates are warmly welcome!

## 📄 License

Distributed under the [MIT License](LICENSE).
