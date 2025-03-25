
import http from '@ohos.net.http';
// 定义常量
const IAM_ENDPOINT = 'iam.myhuaweicloud.com'; // IAM 服务地址
const IOTDA_ENDPOINT = 'fa8fa44365.st1.iotda-app.cn-north-4.myhuaweicloud.com'; // IoTDA 服务地址
const USERNAME = 'GT-2401_87842262'; // 华为云账号用户名
const PASSWORD = '200626Qq'; // 华为云账号密码
const DOMAIN_NAME = 'GT-2401_87842262'; // 账号所属域名
const PROJECT_NAME = 'cn-north-4'; // 项目名称
const PROJECT_ID = '0b37c83e2dba46e08ba5e1da37aeedc8'; // 项目 ID


interface _body{
  "auth":_auth
}
interface _auth{
  "identity":_identity,
  "scope":_scope
}
interface _identity{
  "methods":string[],
  "password":_password
}
interface _password{
  "user":_user
}
interface _user{
  "name":string,
  "password":string
  "domain":_domain
}
interface _domain{
  "name":string
}
interface _scope{
  "project":_project
}
interface _project{
  "name":string
}


interface _body4_get_data{
  service_id:string
  command_name:string
  paras:_paras4
}
interface _paras4{}


interface _body1_push_brightness{
  service_id:string
  command_name:string
  paras:_paras
}
interface _paras{ brightness:number }


export class IoTad{
  Token:string = ''
  DEVICE_ID:string|undefined = "67df87e02902516e866a169d_1001"

  async init() {

      await this.getToken().then((value)=>{
        if(value == 1){
          this.getDeviceList(this.Token).then((value)=>{
            if(value == 1){
              AlertDialog.show({message:"云端连接成功"})
              return
            }else {
              console.log("IoTad getDeviceList fail!!")
              AlertDialog.show({message:"云端连接失败"})
              return
            }
          })

        }else {
          console.log("IoTad getToken fail!!")
          AlertDialog.show({message:"云端连接失败"})
          return
        }
      })

  }

  async  getToken(){
    const httpRequest = http.createHttp();
    const url = `https://${IAM_ENDPOINT}/v3/auth/tokens`;
    const body:_body = {
      "auth": {
        "identity": {
          "methods": ['password'],
          "password": {
            "user": {
              "name": USERNAME,
              "password": PASSWORD,
              "domain": {
                "name": DOMAIN_NAME,
              },
            },
          },
        },
        "scope": {
          "project": {
            "name": PROJECT_NAME,
          },
        },
      },
    };

    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
        },
        extraData: JSON.stringify(body),
      });

      console.log("resp::::"+JSON.stringify(response))
      if (response.responseCode === 201) {
        const token:string = response.header['x-subject-token'];
        console.log("token is :"+JSON.stringify(response.header))
        console.log("real token is:\n"+token)
        this.Token = token;
        return 1;
      } else {
        console.log('Request URL:', url);
        console.log('Request Body:', JSON.stringify(body));
        console.log('Response Code:', response.responseCode);
        console.log('Response Body:', response.result.toString());
        throw new Error(`Failed to get token: ${response.responseCode}`);
      }
    } catch (error) {
      console.error('Error getting token:', error);
      return -1
    } finally {
      httpRequest.destroy();
    }
  }


  async getDeviceList(token: string) {
  const httpRequest = http.createHttp();
  const url = `https://${IOTDA_ENDPOINT}/v5/iot/${PROJECT_ID}/devices`;

  try {
    const response = await httpRequest.request(url, {
      method: http.RequestMethod.GET,
      header: {
        'Content-Type': 'application/json',
        'X-Auth-Token': token,
      },
    });

    if (response.responseCode === 200) {
      console.log("deviceList::::"+response.result.toString())
      let regex = /"device_id":"(.*?)"/
      console.log("DEVICE_ID:::"+response.result.toString().match(regex)?.toString().split(",")[1])
      this.DEVICE_ID = response.result.toString().match(regex)?.toString().split(",")[1]
      const deviceList:string = JSON.parse(response.result.toString());
      return 1;
    } else {
      throw new Error(`Failed to get device list: ${response.responseCode}`);
    }
  } catch (error) {
    console.error('Error getting device list:', error);
    return -1
  } finally {
    httpRequest.destroy();
  }
}


  async get_data(name:string,content:string,service_id:string){

    const httpRequest = http.createHttp();
    const url = `https://${IOTDA_ENDPOINT}/v5/iot/${PROJECT_ID}/devices/${this.DEVICE_ID}/commands`;
    const body :_body4_get_data = {
      service_id: service_id, // 设备模型中的服务 ID
      command_name: name, // 命令名称
      paras: {}
    };

    console.log("body:::"+JSON.stringify(body))
    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'X-Auth-Token': this.Token,
        },
        extraData: JSON.stringify(body),
      });

      console.log("Message sent::"+response.result)
      if (response.responseCode === 200) {
        console.log('Message sent successfully:', response.result.toString());
        let regex = /"response":(.*?)}}}/

        return response.result.toString().match(regex)?.toString().split(",")[1]+"}"
      } else {
        return -1

      }
    } catch (error) {
      console.error('Error sending message:', error);
      return -1
    } finally {
      httpRequest.destroy();
    }
  }


  async set_LED_brightness_by_id(brightness:number,LED_id:number){

    const httpRequest = http.createHttp();
    const url = `https://${IOTDA_ENDPOINT}/v5/iot/${PROJECT_ID}/devices/${this.DEVICE_ID}/commands`;
    const body :_body1_push_brightness = {
      service_id: "device_ctrl", // 设备模型中的服务 ID
      command_name: "set_brightness", // 命令名称
      paras: {
        // 命令参数
        brightness: brightness
      },
    };

    console.log("body:::"+JSON.stringify(body))
    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'X-Auth-Token': this.Token,
        },
        extraData: JSON.stringify(body),
      });

      console.log("Message sent::"+response.result)
      if (response.responseCode === 200) {
        console.log('Message sent successfully:', response.result.toString());
        return 1
      } else {
        return -1
      }
    } catch (error) {
      console.error('Error sending message:', error);
      return -1
    } finally {
      httpRequest.destroy();
    }

  }


}



