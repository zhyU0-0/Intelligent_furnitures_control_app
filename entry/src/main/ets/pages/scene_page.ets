import { Furniture, room } from "../tool/classes";
import { control_aircon } from "../tool/component";
import { _IoTad } from "./scan_devices";

interface EnvironmentItemParams {
  icon: Resource;
  value: string;
  title: string;
  color?: string;
  onAction?: () => void;
}
type DescMap = Record<string, string>;
interface ControlItemParams {
  icon: Resource;
  title: string;
  status: string;
  buttonText: string;
  onAction: () => void;
}

@Component
export struct scene {
  @Link arr_room: room[];
  @State sceneList: string[] = ["睡眠模式", "离家模式", "娱乐模式"];
  @State isSleepSceneShow: boolean = false;
  @State isLeavingSceneShow: boolean = false;
  @State currentScene: string = '';
  @State panelHeight: string = "0%";

  build(): void {
    Stack() {
      Image($r('app.media.bottom_bg1'))
        .objectFit(ImageFit.Cover)

      List() {
        ForEach(this.sceneList, (sceneName: string, index: number) => {
          ListItem() {
            Column() {
              Image(this.getSceneIcon(index))
                .width(48)
                .height(48)
                .margin({ bottom: 8 });

              Text(sceneName)
                .fontSize(18)
                .fontColor('#2C3E50')
                .fontWeight(FontWeight.Medium);

              Text(this.getSceneDescription(sceneName))
                .fontSize(12)
                .fontColor('#7F8C8D')
                .margin({ top: 4 });
            }
            .padding(20)
            .backgroundColor(Color.White)
            .borderRadius(16)
            .shadow({ radius: 8, color: '#00000010', offsetX: 2, offsetY: 4 })
            .width('100%')
            .onClick(() => this.handleSceneClick(index));
          }
          .margin({ top: 8, bottom: 8 })
          .key(index.toString());
        }, (sceneName: string, index: number) => index.toString());
      }
      .width('90%')
      .alignListItem(ListItemAlign.Center)
      .edgeEffect(EdgeEffect.None);

      if (this.isSleepSceneShow || this.isLeavingSceneShow) {
        Column() {
          Blank()
            .onClick(() => this.closeScenePanels())
            .backgroundColor('#00000030');

          if (this.isSleepSceneShow) {
            scenes({
              scene: this.currentScene,
              arr_room: this.arr_room,
              is_show: this.isSleepSceneShow,
              _height: this.panelHeight
            })
              .transition(TransitionEffect.translate({ y: 1000 }).animation({ duration: 300 }));
          }

          if (this.isLeavingSceneShow) {
            leaving_scene({
              arr_room: this.arr_room,
              is_show: this.isLeavingSceneShow,
              _height: this.panelHeight
            })
              .transition(TransitionEffect.translate({ y: 1000 }).animation({ duration: 300 }));
          }
        }
      }
    }
    .height('100%');
  }

  private handleSceneClick(index: number): void {
    this.currentScene = this.sceneList[index];
    animateTo({ duration: 300 }, () => {
      this.panelHeight = "100%";
      if (index === 0) this.isSleepSceneShow = true;
      if (index === 1) this.isLeavingSceneShow = true;
    });
  }

  private closeScenePanels(): void {
    animateTo({ duration: 300 }, () => {
      this.panelHeight = "0%";
      this.isSleepSceneShow = false;
      this.isLeavingSceneShow = false;
    });
  }

  private getSceneIcon(index: number): Resource {
    const icons = [
      $r("app.media.ic_bedtime"),
      $r("app.media.home"),
      $r("app.media.ic_entertainment")
    ];
    return icons[index];
  }

  private getSceneDescription(scene: string): string {
    const descriptionMap: DescMap = {
      "睡眠模式": "关闭灯光，调节空调至适宜睡眠温度",
      "离家模式": "关闭所有设备，启动安防监控系统",
      "娱乐模式": "调暗灯光，准备影音娱乐环境"
    };
    return descriptionMap[scene] || '';
  }
}

@Component
struct scenes {
  @Link scene: string;
  @Link arr_room: room[];
  @Link is_show: boolean;
  @Link _height: string;
  @State furnitureList: Furniture[] = [];
  @State isEnabled: boolean = false;

  aboutToAppear(): void {
    this.furnitureList = this.arr_room
      .flatMap(r => r.furniture_s)
      .filter(f => f.type_id > 999 && f.type_id < 3000);
  }

  build(): void {
    Column() {
      Row() {
        Image($r("app.media.ic_back"))
          .fillColor('#ff111141')
          .width(24)
          .height(24)
          .onClick(() => this.closePanel());


        Text(this.scene)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center);

        Text(this.isEnabled ? "已启用" : "已关闭")
          .fontColor(this.isEnabled ? '#27AE60' : '#E74C3C')

        Toggle({ type: ToggleType.Switch, isOn:this.isEnabled})
          .onClick(()=>{
            this.isEnabled = !this.isEnabled
            if(this.isEnabled){
              _IoTad.set_LED_brightness_by_id(1,1001)
              _IoTad.set_curtain_by_id("off")
              let new_list:Furniture[] = []
              for (let i of this.furnitureList){
                i.switch = 0
                new_list.push(i)
              }
              this.furnitureList = new_list
            }else{
              _IoTad.set_LED_brightness_by_id(5000,1001)
              _IoTad.set_curtain_by_id("on")
            }
          })
      }
      .padding(16)
      .backgroundColor('#ffaaabff')
      .backdropBlur(10);

      Grid() {
        ForEach(this.furnitureList, (item: Furniture,value) => {
          GridItem() {
            Column() {
              Stack() {
                Circle()
                  .width(60)
                  .height(60)
                  .fill(item.switch ? '#3498DB30' : '#BDC3C730');

                Image(this.getDeviceIcon(item.type_id))
                  .width(30)
                  .height(30);
              }

              Text(item.name)
                .fontSize(14)
                .margin({ top: 8 })
                .textAlign(TextAlign.Center);

              Text(item.switch ? "已开启" : "已关闭")
                .fontSize(12)
                .fontColor(item.switch ? '#27AE60' : '#95A5A6');
            }
            .padding(12)
            .backgroundColor(Color.White)
            .borderRadius(12)
            .shadow({ radius: 4, color: '#00000010' })
            .onClick(() => {
              let f = this.toggleDevice(item)
              this.furnitureList[value] = f;
            });
          }
        });
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsGap(12)
      .columnsGap(12)
      .padding(16)
      .layoutWeight(1);
    }
    .backgroundColor('#F8F9FA')
    .height('100%');
  }

  private toggleDevice(item: Furniture): Furniture {
    item.switch = item.switch ? 0 : 1;
    _IoTad.set_curtain_by_id(item.switch ? "on" : "off");
    return new Furniture(item.name,item.switch,item.type_id)
  }

  private closePanel(): void {
    this.is_show = false;
    this._height = "0%";
  }

  private getDeviceIcon(typeId: number): Resource {
    return typeId < 2000 ? $r("app.media.light") : $r("app.media.curtain");
  }
}

@Component
struct leaving_scene {
  @Link arr_room: room[];
  @Link is_show: boolean;
  @Link _height: string;
  @State isAirConditionShow: boolean = false;
  @State petFoodRemaining: number = 65; // 添加剩余量状态

  build(): void {
    Stack(){
      Column() {
        Row() {
          Image($r("app.media.ic_back"))
            .fillColor('#ff111141')
            .width(24)
            .height(24)
            .onClick(() => this.closePanel());
          Text("离家模式")
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
            .textAlign(TextAlign.Center);
        }
        .padding(16)
        .backgroundColor('#ffaaabff')
        .backdropBlur(10);

        Row() {
          EnvironmentItem({
            icon: $r("app.media.ic_temp"),
            value: '26℃',
            title: '室内温度',
            color: '#E74C3C'
          });

          EnvironmentItem({
            icon: $r("app.media.ic_humidity"),
            value: '55%',
            title: '环境湿度',
            color: '#3498DB'
          });

          EnvironmentItem({
            icon: $r("app.media.ic_gas"),
            value: '正常',
            title: '燃气状态',
            color: '#ff544539'
          });
        }
        .padding(16)
        .justifyContent(FlexAlign.SpaceEvenly);

        List() {
          ControlItem({
            params: {
              icon: $r("app.media.ic_camera"),
              title: "安防摄像头",
              status: "在线",
              buttonText: "实时查看",
              onAction: () => this.viewCamera()
            }
          });

          ControlItem({
            params: {
              icon: $r("app.media.ac_icon"),
              title: "空调控制",
              status: "26℃ 制冷模式",
              buttonText: "远程调节",
              onAction: () => this.isAirConditionShow = true
            }
          });

          ControlItem({
            params: {
              icon: $r("app.media.ic_feeder"),
              title: "宠物喂食器",
              status: `剩余量：${this.petFoodRemaining}%`, // 绑定动态值
              buttonText: "立即投喂",
              onAction: () => this.feedPet()
            }
          });
        }
        .borderRadius(16)
        .margin(16)
        .backgroundColor(Color.White)
        .shadow({ radius: 8, color: '#00000010' });


      }
      .backgroundColor('#F8F9FA')
      .height('100%');

      if (this.isAirConditionShow) {
        control_aircon({
          is_show: this.isAirConditionShow,
          arr_room: this.arr_room
        });
      }
    }

  }

  private viewCamera(): void {
    // 查看摄像头逻辑
  }

  private feedPet(): void {
    this.petFoodRemaining = Math.max(this.petFoodRemaining - 5, 0);
  }
  private closePanel(): void {
    this.is_show = false;
    this._height = "0%";
  }
}

@Component
struct EnvironmentItem {
  @Prop icon: Resource;
  @Prop value: string;
  @Prop title: string;
  @Prop color: string = '#ffaaabff';

  build(): void {
    Column() {
      Image(this.icon)
        .width(40)
        .height(40)
        .fillColor(this.color);

      Text(this.value)
        .fontSize(20)
        .fontColor(this.color)
        .margin({ top: 8 })
        .fontWeight(FontWeight.Medium);

      Text(this.title)
        .fontSize(12)
        .fontColor('#7F8C8D');
    }
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 4, color: '#00000010' });
  }
}

@Component
struct ControlItem {
  @Prop params: ControlItemParams;

  build(): void {
    Row() {
      Image(this.params.icon)
        .width(32)
        .height(32)
        .margin({ right: 16 });

      Column() {
        Text(this.params.title)
          .fontSize(16)
          .fontColor('#2C3E50');
        Text(this.params.status)
          .fontSize(12)
          .fontColor('#7F8C8D');
      }
      .layoutWeight(1);

      Button(this.params.buttonText)
        .type(ButtonType.Normal)
        .backgroundColor('#ffaaabff')
        .fontColor(Color.White)
        .borderRadius(20)
        .padding({ left: 16, right: 16 })
        .onClick(this.params.onAction);
    }
    .padding(16)
    .width('100%');
  }
}