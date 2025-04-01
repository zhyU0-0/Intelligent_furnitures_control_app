import { LocalStoraga } from "../entryability/LocalStorage";
import { RoomDatabase } from "../entryability/RdbStorage";
import { tcp } from "../pages/Index";
import { API_DeepSeek } from "../pages/OpenAI_Page";
import { _IoTad } from "../pages/scan_devices";
//import { tcp, udp } from "../pages/Index";
import {  Furniture, room } from "./classes";
import { router } from "@kit.ArkUI";
import { face_cam } from "../pages/face_cma";


let new_arr_rooms:room[]
let new_arr_f:Furniture[]

let Room_db:RoomDatabase = new RoomDatabase(globalThis.getContext())
let new_f_R_Id:number






@Component
export struct furniture_long {

  @Link _height:string
  @Prop room1:room
  @Link is_show_f:boolean
  @Link arr_f:Furniture[]
  @Link index_f:number
  o_name:string = ''
  @State Light_number:number = 0
  @Link is_chang:boolean
  @State is_c:boolean = true
  @State o_f:Furniture = new Furniture('',0,0)
  @Link t_f:Furniture

  aboutToAppear(): void {
    this.Light_number = this.arr_f[this.index_f].lighting
   this.o_f = this.arr_f[this.index_f]
  }
  build() {
    Stack() {
      Column() {
        Row(){
          Text(this.o_f.name)
            .position({
              y:50,
              x:20
            })
          Text(this.o_f.type_id.toString())
            .position({
              y:50,
              x:200
            })
        }
        Row(){
          Button('删除')
            .onClick(async ()=>{
              let r_id = await Room_db.getRoomsIdByName(this.room1.name)

              await Room_db.deleteFurnitureByRoomIdAndName(r_id,this.arr_f[this.index_f].name)
              this.arr_f = this.arr_f.filter((element) => element.name!== this.arr_f[this.index_f].name);
              this.is_chang = !this.is_chang
              this.is_show_f = false
              animateTo({duration:500},()=>{this._height = '0%'})

            })
            .padding(5)
            .width(100)
          Button('返回')
            .onClick(() => {
              this.is_show_f = false
              this.is_chang = !this.is_chang
              animateTo({duration:500},()=>{this._height = '0%'})
            })
            .padding(5)
            .width(100)
        }.height(100)
        .width('100%')
        .justifyContent(FlexAlign.SpaceAround)


      }
      .height("55%")
      .width('100%')
      .borderRadius(20)
      .backgroundColor(Color.White)
      .justifyContent(FlexAlign.End)
       if(this.o_f.type_id <2000 ){
        Text("亮度："+this.Light_number.toString())
          .position({
            y:250,
            x:20
          })
        if(this.o_f.lighting != 0){
          Slider({value:this.arr_f[this.index_f].lighting,max:10,min:1})
            .width('90%')
            .showSteps(true)
            .position({
              x:20,
              y:300
            })
            .onChange((value)=>{
              this.arr_f[this.index_f].lighting = value
              this.Light_number = value
              console.log("LL:"+this.Light_number.toString())
              this.is_chang = !this.is_chang
              tcp.sendLED_chang(value,this.arr_f[this.index_f].type_id)
              this.o_f = this.arr_f[this.index_f]
              //udp.sendLED_chang(value)
            })
        }
      }
      if(this.o_f.type_id >2999 && this.o_f.type_id<4000){
        Text("目前温度："+this.o_f.temp.toString())
          .position({ y:250, x:20 })
        Row() {
          Button("除湿")
        }
        .width(80).height(40).borderRadius(5)
        .position({y:350,x:20})
        .backgroundColor(this.arr_f[this.index_f].is_dry?Color.Blue:Color.White)

      }
    }

    .height(this._height)
    .width('100%')
    .backgroundColor('#9c000000')

  }
}

@Component
struct furniture_edit{

  @Link furniturn:Furniture
  @Link _height:string
  @Prop room1:room
  @Link is_show_f:boolean
  @State Light_number:number = 0
  @State o_f:Furniture = new Furniture('',0,0)
  @State is_c:boolean = false

  aboutToAppear(): void {
    this.Light_number = this.furniturn.lighting
    this.o_f = this.furniturn
    console.log("ccc:::"+this.is_c)
  }
  build() {
    Stack() {
      Column() {
        Row(){
          Text(this.o_f.name)
            .position({
              y:50,
              x:20
            })
          Text(this.o_f.type_id.toString())
            .position({
              y:50,
              x:200
            })

        }
        Row(){
          Button('返回')
            .onClick(() => {
              this.is_show_f = false
              animateTo({duration:500},()=>{this._height = '0%'})
            })
            .padding(5)
            .width(100)
        }.height(100)
        .width('100%')
        .justifyContent(FlexAlign.SpaceAround)


      }
      .height("55%")
      .width('100%')
      .borderRadius(20)
      .backgroundColor(Color.White)
      .justifyContent(FlexAlign.End)
      if(this.o_f.type_id <2000 ){
        Text("亮度："+this.Light_number.toString())
          .position({
            y:250,
            x:20
          })
        if(this.o_f.lighting != 0){
          Slider({value:this.furniturn.lighting,max:10,min:1})
            .width('90%')
            .showSteps(true)
            .position({
              x:20,
              y:300
            })
            .onChange((value)=>{
              this.furniturn.lighting = value
              this.Light_number = value
              console.log("LL:"+this.Light_number.toString())
              tcp.sendLED_chang(value,this.furniturn.type_id)
              this.o_f = this.furniturn
              //udp.sendLED_chang(value)
            })
        }



      }
      if(this.o_f.type_id >2999 && this.o_f.type_id<4000){
        Text("目前温度："+this.o_f.temp.toString())
          .position({ y:250, x:20 })
        Row() {
          Button("处湿")
        }
        .width(80).height(40).borderRadius(5)
        .position({y:350,x:20})
        .backgroundColor(this.furniturn.is_dry?Color.Blue:Color.White)

      }
    }

    .height(this._height)
    .width('100%')
    .backgroundColor('#9c000000')

  }
}
@Component
export struct add_furniture_page {
  @Link _height:string
  @Link arr: Furniture[]
  @State fur_name: string = ''
  @Link is_show: boolean
  type:number = 0

  build() {

    Stack() {
      Column() {
        TextInput({ placeholder: '输入家具名称' ,text:this.fur_name})
          .onChange((value) => {
            this.fur_name = value
          })
          .bindMenu(this.FurnitureMenu)
          .width(300)
          .position({
            y:50
          })
        TextInput({ placeholder: '输入家具ID' })
          .onChange((value) => {
            this.type = Number(value)
          })
          .width(300)
          .position({
            y:100
          })
        Button('完成')
          .backgroundImage($r('app.media.bottom_bg2'))
          .backgroundImageSize(ImageSize.Cover)
          .onClick(async () => {
            if (this.fur_name != ''&&this.type != 0) {
              //数据库
              console.log('roomwwwwww')
              console.log('roomwwwwww'+new_f_R_Id)
              let success = await Room_db.insertFuByRoomId(new_f_R_Id,this.fur_name,this.type)
              console.log('roomwwwwww  success'+success)
              if(success == 1 ){
                this.arr.push(new Furniture(this.fur_name, 0,this.type))
              }else{
                AlertDialog.show({
                  message:"名字或ID重复了喂 >o< "
                })
              }

            }
            new_arr_f = this.arr
            console.log("room^^:"+JSON.stringify(new_arr_f))
            animateTo({duration:500},()=>{this._height = '0%'})
            this.is_show = false
          })
      }
      .height("55%")
      .width('100%')
      .borderRadius(20)
      .backgroundImage($r('app.media.bottom_bg1'))
      .backgroundImageSize(ImageSize.Cover)
      .justifyContent(FlexAlign.End);
    }

    .height(this._height)
    .width('100%')
    .backgroundColor('#9c000000')

  }
  @Builder
  FurnitureMenu(){
    Menu(){
      MenuItem({/*startIcon:*/content:'LED'}).onClick(()=>{
        this.fur_name = 'LED'
      })
      MenuItem({/*startIcon:*/content:'窗帘'}).onClick(()=>{
        this.fur_name = '窗帘'
      })
      MenuItem({/*startIcon:*/content:'空调'}).onClick(()=>{
        this.fur_name = '空调'
      })
      MenuItem({/*startIcon:*/content:'冰箱'}).onClick(()=>{
        this.fur_name = '冰箱'
      })
      MenuItem({/*startIcon:*/content:'扫地机器人'}).onClick(()=>{
        this.fur_name = '扫地机器人'
      })
    }
  }
}

@Component
export struct add_room_page {
  @Link arr: room[]
  @State fur_name: string = ''
  @Link is_show: boolean

  build() {

    Stack() {
      Column() {
        TextInput({ placeholder: '输入房间名称' })
          .onChange((value) => {
            this.fur_name = value
          })
        Row(){
          Button('完成')
            .backgroundImage($r('app.media.bottom_bg2'))
            .backgroundImageSize(ImageSize.Cover)
            .onClick(async () => {
              if (this.fur_name != '') {
                let success = await Room_db.insertRoom(new room(this.fur_name, []))
                if(success != -1){
                  this.arr.push(new room(this.fur_name, []))
                }else{
                  AlertDialog.show({
                    message:"名字重复了喂 >o< "
                  })
                }

              }
              this.is_show = false
            })
            .padding(5)
            .width(100)
          Button('返回')
            .onClick(() => {
              this.is_show = false
            })
            .padding(5)
            .width(100)
        }
        .height(100)
        .width('100%')
        .justifyContent(FlexAlign.SpaceAround)
      }
      .height("55%")
      .width('100%')
      .borderRadius(20)
      .backgroundImage($r('app.media.bottom_bg1'))
      .backgroundImageSize(ImageSize.Cover)
      .justifyContent(FlexAlign.End);
    }

    .height('100%')
    .width('100%')
    .backgroundColor('#9c000000')

  }
}

@Component
export struct myList {


  @Prop room1: room
  @State num1: number = 1
  @State num2: number = 1
  @Prop arr_fnt: Furniture[]
  @State show_add: boolean = false
  @Prop index:number
  @State is_show_f:boolean = false
  //@State f_name:string = ''
  //@State f_type:number = 0
  //@State f_switch:number = 0
  @Link is_sleep:boolean
  @State index_f:number = 0
  @State _height:string = "0%"
  //@State _brightness:number = 0


  @State this_f:Furniture = new Furniture('',0,1)
  @State is_change:boolean = true

  aboutToAppear(): void {

  }
  aboutToDisappear(): void {
    this.room1.furniture_s = this.arr_fnt
  }
  build() {
    Stack() {
      List() {
        ForEach(this.arr_fnt, (item: Furniture, index) => {
          ListItem() {
            Row(){
              myRow({ item1: item ,is_sleep:this.is_sleep ,is_chang:this.is_change})
            }.gesture(
              // 绑定可以重复触发的LongPressGesture
              LongPressGesture({ repeat: true ,duration :300 })
                .onAction((event: GestureEvent|undefined) => {
                  if(event){
                    if (event.repeat) {
                      this.this_f = item
                      this.is_show_f = true
                      this.index_f = index
                      animateTo({duration:200},()=>{
                        this._height = "100%"

                      })
                      console.log('Long_touch')
                    }
                  }
                })
                .onActionEnd(() => {
                })
            )
            .onClick(()=>{
              if(item.type_id<2000){
                if(item.switch){
                  this.arr_fnt[index] = new Furniture(item.name,0,item.type_id)
                  this.arr_fnt[index].lighting = 0
                  tcp.send_off(this.arr_fnt[index].type_id)
                }else{
                  this.arr_fnt[index] = new Furniture(item.name,1,item.type_id)
                  this.arr_fnt[index].lighting = 5
                  tcp.send_on(this.arr_fnt[index].type_id)
                  console.log("ROom F IS :"+JSON.stringify(this.arr_fnt))
                }
              }else{
                if(item.switch){
                  this.arr_fnt[index] = new Furniture(item.name,0,item.type_id)
                  tcp.send_off(this.arr_fnt[index].type_id)
                }else{
                  this.arr_fnt[index] = new Furniture(item.name,1,item.type_id)
                  tcp.send_on(this.arr_fnt[index].type_id)
                }
              }

            })
          }
          .padding(10)
          .onClick(()=>{
            console.log("myRow:" + JSON.stringify(item))
          })
        })
        ListItem() {
          Row(){
            Button("+")
              .onClick(async () => {
                new_f_R_Id = await Room_db.getRoomsIdByName(this.room1.name)
                this.show_add = true
                animateTo({duration:200},()=>{
                  this._height = "100%"
                })

              })
              .backgroundColor("#00879fa0")
              .height('100%')
              .width('100%')
          }
          .height(100)
          .width("90%")
          .padding(10)
          .margin(12)
          .backgroundColor("#ffb6e7ff")
          .borderRadius(20);
        }
      }
      .height("90%")
      .lanes(2)

      if (this.show_add) {
        add_furniture_page({
          _height:this._height,
          arr: this.arr_fnt,
          is_show: this.show_add ,
          })
      }
      if(this.is_show_f){
        furniture_long({
          _height:this._height,
          t_f:this.this_f,
          room1:this.room1,
          is_show_f:this.is_show_f,
          arr_f:this.arr_fnt,
          is_chang:this.is_change,
          index_f:this.index_f
        })
      }

    }.onClick(()=>{
      new_arr_f = this.arr_fnt
    })
  }
}

@Component
export struct myRow {

  @State item1: Furniture = new Furniture("w", 0,0)
  @State is_clicknum: number = 0;
  @Prop is_sleep:boolean
  @Link is_chang:boolean

  build() {
    if(this.item1.type_id > 1999){
      Stack(){
        Row() {
          Text(this.item1.name)
          Image($r('app.media.curtain6'))
            .height(20)
            .width(20)
            .fillColor('rgb(70, 100, 180)');
        }
        .justifyContent(FlexAlign.SpaceAround)
        .height(100)
        .width("100%")
        .margin(2)
        .padding(10)
        .backgroundImage(this.item1.switch?$r('app.media.furniture_bg2') :$r('app.media.furniture_bg'))
        .backgroundImageSize(ImageSize.Cover)
        .borderRadius(20)
        .borderWidth(2)
        .borderColor(this.item1.switch? 'rgb(70, 100, 180)' : "#009caeca");
        /*.onClick(() => {
          this.is_clicknum += 1
          console.log("item", this.item1.switch)
          if (this.item1.switch) {
            this.item1.close()
            //udp.sendLEDon(this.item1.type_id)
            //tcp.sendLEDon(this.item1.type_id)
          } else {
            this.item1.open()
            //udp.sendLEDoff(this.item1.type_id)
            //tcp.sendLEDon(this.item1.type_id)
          }
        })*/
      }


    }else if(this.item1.type_id > 1000){
      Stack(){
        Row() {
          Text(this.item1.name)
          Image($r('app.media.light2'))
            .height(20)
            .width(20)
            .fillColor('rgb(70, 100, 180)');
        }
        .justifyContent(FlexAlign.SpaceAround)
        .height(100)
        .width("100%")
        .margin(2)
        .padding(10)
        .backgroundImage(this.item1.switch?$r('app.media.furniture_bg2') :$r('app.media.furniture_bg'))
        .backgroundImageSize(ImageSize.Cover)
        .borderRadius(20)
        .borderWidth(2)
        .borderColor(this.item1.switch? 'rgb(70, 100, 180)' :"#009caeca" );
      }
    }
    }

}

@Component
export struct displayRoom {


  //可以添加从数据库取出room的方法存入arr_room
  @Link arr_room: room[]
  @Link is_show_r:boolean
  @Link is_sleep:boolean
  @State is_show_lights:boolean = false
  @State is_show_air_condition:boolean = false
  @State is_show_robot:boolean = false
  @State is_show_curtain:boolean = false
  @State value:number = 0
  @State is_edit:boolean = false
  @State edit_f:Furniture = new Furniture("",0,0)
  @State edit_height:string = '0%'
  l:number = 0


  async aboutToAppear(): Promise<void> {

    new_arr_rooms = this.arr_room
    this.l = this.arr_room.length

  }
  aboutToRecycle(): void {
    console.log("room:Recycle")
  }


  @Builder
  MyBuilder() {
    Column() {
      Text("+")
        .fontSize(20)
    }
    .width(50)
    .backgroundColor('#ff8f8f8f')
  }

  build() {
    Stack() {
        Tabs() {
          TabContent(){
            Stack() {
              Image($r('app.media.bottom_bg1'))
                .objectFit(ImageFit.Cover);
              Column(){
                show_f({arr:this.arr_room,is_show_edit:this.is_edit,f:this.edit_f,h:this.edit_height})
              List() {
                ListItem() {
                  Text("灯光控制")
                    .fontColor('rgb(70, 100, 180)')
                    .position({ y: 40, x: 40 });
                }
                .width(150).height(200).borderWidth(2).borderColor(Color.White).padding({ top: 5, bottom: 10, right: 10, left: 10 }).margin({ top: 0, bottom: 15, left: 20, right: 20 })
                .backgroundImage($r('app.media.c_light2'))
                .backgroundImageSize(ImageSize.Cover)
                .shadow({ radius: 5, offsetX: 10, offsetY: 10, color: "#939391" })
                .borderRadius(10)
                .onClick(() => {
                  this.is_show_lights = true;
                });

                ListItem() {
                  Text("窗帘控制")
                    .fontColor('rgb(70, 100, 180)')
                    .position({ y: 40, x: 40 });
                }
                .width(150).height(200).borderWidth(2).borderColor(Color.White).padding({ top: 5, bottom: 10, right: 10, left: 10 }).margin({ top: 0, bottom: 15, left: 10, right: 10 })
                .backgroundImage($r('app.media.curtain5'))
                .backgroundImageSize(ImageSize.Cover)
                .shadow({ radius: 5, offsetX: 10, offsetY: 10, color: "#939391" })
                .borderRadius(10)
                .onClick(() => {
                  this.is_show_curtain = true
                })

                ListItem() {
                  Text("门锁")
                    .fontColor('rgb(70, 100, 180)')
                    .position({ y: 40, x: 35 });
                }
                .width(150).height(200).borderWidth(2).borderColor(Color.White).padding(10).margin({ top: 0, bottom: 40, left: 20, right: 20 })
                .backgroundImage($r('app.media.robot3'))
                .backgroundImageSize(ImageSize.Cover)
                .shadow({ radius: 5, offsetX: 10, offsetY: 10, color: "#939391" })
                .borderRadius(10)
                .onClick(() => {
                  this.is_show_robot = true
                  console.log("oooooooooo")
                  console.log("oooooooooo")
                })

                ListItem() {
                  Text("空调控制")
                    .fontColor('rgb(70, 100, 180)')
                    .position({ y: 40, x: 35 });
                }
                .width(150).height(200).borderWidth(2).borderColor(Color.White).padding(10).margin({ top: 0, bottom: 40, left: 10, right: 10 })
                .backgroundImage($r('app.media.ufo2'))
                .backgroundImageSize(ImageSize.Cover)
                .shadow({ radius: 5, offsetX: 10, offsetY: 10, color: "#939391" })
                .borderRadius(10)
                .onClick(() => {
                  this.is_show_air_condition = true
                })
              }.lanes(2)
              }
              if (this.is_show_lights) {
                control_lights({ arr_room: this.arr_room, is_show: this.is_show_lights })
              }
              if (this.is_show_air_condition) {
                control_aircon({ arr_room: this.arr_room, is_show: this.is_show_air_condition })
              }
              if (this.is_show_curtain) {
                control_curtain({ arr_room: this.arr_room, is_show: this.is_show_curtain });
              }
              //门锁
              if(this.is_show_robot){
                face_cam({is_show:this.is_show_robot})
              }
            }

          }
          .tabBar("全屋")
          ForEach(this.arr_room, (item: room, index) => {
            if(item.name != "null"){
              TabContent() {
                myList({room1:this.arr_room[index],arr_fnt:this.arr_room[index].furniture_s,index:index,is_sleep:this.is_sleep})
              }
              .tabBar(item.name)
              .width(200)
              .height(10)
            }
          })
        }
        .barMode(this.l>3?BarMode.Scrollable:BarMode.Fixed)
        .barWidth("100%")
      if(this.is_show_r){
        add_room_page({ arr: this.arr_room, is_show: this.is_show_r })
      }
      if(this.is_edit){
        furniture_edit({
          furniturn:this.edit_f,
          is_show_f:this.is_edit,
          _height:this.edit_height
        })
      }
    }
  }
}


@Component
struct control_lights{

  @Link is_show:boolean
  @Link arr_room:room[]

  build() {
    Column(){
      Button("返回").onClick(()=>{this.is_show = false})
        .onClick(() => this.is_show = false)
        .padding(10)
        .backgroundColor(Color.White)
        .borderWidth(2)
        .borderColor('#ffc4a1ba')
        .fontColor('#ffc4a1ba')
        .margin(10);
      if(this.arr_room[0].name != 'null'){
        List(){
          ForEach(this.arr_room,(item:room,index)=>{
            ListItem(){
              Column(){
                Text(item.name)
                mySliber({
                  _room:item,
                })
              }.width(320).padding(20).borderRadius(15).margin(20)
              .backgroundColor(
                index % 3 === 0? '#ffffe1f9' :
                  index % 3 === 1? '#ffece6fa' :
                    '#ffe0ebff'
              )
              .shadow({
                radius: 5,
                offsetX: 20,
                offsetY: 20,
                color: "#a8474545"
              });
            }
          })
        }.lanes(1)
      }else{
        Text("还没有房间哦")
      }


    }.backgroundColor( '#e0efff')
    .width("100%").height("100%");

  }

}
@Component
struct mySliber{
  @State lighting:number = 0
  @Prop _room:room
  @State bulbColor: string = '#333333'

  aboutToAppear(): void {
    let max = 0
    for (let f of this._room.furniture_s){
      if(f.lighting>max){
        max = f.lighting
      }
    }
    this.lighting = max
    console.log("room max:"+this.lighting)
  }
  build() {
    Row(){
      Image($r('app.media.light'))
        .height(25)
        .width(25)
        .fillColor(this.bulbColor);
      Slider({
        direction: Axis.Horizontal,
        max: 10,
        min: 0,
        step: 1,
        style: SliderStyle.OutSet,
        value: this.lighting
      })
        .onChange(async (value) => {
          this.lighting = value;
          for (let f of this._room.furniture_s) {
            if (f.type_id > 999 && f.type_id < 2000) {
              await tcp.sendLED_chang(value, f.type_id);
              tcp.getData();
            }
          }
          this.bulbColor = this.calculateBulbColor(this.lighting)
        })
        .width(200)
        .height(20);

      // 添加显示百分比的Text组件
      Text((this.lighting * 10).toFixed(0) + "%") // 转换为百分比
        .fontSize(14)
        .margin({ left: 10 })
        .fontColor('#666666')
        .width("15%")

    }

    }

  calculateBulbColor(lighting: number): string {
    const lightness = lighting / 10;
    const r = Math.floor(51 + (255 - 51) * lightness);
    const g = Math.floor(51 + (255 - 51) * lightness);
    const b = Math.floor(51 + (255 - 51) * lightness);
    return `rgb(${r},${g},${b})`;
  }

}


@Component
export struct control_air_condition{
  @Link is_show:boolean
  @Link arr_room:room[]

  aboutToAppear(): void {


  }
  build() {
    Column(){
      Button().onClick(()=>{this.is_show = false})
        Tabs(){
          ForEach(this.arr_room,(item:room)=>{
            TabContent(){
              air_condition({item:item})
            }.tabBar(item.name)
          })
        }


    }.backgroundColor(Color.White)
    .width("100%").height("100%")
  }
}
@Component
export struct air_condition{
  @Prop item :room
  @State ex_a_c:boolean = false
  @State is_show_add:boolean = false
  @State _height:string = "0%"
  aboutToAppear(): void {
      for(let f of this.item.furniture_s){
        if(f.type_id>2999&&f.type_id<4000){
          this.ex_a_c = true
        }
      }
  }
  build() {

    Stack(){
      Column(){
        if(this.ex_a_c){
          Image($r("app.media.button1")).width(100).height(100)
          Text("温度："+this.item.get_air_condition().temp)
          Button("除湿")
            .onClick(()=>{
              //开启除湿模式
            })
        }else {
          Text("该房间还没有录入空调哦")
          Button("前往录入")
            .onClick(async ()=>{
              //录入逻辑
              new_f_R_Id = await Room_db.getRoomsIdByName(this.item.name)
              this.is_show_add = true
              animateTo({duration:200},()=>{
                this._height = "100%"
              })

            })
        }
      }
      if(this.is_show_add){
        add_furniture_page({
          arr:[],
          is_show:this.is_show_add,

          _height:this._height
        })
      }



    }
  }
}


@Component
struct control_curtain{
  @Link is_show:boolean
  @Link arr_room:room[]

  aboutToAppear(): void {

  }
  build() {
    Column(){
      Button().onClick(()=>{this.is_show = false})
      Tabs(){
        ForEach(this.arr_room,(item:room)=>{
          TabContent(){
            Column(){
              Text(item.name)
              List(){
                ForEach(item.furniture_s,(item:Furniture)=>{
                  if(item.type_id>1999&&item.type_id<3000){
                    ListItem(){
                      Row(){
                        Text(item.name)
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
                      }.backgroundColor(Color.White).width("100%").padding(10)
                    }
                  }


                })
              }.lanes(2)
            }.backgroundColor(Color.Pink)
          }.tabBar(item.name)
        })
      }.height("30%").vertical(true)
    }.backgroundColor(Color.White)
    .width("100%").height("100%")
  }
}

@Component
struct show_f{
  @Link arr:room[]
  @State ex_condition:boolean = false
  @State open_List:Furniture[] = []
  @Link is_show_edit:boolean
  @Link f:Furniture
  @Link h:string

  async aboutToAppear(){
    console.log("f:::11")
    /*setTimeout(()=>{
      this.arr.push(new room("",[new Furniture('',1,1002)]))
    },1000)*/
    setInterval(()=>{
      this.open_List = []
      console.log("f:::11"+JSON.stringify(this.arr))
      for(let r of this.arr){
        for (let f of r.furniture_s){
          console.log("f:::11"+JSON.stringify(f))
          if(f.switch == 1&&f.type_id>2999){
            this.ex_condition = true
            this.open_List.push(f)
          }
        }
      }
    },1000)

  }

  build() {

    if(this.ex_condition){
      List(){
        ForEach(this.open_List,(item:Furniture)=>{
          ListItem(){
            Column(){
              Text(item.name)
            }
            .height(50)
            .width(50)
            .borderRadius(25)
            .backgroundColor(Color.Pink)
            .onClick(()=>{
              this.is_show_edit = true
              this.f = item
              animateTo({duration:200},()=>{
                this.h = "100%"
              })
            })
          }
          ListItem().width(10)
        })

      }
      .listDirection(Axis.Horizontal)
      .width("100%").height(60)
    }



  }
}

@Component
export struct my_DeepSeek{

  @State question:string = ''
  @Link _height:string
  @Link is_show:boolean
  @State history:string  = ''
  @Link _height_AI:string
  @State is_ark:boolean = false
  AI:API_DeepSeek = new API_DeepSeek()
  localstorage:LocalStoraga = new LocalStoraga("AI")
  @State TextList:string[] = []
  async aboutToAppear() {
    if(await this.localstorage.getDate("history") != false){

      this._height = "40%"
      this.history = await this.localstorage._getDate_("history")
      console.log("history::"+this.history)
      for(let message of this.history.split("::::")){
        if(message.split("///")[0] != ''){
          this.TextList.push(message.split("///")[0])
        }
        if(message.split("///")[1] != ''){
          this.TextList.push(message.split("///")[1])
        }

      }
    }

  }
  build() {
    Stack({alignContent:Alignment.BottomEnd}){
      Column()
        .height("100%").width("100%").backgroundColor("#9c000000")
        .onClick(()=>{
          animateTo({duration:500},()=>{
            this._height = "10%"
            this._height_AI = "0%"
            this.is_show = false
          })
        })
      Column(){
        List() {

          ForEach(this.TextList,(item:string,value)=>{
            ListItem(){
              if(value%2 == 0){
                //我说的话
                if(item != "[object Promise]"){
                  Row(){
                    Text(item)
                      .fontColor(Color.White)
                      .backgroundColor(Color.Blue)
                      .borderRadius(10)
                      .padding(10)

                    Column()
                      .width(10)
                    Column()//我的头像
                      .width(50).borderRadius(25).height(50).backgroundColor(Color.Blue)
                  }.justifyContent(FlexAlign.End)
                  .width("100%").padding(10)
                }

              }else{
                //Ai的回答
                Row(){
                  Column()//ai的头像
                    .width(50).borderRadius(25).height(50).backgroundColor("#ffcfcfcf")
                  Column()
                    .width(10)
                  Text(item)
                    .fontColor(Color.Black)
                    .backgroundColor("#ffcfcfcf")
                    .width("75%")
                    .borderRadius(10)
                    .padding(10)
                }.justifyContent(FlexAlign.Start)
                .width("100%").padding(10)
              }
            }

          })

        }.width("100%").height(this._height)
        Row(){
          if(this.is_show){
            TextInput({placeholder:"请输入问题",text:this.question}).width("80%").height("10%")
              .onChange((value)=>{this.question = value})

          }
          if(this.is_ark){
            Progress({ value: 0, total: 100, type: ProgressType.Ring })
              .width(50).color(Color.White).backgroundColor('#ffbebebe')
              .style({ strokeWidth: 10, status: ProgressStatus.LOADING })
          }
          else{
            Button("提问")
              .onClick(async ()=>{
                if(this.question != ''){
                  animateTo({duration:200},()=>{
                    this._height = "40%"
                  })
                  this.is_ark = true
                  this.TextList.push(this.question)
                  this.history = await this.AI.chat(this.question)
                  await this.localstorage.setDate("history",this.history)
                  this.TextList = []
                  for(let message of (this.history).split("::::")){
                    if(message.split("///")[0] != ''||message.split("///")[0] == this.question){
                      this.TextList.push(message.split("///")[0])
                    }
                    if(message.split("///")[1] != ''){
                      this.TextList.push(message.split("///")[1])
                    }
                  }
                  this.question = ''
                  this.is_ark = false
                }else {
                  this.history = "请输入问题"
                }

              })
          }

        }.justifyContent(FlexAlign.End).backgroundColor(Color.White).width("100%")
      }.justifyContent(FlexAlign.End).borderRadius({topLeft:10,topRight:10}).backgroundColor(Color.White)

      //.animation({duration:200})
    }.width("100%").height(this._height_AI)

  }
}

@Component
export struct control_aircon {
  @Link is_show: boolean;
  @Link arr_room: room[];
  @State selectedMode: 'auto' | 'heat' | 'cool' | 'dry' = 'auto';
  @State tempSetting: number = 26;
  @State acColor: string = '#42b983';
  @State is_chang: boolean = true;

  private calculateAcColor(): string {
    switch (this.selectedMode) {
      case 'heat': return '#ff6b6b';
      case 'cool': return '#4fc0d0';
      case 'dry': return '#aaa69d';
      default: return '#42b983';
    }
  }

  build() {
    Column() {
      Button('返回')
        .onClick(() => this.is_show = false)
        .padding(10)
        .backgroundColor('#e0e0e0')
        .borderWidth(2)
        .borderColor('#ffc4a1ba')
        .fontColor('#ffc4a1ba')
        .margin(10);


      Row() {
        ForEach(['auto', 'heat', 'cool', 'dry'] as ['auto', 'heat', 'cool', 'dry'], (mode: 'auto' | 'heat' | 'cool' | 'dry') => {
          Button(mode.toUpperCase())
            .onClick(() => {
              this.selectedMode = mode;
              this.acColor = this.calculateAcColor();
            })
            .padding(10)
            .backgroundColor(this.selectedMode === mode ? '#42b983' : '#e0e0e0')
            .fontColor('white')
            .margin(5);
        });
      }
      .margin(20);

      Column() {
        Text(`当前温度: ${this.tempSetting.toFixed(1)}°C`)
          .fontSize(24)
          .margin(20);

        Row() {
          Button('-')
            .onClick(() => {
              if (this.tempSetting > 16) {
                this.tempSetting -= 0.5;
                this.is_chang = !this.is_chang;
              }
            })
            .padding(10)
            .backgroundColor('#e0e0e0')
            .margin(5);

          this.CustomCircularProgress(); // 直接调用，无需传参

          Button('+')
            .onClick(() => {
              if (this.tempSetting < 30) {
                this.tempSetting += 0.5;
                this.is_chang = !this.is_chang;
              }
            })
            .padding(10)
            .backgroundColor('#e0e0e0')
            .margin(5);
        }
        .margin(20);
      }
      .backgroundColor('#f8f8f8')
      .borderRadius(15)
      .padding(20);

      List() {
        ForEach(this.arr_room, (item: room) => {
          ListItem() {
            Column() {
              Text(item.name)
                .fontSize(18)
                .margin(10);

              Row() {
                Image($r(`app.media.ac_${this.selectedMode}`))
                  .height(40)
                  .width(40)
                  .fillColor(this.calculateAcColor());

                Text(`${this.tempSetting.toFixed(1)}°C`)
                  .fontSize(20)
                  .margin(10);
              }
            }
            .width('90%')
            .padding(15)
            .backgroundColor('#ffffff')
            .borderRadius(10)
            .shadow({ radius: 3, offsetX: 2, offsetY: 2, color: '#999999' });
          }
        });
      }
      .margin(20);
    }
    .backgroundColor('#e0efff')
    .width('100%')
    .height('100%');
  }

  @Builder
  CustomCircularProgress() {
    // 直接使用组件内的 @State tempSetting


    Progress({
      value:this.tempSetting - 16,
      total: 14,
      style: ProgressStyle.Ring
    })
      .style({
        strokeWidth: 10,
        ringStyle: {
          startAngle: -90,
          sweepAngle: 360,
          gapRadius: 0
        }
      } as RingStyleOptions)
      .color(`rgb(255, ${255 -  Math.min(255, Math.max(0, (this.tempSetting - 16) * 18))}, ${255 -  Math.min(255, Math.max(0, (this.tempSetting - 16) * 18))})`)
      .size({ width: 120, height: 120 })
  }
}
// 类型声明
declare interface SliderStyle {
  readonly OutSet: SliderStyle;
}


