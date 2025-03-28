//自动搜索设备页面
import { resolveIP, _Udp } from '../tool/UDP'
import util from '@ohos.util';
import { socket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { wifi } from '@kit.ConnectivityKit';


let udp:socket.UDPSocket = socket.constructUDPSocketInstance()
@Component
export struct search_device{

  @State message:string = ''
  @State List:string[] = []

  async aboutToAppear() {
    await this.init()
  }
  build() {
    Column(){
      if(this.List.length != 0){
        List(){
          ForEach(this.List,(item:string)=>{
            ListItem(){
              Text(item)
            }
          })
        }
      } else{
        Text("正在搜索")
        Button()
          .onClick(async ()=>{
            await this.search()
            setTimeout(()=>{
              this.close()
            },10000)
          })
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
        this.List.push("无")
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