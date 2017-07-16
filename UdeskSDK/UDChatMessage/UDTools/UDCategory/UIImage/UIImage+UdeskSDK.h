//
//  UIImage+UdeskSDK.h
//  UdeskSDK
//
//  Created by Udesk on 16/3/2.
//  Copyright © 2016年 Udesk. All rights reserved.
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
 *  评价图片
 *
 *  @return 评价图片
 */
+ (UIImage *)ud_defaultSurveyImage;
/**
 *  评价高亮图片
 *
 *  @return 评价高亮图片
 */
+ (UIImage *)ud_defaultSurveyHighlightedImage;
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
 *  提示语音过短图片(中文)
 *
 *  @return 短
 */
+ (UIImage *)ud_defaultVoiceTooShortImageCN;

/**
 *  提示语音过短图片(英文)
 *
 *  @return 短
 */
+ (UIImage *)ud_defaultVoiceTooShortImageEN;

/**
 *  导航栏左侧返回图片
 *
 *  @return 返回图片
 */
+ (UIImage *)ud_defaultBackImage;

/**
 *  导航栏左侧返回图片
 *
 *  @return 返回图片
 */
+ (UIImage *)ud_defaultWhiteBackImage;

/**
 *  客服在线绿点
 *
 *  @return 返回图片
 */
+ (UIImage *)ud_defaultAgentOnlineImage;
/**
 *  客服离线灰点
 *
 *  @return 返回图片
 */
+ (UIImage *)ud_defaultAgentOfflineImage;
/**
 *  客服繁忙红点
 *
 *  @return 返回图片
 */
+ (UIImage *)ud_defaultAgentBusyImage;

/**
 *  压缩图片
 *
 *  @param image 要压缩的图片
 *
 *  @return 已经压缩的图片
 */
+ (UIImage *)compressImageWith:(UIImage *)image;
/**
 *  相机图片
 *
 *  @return 相机图片
 */
+ (UIImage *)ud_defaultCameraImage;
/**
 *  相机高亮图片
 *
 *  @return 相机高亮图片
 */
+ (UIImage *)ud_defaultCameraHighlightedImage;
/**
 *  相册图片
 *
 *  @return 相机图片
 */
+ (UIImage *)ud_defaultAlbumImage;
/**
 *  相册高亮图片
 *
 *  @return 相机高亮图片
 */
+ (UIImage *)ud_defaultAlbumHighlightedImage;
/**
 *  录制语音显示图片
 *
 *  @return 录制语音显示图片
 */
+ (UIImage *)ud_defaultRecordVoiceImage;
/**
 *  录制语音高亮显示图片
 *
 *  @return 录制语音高亮显示图片
 */
+ (UIImage *)ud_defaultRecordVoiceHighImage;
/**
 *  删除录制语音显示图片
 *
 *  @return 录制语音高亮显示图片
 */
+ (UIImage *)ud_defaultDeleteRecordVoiceImage;
/**
 *  删除录制语音高亮显示图片
 *
 *  @return 录制语音高亮显示图片
 */
+ (UIImage *)ud_defaultDeleteRecordVoiceHighImage;

/**
 *  转人工
 *
 *  @return 转人工
 */
+ (UIImage *)ud_defaultTransferImage;
/**
 *  默认图片
 *
 *  @return 图片
 */
+ (UIImage *)ud_defaultLoadingImage;

/**
 默认重发图片

 @return 图片
 */
+ (UIImage *)ud_defaultResetButtonImage;
/**
 *  修改图片颜色
 *
 *  @param toColor 颜色
 *
 *  @return 图片
 */
- (UIImage *)convertImageColor:(UIColor *)toColor;

@end
