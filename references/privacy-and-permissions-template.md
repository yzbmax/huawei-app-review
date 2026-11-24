# HarmonyOS 审核合规代码实现与配置范式

本参考文档提供在 ArkTS (Stage 模型) 中满足华为应用市场最新审核规范的生产级代码与配置范式。重点覆盖**首次隐私协议时序控制**、**撤回隐私同意**、**系统安全控件免权限方案 (SaveButton/PasteButton/LocationButton/PhotoViewPicker)**、**双清单组件**与**华为账号登录接入**。

---

## 目录
1. [`module.json5` 权限声明与 reason 规范](#一modulejson5-权限声明与-reason-规范-api-12-26)
2. [首次启动隐私弹窗与合规时序 (ArkTS 实现)](#二首次启动隐私弹窗与合规时序-arkts-实现)
3. [撤回隐私同意与状态回退逻辑](#三撤回隐私同意与状态回退逻辑)
4. [系统安全控件免权限实战 (SaveButton / PasteButton / LocationButton / PhotoViewPicker)](#四系统安全控件免权限实战重中之重)
5. [权限动态申请与拒绝优雅降级 (无循环弹窗、防闪退)](#五权限动态申请与拒绝优雅降级-无循环弹窗防闪退)
6. [个人信息保护“双清单”界面模板](#六个人信息保护双清单界面模板)
7. [华为账号一键登录规范 (支持第三方登录时的强制要求)](#七华为账号一键登录规范-支持第三方登录时的强制要求)
8. [构建与提审准备检查项 (`build-profile.json5`)](#八构建与提审准备检查项-build-profilejson5)

---

## 一、`module.json5` 权限声明与 reason 规范 (API 12-26)

### 1. `module.json5` 声明示例
必须遵循权限最小化原则。**凡是可以通过系统安全控件或系统 Picker 解决的场景，一律不静态申请长期敏感权限**。

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
> - ✅ 正确写法：明确交代**在什么具体场景下**、**获取什么数据（行为）**、**用于达成什么具体目的（结果）**。

---

## 二、首次启动隐私弹窗与合规时序 (ArkTS 实现)

### 核心铁律：
1. **用户未点击“同意”前，绝不调用任何敏感 API（如 OAID、剪贴板、位置等），绝不初始化任何第三方 SDK。**
2. 弹窗必须具备明确的“同意”与“不同意/退出”选项，严禁默认勾选，严禁使用“好的/我知道了”等模糊词。

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
              // 跳转隐私政策详情页或拉起 Web 浏览器
            })
          Span('与')
          Span('《用户服务协议》')
            .fontColor('#0A59F7')
            .onClick(() => {
              // 跳转用户协议详情页
            })
          Span('。我们将严格按照政策说明收集、使用和保护您的个人信息。未经您的同意，我们不会收集设备标识或向第三方共享您的个人信息。')
        }
        .fontSize(14)
        .lineHeight(22)
        .fontColor('#666666')
      }
      .maxHeight(220)

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

## 三、撤回隐私同意与状态回退逻辑

> **审核要求**：必须在应用二级页面（如“设置-隐私政策”）提供“撤回隐私政策同意”的途径。撤回后，应用应清除本地同意凭据，并回退到未授权状态或游客模式，严禁应用直接崩溃或锁死。

```typescript
// PrivacyConsentManager.ets
import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

export class PrivacyConsentManager {
  private static readonly PREF_NAME = 'app_privacy_store';
  private static readonly KEY_AGREED = 'privacy_agreed_status';

  /**
   * 记录用户已同意隐私政策
   */
  public static async markAgreed(context: common.UIAbilityContext): Promise<void> {
    const pref = await preferences.getPreferences(context, PrivacyConsentManager.PREF_NAME);
    await pref.put(PrivacyConsentManager.KEY_AGREED, true);
    await pref.flush();
  }

  /**
   * 查询是否已同意
   */
  public static async isAgreed(context: common.UIAbilityContext): Promise<boolean> {
    const pref = await preferences.getPreferences(context, PrivacyConsentManager.PREF_NAME);
    return (await pref.get(PrivacyConsentManager.KEY_AGREED, false)) as boolean;
  }

  /**
   * 撤回隐私政策同意 (重置状态，停用已初始化的服务)
   */
  public static async revokeConsent(context: common.UIAbilityContext, onRevoked: () => void): Promise<void> {
    const pref = await preferences.getPreferences(context, PrivacyConsentManager.PREF_NAME);
    await pref.put(PrivacyConsentManager.KEY_AGREED, false);
    await pref.flush();
    
    // 执行撤回后清理逻辑，如停用上报、清空缓存标识、提示用户
    onRevoked();
  }
}
```

---

## 四、系统安全控件免权限实战（重中之重）

在 HarmonyOS 中，官方强烈倡导使用**安全控件（Security Component）**。**用户主动点击安全控件即视为一次临时授权（无需弹窗、无需配置敏感权限）**。如果开发者可使用安全控件却依然声明敏感权限，华为应用市场将直接驳回。

### 1. `SaveButton` 保存图片/文件到系统相册（免权限）
无需在 `module.json5` 申请受限的 `ohos.permission.WRITE_IMAGEVIDEO`。

```typescript
// SaveImageComponent.ets
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';

@Component
export struct SaveImageComponent {
  // 待保存的临时文件路径或 PixelMap
  private tempFilePath: string = '';

  build() {
    Column() {
      // 使用系统 SaveButton 安全控件
      SaveButton({
        icon: SaveIconStyle.FULL_FILLED,
        text: SaveDescription.SAVE_IMAGE,
        buttonType: ButtonType.Capsule
      })
      .onClick(async (event: ClickEvent, result: SaveButtonOnClickResult) => {
        if (result === SaveButtonOnClickResult.SUCCESS) {
          // 获得系统授予的 10 秒临时写入特权
          try {
            const context = getContext(this) as common.UIAbilityContext;
            const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
            // 直接安全创建媒体资源，无需长期写权限
            const assetUri = await phAccessHelper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg');
            const file = await fileIo.open(assetUri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
            // 写入图片数据...
            await fileIo.close(file);
            promptAction.showToast({ message: '图片已成功保存至相册' });
          } catch (err) {
            console.error(`Save image failed: ${JSON.stringify(err)}`);
          }
        } else {
          promptAction.showToast({ message: '保存失败或已取消' });
        }
      })
    }
  }
}
```

### 2. `PhotoViewPicker` 选择相册图片（免媒体读取权限）
无需在 `module.json5` 申请 `ohos.permission.READ_IMAGEVIDEO`。

```typescript
// PhotoPickerHelper.ets
import { photoAccessHelper } from '@kit.MediaLibraryKit';

export class PhotoPickerHelper {
  /**
   * 拉起系统图库选择单张或多张图片（完全免权限）
   */
  public static async selectPhotos(maxSelectNumber: number = 1): Promise<Array<string>> {
    try {
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = maxSelectNumber;

      const photoPicker = new photoAccessHelper.PhotoViewPicker();
      const photoSelectResult = await photoPicker.select(photoSelectOptions);
      return photoSelectResult.photoUris;
    } catch (err) {
      console.error(`PhotoViewPicker failed: ${JSON.stringify(err)}`);
      return [];
    }
  }
}
```

### 3. `PasteButton` 粘贴剪贴板内容（免敏感探针拦截）
严禁在冷启动或页面加载时无交互探测剪贴板，使用 `PasteButton` 保障 100% 合规。

```typescript
// SafePasteComponent.ets
import { pasteboard } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';

@Component
export struct SafePasteComponent {
  @State pastedContent: string = '';

  build() {
    Row({ space: 8 }) {
      TextInput({ text: this.pastedContent, placeholder: '点击右侧按钮粘贴' })
        .layoutWeight(1)

      PasteButton()
        .onClick(async (event: ClickEvent, result: PasteButtonOnClickResult) => {
          if (result === PasteButtonOnClickResult.SUCCESS) {
            try {
              const systemPasteboard = pasteboard.getSystemPasteboard();
              const pasteData = await systemPasteboard.getData();
              this.pastedContent = pasteData.getPrimaryText() || '';
            } catch (e) {
              promptAction.showToast({ message: '读取剪贴板失败' });
            }
          }
        })
    }
  }
}
```

### 4. 安全控件设计红线自查：
- ✅ **真实清晰可见**：必须为标准尺寸（推荐高度 >= 36vp），严禁设置为完全透明、隐藏或 1x1 像素。
- ✅ **所见即所得**：按钮文案必须与行为严格一致，严禁挂羊头卖狗肉（如按钮文字标为“领取红包/抽奖”，实际点击挂载 `SaveButton` 写入媒体）。
- ✅ **错误优雅处理**：在回调中校验 `result === SUCCESS`，处理取消或失败分支，严禁闪退。

---

## 五、权限动态申请与拒绝优雅降级 (无循环弹窗、防闪退)

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

## 六、个人信息保护“双清单”界面模板

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
    { name: '相册图片', purpose: '作品创作与图片处理', scene: '用户主动在画廊选择图片时', frequency: '用户操作时按需调用' }
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

## 七、华为账号一键登录规范 (支持第三方登录时的强制要求)

> **审核规则 3.16**：若应用支持任何第三方登录（微信、QQ、微博等），必须同步提供华为账号登录（Account Kit）。

```typescript
// HuaweiLoginButton.ets
import { authentication } from '@kit.AccountKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

export async function loginWithHuaweiID(): Promise<authentication.AuthorizationWithHuaweiIDResponse | undefined> {
  const loginRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
  loginRequest.scopes = ['openid']; // 按需申请权限范围，遵循最小化原则
  
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

## 八、构建与提审准备检查项 (`build-profile.json5`)

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
