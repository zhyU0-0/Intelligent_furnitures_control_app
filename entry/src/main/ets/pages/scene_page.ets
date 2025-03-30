import { Furniture, room } from "../tool/classes"
import { _IoTad } from "./scan_devices"

@Entry
@Component
export struct scene{

  @Link arr_room:room[]
  @State List_scene:string[] = ["睡眠模式","离家模式","娱乐模式"]
  @State is_show_sleep:boolean = false
  @State is_show_leaving:boolean = false
  @State this_scene:string = ''
  @State _height:string = "0%"


  build() {
    Stack(){
      List(){
        ForEach(this.List_scene,(item:string,value)=>{
          ListItem(){
            Row(){
              Text(item)
            }.padding(10).width('100%').height("100%").backgroundColor(Color.White)
            .onClick(()=>{
              this.this_scene = item
              if(value == 0){
                this.is_show_sleep = true
                animateTo({duration:500},()=>{
                  this._height = "100%"
                })
              }else if(value == 1){
                this.is_show_leaving = true
                animateTo({duration:500},()=>{
                  this._height = "100%"
                })
              }


            })
          }.width("100%").height("20%").padding(10).backgroundColor(value%2?Color.Pink:Color.Orange)
          ListItem().height(10)
        })



      }
      if(this.is_show_sleep){
        scenes({
          scene:this.this_scene,
          arr_room:this.arr_room,
          _height:this._height,
          is_show:this.is_show_sleep
        })
      }
      if(this.is_show_leaving){
        leaving_scene({
          arr_room:this.arr_room,
          _height:this._height,
          is_show:this.is_show_leaving
        })
      }
    }
  }
}

@Component
struct scenes{
  @Link scene:string
  @Link arr_room:room[]
  @Link _height:string
  @Link is_show:boolean
  @State List_f:Furniture[] = []
  aboutToAppear(): void {
    for(let r of this.arr_room){
      for(let f of r.furniture_s){
        if(f.type_id>999&&f.type_id<3000){
          this.List_f.push(f)
        }
      }
    }
  }
  build() {
    Stack(){
        Column(){
          List(){
            ListItem(){
              Row(){
                Text(this.scene)
                Row().width("50%")
                Button("返回").onClick(()=>{
                  this.is_show = false
                  this._height = "0%"
                })
              }.width("100%").height("20%")

            }
            ForEach(this.List_f,(item:Furniture,value)=>{
              ListItem(){
                Row(){
                  Text(item.name).fontSize(20).width("20%")
                  Row().width("60%")
                  Toggle({ type: ToggleType.Switch, isOn:item.switch? true:false })
                    .onClick(() => {
                      if (!item.switch) {
                        item.switch = 1
                        _IoTad.set_curtain_by_id("on")
                      } else {
                        item.switch = 0
                        _IoTad.set_curtain_by_id("off")
                      }
                    })
                }
                .width("95%").height("15%").borderRadius(5).backgroundColor(Color.White).padding(10)
              }
              ListItem().height(10)
            })
          }.padding(10)
        }.width("100%").height(this._height).backgroundColor(Color.White)
        .backgroundColor(Color.Pink)



    }
  }
}

@Component
struct leaving_scene{
  @Link arr_room:room[]
  @Link _height:string
  @Link is_show:boolean

  build() {
    Column(){
      Row() {
        Column(){
          Text("温度")
          Text("燃气")
          Text("湿度")
        }
        Row().width("50%")
        Button("返回")
          .onClick(()=>{
            this.is_show = false
            this._height = "0%"

          })
      }.width("100%").height("35%")
      List(){
        ListItem(){
          Row(){
            Text("摄像头").width("20%")
            Row().width("60%")
            Button("查看")
              .onClick(()=>{
                //看摄像头
              })
          }.width("95%").height("15%").borderRadius(5).backgroundColor(Color.White).padding(10)
        }
        ListItem().height(10)
        ListItem(){
          Row(){
            Text("空调").width("20%")
            Row().width("60%")
            Button("控制")
              .onClick(()=>{
                //远程控制空调
              })
          }.width("95%").height("15%").borderRadius(5).backgroundColor(Color.White).padding(10)
        }
        ListItem().height(10)
        ListItem(){
          Row(){
            Text("宠物喂食器").width("20%")
            Row().width("60%")
            Button("控制")
              .onClick(()=>{
                //控制宠物喂食器
              })
          }.width("95%").height("15%").borderRadius(5).backgroundColor(Color.White).padding(10)
        }
        ListItem().height(10)
      }.height("70%")
      .backgroundColor(Color.Pink).borderRadius(10).padding(10)

    }.width("100%").height(this._height).backgroundColor(Color.White)
  }
}