import { router } from '@kit.ArkUI';
import { url } from '@kit.ArkTS';
import { LocalStoraga } from '../entryability/LocalStorage'
import { text } from '@kit.ArkGraphics2D';
import { HttpRequest } from '../entryability/HttpFuntion';

export let nameId:string
@Entry
@Component
struct NewPage {
  @State message: string = 'Hello World';
  @State input_userName: string = ''
  @State input_password: string = ''
  is_landing:boolean = false
  localstorage: LocalStoraga = new LocalStoraga("User_data")
  Http: HttpRequest = new HttpRequest()

  /**/
  aboutToAppear(): void {
    this.localstorage.getDate("username").then(_User_ => {
      console.log("user", _User_)
      this.input_userName = _User_ as string
    })
    this.localstorage.getDate('is_landing').then(value=>{
      console.log("is_landing:::"+value)
      this.localstorage.getDate('password').then(value1=>{
        nameId = value1.toString()
        console.log("password:::"+nameId)
        if (value){
          router.replaceUrl({
            url:"pages/scan_devices"

          })
          return
        }
      })

    })
    //this.Http.request("https://www.baidu.com/")


  }


  build() {


    Column() {


      Text("登录")
      Row() {
        TextInput({
          text: this.input_userName,
          placeholder: '请输入用户名'
        })
          .onChange((value: string) => {
            this.input_userName = value


          })
      }
      .width("100%")
      .height(50)

      Row() {
        TextInput({
          text: this.input_password,
          placeholder: "请输入密码"
        })
          .onChange((value: string) => {
            this.input_password = value
            nameId = value
          })

      }
      .width("100%")
      .height(50)

      Button("登录")
        .onClick(() => {
          console.log(this.input_userName + "s", this.input_password)
          if (this.input_userName != '') {
            if (this.input_password != '') {
              this.localstorage.setDate("username", this.input_userName)
              this.localstorage.setDate("password", this.input_password)
              router.replaceUrl({
                url: "pages/scan_devices"
              })
              this.localstorage.setDate("is_landing",true)
            } else {
              //输入密码
              AlertDialog.show({
                message: '请输入密码'
              })
            }
          } else {
            //输入用户名
            AlertDialog.show({
              message: '请输入用户名'
            })
          }
          console.log("app", "back")
        })
      Button("注册")
        .onClick(() => {

          router.replaceUrl({
            url: "pages/Register"
          })


          console.log("app", "back")
        })


    }
    .height('100%')
    .width('100%')
  }
}