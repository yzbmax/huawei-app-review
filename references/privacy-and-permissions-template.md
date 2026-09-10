# HarmonyOS 审核合规代码实现与配置范式

本参考文档提供在 ArkTS (Stage 模型) 中满足华为应用市场审核规范的生产级代码模板。

---

## 一、`module.json5` 权限声明与 reason 规范 (API 22-26)

### 1. `module.json5` 声明示例
必须遵循最小化原则，仅声明实际业务必需的权限：

```json5
{
  "module": {
    "name": "entry",
    "type": "entry",
    // ...
    "requestPermissions": [
      {
        "name": "ohos.permission.CAMERA",
        "reason": "$string:permission_reason_camera",
        "usedScene": {
          "abilities": ["EntryAbility"],
          "when": "inuse"
        }
      },
      {
        "name": "ohos.permission.MICROPHONE",
        "reason": "$string:permission_reason_microphone",
        "usedScene": {
          "abilities": ["EntryAbility"],
          "when": "inuse"
        }
      }
    ]
  }
}
```

### 2. `string.json` 中 reason 写作规范 (严禁泛泛而谈)
在 `entry/src/main/resources/base/element/string.json` 中：

```json
{
  "string": [
    {
      "name": "permission_reason_camera",
      "value": "用于拍摄照片和录制视频，以便您在创作作品时导入素材"
    },
    {
      "name": "permission_reason_microphone",
      "value": "用于录制视频时同步录制环境音频"
    }
  ]
}
```

> **审核红线说明**：
> - ❌ 错误写法："为了保障更好的服务体验"、"系统需要该权限"（直接驳回）。
> - ✅ 正确写法：明确交代**在什么具体功能下（场景）**、**获取什么数据（行为）**、**用于达成什么目的（结果）**。

---

## 二、首次启动隐私弹窗与合规时序 (ArkTS 实现)

### 核心铁律：
1. **用户未点击“同意”前，绝不调用任何敏感 API（如 OAID、获取位置等），绝不初始化任何第三方收集 SDK。**
2. 弹窗必须具备明确的“同意”与“不同意/退出”选项，严禁默认勾选。

```typescript
// PrivacyDialog.ets
import { promptAction } from '@kit.ArkUI';

@CustomDialog
export struct PrivacyDialog {
  controller: CustomDialogController;
  onConfirm: () => void = () => {};
  onCancel: () => void = () => {};

  build() {
    Column({ space: 16 }) {
      Text('用户个人信息保护及隐私政策')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1a1a1a')

      Scroll() {
        Text() {
          Span('欢迎使用本应用！我们非常重视您的个人信息和隐私保护。在您使用本应用前，请认真阅读并充分理解')
          Span('《隐私政策》')
            .fontColor('#0A59F7')
            .onClick(() => {
              // 跳转隐私政策详情页或打开 H5
            })
          Span('与')
          Span('《用户服务协议》')
            .fontColor('#0A59F7')
            .onClick(() => {
              // 跳转用户协议详情页
            })
          Span('。我们将严格按照政策说明收集、使用和保护您的个人信息，未经您的同意，我们不会向第三方共享您的个人信息。')
        }
        .fontSize(14)
        .lineHeight(22)
        .fontColor('#666666')
      }
      .maxHeight(200)

      Row({ space: 12 }) {
        Button('不同意并退出')
          .layoutWeight(1)
          .backgroundColor('#f2f2f2')
          .fontColor('#666666')
          .onClick(() => {
            this.controller.close();
            this.onCancel();
          })

        Button('同意并继续')
          .layoutWeight(1)
          .backgroundColor('#0A59F7')
          .fontColor('#ffffff')
          .onClick(() => {
            this.controller.close();
            this.onConfirm();
          })
      }
      .width('100%')
    }
    .padding(24)
    .backgroundColor('#ffffff')
    .borderRadius(16)
  }
}
```

---

## 三、权限动态申请与拒绝优雅降级 (无循环弹窗、防闪退)

```typescript
// PermissionHelper.ets
import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';

export class PermissionHelper {
  private static atManager = abilityAccessCtrl.createAtManager();

  /**
   * 动态申请单个权限，并具备拒绝宽容降级处理
   */
  public static async requestPermissionWithFallback(
    context: common.UIAbilityContext,
    permission: Permissions,
    featureName: string,
    onGranted: () => void,
    onDeniedFallback?: () => void
  ): Promise<void> {
    try {
      const grantStatus = await PermissionHelper.atManager.requestPermissionsFromUser(context, [permission]);
      if (grantStatus.authResults.length > 0 && grantStatus.authResults[0] === 0) {
        // 授权成功 (0 = PERMISSION_GRANTED)
        onGranted();
      } else {
        // 用户拒绝：绝不能直接退出应用！提示影响的功能并提供备选方案
        console.warn(`[Permission] User denied ${permission} for ${featureName}`);
        if (onDeniedFallback) {
          onDeniedFallback();
        }
      }
    } catch (err) {
      console.error(`[Permission] Request failed: ${JSON.stringify(err)}`);
    }
  }
}
```

---

## 四、个人信息保护“双清单”界面模板

按照工信部与华为审核指南要求，应用二级菜单中必须常驻：
1. **已收集个人信息清单**
2. **与第三方共享个人信息清单**

```typescript
// PersonalInfoDoubleList.ets
interface InfoItem {
  name: string;
  purpose: string;
  scene: string;
  frequency: string;
}

interface SdkShareItem {
  sdkName: string;
  entity: string;
  dataShared: string;
  purpose: string;
  privacyLink: string;
}

@Component
export struct PersonalInfoDoubleList {
  @State activeTab: number = 0;

  // 1. 已收集清单
  private collectedList: InfoItem[] = [
    { name: '设备信息 (网络类型)', purpose: '适配网络状态并提示数据流量', scene: '应用启动及网络切换时', frequency: '单次触发' },
    { name: '相册图片', purpose: '作品创作与图片调色处理', scene: '用户主动在画廊选择图片时', frequency: '用户操作时按需调用' }
  ];

  // 2. 第三方共享清单 (若无第三方SDK，请明示“本应用未接入任何收集个人信息的第三方SDK”)
  private sdkList: SdkShareItem[] = [
    {
      sdkName: '未接入第三方共享SDK',
      entity: '无',
      dataShared: '无',
      purpose: '本应用完全离线运行，不与任何第三方实体共享用户数据',
      privacyLink: '无'
    }
  ];

  build() {
    Column() {
      // 切换 Tab
      Row() {
        Text('已收集个人信息清单')
          .fontWeight(this.activeTab === 0 ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.activeTab === 0 ? '#0A59F7' : '#333333')
          .onClick(() => this.activeTab = 0)
        
        Blank()

        Text('第三方共享信息清单')
          .fontWeight(this.activeTab === 1 ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.activeTab === 1 ? '#0A59F7' : '#333333')
          .onClick(() => this.activeTab = 1)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })

      // 清单内容展示
      List({ space: 12 }) {
        if (this.activeTab === 0) {
          ForEach(this.collectedList, (item: InfoItem) => {
            ListItem() {
              Column({ space: 6 }) {
                Text(`信息类型：${item.name}`).fontWeight(FontWeight.Medium)
                Text(`使用目的：${item.purpose}`).fontSize(13).fontColor('#666666')
                Text(`使用场景：${item.scene}`).fontSize(13).fontColor('#666666')
                Text(`收集频次：${item.frequency}`).fontSize(13).fontColor('#666666')
              }
              .alignItems(HorizontalAlign.Start)
              .padding(12)
              .backgroundColor('#f8f9fa')
              .borderRadius(8)
              .width('100%')
            }
          })
        } else {
          ForEach(this.sdkList, (item: SdkShareItem) => {
            ListItem() {
              Column({ space: 6 }) {
                Text(`共享方/SDK：${item.sdkName}`).fontWeight(FontWeight.Medium)
                Text(`运营主体：${item.entity}`).fontSize(13).fontColor('#666666')
                Text(`共享字段：${item.dataShared}`).fontSize(13).fontColor('#666666')
                Text(`使用目的：${item.purpose}`).fontSize(13).fontColor('#666666')
              }
              .alignItems(HorizontalAlign.Start)
              .padding(12)
              .backgroundColor('#f8f9fa')
              .borderRadius(8)
              .width('100%')
            }
          })
        }
      }
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })
    }
  }
}
```

---

## 五、华为账号一键登录规范 (支持第三方登录时的强求要求)

> **审核规则 3.16**：若应用支持任何三方登录（微信/微博等），必须同步提供华为账号登录（Account Kit）。

```typescript
// HuaweiLoginButton.ets
import { authentication } from '@kit.AccountKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

export async function loginWithHuaweiID(): Promise<authentication.AuthorizationWithHuaweiIDResponse | undefined> {
  const loginRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
  loginRequest.scopes = ['openid']; // 按需申请权限范围，最小化原则
  
  const controller = new authentication.AuthenticationController();
  try {
    const response = await controller.executeRequest(loginRequest);
    return response as authentication.AuthorizationWithHuaweiIDResponse;
  } catch (error) {
    hilog.error(0x0000, 'AccountKit', `HuaweiID Login failed: ${JSON.stringify(error)}`);
    return undefined;
  }
}
```

---

## 六、构建与提审准备检查项 (`build-profile.json5`)

在提交审核时，必须确保以下构建参数正确配置：

```json5
// build-profile.json5 (Release 模式配置)
{
  "app": {
    "signingConfigs": [
      {
        "name": "release",
        "material": {
          "certpath": "...", // 华为 AGC 正式证书
          "storePassword": "...",
          "keyAlias": "...",
          "keyPassword": "...",
          "profile": "...", // 正式 Release profile
          "signAlg": "SHA256withECDSA"
        }
      }
    ],
    "products": [
      {
        "name": "default",
        "signingConfig": "release",
        "compileSdkVersion": "6.1.1(24)", // 或匹配的 API 版本
        "compatibleSdkVersion": "6.1.0(23)",
        "targetSdkVersion": "6.1.1(24)",
        "buildOption": {
          "strictMode": true,
          "arkOptions": {
            "obfuscation": {
              "ruleOptions": {
                "enable": true, // 正式提审务必开启代码混淆
                "files": ["./obfuscation-rules.txt"]
              }
            }
          }
        }
      }
    ]
  }
}
```
