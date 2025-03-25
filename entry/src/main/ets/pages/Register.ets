import router from '@ohos.router'
import { preferences } from '@kit.ArkData';
@Entry
@Component
struct Register {
  new_userName:string = ''
  new_password:string = ''
  islike:boolean = false
  dataPreferences: preferences.Preferences | null = null


  build() {
    Column(){
      Text("注册")
      Row(){
        TextInput({placeholder:'用户名'}).onCopy((value)=>{
          this.new_userName = value
        })
      }
      .width("100%")
      .height(50)
      Row(){
        TextInput({placeholder:'密码'}).onCopy((value)=>{
          this.new_password = value
        })
      }
      .width("100%")
      .height(50)
      Row(){
        TextInput({placeholder:'再次输入密码'}).onCopy((value)=>{
          if(value!=this.new_password){
            //密码不一致
          }else {
            this.islike = true
          }
        })
      }
      .width("100%")
      .height(50)
      Button("注册")
        .onClick(()=>{
          router.replaceUrl({
            url:"pages/Open"
          })
          console.log("app","back")
        })


    }
    .height('100%')
    .width('100%')
  }
}