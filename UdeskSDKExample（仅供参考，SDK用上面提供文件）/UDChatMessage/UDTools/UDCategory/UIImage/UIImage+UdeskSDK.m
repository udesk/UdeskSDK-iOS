//
//  UIImage+UdeskSDK.m
//  UdeskSDK
//
//  Created by xuchen on 16/3/2.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UIImage+UdeskSDK.h"
#import "UdeskUtils.h"

@implementation UIImage (UdeskSDK)

+ (UIImage *)ud_bubbleSendImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udChatBubbleSendingSolid.png")];
}

+ (UIImage *)ud_bubbleReceiveImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udChatBubbleReceivingSolid.png")];
}

+ (UIImage *)ud_defaultDeleteImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"uddeleteMessageButton@2x.png")];
}

+ (UIImage *)ud_defaultDeleteHighlightedImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"uddeleteMessageButtonH@2x.png")];
}

+ (UIImage *)ud_defaultRefreshImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udrefreshButton.png")];
}

+ (UIImage *)ud_defaultVoiceImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udVoice.png")];
}

+ (UIImage *)ud_defaultVoiceHighlightedImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udVoiceHigh.png")];
}
+ (UIImage *)ud_defaultPhotoImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udAlbum.png")];
}

+ (UIImage *)ud_defaultPhotoHighlightedImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udAlbumHigh.png")];
}

+ (UIImage *)ud_defaultSmileImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udSmileButton.png")];
}

+ (UIImage *)ud_defaultSmileHighlightedImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udSmileButtonHigh.png")];
}

+ (UIImage *)ud_defaultCustomerImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udCustomerAvatar.png")];
}

+ (UIImage *)ud_defaultAgentImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udAgentAvatar.png")];
}

+ (UIImage *)ud_defaultBackImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udblueBack.png")];
}

+ (UIImage *)ud_defaultWhiteBackImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udwhiteBack.png")];
}

+ (UIImage *)ud_defaultVoiceTooShortImageCN {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udVoiceTooshort.png")];
}


+ (UIImage *)compressImageWith:(UIImage *)image
{
    float imageWidth = image.size.width;
    float imageHeight = image.size.height;
    
    if (imageWidth < 400) {
        return image;
    }
    
    float width = 400;
    float height = image.size.height/(image.size.width/width);
    
    float widthScale = imageWidth /width;
    float heightScale = imageHeight /height;
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    
    if (widthScale > heightScale) {
        [image drawInRect:CGRectMake(0, 0, imageWidth /heightScale , height)];
    }
    else {
        [image drawInRect:CGRectMake(0, 0, width , imageHeight /widthScale)];
    }
    
    // 从当前context中创建一个改变大小后的图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

//改变图片颜色
- (UIImage *)convertImageColor:(UIColor *)toColor {
    if (self != nil) {
        CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, 0, self.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextClipToMask(context, rect, self.CGImage);
        CGContextSetFillColorWithColor(context, [toColor CGColor]);
        CGContextFillRect(context, rect);
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return img;
    } else {
        return nil;
    }
}

+ (UIImage *)ud_defaultAgentOnlineImage {
	return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udAgentStatusOnline.png")];
}

+ (UIImage *)ud_defaultAgentOfflineImage {
	return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udAgentStatusOffline.png")];
}

+ (UIImage *)ud_defaultAgentBusyImage {
	return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udAgentStatusBusy.png")];
}

+ (UIImage *)ud_defaultSurveyImage {
	return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udAgentSurvey.png")];
}

+ (UIImage *)ud_defaultSurveyHighlightedImage {
	return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udAgentSurveyHigh.png")];
}

+ (UIImage *)ud_defaultCameraImage {
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udCamera.png")];
}

+ (UIImage *)ud_defaultCameraHighlightedImage {
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udCameraHigh.png")];
}

+ (UIImage *)ud_defaultAlbumImage {
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udAlbum.png")];
}

+ (UIImage *)ud_defaultAlbumHighlightedImage {
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udAlbumHigh.png")];
}

+ (UIImage *)ud_defaultRecordVoiceImage {
	return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udRecordVoice.png")];
}

+ (UIImage *)ud_defaultRecordVoiceHighImage {
	return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udRecordVoiceHigh.png")];
}

+ (UIImage *)ud_defaultDeleteRecordVoiceImage {
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udDeleteRecordVoice.png")];
}

+ (UIImage *)ud_defaultDeleteRecordVoiceHighImage {
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udDeleteRecordVoiceHigh.png")];
}

+ (UIImage *)ud_defaultTransferImage {
    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udTransfer.png")];
}

+ (UIImage *)ud_defaultLoadingImage {
	return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udImageLoading.png")];
}

+ (UIImage *)ud_defaultVoiceTooShortImageEN {
	return [UIImage imageWithContentsOfFile:getUDBundlePath(@"udVoiceTooshortEn.png")];
}

@end
