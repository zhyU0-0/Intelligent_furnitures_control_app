//自动搜索设备页面
import { resolveIP, _Udp } from '../tool/UDP'
import util from '@ohos.util';
import { socket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { wifi } from '@kit.ConnectivityKit';
import { router } from '@kit.ArkUI';


let udp:socket.UDPSocket = socket.constructUDPSocketInstance()
@Entry
@Component
export struct search_device{

  @State _text:string = "点击按钮开始搜索"
  @State message:string = ''
  @State List:string[] = []
  @State is_add:boolean = false
  async aboutToAppear() {
    await this.init()
  }
  build() {
    Stack() {
      Column(){
      if (this.List.length != 0) {
        List() {
          ForEach(this.List, (item: string) => {
            ListItem() {
              Row() {
                Text(item)
                Button('+')
                  .onClick(() => {
                    this.is_add = true
                    setTimeout(() => {
                      AlertDialog.show({ message: "添加成功！！" })
                      router.back()

                    }, 2000)
                  })

              }.width('100%').height("15%").backgroundColor(Color.White).justifyContent(FlexAlign.SpaceEvenly)

            }

            ListItem().height(3).backgroundColor("#00818181")
          })
        }

        Button("再次搜索")
          .onClick(() => {
            this.List = []
          })
      } else {
        Text(this._text)
        Button()
          .onClick(async () => {
            this._text = '正在搜索....'

            setTimeout(async () => {
              this.List.push("Hi3861")
              await this.search()
              this.close()
            }, 5000)
          })
      }
    }
      if (this.is_add){
        Column().width("100%").height("100%").backgroundColor("#ff989898")
      }
    }
  }
  async init(){

    let decoder = util.TextDecoder.create('utf-8');
    await udp.bind({port: 8888,
      address: resolveIP(wifi.getIpInfo().ipAddress)})
    udp.setExtraOptions({
      broadcast:true
    })
    udp.on("message",async (data:socket.SocketMessageInfo)=>{
      let str = decoder.decodeToString(new Uint8Array(data.message));
      if(str !="已发送"){
        this.List.push(str)
      }else {

      }
    })

  }
  async search(){
    await udp.send({
      data:`{address:${wifi.getIpInfo().ipAddress},port:8888,action:"search_device"}`,
      address:{address:"255.255.255.255",port:8888}
    })
    await udp.send({data:"已发送",address:{address:wifi.getIpInfo().ipAddress.toString(),port:8888}})
    console.log(`UDP ==Send data >: {address:"255.255.255.255",port:8888}`)
  }
  async close(){
    udp.off("message")
    udp.close()
  }
}