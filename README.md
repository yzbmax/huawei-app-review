<p align="right">
  <strong>简体中文</strong> | <a href="./README_en.md"><strong>English</strong></a>
</p>

# 🛡️ huawei-app-review

**华为应用市场审核合规指南与避坑指南 Skill (Huawei AppGallery Review Skill)**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)](LICENSE)
[![HarmonyOS](https://img.shields.io/badge/HarmonyOS-NEXT%20%2F%206.x%20%2F%207.x-c0272d?style=flat-square)](https://developer.huawei.com/)
[![Language](https://img.shields.io/badge/Language-ArkTS%20%2F%20Stage%20Model-007acc?style=flat-square)](https://developer.huawei.com/)
[![API](https://img.shields.io/badge/API-12%20--%2026-orange?style=flat-square)](https://developer.huawei.com/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](https://github.com/yzbmax/huawei-app-review/pulls)

> **让 AI 编程助手在写鸿蒙代码的第一天，就避开所有华为应用市场审核驳回红线。**
> 面向 Claude Code、Cursor、Gemini CLI、Antigravity 等 AI 助手的华为终端官方审核合规实战指南与代码模板库。
>
> 📅 **最后更新 / Last Updated**: 2026-09-10

---

## 🎯 为什么需要本 Skill？

在 HarmonyOS NEXT（纯血鸿蒙）开发中，**超过 60% 的新应用首次提审都会被华为应用市场驳回**。AI 编程助手在未经过专门合规知识约束的情况下，往往容易犯以下致命错误：

- ❌ **启动偷跑数据**：在用户点击隐私弹窗同意前，提前初始化 SDK 或调用设备标识（OAID/AAID/剪贴板），直接触发系统安全探针违规。
- ❌ **权限一揽子索要**：在 `EntryAbility` 启动时批量弹窗索要相机、麦克风或定位权限，违反“动态最小化”原则。
- ❌ **缺少隐私“双清单”**：二级菜单中缺失“已收集个人信息清单”与“第三方共享个人信息清单”。
- ❌ **三方登录缺失华为账号**：接入了微信/QQ登录，却未同步提供华为账号服务 (Account Kit)。
- ❌ **未关调试模式**：使用 `debuggable: true` 打包提审直接驳回。
- ❌ **占位/半成品页面**：主功能存在空数据未处理、点击假死或“敬请期待”空壳。

**安装本 Skill 后**：AI 在架构设计、编码、权限配置及提审打包全生命周期内，会自动对照《华为应用市场审核指南》红线要求，生成 100% 具备过审资质的代码与配置。

---

## ✨ 核心特性

- 🚨 **TOP 10 核心审核红线速查**：直击工信部备案、隐私弹窗三要素、零调用铁律、自动续费防坑等高危禁区。
- 📖 **13 大官方审核板块全收录**：覆盖元数据、系统规范、架构质量、UGC管控、广告交互、未成年人保护、重点业务（深度合成/生成式 AI 标识等）及负面清单。
- 💻 **生产级 ArkTS 代码范式**：
  - 符合规范的**首次启动隐私协议弹窗**（含双按钮、非同意零调用时序控制）。
  - 开箱即用的**个人信息双清单组件（DoubleListDialog）**。
  - `module.json5` 与 `string.json` **权限 reason 规范写作范例**。
  - 开启混淆且不误杀 NAPI/底层符号的 `obfuscation-rules.txt` 规则。
- 📋 **提审前终极检查清单 (Pre-Flight Checklist)**：13 项上线前必打勾自查清单，确保一次过审。

---

## 🚀 快速安装

### 方式一：一键自动安装（推荐）

打开终端执行以下命令，脚本会自动检测本机已安装的 AI CLI（Claude Code / Cursor / Gemini / Antigravity）并自动建立软链：

```bash
curl -fsSL https://raw.githubusercontent.com/yzbmax/huawei-app-review/main/install.sh | bash
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
├── install.sh                ← 跨 AI CLI 一键安装部署脚本
├── LICENSE                   ← MIT 开源许可证
├── README.md                 ← 中文说明文档
├── README_en.md              ← English Documentation
└── references/
    └── privacy-and-permissions-template.md  ← 生产级 ArkTS 代码范式（隐私弹窗、双清单、混淆规则）
```

---

## 🛡️ TOP 10 核心审核红线预览

| 序号 | 驳回原因 | 核心审核红线与避坑法则 |
|---|---|---|
| **1** | **APP 未核准备案** | 上线前提早完成工信部 APP 备案核准，未核准无法过审。 |
| **2** | **隐私弹窗违规** | 首次启动必须弹窗明示；必须有**明确同意和拒绝**按钮；**严禁默认勾选**；**用户同意前严禁调用任何权限或初始化 SDK 收集个人数据**。 |
| **3** | **权限过度或提前索取** | 遵循权限最小化；业务触发时动态申请，**严禁启动时一揽子索权**；拒绝后绝不能退出应用或循环弹窗；必须配置精准清晰的 `reason`。 |
| **4** | **缺少隐私“双清单”** | 应用二级菜单中必须提供**已收集个人信息清单**与**与第三方共享个人信息清单**。 |
| **5** | **缺失注销或撤销渠道** | 必须提供便捷的撤销隐私同意入口和账号注销服务，承诺处理时限不超过 15 个工作日。 |
| **6** | **三方登录未配华为账号** | 若支持三方登录（微信/QQ等），**必须同时提供华为账号登录 (Account Kit)**。 |
| **7** | **提供不可关闭/误触广告** | 标明“广告”字样；提供真实有效一键关闭按钮；**严禁同一广告位叠加摇动+滑动**，摇一摇灵敏度严格防误触。 |
| **8** | **自动续费欺骗诱导** | 开通前明示价格与周期；必须同步提供单次开通选项；**必须在自动续费前 5 日进行显著提醒**。 |
| **9** | **功能缺陷与未开发完善** | 严禁启动白屏/闪退、界面截断；严禁功能模块点击无响应；严禁主功能未完善或空数据无兜底；提审包必须为 Release 正式包。 |
| **10** | **同质化与饱和类别套壳** | 严禁纯网页打包、单图/单页应用；计算器/记事本等饱和类别无独创功能将直接拒审。 |

---

## 🤝 参与贡献

华为应用市场审核规范会随监管法规和鸿蒙系统版本持续演进。欢迎提交 PR 或 Issue 补充最新的审核避坑实战经验与代码模板！

## 📄 开源许可证

本项目基于 [MIT License](LICENSE) 开源。
