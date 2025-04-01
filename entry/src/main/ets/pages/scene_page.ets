import { Furniture, room } from "../tool/classes"
import { control_aircon, control_air_condition } from "../tool/component"
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
  @State is_open:boolean = false
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
          Row(){
            Text(this.scene)
            Row().width("50%")
            Button("返回").onClick(()=>{
              this.is_show = false
              this._height = "0%"
              this.is_open = false
            })
            Button(this.is_open?"关闭":"开启")
              .onClick(()=>{
                /*for(let r of this.arr_room){
                  for(let f of r.furniture_s){
                    if(f.type_id>999&&f.type_id<3000){
                      f.switch = 0
                    }
                  }
                }*/
                console.log("L:::1")
                let L:Furniture[] = []
                for (let i of this.List_f){
                  i.switch = 0
                  L.push(i)
                }
                console.log("L:::2")
                this.List_f = L
                this.is_open = !this.is_open
                console.log("L:::3"+this.is_open+JSON.stringify(this.List_f))
              })
          }
              .width("100%").height("20%").backgroundColor(Color.White)
          List(){
            ForEach(this.List_f,(item:Furniture,value)=>{
              ListItem(){
                Row_s({item:item})
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
struct Row_s{
  @Prop item:Furniture
  build() {
    Row(){
      Text(this.item.name).fontSize(20).width("20%")
      Row().width("60%")
      Toggle({ type: ToggleType.Switch, isOn:this.item.switch? true:false })
        .onClick(() => {
          if (!this.item.switch) {
            this.item.switch = 1
            _IoTad.set_curtain_by_id("on")
          } else {
            this.item.switch = 0
            _IoTad.set_curtain_by_id("off")
          }
        })
    }.width("95%").height("15%").borderRadius(5).backgroundColor(Color.White).padding(10)
  }
}



@Component
struct leaving_scene{
  @Link arr_room:room[]
  @Link _height:string
  @Link is_show:boolean
  @State is_show_air_condition:boolean = false

  build() {
    Stack(){
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
                  this.is_show_air_condition = true
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
      if(this.is_show_air_condition){
        control_aircon({is_show:this.is_show_air_condition,arr_room:this.arr_room})
      }

    }

  }
}