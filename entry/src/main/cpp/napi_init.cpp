/*
#ifndef OpencvSample_common_H
#define OpencvSample_common_H
 
#include <string>
#include <stdio.h>
#include <js_native_api.h>
#include <js_native_api_types.h>
#include <vector>
#include "opencv2/opencv.hpp"
#include "opencv2/imgcodecs/legacy/constants_c.h"
#include "hilog/log.h"
#include "napi/native_api.h"
#include "rawfile/raw_file_manager.h"
#include "rawfile/raw_file.h"
#include "rawfile/raw_dir.h"
 
#define GLOBAL_RESMGR (0xFFEE)
constexpr int32_t RGB_565 = 2;
constexpr int32_t RGBA_8888 = 3;
 
constexpr int32_t STR_MAX_SIZE = 200;
constexpr int32_t LONG_STR_MAX_SIZE = 1024;
constexpr int32_t ERR_OK = 0;
constexpr int8_t NO_ERROR = 0;
constexpr int8_t ERROR = -1;
constexpr uint8_t PARAM0 = 0;
constexpr uint8_t PARAM1 = 1;
constexpr uint8_t PARAM2 = 2;
constexpr uint8_t PARAM3 = 3;
constexpr uint8_t PARAM4 = 4;
constexpr uint8_t PARAM5 = 5;
constexpr uint8_t PARAM6 = 6;
constexpr uint8_t PARAM7 = 7;
constexpr uint8_t PARAM8 = 8;
constexpr uint8_t PARAM9 = 9;
constexpr uint8_t PARAM10 = 10;
constexpr uint8_t PARAM11 = 11;
constexpr uint8_t PARAM12 = 12;
 
constexpr int32_t ARGS_ONE = 1;
constexpr int32_t ARGS_TWO = 2;
constexpr int32_t ONLY_CALLBACK_MAX_PARA = 1;
constexpr int32_t ONLY_CALLBACK_MIN_PARA = 0;
 
struct CallbackPromiseInfo {
    napi_ref callback = nullptr;
    napi_deferred deferred = nullptr;
    bool isCallback = false;
    int32_t errorCode = 0;
};
 
template <typename T> void FreeMemory(T *p) {
    if (p == nullptr) {
        return;
    }
    delete p;
    p = nullptr;
}
 
template <typename T> void FreeMemoryArray(T *p) {
    if (p == nullptr) {
        return;
    }
    delete[] p;
    p = nullptr;
}
#define NAPI_RETVAL_NOTHING
#define NAPI_CALL_BASE(env, theCall, retVal)                                                                           \
    do {                                                                                                               \
        if ((theCall) != 0) {                                                                                          \
            return retVal;                                                                                             \
        }                                                                                                              \
    } while (0)
 
#define NAPI_CALL(env, theCall) NAPI_CALL_BASE(env, theCall, nullptr)
#define NAPI_CALL_RETURN_VOID(env, theCall) NAPI_CALL_BASE(env, theCall, NAPI_RETVAL_NOTHING)
 
extern bool GetMatFromRawFile(napi_env env, napi_value jsResMgr, const std::string &rawfileDir,
                              const std::string &fileName, cv::Mat &srcImage);
extern bool cvtMat2Pixel(cv::InputArray _src, cv::OutputArray &_dst, int code);
extern napi_value NapiGetNull(napi_env env);
extern uint32_t GetMatDataBuffSize(const cv::Mat &mat);
extern bool CreateArrayBuffer(napi_env env, uint8_t *src, size_t srcLen, napi_value *res);
extern napi_value NapiGetUndefined(napi_env env);
extern napi_value GetCallbackErrorValue(napi_env env, int32_t errCode);
extern napi_value NapiGetBoolean(napi_env env, const bool &isValue);
extern uint32_t GetMatDataBuffSize(const cv::Mat &mat);
extern void SetCallback(const napi_env &env, const napi_ref &callbackIn, const int32_t &errorCode,
                        const napi_value &result);
extern void SetPromise(const napi_env &env, const napi_deferred &deferred, const int32_t &errorCode,
                       const napi_value &result);
extern void ReturnCallbackPromise(const napi_env &env, const CallbackPromiseInfo &info, const napi_value &result);
extern napi_value JSParaError(const napi_env &env, const napi_ref &callback);
extern void PaddingCallbackPromiseInfo(const napi_env &env, const napi_ref &callback, CallbackPromiseInfo &info,
                                       napi_value &promise);
extern bool WrapJsPixelInfoInfo(napi_env env, cv::Mat &outMat, napi_value &result);
 
#endif //OpencvSample_common_H


using namespace std;
using namespace cv;
static const char *TAG = "[opencv_img2Gray]";
 
napi_value Img2Gray(napi_env env, napi_callback_info info) {
    OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "Img2Gray Begin");
    napi_value result = NapiGetNull(env);
    size_t argc = 3;
    napi_value argv[3] = {nullptr};
 
    napi_get_cb_info(env, info, &argc, argv, nullptr, nullptr);
 
    size_t strSize;
    char strBuf[256];
    napi_get_value_string_utf8(env, argv[1], strBuf, sizeof(strBuf), &strSize);
    std::string fileDir(strBuf, strSize);
    OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "fileDir：%{public}s", fileDir.c_str());
 
    napi_get_value_string_utf8(env, argv[2], strBuf, sizeof(strBuf), &strSize);
    std::string fileName(strBuf, strSize);
    OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "fileName：%{public}s", fileName.c_str());
 
    Mat srcImage;
    if (!GetMatFromRawFile(env, argv[0], fileDir, fileName, srcImage)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RESMGR, TAG, "Get Mat from rawfile failed!.");
        return result;
    }
 
    Mat srcGray;
    cvtColor(srcImage, srcGray, COLOR_RGB2GRAY);
 
    // 將图像转换为pixelMap格式
    Mat outMat;
    cvtMat2Pixel(srcGray, outMat, RGBA_8888);
    OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "outMat size: %zu, cols：%{public}d, rows：%{public}d",
                 outMat.total(), outMat.cols, outMat.rows);
 
    napi_create_object(env, &result);
    bool retVal = WrapJsPixelInfoInfo(env, outMat, result);
    if (!retVal) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RESMGR, TAG, "WrapJsInfo failed!.");
    }
 
    return result;
}
 */
#include <string>
#include <stdio.h>
#include <js_native_api.h>
#include <js_native_api_types.h>
#include <vector>
/*
#include "opencv2/opencv.hpp"
#include "opencv2/imgcodecs/legacy/constants_c.h"
#include "hilog/log.h"
#include "napi/native_api.h"
#include "rawfile/raw_file_manager.h"
#include "rawfile/raw_file.h"
#include "rawfile/raw_dir.h"
constexpr int32_t RGBA_8888 = 3;

using namespace cv;
static napi_value Add(napi_env env, napi_callback_info info)
{
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args , nullptr, nullptr);
    double value1;
    napi_get_value_double(env, args[0], &value1);
    napi_value a;
    napi_create_double(env,  value1, &a);
    return a;
    napi_throw_type_error(env, nullptr, "参数必须是 ArrayBuffer");
        return nullptr;
    
     napi_valuetype valueType;
    napi_typeof(env, args[1], &valueType);
    if (valueType != napi_object) {
        napi_throw_type_error(env, nullptr, "参数必须是 ArrayBuffer");
        return nullptr;
    }else{
        napi_throw_type_error(env, nullptr, "参数是 ArrayBuffer");
        return nullptr;
    }
    
    napi_valuetype valuetype0;
    napi_typeof(env, args[0], &valuetype0);

    napi_valuetype valuetype1;
    napi_typeof(env, args[1], &valuetype1);

    double value0;
    napi_get_value_double(env, args[0], &value0);

    */
/*double value1;
    napi_get_value_double(env, args[1], &value1);*//*


    napi_value sum;
    napi_create_double(env, value0 + value1, &sum);

    return sum;

}

static napi_value Max(napi_env env,napi_callback_info info){
    
    // 获取参数
    size_t argc = 3;
    napi_value args[3];
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    
    // 检查参数是否为 ArrayBuffer
    napi_valuetype valueType;
    napi_typeof(env, args[0], &valueType);
    if (valueType != napi_object) {
        napi_throw_type_error(env, nullptr, "参数必须是 ArrayBuffer");
        return nullptr;
    }
    
    
    // 获取 ArrayBuffer 的数据指针和长度
    uint8_t* bufferData = nullptr;
    size_t bufferLength = 0;
    napi_get_arraybuffer_info(env, args[0], reinterpret_cast<void**>(&bufferData), &bufferLength);
    
    // 获取宽度和高度
    int width, height;
    napi_get_value_int32(env, args[1], &width);
    napi_get_value_int32(env, args[2], &height);
    
    
    cv::Mat image(height, width, CV_8UC3, bufferData);
   
    
    if (image.empty()) {
        napi_throw_error(env, nullptr,"image.empty()");
        return nullptr;
    }

     
    // 灰度化处理
    cv::Mat grayImage;
    cv::cvtColor(image, grayImage, cv::COLOR_BGR2GRAY);
    
    

    
    napi_value result ;
    napi_create_date(env,image.total(), &result);
 
    return result;
   
    */
/*/*
/ 保存处理后的图片
    std::string outputPath = "gray_" + std::string(filePath);
    cv::imwrite(outputPath, grayImage);

    // 返回处理后的图片路径*//*

    
   
    napi_create_double(env,  4, &result);
    //napi_create_string_utf8(env, outputPath.c_str(), outputPath.size(), &result);
    return result;
}
//
// Created on 2024/3/5.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".
 

#define OpencvSample_common_H
 

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        { "add", nullptr, Add, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "max", nullptr, Max, nullptr, nullptr, nullptr, napi_default, nullptr },
        //{"img2Gray",nullptr,Img2Gray,nullptr,nullptr,nullptr,napi_default,nullptr}
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,//napi_module入口方法
    .nm_modname = "entry",//napi_module模块名
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterEntryModule(void)
{
    napi_module_register(&demoModule);
}
*/
