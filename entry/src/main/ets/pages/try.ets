import { HttpRequest } from '../data/HttpFuntion';
import { search_device } from './Search_devices'
import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';





@Entry
@Component
struct Index {
  @State checkboxEnabled: boolean = true;
  build() {
    Column({ space: 100 }) {

      Row() {
        Toggle({ type: ToggleType.Switch, isOn: true }).onClick(() => {
          if (!this.checkboxEnabled) {
            this.checkboxEnabled = true
          } else {
            this.checkboxEnabled = false
          }
        })
      }.position({ x: 50, y: 130 })
    }.margin({top : 30})
  }

  http(){
    let myhttp = http.createHttp()

  }

  private readonly BASE_URL = 'http://192.168.204.68';

  // 发送控制命令（如方向控制）
  async sendCommand(command: string): Promise<void> {
    const url = `${this.BASE_URL}/cgi-bin/ptz.cgi?action=${command}`;
    try {
      let response = await http.createHttp().request(url,{method:http.RequestMethod.GET,readTimeout:10000})

      console.log(`Control success: ${response.result}`);
    } catch (err) {
      console.error(`Control failed: ${(err as BusinessError).message}`);
    }
  }

  // 获取视频流（显示在Web组件中）
  getVideoStreamUrl(): string {
    return `${this.BASE_URL}/video`;
  }

}
