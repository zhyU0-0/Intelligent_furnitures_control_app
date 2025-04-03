import { IoTad } from '../tool/IoTad';
import { On } from '@ohos.UiTest';


let _IoTad:IoTad = new IoTad()
@Entry
@Component
struct Test_Page {
  @State message: string|number = 'Hello World';

  aboutToAppear(): void {
    _IoTad.init()
  }
  build() {
    Column() {

      Text(this.message.toString()).width("100%").height("40%")
      Button("获取数据")
        .onClick(async ()=>{
          this.message = await _IoTad.get_data()
        })

      Row(){
        Button("窗帘开").onClick(()=>{
          _IoTad.set_curtain_by_id("on")
        })
        Button("窗帘关").onClick(()=>{
          _IoTad.set_curtain_by_id("off")
        })
      }
      Row(){
        Button("风扇开").onClick(()=>{
          _IoTad.set_fan_by_id("on")
        })
        Button("风扇关").onClick(()=>{
          _IoTad.set_fan_by_id("off")
        })
      }
      Row(){
        Button("空调25").onClick(()=>{
          _IoTad.set_air_condition_by_id(25)
        })
        Button("空调28").onClick(()=>{
          _IoTad.set_air_condition_by_id(28)
        })
      }
      Row(){
        Button("灯开").onClick(()=>{
          _IoTad.set_LED_brightness_by_id(8888)
        })
        Button("灯关").onClick(()=>{
          _IoTad.set_LED_brightness_by_id(1)
        })
      }
    }
    .height('100%')
    .width('100%')
  }
}