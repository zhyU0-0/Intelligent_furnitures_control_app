import router from '@ohos.router';
import { preferences } from '@kit.ArkData';
import cryptoFramework from '@ohos.security.cryptoFramework';
import common from '@ohos.app.ability.common';
import util from '@ohos.util';

@Entry
@Component
struct NewPage {
  @State input_userName: string = '';
  @State input_password: string = '';
  @State is_landing: boolean = false;
  @State showToast: boolean = false;
  @State toastMessage: string = '';
  @State toastColor: string = '#721c24';
  @State toastBorderColor: string = '#721c24';
  @State toastTextColor: string = '#721c24';
  private userPreferences: preferences.Preferences | null = null;

  async aboutToAppear() {
    const context = getContext(this) as common.UIAbilityContext;
    this.userPreferences = await preferences.getPreferences(context, 'userData');
    const is_land =  await this.userPreferences.get("is_land",false)
    if(is_land){
      router.replaceUrl({ url: "pages/Search_devices" });
    }
  }

  build() {
    Stack() {
      Column({ space: 20 }) {
        Text("登录")
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 50 })
          .fontColor('#254e7a');


        Row() {
          Image($r('app.media.user_icon'))
            .width(20)
            .height(20)
            .margin({ right: 10 })
          TextInput({ placeholder: '请输入用户名' })
            .onChange(v => this.input_userName = v)
            .width("calc(100% - 100px)")
            .padding({ left: 10, right: 10 })
            .borderRadius(10)
            .border({ width: 1, color: Color.Gray });
        }
        .width("90%")
        .height(50);

        Row() {
          Image($r('app.media.password_icon'))
            .width(20)
            .height(20)
            .margin({ right: 10 })

          TextInput({ placeholder: "请输入密码" })
            .type(InputType.Password)
            .onChange(v => this.input_password = v)
            .width("calc(100% - 100px)")
            .padding({ left: 10, right: 10 })
            .borderRadius(10)
            .border({ width: 1, color: Color.Gray });
        }
        .width("90%")
        .height(50);

        Button("登录")
          .width("90%")
          .height(50)
          .backgroundImage(this.is_landing ? $r('app.media.R_L_bg') : $r('app.media.btn_bg'))
          .backgroundImageSize(ImageSize.Cover)
          .fontColor(this.is_landing ? Color.Blue : Color.White)
          .border({ width: 2, color: this.is_landing ? Color.Blue : Color.Transparent })
          .borderRadius(10)
          .enabled(!this.is_landing)
          .onClick(async () => {
            if (!this.validateInput()) return;
            this.is_landing = true;
            try {
              const success = await this.handleLogin();
              if (success) {
                this.showCustomToast('登录成功', 'success');
                setTimeout(() => {
                  router.replaceUrl({ url: "pages/Index" });
                }, 200);

              }
            } finally {
              this.is_landing = false;
            }
          });

        Button("注册")
          .width("90%")
          .height(50)
          .backgroundImage($r('app.media.btn_bg'))
          .backgroundImageSize(ImageSize.Cover)
          .fontColor(Color.White)
          .borderRadius(10)
          .onClick(() => {
            router.replaceUrl({ url: "pages/Register" });
          });
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center);

      if (this.showToast) {
        Column() {
          Text(this.toastMessage)
            .fontSize(16)
            .padding(12)
            .backgroundColor(this.toastColor)
            .borderRadius(8)
            .fontColor(this.toastTextColor)
            .border({ width: 1, color: this.toastBorderColor });
        }
        .width('100%')
        .position({ y: '80%' })
        .alignItems(HorizontalAlign.Center)
        .onClick(() => this.showToast = false);
      }
    }
  }

  private showCustomToast(message: string, type: 'success' | 'error') {
    this.toastColor = type === 'success' ? '#d4edda' : '#f8d7da';
    this.toastBorderColor = type === 'success' ? '#155724' : '#721c24';
    this.toastTextColor = type === 'success' ? '#155724' : '#721c24';
    this.toastMessage = message;
    this.showToast = true;
    setTimeout(() => this.showToast = false, 1000);
  }

  private validateInput(): boolean {
    if (!this.input_userName.trim()) {
      this.showCustomToast('请输入用户名', 'error');
      return false;
    }
    if (!this.input_password.trim()) {
      this.showCustomToast('请输入密码', 'error');
      return false;
    }
    return true;
  }

  private async handleLogin(): Promise<boolean> {
    try {
      if (!this.userPreferences) {
        this.showCustomToast('系统未初始化', 'error');
        return false;
      }

      const users = await this.userPreferences.get('user_list', '[]') as string;
      const userList: string[] = JSON.parse(users);
      if (!userList.includes(this.input_userName)) {
        this.showCustomToast('用户不存在', 'error');
        return false;
      }

      const storedPassword = await this.userPreferences.get(`user_${this.input_userName}`, '');
      if (!storedPassword) {
        this.showCustomToast('密码数据异常', 'error');
        return false;
      }

      const encryptedPassword = await this.encryptPassword(this.input_password);
      if (encryptedPassword !== storedPassword) {
        this.showCustomToast('密码错误', 'error');
        return false;
      }

      await this.userPreferences.put('last_login', this.input_userName);
      await this.userPreferences.put("is_land",true)
      await this.userPreferences.flush();
      return true;
    } catch (error) {
      this.showCustomToast(`登录失败: ${error.message}`, 'error');
      return false;
    }
  }

  private async encryptPassword(plainText: string): Promise<string> {
    try {
      const md = cryptoFramework.createMd('SHA256');
      const input: cryptoFramework.DataBlob = {
        data: new util.TextEncoder().encode(plainText)
      };
      await md.update(input);
      const digest = await md.digest();
      return Array.from(new Uint8Array(digest.data))
        .map((b: number) => b.toString(16).padStart(2, '0'))
        .join('');
    } catch (error) {
      throw new Error('密码加密失败: ' + error.message);
    }
  }
}
