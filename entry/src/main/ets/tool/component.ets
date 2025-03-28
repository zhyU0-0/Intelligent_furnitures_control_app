import { LocalStoraga } from "../entryability/LocalStorage";
import { RoomDatabase } from "../entryability/RdbStorage";
import { tcp } from "../pages/Index";
import { API_DeepSeek } from "../pages/OpenAI_Page";
import { _IoTad } from "../pages/scan_devices";
//import { tcp, udp } from "../pages/Index";
import {  Furniture, room } from "./classes";




let new_arr_rooms:room[]
let new_arr_f:Furniture[]

let Room_db:RoomDatabase = new RoomDatabase(globalThis.getContext())
let new_f_R_Id:number





@Component
export struct furniture_long {

  @Link _height:string

  //@Link f_type:number
  @Prop room1:room
  //@Link f_name:string
  //@Link f_switch:number
  @Link is_show_f:boolean
  @Link arr_f:Furniture[]
  @Link index_f:number
  o_name:string = ''
  @State Light_number:number = 0
  @Link is_chang:boolean
  @State is_c:boolean = true
  @State o_f:Furniture = new Furniture('',0,0)

  //@Link f_brightness:number

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
          Button("处湿")
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
export struct add_furniture_page {
  @Link _height:string
  @Link arr: Furniture[]
  @State fur_name: string = ''
  @Link is_show: boolean
  @Link index:number
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
          .onClick(async () => {
            if (this.fur_name != ''&&this.type != 0) {
              //数据库
              console.log('roomwwwwww')
              //let new_f_R_Id = await Room_db.getRoomsIdByName(new_arr_rooms[this.index].name)
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
      .backgroundColor(Color.White)
      .justifyContent(FlexAlign.End)
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
        }.height(100)
        .width('100%')
        .justifyContent(FlexAlign.SpaceAround)



      }
      .height("55%")
      .width('100%')
      .borderRadius(20)
      .backgroundColor(Color.White)
      .justifyContent(FlexAlign.End)
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
                      /*this.f_name = item.name
                      this.f_type = item.type_id

                      this.f_switch = item.switch
                      if(this.f_type <2000){
                          this._brightness = item.lighting
                      }*/
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
            .backgroundColor("#ab879fa0")
            .borderRadius(20)

        }
      }
      .height("90%")
      .lanes(2)

      if (this.show_add) {
        add_furniture_page({
          _height:this._height,
          arr: this.arr_fnt,
          is_show: this.show_add ,
          index:this.index})
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

          Image($r('app.media.curtain'))
            .height(20)
            .width(20)
            .fillColor('#ff1c6670')
        }
        .justifyContent(FlexAlign.SpaceAround)
        .height(100)
        .width("100%")
        .margin(2)
        .padding(10)
        .backgroundColor(this.item1.switch ? '#ffe8efff' : "#ff9caeca")
        .borderRadius(20)
        .borderWidth(2)
        .borderColor(this.item1.switch ? '#0080f5' : "#ff9caeca")
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
          Image($r('app.media.light'))
            .height(20)
            .width(20)
            .fillColor('#ff1c6670')
        }
        .justifyContent(FlexAlign.SpaceAround)
        .height(100)
        .width("100%")
        .margin(2)
        .padding(10)
        .backgroundColor(this.item1.switch?'#ffe8efff' : "#ff9caeca")
        .borderRadius(20)
        .borderWidth(2)
        .borderColor(this.item1.switch ? '#0080f5' : "#ff9caeca")
        /*.onClick(() => {
          this.is_clicknum += 1
          console.log("item", this.item1.switch)
          if (this.item1.switch) {
            this.is_sleep = true
            this.item1.close()
            //udp.sendLEDon(this.item1.type_id)
            //tcp.sendLEDon(this.item1.type_id)
          } else {
            this.is_sleep = false
            this.item1.open()
            //udp.sendLEDoff(this.item1.type_id)
            //tcp.sendLEDon(this.item1.type_id)
          }
        })*/



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
              Column(){
                show_f({arr:this.arr_room})
              List() {
                ListItem() {
                  Text("灯光控制")
                }
                .width("100%")
                .height(250)
                .borderWidth(2)
                .borderColor(Color.White)
                .padding(10)
                .onClick(() => {
                  this.is_show_lights = true
                })

                ListItem() {
                  Text("窗帘控制")
                }
                .width("100%")
                .height(250)
                .borderWidth(2)
                .borderColor(Color.White)
                .padding(10)
                .onClick(() => {
                  this.is_show_curtain = true
                })

                ListItem() {
                  Text("机器人控制")
                }
                .width("100%")
                .height(250)
                .borderWidth(2)
                .borderColor(Color.White)
                .padding(10)
                .onClick(() => {
                  this.is_show_robot = true
                })

                ListItem() {
                  Text("空调控制")
                }
                .width("100%")
                .height(250)
                .borderWidth(2)
                .borderColor(Color.White)
                .padding(10)
                .onClick(() => {
                  this.is_show_air_condition = true
                })
              }.lanes(2)
              }
              if (this.is_show_lights) {
                control_lights({ arr_room: this.arr_room, is_show: this.is_show_lights })
              }
              if (this.is_show_air_condition) {
                control_air_condition({ arr_room: this.arr_room, is_show: this.is_show_air_condition })
              }
              if (this.is_show_curtain) {
                control_curtain({ arr_room: this.arr_room, is_show: this.is_show_curtain })
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

          /*TabContent() {

          }
          .tabBar(this.MyBuilder)
          .width(200)
          .height(10)*/

        }
        .barMode(this.l>3?BarMode.Scrollable:BarMode.Fixed)
        .barWidth("100%")



      if(this.is_show_r){
        add_room_page({ arr: this.arr_room, is_show: this.is_show_r })
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
      Button().onClick(()=>{this.is_show = false})
      if(this.arr_room[0].name != 'null'){
        List(){

          ForEach(this.arr_room,(item:room)=>{

            ListItem(){
              Column(){
                Text(item.name)
                mySliber({_room:item})

              }.height(250).padding(20).borderRadius(5)
              .backgroundColor(Color.Pink)
            }
          })

        }.lanes(4)
      }else{
        Text("还没有房间哦")
      }


    }.backgroundColor(Color.White)
    .width("100%").height("100%")

  }
}
@Component
struct mySliber{
  @State lighting:number = 0
  @State _room:room = new room('',[])
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
    Slider({
      direction:Axis.Vertical,
      reverse:true,
      max:10,
      min:0,
      step:1,
      style:SliderStyle.OutSet,
      value:this.lighting
    })
      .onChange(async (value)=>{
        for (let f of this._room.furniture_s) {
          if (f.type_id > 999 && f.type_id < 2000) {
            await tcp.sendLED_chang(value, f.type_id)
            tcp.getData()
          }
        }
      })
  }
}


@Component
struct control_air_condition{
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
struct air_condition{
  @Prop item :room
  @State ex_a_c:boolean = false
  aboutToAppear(): void {
      for(let f of this.item.furniture_s){
        if(f.type_id>2999&&f.type_id<4000){
          this.ex_a_c = true
        }
      }
  }
  build() {

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
          .onClick(()=>{
            //录入逻辑
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
                            } else {
                              item.switch = 0
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
      Button("on").height("10%")
        .onClick(()=>{
          _IoTad.set_curtain_by_id("on")
        })
      Button("off").height("10%")
        .onClick(()=>{
          _IoTad.set_curtain_by_id("off")
        })


    }.backgroundColor(Color.White)
    .width("100%").height("100%")
  }
}


@Component
struct show_f{
  @Prop arr:room[]
  @State ex_condition:boolean = false

  async aboutToAppear(){
    console.log("f:::11")
    for(let r of this.arr){
      console.log("f:::11"+JSON.stringify(r))
     this.ex_condition = r.ex_air_condition()
    }
  }

  build() {
    if(this.ex_condition){
      List(){
          ListItem(){
            Column()
              .height(50)
              .width(50)
              .borderRadius(25)
              .backgroundColor(Color.Pink)
          }
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
            TextInput({placeholder:"请输入问题"}).width("80%").height("10%")
              .onChange((value)=>{this.question = value})
          }
          Button("提问")
            .onClick(async ()=>{
              if(this.question != ''){
                animateTo({duration:200},()=>{
                  this._height = "40%"
                })
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
              }else {
                this.history = "请输入问题"
              }

            })
        }.justifyContent(FlexAlign.End).backgroundColor(Color.White).width("100%")
      }.justifyContent(FlexAlign.End).borderRadius({topLeft:10,topRight:10}).backgroundColor(Color.White)

      //.animation({duration:200})
    }.width("100%").height(this._height_AI)

  }
}



