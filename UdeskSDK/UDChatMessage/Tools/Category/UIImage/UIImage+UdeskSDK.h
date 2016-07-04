//
//  UIImage+UdeskSDK.h
//  UdeskSDK
//
//  Created by xuchen on 16/3/2.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UdeskSDK)

/**
 *  发送消息气泡图片
 *
 *  @return 气泡图片
 */
+ (UIImage *)ud_bubbleSendImage;
/**
 *  接收消息气泡图片
 *
 *  @return 气泡图片
 */
+ (UIImage *)ud_bubbleReceiveImage;
/**
 *  删除图片
 *
 *  @return 删除图片
 */
+ (UIImage *)ud_defaultDeleteImage;
/**
 *  删除高亮图片
 *
 *  @return 删除高亮图片
 */
+ (UIImage *)ud_defaultDeleteHighlightedImage;
/**
 *  重发图片
 *
 *  @return 重发图片
 */
+ (UIImage *)ud_defaultRefreshImage;
/**
 *  语音图片
 *
 *  @return 语音图片
 */
+ (UIImage *)ud_defaultVoiceImage;
/**
 *  语音高亮图片
 *
 *  @return 语音高亮图片
 */
+ (UIImage *)ud_defaultVoiceHighlightedImage;
/**
 *  语音输入框图片
 *
 *  @return 语音输入框图片
 */
+ (UIImage *)ud_defaultVoiceInputImage;
/**
 *  语音输入框高亮图片
 *
 *  @return 语音输入框高亮图片
 */
+ (UIImage *)ud_defaultVoiceInputHighlightedImage;
/**
 *  键盘图片
 *
 *  @return 键盘图片
 */
+ (UIImage *)ud_defaultKeyboardImage;
/**
 *  图片选择图片
 *
 *  @return 图片选择图片
 */
+ (UIImage *)ud_defaultPhotoImage;
/**
 *  图片选择高亮图片
 *
 *  @return 图片选择图片
 */
+ (UIImage *)ud_defaultPhotoHighlightedImage;
/**
 *  表情图片
 *
 *  @return 表情图片
 */
+ (UIImage *)ud_defaultSmileImage;
/**
 *  表情高亮图片
 *
 *  @return 表情高亮图片
 */
+ (UIImage *)ud_defaultSmileHighlightedImage;
/**
 *  用户头像图片
 *
 *  @return 用户头像图片
 */
+ (UIImage *)ud_defaultCustomerImage;
/**
 *  客服头像图片
 *
 *  @return 客服头像图片
 */
+ (UIImage *)ud_defaultAgentImage;
/**
 *  发送语音时话筒图片
 *
 *  @return 话筒图片
 */
+ (UIImage *)ud_defaultVoiceSpeakImage;
/**
 *  发送语音时声贝图片
 *
 *  @return 声贝图片
 */
+ (UIImage *)ud_defaultRecordingImage;
/**
 *  发送语音时取消发送图片
 *
 *  @return 取消发送图片
 */
+ (UIImage *)ud_defaultVoiceRevokeImage;

/**
 *  提示语音过短图片
 *
 *  @return 短
 */
+ (UIImage *)ud_defaultVoiceTooShortImage;

/**
 *  导航栏左侧返回图片
 *
 *  @return 返回图片
 */
+ (UIImage *)ud_defaultBackImage;

@end
