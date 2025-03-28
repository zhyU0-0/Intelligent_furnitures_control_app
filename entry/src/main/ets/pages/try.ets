import { search_device } from './Search_device'


@Component
struct Page {

  build() {
    Column(){
      search_device()
    }
  }
}


@Entry
@Component
struct Index {
  @State checkboxEnabled: boolean = true;
  build() {
    Column({ space: 100 }) {
      /*Checkbox()
        //.contentModifier(new MyCheckboxStyle(Color.Red))
        .onChange((value: boolean) => {
          console.info('Checkbox change is' + value)
        }).enabled(this.checkboxEnabled)*/

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
}