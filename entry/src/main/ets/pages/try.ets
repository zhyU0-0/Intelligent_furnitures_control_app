import { HttpRequest } from '../entryability/HttpFuntion';
import { search_device } from './Search_devices'
import { http } from '@kit.NetworkKit';


@Component
struct Page {

  build() {
    Column(){

    }
  }
}


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
}