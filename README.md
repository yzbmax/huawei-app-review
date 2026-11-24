<p align="right">
  <strong>简体中文</strong> | <a href="./README_en.md"><strong>English</strong></a>
</p>

# 🛡️ huawei-app-review

**华为应用市场审核合规指南与避坑指南 Skill (Huawei AppGallery Review Skill)**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)](LICENSE)
[![HarmonyOS](https://img.shields.io/badge/HarmonyOS-NEXT%20%2F%205.x%20%2F%206.x-c0272d?style=flat-square)](https://developer.huawei.com/)
[![Language](https://img.shields.io/badge/Language-ArkTS%20%2F%20Stage%20Model-007acc?style=flat-square)](https://developer.huawei.com/)
[![API](https://img.shields.io/badge/API-12%20--%2026-orange?style=flat-square)](https://developer.huawei.com/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](https://github.com/yzbmax/huawei-app-review/pulls)

> **让 AI 编程助手在写鸿蒙代码的第一天，就避开所有华为应用市场审核驳回红线。**
> 面向 Claude Code、Cursor、Gemini CLI、Antigravity 等 AI 助手的华为终端官方审核合规实战指南与代码模板库。
>
> 📅 **最后更新 / Last Updated**: 2026-11-24

---

## 🎯 为什么需要本 Skill？

在 HarmonyOS NEXT（纯血鸿蒙）开发中，**超过 60% 的新应用首次提审都会被华为应用市场驳回**。AI 编程助手在未经过专门合规知识约束的情况下，往往容易犯以下致命错误：

- ❌ **启动偷跑数据**：在用户点击隐私弹窗同意前，提前初始化 SDK 或调用设备标识（OAID/AAID/剪贴板），直接触发系统安全探针违规。
- ❌ **未优先使用安全控件**：本该使用 `SaveButton` / `PhotoViewPicker` / `PasteButton` 免权限实现的场景，强行申请敏感权限甚至受限 ACL 权限导致直接拒审。
- ❌ **缺少隐私“双清单”与撤回同意**：二级菜单中缺失“已收集个人信息清单”与“第三方共享个人信息清单”，未提供便捷的撤回隐私同意入口。
- ❌ **多任务列表信息不一致**：切后台后，最近任务列表中显示默认包名、默认图标或空白，与提审信息不符。
- ❌ **跨端功能严重缩水**：存在 Android/iOS 版本时，鸿蒙端主功能残缺或仅提供空占位“敬请期待”。
- ❌ **三方登录缺失华为账号**：接入了微信/QQ登录，却未同步提供华为账号服务 (Account Kit)。
- ❌ **未关调试模式**：使用 `debuggable: true` 打包提审直接驳回。

**安装本 Skill 后**：AI 在架构设计、编码、权限配置及提审打包全生命周期内，会自动对照《华为应用市场审核指南》最新红线要求，生成 100% 具备过审资质的代码与配置。

---

## ✨ 核心特性

- 🚨 **TOP 10 核心审核红线速查**：直击工信部鸿蒙备案、隐私弹窗三要素、零调用铁律、系统安全控件优先、自动续费防坑等高危禁区。
- 📖 **13 大官方审核板块全收录**：覆盖元数据（名称年改2次限制、多任务列表呈现一致性）、安全规范（严禁动态热更新、剪贴板探测拦截）、架构质量、UGC管控、广告交互（开屏跳过按钮与摇一摇防误触）、生成式 AI 双标识（显式水印+隐式元数据）及负面清单。
- 💻 **生产级 ArkTS 代码范式**：
  - 符合规范的**首次启动隐私协议弹窗**（含双按钮、非同意零调用时序控制）。
  - **撤回隐私政策同意**与状态优雅回退管理类 (`PrivacyConsentManager`)。
  - **四大系统安全控件免权限实战**（`SaveButton` 保存相册、`PhotoViewPicker` 选图、`PasteButton` 粘贴剪贴板、`LocationButton` 前台定位）。
  - 开箱即用的**个人信息双清单组件（PersonalInfoDoubleList）**。
  - `module.json5` 与 `string.json` **权限 reason 规范写作范例**。
  - 开启混淆且不误杀 NAPI/底层符号的 `obfuscation-rules.txt` 规则。
- 📋 **提审前终极检查清单 (Pre-Flight Checklist)**：16 项上线前必打勾自查清单，确保一次过审。

---

## 🚀 快速安装

### 方式一：一键自动安装（推荐）

* **Linux / macOS**：
  ```bash
  curl -fsSL https://raw.githubusercontent.com/yzbmax/huawei-app-review/main/install.sh | bash
  ```
* **Windows (PowerShell)**：
  ```powershell
  irm https://raw.githubusercontent.com/yzbmax/huawei-app-review/main/install.ps1 | iex
  ```

### 方式二：手动克隆与安装

```bash
# 1. 克隆到本地
git clone https://github.com/yzbmax/huawei-app-review.git ~/.local/share/huawei-app-review

# 2. 运行安装脚本
cd ~/.local/share/huawei-app-review
bash install.sh
```

### 方式三：针对具体 AI 工具手动软链

* **Claude Code**：
  ```bash
  mkdir -p ~/.claude/skills && ln -s ~/.local/share/huawei-app-review ~/.claude/skills/huawei-app-review
  ```
* **Antigravity / Gemini CLI**：
  ```bash
  mkdir -p ~/.gemini/config/skills && ln -s ~/.local/share/huawei-app-review ~/.gemini/config/skills/huawei-app-review
  ```
* **Cursor**：
  ```bash
  mkdir -p ~/.cursor/skills && ln -s ~/.local/share/huawei-app-review ~/.cursor/skills/huawei-app-review
  ```
* **标准 Agent Skills 规范 (`~/.agents/skills`)**：
  ```bash
  mkdir -p ~/.agents/skills && ln -s ~/.local/share/huawei-app-review ~/.agents/skills/huawei-app-review
  ```

---

## 📁 目录结构

```text
huawei-app-review/
├── SKILL.md                  ← 核心指南：审核标准、红线自检与提审 Checklist
├── install.sh                ← Linux/macOS 跨 AI CLI 一键安装脚本
├── install.ps1               ← Windows PowerShell 跨 AI CLI 一键安装脚本
├── LICENSE                   ← MIT 开源许可证
├── README.md                 ← 中文说明文档
├── README_en.md              ← English Documentation
└── references/
    └── privacy-and-permissions-template.md  ← 生产级 ArkTS 代码范式（安全控件、隐私弹窗、撤回同意、双清单、混淆规则）
```

---

## 🛡️ TOP 10 核心审核红线预览

| 序号 | 驳回原因 | 核心审核红线与避坑法则 |
|---|---|---|
| **1** | **APP 未核准备案** | 上线前提早完成工信部 APP 备案核准，未核准无法过审。纯鸿蒙应用备案需选择“鸿蒙”平台及包名。 |
| **2** | **隐私弹窗违规** | 首次启动必须弹窗明示；必须有**明确同意和拒绝**按钮；**严禁默认勾选**；**用户同意前严禁调用任何权限或初始化 SDK 收集个人数据**。 |
| **3** | **过度索权 / 未用安全控件** | 遵循权限最小化；在业务触发时动态申请，**严禁启动时一揽子索权**。**能用安全控件（SaveButton/PhotoViewPicker/PasteButton/LocationButton）的场景必须优先使用**；申请受限 ACL 权限需录制真实场景演示视频。 |
| **4** | **缺少隐私“双清单”** | 应用二级菜单中必须提供**已收集个人信息清单**与**与第三方共享个人信息清单**，披露内容与实际调用一致。 |
| **5** | **缺失注销或撤销渠道** | 必须提供便捷的“撤销隐私同意”入口和账号注销服务，承诺处理时限不超过 15 个工作日，撤回后优雅回退。 |
| **6** | **三方登录未配华为账号** | 若支持三方登录（微信/QQ等），**必须同时提供华为账号登录 (Account Kit)**。 |
| **7** | **广告诱导/跳过与关闭违规** | 标明“广告”字样；开屏跳过按钮响应区域清晰合规且倒计时结束自动关闭；**严禁同一广告位叠加摇动+滑动**，摇一摇灵敏度严格防误触。 |
| **8** | **自动续费欺骗诱导** | 开通前明示价格与周期；必须同步提供单次开通选项；**必须在自动续费前 5 日进行显著提醒**。 |
| **9** | **功能缺陷与跨端缩水** | 严禁启动白屏/闪退、界面截断；严禁功能模块点击无响应；提审包必须为 Release 正式包；**鸿蒙原生版本主功能不得明显低于 Android/iOS 其他平台版本**。 |
| **10** | **同质化与饱和类别套壳** | 严禁纯网页打包、单图/单页应用；敲木鱼、随机数、极简计算器/手电筒/记事本等高度饱和同质化工具无独创核心功能将直接拒审。 |

---

## 🤝 参与贡献

华为应用市场审核规范会随监管法规和鸿蒙系统版本持续演进。欢迎提交 PR 或 Issue 补充最新的审核避坑实战经验与代码模板！

## 📄 开源许可证

本项目基于 [MIT License](LICENSE) 开源。
