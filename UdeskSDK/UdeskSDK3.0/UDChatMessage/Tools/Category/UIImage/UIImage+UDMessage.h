//
//  UIImage+UDMessage.h
//  UdeskSDK
//
//  Created by xuchen on 16/3/2.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UDMessage)

+ (UIImage *)ud_bubbleSendImage;

+ (UIImage *)ud_bubbleReceiveImage;

+ (UIImage *)ud_defaultDeleteImage;

+ (UIImage *)ud_defaultDeleteHighlightedImage;

+ (UIImage *)ud_defaultRefreshImage;

+ (UIImage *)ud_defaultVoiceImage;

+ (UIImage *)ud_defaultVoiceHighlightedImage;

+ (UIImage *)ud_defaultVoiceInputImage;

+ (UIImage *)ud_defaultVoiceInputHighlightedImage;

+ (UIImage *)ud_defaultKeyboardImage;

+ (UIImage *)ud_defaultPhotoImage;

+ (UIImage *)ud_defaultPhotoHighlightedImage;

+ (UIImage *)ud_defaultSmileImage;

+ (UIImage *)ud_defaultSmileHighlightedImage;

+ (UIImage *)ud_defaultCustomerImage;

+ (UIImage *)ud_defaultAgentImage;

+ (UIImage *)ud_defaultVoiceSpeakImage;

+ (UIImage *)ud_defaultRecordingImage;

+ (UIImage *)ud_defaultVoiceRevokeImage;

@end
