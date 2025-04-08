import { McLineChart, Options } from '@mcui/mccharts'
import util from '@ohos.util';
import router from '@ohos.router';
import { air_condition, Furniture, room } from '../tool/classes';
import { displayRoom, my_DeepSeek} from '../tool/component';
import { LocalStoraga } from '../entryability/LocalStorage';
import { _Udp } from '../tool/UDP';
import { Data_Tcp, _Tcp } from '../tool/TCP';
import { RoomDatabase } from '../entryability/RdbStorage';
import socket from '@ohos.net.socket';
import wifi from '@ohos.wifi';
import {  notificationManager } from '@kit.NotificationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { _IoTad } from './scan_devices';
import { scene } from './scene_page';
import { Data_id_yun, DATA_new } from '../tool/IoTad';

let DATA_IoTda:string =''
let Data_Id_me:string = ''
const max_temp = 30
const max_humi = 90
const max_smoke = 100
const TAG: string = '[PublishOperation]';
const DOMAIN_NUMBER: number = 0xFF00;
//export let udp:_Udp = new _Udp(3861,'172.16.0.119')
//export let tcp:_Tcp = new _Tcp(3861,'172.16.0.119')
export let tcp:_Tcp = new _Tcp(8888,'192.168.191.19')
let Room_db:RoomDatabase = new RoomDatabase(globalThis.getContext())


function resolveIP(ip:number):string{
  if(ip<0||ip>0xFFFFFFFF){
    return '0'
  }
  return (ip >>>24)+'.'+(ip >> 16 & 0xFF)+'.'+(ip >>8 &0xFF) +'.'+(ip &0xFF);
}


@Component
struct homepage{

  @State serOption_temp:Options = new Options({
    xAxis:{data:["0:00","3:00","6:00","9:00","12:00","15:00","18:00","21:00"]},
    yAxis:{name:'温度'},
    series:[{
      name:'最高气温',
      data:[14,16,17,18,22,22,21,18],
      color:"#dd00dd",
      arcLineWidth:100
    }]
  })
  @State serOption_humi:Options = new Options({
    xAxis:{data:["0:00","3:00","6:00","9:00","12:00","15:00","18:00","21:00"]},
    yAxis:{name:'温度'},
    series:[{
      name:'平均湿度',
      data:[40,41,42,40,42,50,55,46],
      color: "#ff039f96",
      arcLineWidth:100
    }]
  })
  @State serOption_smoke:Options = new Options({
    xAxis:{data:["0:00","3:00","6:00","9:00","12:00","15:00","18:00","21:00"]},
    yAxis:{name:'温度'},
    series:[{
      name:'最高气温',
      data:[11,10,2,11,22,66,10,60],
      color: "#ffddb801",
      arcLineWidth:100
    }]
  })

  private localAddr:socket.NetAddress |null = null
  private mixerAddr:socket.NetAddress |null = null
  @State _h_detail:string = '0%'
  @State num1:string = '';
  @State num2:string = '';
  @State is_Lock:boolean = false
  @State is_show_r:boolean = false
  @State is_sleep:boolean = false
  @State is_chang:boolean = false
  @State is_delete_h:string= "0%"
  @Link arr_room:room[]
  @State is_show_humidity:boolean = false
  @State _height:string = "20%"
  @State backG:string = "app.media.back_house"
  @State _width:string = '90%'
  @State temp:string = ''
  @State humi:string = ''
  @State smoke:string = ''
  @Link is_warn:boolean
  @Link warn_data:Datamodel


  async aboutToAppear() {
    this.localAddr = {
      family: 1,
      port: 8889,
      address: resolveIP(wifi.getIpInfo().ipAddress)
    }
    //接收者的ip地址
    this.mixerAddr = {
      address:'192.168.191.19',
      port:8889
    }

    setTimeout(async ()=>{
      let room:room[] = await Room_db.getAllRooms()
      if(room[0].name=="null"){
        AlertDialog.show({message:"还没有家居哦，快去录入吧~"})
      }
        for (let item of await Room_db.getAllRooms()) {
          this.arr_room.push(item)
          console.log("q_room"+JSON.stringify(item))
        }

      console.log("open_arr_room:"+JSON.stringify(this.arr_room))

      this.new_analyze_data("")
      /*setTimeout(async ()=>{

        await tcp.getData()
        console.log("Tcp_get_data : "+Data_Tcp)
        this.analyze_data(Data_Tcp)
        await _IoTad.get_data()
        Data_Id_me = Data_id_yun

      },1000)

      setInterval(async ()=>{
        if(Data_Id_me != Data_id_yun){
          DATA_IoTda = DATA_new
          await this.new_analyze_data(DATA_IoTda)
        }
      },1000)*/
    },100)
    //setTimeout(()=>{ this.udp_send()},1000)
  }
  async judge(temp?:number,humi?:number,smoke?:number){
    let title:string = ''

    if(temp != null){
      if(temp>max_temp) {
        let paramInfo: Datamodel = {
          type: "temp",
          data: temp,
          arr: await Room_db.getAllRooms()
        }
        this.warn_data = paramInfo
        this.is_warn = true
      }
      title = "温度过高"
    }
    if(humi != null) {
      if (humi > max_humi) {
        let paramInfo: Datamodel = {
          type: "humi",
          data: humi,
          arr: await Room_db.getAllRooms()
        }
        this.warn_data = paramInfo
        this.is_warn = true
      }
      title = "湿度过高"
    }
    if(smoke != null){
      if(smoke>max_smoke) {
        let paramInfo: Datamodel = {
          type: "smoke",
          data: smoke,
          arr: await Room_db.getAllRooms()
        }
        this.warn_data = paramInfo
        this.is_warn = true
      }
      title = "烟雾浓度过高"
    }

      let notificationRequest: notificationManager.NotificationRequest = {
      id: 1,
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT, // 普通文本类型通知
        normal: {
          title: '警告',
          text: title,
          additionalText: 'test_additionalText',
        }
      }
    };
      notificationManager.publish(notificationRequest, (err: BusinessError) => {
        if (err) {
          hilog.error(DOMAIN_NUMBER, TAG, `Failed to publish notification. Code is ${err.code}, message is ${err.message}`);
          return;
        }
        hilog.info(DOMAIN_NUMBER, TAG, 'Succeeded in publishing notification.');
      });

  }
  analyze_data(data:string){
    let arr:string[] = data.split("/")
    for(let item of arr){
      console.log("TCp data:"+item)
      let values:string = JSON.parse(item)
      if(typeof values?.["temp"] != "undefined") {
        this.temp = values?.["temp"]
        this.humi = values?.["humi"]
        this.judge(Number(this.temp),Number(this.humi))


        console.log("udp send temp"+this.temp+"::"+this.humi)
      }else {
        let new_arr_room:room[] = []
        for (let r of this.arr_room){
          let new_arr_f:Furniture[] = []
          for (let f of r.furniture_s){
            if(f.type_id ==values?.["id"]){
              if(typeof values?.["lighting"] != "undefined") {
                f = new Furniture(f.name,values?.["switch"],values?.["id"])
                f.lighting = values?.["lighting"]
                console.log("udp send t"+f.switch+"::"+f.lighting+'::'+f.type_id)
              }else if(typeof values?.["a_temp"] != "undefined"){
                f = new Furniture(f.name,values?.["switch"],values?.["id"])
                f.temp = values?.["a_temp"]
                f.mode = values?.["mode"]
              }
              else {
                f = new Furniture(f.name,values?.["switch"],values?.["id"])
                console.log("udp send t"+f.switch+"::"+f.type_id)
              }
            }
            new_arr_f.push(f)
          }
          new_arr_room.push(new room(r.name,new_arr_f))
          console.log("UDP ROOM NEW"+JSON.stringify(r))
        }
        this.arr_room = new_arr_room
      }

    }
  }
  //{"temperature":16,"humidity":0,"smoke":0,"motion_state":1,"door_state":0,"brightness":500,"1001":1,"1102":1,"2001":0,"3001_2":0,"4001":0,"3001_1":0,"3001_3":0}
  async new_analyze_data(data:string){
    data = "{\"temperature\":16,\"humidity\":0,\"smoke\":0,\"motion_state\":1,\"door_state\":0,\"brightness\":500,\"1001\":1,\"1102\":1,\"2001\":1,\"3001_2\":22,\"4001\":1,\"3001_1\":1,\"3001_3\":\"zl\"}"
    let arr:string[] = data.split("/")
    for(let item of arr){
      console.log("IoTad data:"+item)
      let values:string = JSON.parse(item)
      if(typeof values?.["temperature"] != "undefined") {
        this.temp = values?.["temperature"]
        this.humi = values?.["humidity"]
        this.smoke = values?.['smoke']
        this.judge(Number(this.temp),Number(this.humi))
        console.log("IoTad send temp"+this.temp+"::"+this.humi)
        let new_arr_room:room[] = []
        for (let r of this.arr_room){
          let new_arr_f:Furniture[] = []
          for (let f of r.furniture_s){
            if(typeof values?.[f.type_id.toString()] != "undefined"){
              let new_v:string = values?.[f.type_id.toString()]
              new_v = JSON.parse(new_v)
              if(f.type_id<999){
                f = new Furniture(f.name,values?.[f.type_id.toString()],f.type_id)

              }else if(f.type_id<1999){
                f = new Furniture(f.name,values?.[f.type_id.toString()],f.type_id)
                f.lighting = (values?.["brightness"])/100

              }else if(f.type_id<2999){
                f = new Furniture(f.name,values?.[f.type_id.toString()],f.type_id)

              }else if(f.type_id<3999&&f.type_id>3000){
                console.log("air_condition:::"+JSON.stringify(f))
                f = new Furniture(f.name,values?.[f.type_id.toString()],f.type_id)
                f.temp = Number(values?.[f.type_id.toString()+"_2"])
                f.mode = values?.[f.type_id.toString()+"_3"]
                console.log("air_condition:::"+JSON.stringify(f))
              }else{
                f = new Furniture(f.name,values?.[f.type_id.toString()],f.type_id)
              }
              /*if(typeof new_v?.["lighting"] != "undefined") {
                f = new Furniture(f.name,values?.["switch"],values?.["id"])
                f.lighting = values?.["lighting"]
                console.log("udp send t"+f.switch+"::"+f.lighting+'::'+f.type_id)
              }else if(typeof values?.["a_temp"] != "undefined"){
                f = new Furniture(f.name,values?.["switch"],values?.["id"])
                f.temp = values?.["a_temp"]
                f.is_dry = values?.["is_dry"]
              }
              else {
                f = new Furniture(f.name,values?.["switch"],values?.["id"])
                console.log("udp send t"+f.switch+"::"+f.type_id)
              }*/
            }
            new_arr_f.push(f)
          }
          new_arr_room.push(new room(r.name,new_arr_f))
          console.log("UDP ROOM NEW"+JSON.stringify(r))
        }
        this.arr_room = new_arr_room
      }

    }
  }


  @Builder
  MenuBar(){
    Menu(){
      MenuItem({content:'添加房间'}).onClick(()=>{
        this.is_show_r = true
      })
      MenuItem({content:"删除房间"}).onClick(()=>{
        animateTo({duration:500},()=>this.is_delete_h = "90%")

      })
    }
  }

  build() {


    Column(){
      //头部
      Row(){
        Stack(){
          Row(){
            Column().width("25%")
            Column(){
              Row(){
                Image($r("app.media._temp"))
                  .fillColor('#6d9cee').width(25).height(25)
                Text("温度：")
                  .fontSize(15)
                  .width(50)
                  .fontColor( '#6d9cee')
                  .margin({ bottom: 5 });
                Text(this.temp.toString())
                  .fontSize(15)
                  .width(50)
                  .fontColor( '#6d9cee')
                  .margin({ bottom: 5 });
              }
              Row(){
                Image($r("app.media._humi"))
                  .fillColor('#6d9cee').width(25).height(25).size({width:20,height:20})
                Text("湿度：")
                  .fontSize(15)
                  .width(50)
                  .fontColor( '#6d9cee')
                  .margin({ bottom: 5 });
                Text(this.humi.toString())
                  .fontSize(15)
                  .width(50)
                  .fontColor( '#6d9cee')
                  .margin({ bottom: 5 });

              }

              Row(){
                Image($r("app.media._smoke"))
                  .fillColor('#6d9cee').width(25).height(25).size({width:20,height:20})
                Text("烟雾：")
                  .fontSize(15)
                  .width(50)
                  .fontColor( '#6d9cee')
                  .margin({ bottom: 5 });
                Text(this.smoke.toString())
                  .fontSize(15)
                  .width(50)
                  .fontColor( '#6d9cee')
                  .margin({ bottom: 5 });
              }

            }.width("50%").height('100').justifyContent(FlexAlign.SpaceAround)
            .onClick(()=>{
              //this.is_show_humidity = !this.is_show_humidity
              animateTo({duration:500},()=>{
                this._h_detail = "90%"
                this.is_show_humidity = true
              })
            })
            Column(){
              Row(){
                Button('+')
                  .backgroundColor(this.is_sleep?'transparent'   : '#e0efff')
                  .fontColor(this.is_sleep ? 'transparent'  : '#6d9cee')
                  .padding({ left: 15, right: 15 })
                  .bindMenu(this.MenuBar)
                  .width(50)
                  .height(50);
              }

            }
          }.height(this._height).width(this._width)
          .backgroundImage($r(this.backG))
          .backgroundImageSize(ImageSize.Cover)
          .padding(10)
          .borderRadius(15)
          .shadow({
            color: '#0000005d',
            radius: 10,
            offsetX: 10,
            offsetY: 10
          });
          if(this.is_show_r){
            Column().width("100%").height('20%').backgroundColor("#9c000000")
          }
        }
      }
      //显示温度详情数据
      detail_data({
        _h:this._h_detail,
        is_show:this.is_show_humidity,
        serOption_humi:this.serOption_humi,
        serOption_temp:this.serOption_temp,
        serOption_smoke:this.serOption_smoke
      })
      //删除房间
      delete_room({_h:this.is_delete_h,arr_room:this.arr_room})
      //主体
      Column(){
        displayRoom({is_show_r:this.is_show_r,arr_room:this.arr_room,is_sleep:this.is_sleep})
      }
      .height("90%")
      .width('100%')
    }.height("100%").width("100%")
  }
}


@Component
struct detail_data{
  @Link is_show:boolean
  @Link serOption_humi:Options
  @Link serOption_temp:Options
  @Link serOption_smoke:Options
  @State _w:string = "100%"
  @Link _h:string
  build() {
    Column(){
      Button("返回")
        .onClick(()=>{

          animateTo({duration:500},()=>{
            this._h = "0%"
            this.is_show = false
          })

        })

      Row().width("100%").height("10%")
        if(this.is_show){
          Row(){
            Column(){
              Text("平均湿度")
            }.width("20%")
            McLineChart({options:this.serOption_humi}).width("80%").padding(10)
          }.width('100%')
          .padding(10)
          .height('30%')
          .backgroundColor(Color.White)
          .margin({ bottom: 10 })
          .shadow({
            color: '#0000001A',
            radius: 10,
            offsetX: 2,
            offsetY: 2
          });
          Row(){
            Column(){
              Text("最高温度")
            }.width("20%")
            McLineChart({options:this.serOption_temp}).width("80%").padding(10)
          }.width('100%')
          .padding(10)
          .height('30%')
          .backgroundColor(Color.White)
          .margin({ bottom: 10 })
          .shadow({
            color: '#0000001A',
            radius: 10,
            offsetX: 2,
            offsetY: 2
          });
        }


    }.height(this._h).width(this._w)
  }
}
@Component
struct delete_room{
  @Link arr_room:room[]
  @Link _h:string
  build() {
    Column() {
      Button("返回").onClick(()=>{
        animateTo({duration:500},()=>this._h = "0%")
      } )
        .backgroundColor(Color.White)
        .borderWidth(2)
        .borderColor('#6d9cee')
        .fontColor('#6d9cee')
      List(){
        ForEach(this.arr_room,(item:room,value)=>{
          ListItem() {
            Row(){
              Row().width("10%")
              Text(item.name).width("40%")
              Row().width('20%')
              Button("删除")
                .backgroundColor(Color.White)
                .borderWidth(2)
                .borderColor('#6d9cee')
                .fontColor('#6d9cee')
                .onClick(async ()=>{
                  //删除房间数据
                  this.getUIContext().showActionSheet({
                    title: `是否删除"${item.name}"`,
                    message: "请确认",
                    sheets: [
                      {title:"确认",action:async ()=>{
                        await Room_db.deleteRoomByName(item.name)
                        this.arr_room = this.arr_room.filter((element)=>element.name!== this.arr_room[value].name)
                      }},
                      {title:"取消",action:()=>{}}
                    ]
                  })
                  //this.arr_f = this.arr_f.filter((element) => element.name!== this.arr_f[this.index_f].name);
                })
            }
          }
          ListItem().height(5)
        })
      }
    }.height(this._h).width("100%")
  }
}
@Component
struct userpage{
  localstorage: LocalStoraga = new LocalStoraga("userData");
  @State username: string = '';
  @State is_show_all_f: boolean = false;
  @State f_arr: Furniture[] = [];
  @State _height: string = "0%";

  aboutToAppear() {
    console.log("user", 'into');
    this.localstorage.getDate("last_login").then(_User_ => {
      console.log("user", _User_);
      this.username = _User_ as string;
    });
  }

  build() {
    Stack() {
      Image($r('app.media.bottom_bg1'))
        .objectFit(ImageFit.Cover)
      Column() {
        Text("用户界面")
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 50 })
          .fontColor('#254e7a');

        Text(this.username)
          .fontSize(20)
          .margin({ top: 20 })
          .fontColor('#254e7a');

        Button("退出登录")
          .width("90%")
          .height(50)
          .margin(10)
          .backgroundImage($r('app.media.btn_bg'))
          .backgroundImageSize(ImageSize.Cover)
          .fontColor(Color.White)
          .borderRadius(10)
          .onClick(() => {
            this.localstorage.setDate('is_land', false);
            router.replaceUrl({
              url: 'pages/Open'
            });
          });

        Button("我的家居")
          .width("90%")
          .height(50)
          .margin(10)
          .backgroundImage($r('app.media.btn_bg'))
          .backgroundImageSize(ImageSize.Cover)
          .fontColor(Color.White)
          .borderRadius(10)
          .onClick(async () => {
            this.is_show_all_f = !this.is_show_all_f;

            this.f_arr = await Room_db.getAllFurinture();
            animateTo({ duration: 500 }, () => {
              if(this._height == "0%"){
                this._height = "50%";
              }else {
                this._height = "0%"
              }
            });
          });
        if (this.is_show_all_f) {
          Column() {
            List() {
              ForEach(this.f_arr, (item: Furniture, index) => {
                ListItem() {
                  Row() {
                    Text(item.name)
                      .fontSize(16)
                    Text(item.type_id.toString())
                      .fontSize(16)
                  }
                  .width('100%')
                  .height(50)
                  .justifyContent(FlexAlign.SpaceAround);
                }
              });
            }
          }
          .width('90%')
          .height(this._height)
          .onClick(() => {
            this.is_show_all_f = false;
            this._height = '0%';
          });
        }
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center);


    }.width("100%").height("100%")
  }
}
//////////////////////////////*********************///////////////////////////////////////
@Entry
@Component
struct Index {

  @State arr_room:room[] = []
  @State selectnumber:number = 0;
  @State is_show_humidity:boolean = false
  @State is_warn:boolean = false
  @State warn_data:Datamodel={type:'',arr:[],data:0}
  @State _height_AI:string = "0%"
  @State is_show_AI:boolean = false
  @State _height_AI_com:string = '10%'

  @Builder
  MyBuilder_user (title:string,num:number){
    Column(){
      Row().width("100%").height(15)
      Image($r("app.media.user"))
        .height(num==this.selectnumber?20:10)
        .width(num==this.selectnumber?20:10)
        .fillColor(num==this.selectnumber?'#4A90E2':Color.White)

      Text(title)
        .fontColor(num==this.selectnumber?'#4A90E2':Color.White)
    }
    .width('100%')
    .height('100%')
    .backgroundImage(num == this.selectnumber ? $r('app.media.bottom_bg1') : $r('app.media.bottom_bg2'))
    .backgroundImageSize(ImageSize.Cover)
  }
  @Builder
  MyBuilder_add(title: string, num: number) {
    Column() {
      Row().width("100%").height(15);
      Image($r("app.media.add"))
        .height(num == this.selectnumber ? 20 : 10)
        .width(num == this.selectnumber ? 20 : 10)
        .fillColor(num == this.selectnumber ? '#4A90E2' : Color.White);

      Text(title)
        .fontColor(num == this.selectnumber ? '#4A90E2' : Color.White);
    }
    .width('100%')
    .height('100%')
    .backgroundImage(num == this.selectnumber ? $r('app.media.bottom_bg1') : $r('app.media.bottom_bg2'))
    .backgroundImageSize(ImageSize.Cover)
  }
  @Builder
  MyBuilder_home(title: string, num: number) {
    Column() {
      Row().width("100%").height(15);
      Image($r("app.media.home"))
        .height(num == this.selectnumber ? 20 : 10)
        .width(num == this.selectnumber ? 20 : 10)
        .fillColor(num == this.selectnumber ? '#4A90E2' : Color.White);

      Text(title)
        .fontColor(num == this.selectnumber ? '#4A90E2' : Color.White);
    }
    .width('100%')
    .height('100%')
    .backgroundImage(num == this.selectnumber ? $r('app.media.bottom_bg1') : $r('app.media.bottom_bg2'))
    .backgroundImageSize(ImageSize.Cover)
  }

  build() {
    Stack() {
      Column(){
        Tabs({ barPosition:BarPosition.End }){
          //主页面
          TabContent(){
            homepage({is_warn:this.is_warn,warn_data:this.warn_data,arr_room:this.arr_room})
          }
          .tabBar(this.MyBuilder_home("主页",0))

          //场景页面
          TabContent(){
            scene({arr_room:this.arr_room})
          }
          .tabBar(this.MyBuilder_add("场景",1))

          //用户页面
          TabContent(){
            userpage()
          }.tabBar(this.MyBuilder_user("用户",2))
        }
        .width('100%')
        .height('100%')
        .onChange((index:number)=> {
          this.selectnumber = index
        })
        .animationDuration(10)
      }
      .height('100%')
      .width('100%')
      .backgroundColor("#E6F2FF");


      Button("AI")
        .backgroundImage($r('app.media.ai_bg2'))
        .backgroundImageSize(ImageSize.Cover)
        .fontColor("#a8474545")
        .shadow({
          radius: 5,
          offsetX: 12,
          offsetY: 12,
          color: "#a8474545"
        })
        .onClick(()=>{
          this.is_show_AI = true
          animateTo({duration:500},()=>{
            this._height_AI = "100%"
          })
        })
        .position({x:"83%",y:"80%"})
        .width(60)
        .height(60)
        .borderRadius(30)

      if(this.is_show_AI){
        my_DeepSeek({is_show:this.is_show_AI,_height_AI:this._height_AI,_height:this._height_AI_com})
      }
      //最上层
      if(this.is_warn){
        WarnPage({warn_data:this.warn_data,is_warn:this.is_warn})
      }
    }
    .height('100%')
    .width('100%')
  }
}

export class Datamodel{
  type:string = ''
  arr:room[] = []
  data:number = 0
}

@Component
export struct WarnPage {
  title:string = "warning!!"
  @Link warn_data:Datamodel
  @State Warn_f_list:Furniture[] = []
  @State have_air_condition:boolean = false
  @State have_fan:boolean = false
  @Link is_warn:boolean
  @State a_id:number = 0
  @State Air_c:Furniture = new Furniture("",0,0)
  aboutToAppear(): void {
    for(let r of this.warn_data.arr){
      for(let f of r.furniture_s){
        if(f.type_id<4000&&f.type_id>2999){
          this.Warn_f_list.push(f)
          this.have_air_condition = true
          this.a_id = f.type_id
          this.Air_c = f
        }
        if(f.type_id>3999&&f.type_id<5000){
          this.Warn_f_list.push(f)
          this.have_fan = true
        }
      }
    }
  }
  build() {
    Stack() {
      Image($r('app.media.bottom_bg1'))
        .objectFit(ImageFit.Cover)
      if (this.warn_data.type == 'temp') {
        Column() {
          Text(this.warn_data.data.toString())
            .fontColor(Color.Red)
            .fontSize(100);
          Text("***温度警告***")
            .fontSize(18);
          Text("解决方案：目前温度已超过安全标准，请立即行动起来！！")
            .fontSize(16);
          Button(this.have_air_condition ? "开空调" : "开窗")
            .backgroundColor(Color.White)
            .width("50%")
            .height(50)
            .borderRadius(5)
            .borderWidth(2)
            .borderColor(Color.Black)
            .fontColor(Color.Red)
            .padding({ left: 15, right: 15 })
            .onClick(async () => {
              if (this.have_air_condition) {
                await tcp.send_on(this.a_id)
                await _IoTad.set_air_condition_by_id(25,"on","zl");
              }
              this.is_warn = false;
            });
          Row().height(5)
          Button("什么都不做")
            .onClick(()=>{this.is_warn = false;})
            .backgroundColor(Color.White)
            .width("50%")
            .height(50)
            .borderRadius(5)
            .borderWidth(2)
            .borderColor("#ff3e3e3e")
            .fontColor("#ff3e3e3e")

        }
      }
      if (this.warn_data.type == 'humi') {
        Column() {
          Row(){
            Text(this.warn_data.data.toString())
              .fontColor(Color.Red)
              .fontSize(100);
          }

          Text("***湿度警告***")
            .fontSize(18);
          Text("解决方案：")
            .fontSize(16);
          Text("  目前湿度已超过安全标准，请立即行动起来！！")
            .fontSize(16);
          Button(this.have_air_condition ? "开空调，并开始除湿" : "开窗")
            .backgroundColor(Color.White)
            .backgroundColor(Color.White)
            .width("50%")
            .height(50)
            .borderRadius(5)
            .borderWidth(2)
            .borderColor(Color.Black)
            .fontColor(Color.Red)
            .padding({ left: 15, right: 15 })
            .onClick(async () => {
              if (this.have_air_condition) {
                await tcp.send_on(this.a_id)
                await _IoTad.set_air_condition_by_id(25,"on","cs");
              }
              this.is_warn = false;
            });
          Row().height(5)
          Button("什么都不做")
            .onClick(()=>{this.is_warn = false;})
            .backgroundColor(Color.White)
            .width("50%")
            .height(50)
            .borderRadius(5)
            .borderWidth(2)
            .borderColor(Color.Black)
            .fontColor(Color.Black)
        }
      }
      if (this.warn_data.type == 'smoke') {
        Column() {
          Text(this.warn_data.data.toString())
            .fontColor(Color.Red)
            .fontSize(100);
          Text("***烟雾报警***")
            .fontSize(18);
          Text("解决方案：目前温度已超过安全标准，请立即行动起来！！")
            .fontSize(16);
          Button(this.have_fan ? "打开排风扇" : "开窗")
            .backgroundColor(Color.White)
            .width("50%")
            .height(50)
            .borderRadius(5)
            .borderWidth(2)
            .borderColor(Color.Black)
            .fontColor(Color.Red)
            .padding({ left: 15, right: 15 })
            .onClick(async () => {
              if (this.have_air_condition) {
                await tcp.send_on(this.a_id)
                await _IoTad.set_fan_by_id("on");
              }
              this.is_warn = false;
            });
          Row().height(5)
          Button("什么都不做")
            .onClick(()=>{this.is_warn = false;})
            .backgroundColor(Color.White)
            .width("50%")
            .height(50)
            .borderRadius(5)
            .borderWidth(2)
            .borderColor("#ff3e3e3e")
            .fontColor("#ff3e3e3e")
        }
      }
    }
    .height('100%')
    .width('100%')
    .backgroundColor("#E6F2FF");
  }
}