//
//  UIImage+UdeskSDK.m
//  UdeskSDK
//
//  Created by Udesk on 16/3/2.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UIImage+UdeskSDK.h"
#import "UdeskBundleUtils.h"

@implementation UIImage (UdeskSDK)

+ (UIImage *)udAnimatedGIFWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    size_t count = CGImageSourceGetCount(source);
    
    UIImage *animatedImage;
    
    if (count <= 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
    }
    else {
        NSMutableArray *images = [NSMutableArray array];
        
        NSTimeInterval duration = 0.0f;
        
        for (size_t i = 0; i < count; i++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            if (!image) {
                continue;
            }
            
            duration += [self udFrameDurationAtIndex:i source:source];
            
            [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
            
            CGImageRelease(image);
        }
        
        if (!duration) {
            duration = (1.0f / 10.0f) * count;
        }
        
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }
    
    CFRelease(source);
    
    return animatedImage;
}

+ (float)udFrameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTimeUnclampedProp) {
        frameDuration = [delayTimeUnclampedProp floatValue];
    }
    else {
        
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTimeProp) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    
    // Many annoying ads specify a 0 duration to make an image flash as quickly as possible.
    // We follow Firefox's behavior and use a duration of 100 ms for any frames that specify
    // a duration of <= 10 ms. See <rdar://problem/7689300> and <http://webkit.org/b/36082>
    // for more information.
    
    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }
    
    CFRelease(cfFrameProperties);
    return frameDuration;
}

+ (UIImage *)udBubbleSendImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udChatBubbleSendingSolid.png")];
}

+ (UIImage *)udBubbleReceiveImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udChatBubbleReceivingSolid.png")];
}

+ (UIImage *)udDefaultRefreshImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udRefreshButton.png")];
}

+ (UIImage *)udDefaultVoiceImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udChatVoice.png")];
}

+ (UIImage *)udDefaultKeyboardImage {
    
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udChatKeyboard.png")];
}

+ (UIImage *)udDefaultMoreImage {
    
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udChatMore.png")];
}

+ (UIImage *)udDefaultSmileImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udSmileButton.png")];
}

+ (UIImage *)udDefaultCustomerImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udCustomerAvatar.png")];
}

+ (UIImage *)udDefaultAgentImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udAgentAvatar.png")];
}

+ (UIImage *)udDefaultBackImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udBlueBack.png")];
}

+ (UIImage *)udDefaultWhiteBackImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udWhiteBack.png")];
}

//更多-相册
+ (UIImage *)udDefaultChatBarMorePhotoImage {
    
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udChatBarMorePhoto.png")];
}

//更多-相机
+ (UIImage *)udDefaultChatBarMoreCameraImage {
    
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udChatBarMoreCamera.png")];
}

//更多-评价
+ (UIImage *)udDefaultChatBarMoreSurveyImage {
    
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udChatBarMoreSurvey.png")];
}

//更多-地理位置
+ (UIImage *)udDefaultChatBarMoreLocationImage{
    
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udChatBarMoreLocation.png")];
}

//更多-视频通话
+ (UIImage *)udDefaultChatBarMoreVideoCallImage{
    
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udChatBarMoreVideoCall.png")];
}

//取消发送
+ (UIImage *)udDefaultVoiceRevokeImage {
    
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udVoiceRevoke.png")];
}

/** 发送语音时话筒图片 */
+ (UIImage *)udDefaultVoiceSpeakImage {
    
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udVoiceSpeak.png")];
}

/** 语音太短 */
+ (UIImage *)udDefaultVoiceTooShortImage {
    
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udVoiceTooshort.png")];
}

/** 自定义工具栏 满意度评价 */
+ (UIImage *)udDefaultCustomToolBarSurveyImage {
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udCustomToolBarSurvey.png")];
}

/** 满意度评价关闭按钮 */
+ (UIImage *)udDefaultSurveyCloseImage {
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udSurveyClose.png")];
}

/** 满意度评价文本模式未选择 */
+ (UIImage *)udDefaultSurveyTextNotSelectImage {
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udSurveyTextNotSelect.png")];
}

/** 满意度评价文本模式选择 */
+ (UIImage *)udDefaultSurveyTextSelectedImage {
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udSurveyTextSelected.png")];
}

/** 满意度评价表情 满意 */
+ (UIImage *)udDefaultSurveyExpressionSatisfiedImage {
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udSurveyExpressionSatisfied.png")];
}

/** 满意度评价表情 一般 */
+ (UIImage *)udDefaultSurveyExpressionGeneralImage {
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udSurveyExpressionGeneral.png")];
}

/** 满意度评价表情 不满意 */
+ (UIImage *)udDefaultSurveyExpressionUnsatisfactoryImage {
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udSurveyExpressionUnsatisfactory.png")];
}

/** 满意度评价表情 空星 */
+ (UIImage *)udDefaultSurveyStarEmptyImage {
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udSurveyStarEmpty.png")];
}

/** 满意度评价表情 实星 */
+ (UIImage *)udDefaultSurveyStarFilledImage {
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udSurveyStarFilled.png")];
}

+ (UIImage *)udDefaultAgentOnlineImage {
	return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udAgentStatusOnline.png")];
}

+ (UIImage *)udDefaultAgentOfflineImage {
	return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udAgentStatusOffline.png")];
}

+ (UIImage *)udDefaultAgentBusyImage {
	return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udAgentStatusBusy.png")];
}

+ (UIImage *)udDefaultTransferImage {
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udTransfer.png")];
}

+ (UIImage *)udDefaultLoadingImage {
	return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udImageLoading.png")];
}

+ (UIImage *)udDefaultResetButtonImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udRefreshButton.png")];
}

+ (UIImage *)udDefaultLocationPinImage {
    
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udMapLocation.png")];
}

+ (UIImage *)udDefaultMarkImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udMark.png")];
}

//视频会话
+ (UIImage *)udDefaultVideoCallImage {
    
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udVideoCall.png")];
}

//视频会话(收到
+ (UIImage *)udDefaultVideoCallReceiveImage {
    
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udVideoCallReceive.png")];
}

//图片选择器，未选择
+ (UIImage *)udDefaultImagePickerNotSelected {
    
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udNotSelected.png")];
}

//图片选择器，未原图
+ (UIImage *)udDefaultImagePickerFullImage {
    
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udFullImage.png")];
}

//图片选择器，已原图
+ (UIImage *)udDefaultImagePickerFullImageSelected {
    
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udFullImageSelected.png")];
}

//图片选择器，视频播放
+ (UIImage *)udDefaultImagePickerVideoPlay {
    
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udPhotosVideoPlay.png")];
}

//图片选择器，视频icon
+ (UIImage *)udDefaultImagePickerVideoIcon {
    
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udPhotosAssetVideoIcon.png")];
}

//小视频返回按钮
+ (UIImage *)udDefaultSmallVideoBack {
    
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udClose.png")];
}

//小视频切换摄像头按钮
+ (UIImage *)udDefaultSmallVideoCameraSwitch {
    
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udCameraSwitch.png")];
}

//小视频重拍
+ (UIImage *)udDefaultSmallVideoRetake {
    
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udSmallVideoRetake.png")];
}

//小视频完成
+ (UIImage *)udDefaultSmallVideoDone {
    
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udSmallVideoRight.png")];
}

//小视频下载
+ (UIImage *)udDefaultVideoDownload {
    
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udVideoDownload.png")];
}

//小视频下载
+ (UIImage *)udDefaultVideoPlay {
    
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udVideoPlay.png")];
}

@end
