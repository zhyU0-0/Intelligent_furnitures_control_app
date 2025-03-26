import { rcp } from '@kit.RemoteCommunicationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { ArrayList } from '@kit.ArkTS';




class Message{
  public role:string= ''
  public content:string = ''

  constructor(role:string,content:string) {
    this.role = role
    this.content = content
  }
}

class ChatInfo{
  public model :string = ''
  public messages: Array<Message> = new Array()

  constructor(model: string, messages: Array<Message>) {
    this.model = model
    this.messages = messages
  }
}

//AI的一个回答
class Choice{
  public finish_reason:string = ''
  public message: Message = new Message("", "")

  constructor(finish_reason: string, message: Message) {
    this.finish_reason = finish_reason
    this.message = message
  }
}

//Token消耗情况
export class Usage {
  public prompt_tokens: number = 0
  public completion_tokens: number = 0
  public total_tokens: number = 0

  constructor(prompt_tokens: number, completion_tokens: number, total_tokens: number) {
    this.prompt_tokens = prompt_tokens
    this.completion_tokens = completion_tokens
    this.total_tokens = total_tokens
  }
}

//AI正常返回的信息
export class ChatResponse{
  public choices: Array<Choice> = new Array()
  public object: string = ""
  public usage: Usage = new Usage(0, 0, 0)
  public created: number = 0
  public system_fingerprint: string = ""
  public model: string = ""
  public id: string = ""

  constructor(choices: Array<Choice>, object: string, usage: Usage, created: number
    , system_fingerprint: string, model: string, id: string) {
    this.choices = choices
    this.object = object
    this.usage = usage
    this.created = created
    this.system_fingerprint = system_fingerprint
    this.model = model
    this.id = id
  }
}

export class API_DeepSeek{
  title: string = '使用RCP调用OpenAI接口实现智能助手';
  //连接、通讯历史记录
  msgHistory: string = ''
  //提问的问题
  question: string = ""
  //基地址
  baseUrl: string = "https://api.deepseek.com/v1"
  //API KEY
  apiKey: string = "sk-8304f07190544c7682b42db3c894a3d6"
  //模型名称
  modelName: string = "deepseek-chat"
  chaHistory: ArrayList<Message> = new ArrayList()
  chatAPI: string = "/chat/completions"
  scroll: Scroller = new Scroller()


  async chat(question:string):Promise<string> {
    let cfg: rcp.SessionConfiguration = {
      headers: {
        'Authorization': `Bearer ${this.apiKey}`,
        'Content-Type': 'application/json'
      }
    }

    let chatInfo = this.getChatInfo(question)
    let postInfo = JSON.stringify(chatInfo)
    const session = rcp.createSession(cfg)
    await session.post(this.baseUrl + this.chatAPI, postInfo)
      .then(resp => {
        console.log("resp::"+resp.toString())
        if (resp.statusCode == 200) {
          let chatResp = resp.toJSON() as ChatResponse;

          this.msgHistory += `我：${question}\r\n`
          this.msgHistory += `AI：${chatResp.choices[0].message.content}\r\n`
          this.msgHistory += `(共消耗token:${chatResp.usage.total_tokens}，其中提问：${chatResp.usage.prompt_tokens},回答：${chatResp.usage.completion_tokens})\r\n`
          return this.msgHistory
        }else {
          console.log("History::"+this.msgHistory)
          return "网络异常，请稍后再试"
        }
        console.log("History::"+this.msgHistory)
        return this.msgHistory
        console.log("success:cord:" + JSON.stringify(resp))

      })
      .catch((err: BusinessError) => {
        console.error(`err: err code is ${err.code}, err message is ${JSON.stringify(err)}`);
        return this.msgHistory
      })
    return this.msgHistory
  }

  getChatInfo(question:string) {
    let newMessage = new Message("user", question)
    this.chaHistory.add(newMessage)
    let chatInfo: ChatInfo = new ChatInfo(this.modelName, this.chaHistory.convertToArray())
    return chatInfo
  }
  getHistory(){
    console.log("History::"+this.msgHistory)
    return this.msgHistory
  }
}
@Entry
@Component
export struct OpenAI {
  @State title: string = '使用RCP调用OpenAI接口实现智能助手';
  //连接、通讯历史记录
  @State msgHistory: string = ''
  //提问的问题
  @State question: string = "二的三次方等于几"
  //基地址
  @State baseUrl: string = "https://api.deepseek.com/v1"
  //API KEY
  @State apiKey: string = "sk-8304f07190544c7682b42db3c894a3d6"
  //模型名称
  @State modelName: string = "deepseek-chat"
  chaHistory: ArrayList<Message> = new ArrayList()
  chatAPI: string = "/chat/completions"
  scroll: Scroller = new Scroller()

  build() {
    Row() {
      Column() {
        Text(this.title)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding(10)

        Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
          Text("Base Url:")
            .fontSize(14)
            .width(80)
          TextInput({ text: this.baseUrl })
            .onChange((value) => {
              this.baseUrl = value
            })
            .width(110)
            .fontSize(11)
            .flexGrow(1)

        }
        .width('100%')
        .padding(10)

        Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
          Text("API KEY：")
            .fontSize(14)
            .width(80)

          TextInput({ text: this.apiKey })
            .onChange((value) => {
              this.apiKey = value
            })
            .width(110)
            .type(InputType.Password)
            .fontSize(11)
            .flexGrow(1)
        }
        .width('100%')
        .padding(10)

        Flex({ justifyContent: FlexAlign.End, alignItems: ItemAlign.Center }) {
          Text("模型名称：")
            .fontSize(14)
            .width(80)

          TextInput({ text: this.modelName })
            .onChange((value) => {
              this.modelName = value
            })
            .width(110)
            .fontSize(11)
            .flexGrow(1)

          Button("提问")
            .onClick(() => {
              this.chat()
            })
            .width(100)
            .fontSize(14)
        }
        .width('100%')
        .padding(10)

        Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
          Text("您的问题：")
            .fontSize(14)
            .width(80)

          TextInput({ text: this.question })
            .onChange((value) => {
              this.question = value
            })
            .width(110)
            .fontSize(11)
            .flexGrow(1)
        }
        .width('100%')
        .padding(10)

        Scroll(this.scroll) {
          Text(this.msgHistory)
            .textAlign(TextAlign.Start)
            .padding(10)
            .width('100%')
            .backgroundColor(0xeeeeee)
        }
        .align(Alignment.Top)
        .backgroundColor(0xeeeeee)
        .height(300)
        .flexGrow(1)
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.On)
        .scrollBarWidth(20)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .height('100%')
    }
    .height('100%')
  }
  async chat() {
    let cfg: rcp.SessionConfiguration = {
      headers: {
        'Authorization': `Bearer ${this.apiKey}`,
        'Content-Type': 'application/json'
      }
    }

    let chatInfo = this.getChatInfo()
    let postInfo = JSON.stringify(chatInfo)
    const session = rcp.createSession(cfg)
    session.post(this.baseUrl + this.chatAPI, postInfo)
      .then(resp => {
        if (resp.statusCode == 200) {
          let chatResp = resp.toJSON() as ChatResponse;

          this.msgHistory += `我：${this.question}\r\n`
          this.msgHistory += `AI：${chatResp.choices[0].message.content}\r\n`
          this.msgHistory += `(共消耗token:${chatResp.usage.total_tokens}，其中提问：${chatResp.usage.prompt_tokens},回答：${chatResp.usage.completion_tokens})\r\n`
        }
        console.log("success:cord:" + JSON.stringify(resp))
      })
      .catch((err: BusinessError) => {
        console.error(`err: err code is ${err.code}, err message is ${JSON.stringify(err)}`);
      })
  }

  getChatInfo() {
    let newMessage = new Message("user", this.question)
    this.chaHistory.add(newMessage)
    let chatInfo: ChatInfo = new ChatInfo(this.modelName, this.chaHistory.convertToArray())
    return chatInfo
  }
}
