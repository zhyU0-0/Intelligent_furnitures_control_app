import { textRecognition } from '@kit.CoreVisionKit'
import { image } from '@kit.ImageKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';

let imageSource: image.ImageSource | undefined = undefined;
let chooseImage: PixelMap | undefined = undefined;
// 将图片转换为PixelMap，可以通过图库获取
let photoPicker: photoAccessHelper.PhotoViewPicker = new photoAccessHelper.PhotoViewPicker();
photoPicker.select({
  MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE, maxSelectNumber: 1
}).then((res: photoAccessHelper.PhotoSelectResult) => {
  let uri = res.photoUris[0];
  if (uri === undefined) {
    hilog.error(0x0000, 'OCRDemo', "Failed to get uri.");
    return;
  }
  setTimeout(async () => {
    let fileSource = await fileIo.open(uri, fileIo.OpenMode.READ_ONLY);
    imageSource = image.createImageSource(fileSource.fd);
    chooseImage = await imageSource.createPixelMap();
    hilog.info(0x0000, 'OCRDemo', `chooseImage：${chooseImage.toString()}`);
    if (!chooseImage) {
      return;
    }

    if (canIUse("SystemCapability.AI.OCR.TextRecognition")) {
      console.log("该设备支持SystemCapability.ArkUI.ArkUI.Full");
    } else {
      console.log("该设备不支持SystemCapability.ArkUI.ArkUI.Full");
    }
    console.log("recognizing 1")
    // 调用文本识别接口
    let visionInfo: textRecognition.VisionInfo = {
      pixelMap: chooseImage
    };
    console.log("recognizing 2")
    textRecognition.init()
    textRecognition.recognizeText(visionInfo, (error: BusinessError, data: textRecognition.TextRecognitionResult) => {
      if (error.code !== 0) {
        console.log("recognizing Failed")
        hilog.error(0x0000, 'OCRDemo', `Failed to recognize text. Code: ${error.code}, message: ${error.message}`);
        return;
      }
      console.log("recognizing 3")
      // 识别成功，获取对应的结果
      let recognitionString = data.toString();
      hilog.info(0x0000, 'OCRDemo', `Succeeded in recognizing text：${recognitionString}`);
      console.log("Succeeded in recognizing text"+recognitionString)

      if(chooseImage && imageSource) {
        chooseImage.release();
        imageSource.release();
      }
    });
  }, 100)
}).catch((err: BusinessError) => {
  hilog.error(0x0000, 'OCRDemo', `Failed to get photo image uri. Code：${err.code}，message：${err.message}`);
  console.log("Failed to get photo image uri")
})

@Entry
@Component
struct Page {

  build() {
    Column(){
    }
  }
}