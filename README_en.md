<p align="right">
  <a href="./README.md"><strong>简体中文</strong></a> | <strong>English</strong>
</p>

# 🛡️ huawei-app-review

**Huawei AppGallery Review & Compliance Skill for AI Coding Assistants**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)](LICENSE)
[![HarmonyOS](https://img.shields.io/badge/HarmonyOS-NEXT%20%2F%206.x%20%2F%207.x-c0272d?style=flat-square)](https://developer.huawei.com/)
[![Language](https://img.shields.io/badge/Language-ArkTS%20%2F%20Stage%20Model-007acc?style=flat-square)](https://developer.huawei.com/)
[![API](https://img.shields.io/badge/API-12%20--%2026-orange?style=flat-square)](https://developer.huawei.com/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](https://github.com/yzbmax/huawei-app-review/pulls)

> **Ensure AI coding assistants avoid all Huawei AppGallery review rejections on day one of writing HarmonyOS code.**
> A production-ready compliance skill and code template library for Claude Code, Cursor, Gemini CLI, Antigravity, and other AI agents.
>
> 📅 **Last Updated**: 2026-09-10

---

## 🎯 Why This Skill Is Essential

In HarmonyOS NEXT (pure HarmonyOS) app development, **more than 60% of new applications fail their initial review on Huawei AppGallery**. When AI assistants lack domain-specific compliance awareness, they frequently introduce critical compliance hazards:

- ❌ **Premature Data Collection**: Initializing third-party SDKs or fetching device identifiers (OAID/AAID/Clipboard) before the user explicitly agrees to the privacy policy, triggering automated security audit rejections.
- ❌ **Batch / Early Permission Requests**: Bombarding users with Camera, Microphone, or Location permission dialogs upon `EntryAbility` launch, violating the "dynamic minimization" rule.
- ❌ **Missing Privacy "Double-Checklists"**: Omitting mandatory "Collected Personal Information List" and "Third-Party Data Sharing List" in secondary menus.
- ❌ **Third-Party Login Without Huawei ID**: Integrating WeChat or QQ login without simultaneously providing Huawei Account Kit login.
- ❌ **Submitting Debuggable Packages**: Failing to disable `debuggable: true` in Release builds.
- ❌ **Placeholder & Half-Baked Features**: Submitting unhandled empty states, non-responsive buttons, or placeholder screens labeled "Coming Soon".

**With this Skill enabled**: Your AI assistant proactively validates code against the official *Huawei AppGallery Review Guidelines* across architecture, UI design, permission declarations, and release packaging—guaranteeing 100% rejection-free builds.

---

## ✨ Key Features

- 🚨 **TOP 10 Review Red Lines**: High-frequency rejection points including MIIT ICP filing, Privacy Dialog 3-Elements, Zero-Invocation Rule, and auto-renewal disclosures.
- 📖 **Complete 13-Section Audit Scope**: Metadata, system specifications, code stability, UGC moderation, ad interactions, minor protection, AI generative watermarks, and prohibited categories.
- 💻 **Production-Ready ArkTS Templates**:
  - Fully compliant **First-Launch Privacy Agreement Dialog** with strict non-agreement lifecycle gating.
  - Drop-in **Personal Information Double-Checklist Component (`DoubleListDialog`)**.
  - Standardized **Permission `reason` specifications** for `module.json5` and `string.json`.
  - Release-ready **`obfuscation-rules.txt`** that protects NAPI/Native bindings from symbol mangling.
- 📋 **Pre-Flight Release Checklist**: 13 essential check items to verify before clicking "Submit for Review".

---

## 🚀 Quick Installation

### Method 1: Automated One-Line Install (Recommended)

Run the following command in your terminal. The script automatically detects installed AI CLIs (Claude Code, Cursor, Gemini CLI, Antigravity) and creates symlinks:

```bash
curl -fsSL https://raw.githubusercontent.com/yzbmax/huawei-app-review/main/install.sh | bash
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
├── install.sh                ← Multi-CLI one-click installer script
├── LICENSE                   ← MIT License
├── README.md                 ← Simplified Chinese documentation
├── README_en.md              ← English documentation
└── references/
    └── privacy-and-permissions-template.md  ← Production ArkTS templates (Dialogs, checklists, obfuscation)
```

---

## 🛡️ TOP 10 Review Red Lines Preview

| No. | Rejection Cause | Core Rule & Compliance Action |
|---|---|---|
| **1** | **Unregistered App / Missing ICP** | Complete mandatory MIIT APP filing before release; unapproved apps cannot pass review. |
| **2** | **Privacy Dialog Violations** | Must display explicit dialog on first launch with distinct "Agree" and "Decline" buttons; **never pre-check agreements**; **strictly zero data/SDK calls prior to consent**. |
| **3** | **Excessive / Early Permissions** | Apply dynamic minimization; never batch-request permissions upon app start; declining must not exit the app; define clear, granular `reason` strings. |
| **4** | **Missing Privacy "Double-Checklist"** | Secondary menus must provide an **Itemized Collected Info List** and a **Third-Party Data Sharing List**. |
| **5** | **No Account Deletion / Revocation** | Must provide an easy privacy revocation entry and account cancellation service (commitment SLA $\le$ 15 business days). |
| **6** | **Third-Party Login Without Huawei ID** | If offering WeChat, QQ, or other third-party logins, **Huawei Account Kit MUST be simultaneously provided**. |
| **7** | **Uncloseable / Accidental Ads** | Prominently label "Ad"; provide an immediate, delay-free close "X" button; **never combine shake-to-open and swipe-to-open on the same ad slot**. |
| **8** | **Deceptive Auto-Renewals** | Clearly disclose subscription pricing and recurring intervals; offer a one-time purchase alternative; **actively notify user 5 days prior to auto-renewal**. |
| **9** | **Functional Defects & Incomplete UI** | Strictly avoid crash-on-launch, white-screen, or UI clipping; ensure all clickable elements respond; never ship unfinished features or empty states; Release build must be non-debuggable. |
| **10** | **Low-Quality Wrappers & Clones** | Webview-only wrappers or single-image apps with no unique functionality will be rejected immediately. |

---

## 🤝 Contributing

Huawei AppGallery review standards continuously evolve with regulatory policies and HarmonyOS API releases. Contributions, issue reports, and template improvements are warmly welcomed!

## 📄 License

This project is licensed under the [MIT License](LICENSE).
