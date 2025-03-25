import { faceDetector } from '@kit.CoreVisionKit';
import { image } from '@kit.ImageKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import testNapi from 'libentry.so';

@Entry
@Component
struct Index {
  @State chooseImage: PixelMap | undefined = undefined
  @State dataValues: string = ''


  build() {
    Column() {
      Image(this.chooseImage)
        .objectFit(ImageFit.Fill)
        .height('60%')
      Text(this.dataValues)
        .copyOption(CopyOptions.LocalDevice)
        .height('15%')
        .margin(10)
        .width('60%')
      Button('选择图片')
        .type(ButtonType.Capsule)
        .fontColor(Color.White)
        .alignSelf(ItemAlign.Center)
        .width('80%')
        .margin(10)
        .onClick(() => {
          // 拉起图库
          this.selectImage()
        })
      Button('人脸检测')
        .type(ButtonType.Capsule)
        .fontColor(Color.White)
        .alignSelf(ItemAlign.Center)
        .width('80%')
        .margin(10)
        .onClick(async () => {
          if(!this.chooseImage) {
            console.log("chooseImage is undefind")
            return;
          }
          console.log("chooseImage not is undefind")
          const readBuffer: ArrayBuffer = new ArrayBuffer(96);
          this.chooseImage.readPixelsToBuffer(readBuffer)
          console.log("chooseImage is"+readBuffer+testNapi.max(readBuffer,4,4))
          testNapi.add(readBuffer,4)


        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  private async selectImage() {
    let uri = await this.openPhoto()
    if (uri === undefined) {
      hilog.error(0x0000, 'faceDetectorSample', "Failed to get uri.");
    }
    this.loadImage(uri);
  }

  private openPhoto(): Promise<string> {
    return new Promise<string>((resolve) => {
      let photoPicker: photoAccessHelper.PhotoViewPicker = new photoAccessHelper.PhotoViewPicker();
      photoPicker.select({
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 1
      }).then(res => {
        resolve(res.photoUris[0])
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, 'faceDetectorSample', `Failed to get photo image uri.code：${err.code}，message：${err.message}`);
        resolve('');
      })
    })
  }

  private loadImage(name: string) {
    setTimeout(async () => {
      let imageSource: image.ImageSource | undefined = undefined;
      let fileSource = await fileIo.open(name, fileIo.OpenMode.READ_ONLY);
      imageSource = image.createImageSource(fileSource.fd);
      this.chooseImage = await imageSource.createPixelMap();
      this.dataValues = "";
      hilog.info(0x0000, 'faceDetectorSample', 'this.chooseImage:', this.chooseImage);
    }, 100
    )
  }
}