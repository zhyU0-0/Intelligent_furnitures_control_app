// 引入包名
import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';


export class HttpRequest{
  url:string = ''
  httpRequest = http.createHttp();

  request(url:string){

    let body:string = ''
    let httpRequest = http.createHttp();
    httpRequest.request(url,{header:{"Content-Type": "application/json",
      "X-Auth-Token":{
        "auth": {
          "identity": {
            "methods": [
              "password"
            ],
            "password": {
              "user": {
                "domain": {
                  "name": "IAMDomain"
                },
                "name": "IAMUser",
                "password": "IAMPassword"
              }
            }
          },
          "scope": {
            "domain": {
              "name": "IAMDomain"
            }
          }
        }
      }
    }}, (err: Error, data: http.HttpResponse) => {
      if (!err) {
        console.info('Result:' + JSON.stringify(data.result));
        console.info('code:' + data.responseCode);
        console.info('type:' + JSON.stringify(data.resultType));
        console.info('header:' + JSON.stringify(data.header));
        console.info('cookies:' + data.cookies); // 自API version 8开始支持cookie。
        body = JSON.stringify(data.result)
        console.log("re::::::"+body)

      } else {
        console.info('error:' + JSON.stringify(err));
      }
    });
    return body


  }


}