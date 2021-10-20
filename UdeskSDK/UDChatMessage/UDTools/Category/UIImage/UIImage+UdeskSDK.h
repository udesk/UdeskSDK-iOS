//
//  UIImage+UdeskSDK.h
//  UdeskSDK
//
//  Created by Udesk on 16/3/2.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UdeskSDK)

/** GIF */
+ (UIImage *)udAnimatedGIFWithData:(NSData *)data;

/** 发送消息气泡图片 */
+ (UIImage *)udBubbleSend01Image;
+ (UIImage *)udBubbleSend02Image;
+ (UIImage *)udBubbleSend03Image;
+ (UIImage *)udBubbleSend04Image;
/** 接收消息气泡图片 */
+ (UIImage *)udBubbleReceive01Image;
+ (UIImage *)udBubbleReceive02Image;
+ (UIImage *)udBubbleReceive03Image;
+ (UIImage *)udBubbleReceive04Image;
/** 重发图片 */
+ (UIImage *)udDefaultRefreshImage;
/** 语音图片 */
+ (UIImage *)udDefaultVoiceImage;
/** 表情图片 */
+ (UIImage *)udDefaultSmileImage;
/** 客服头像图片 */
+ (UIImage *)udDefaultAgentImage;
/** 客户头像图片 */
+ (UIImage *)udDefaultCustomerAvatarImage;
/** 导航栏左侧返回图片 */
+ (UIImage *)udDefaultBackImage;
/** 导航栏左侧返回图片 */
+ (UIImage *)udDefaultWhiteBackImage;
/** 客服在线 */
+ (UIImage *)udDefaultAgentOnlineImage;
/** 客服离线 */
+ (UIImage *)udDefaultAgentOfflineImage;
/** 客服繁忙 */
+ (UIImage *)udDefaultAgentBusyImage;
/** 转人工 */
+ (UIImage *)udDefaultTransferImage;
/** 默认图片 */
+ (UIImage *)udDefaultLoadingImage;
/** 默认重发图片 */
+ (UIImage *)udDefaultResetButtonImage;
/** 地图大头针 */
+ (UIImage *)udDefaultLocationPinImage;
/** 打勾 */
+ (UIImage *)udDefaultMarkImage;
/** 视频会话 */
+ (UIImage *)udDefaultVideoCallImage;
/** //视频会话(收到 */
+ (UIImage *)udDefaultVideoCallReceiveImage;
/** 图片选择器，未选择 */
+ (UIImage *)udDefaultImagePickerNotSelected;
/** 图片选择器，未选择原图 */
+ (UIImage *)udDefaultImagePickerFullImage;
/** 图片选择器，已选择原图 */
+ (UIImage *)udDefaultImagePickerFullImageSelected;
/** 图片选择器，视频播放 */
+ (UIImage *)udDefaultImagePickerVideoPlay;
/** 图片选择器，视频icon */
+ (UIImage *)udDefaultImagePickerVideoIcon;
/** 小视频返回按钮 */
+ (UIImage *)udDefaultSmallVideoBack;
/** 小视频切换摄像头按钮 */
+ (UIImage *)udDefaultSmallVideoCameraSwitch;
/** 小视频重拍 */
+ (UIImage *)udDefaultSmallVideoRetake;
/** 小视频完成 */
+ (UIImage *)udDefaultSmallVideoDone;
/** 小视频下载 */
+ (UIImage *)udDefaultVideoDownload;
/** 小视频下载 */
+ (UIImage *)udDefaultVideoPlay;
/** 聊天键盘 */
+ (UIImage *)udDefaultKeyboardImage;
/** 聊天小键盘 */
+ (UIImage *)udDefaultKeyboardSmallImage;
/** 聊天输入框更多 */
+ (UIImage *)udDefaultMoreImage;
/** 聊天输入框更多 */
+ (UIImage *)udDefaultMoreCloseImage;
/** 更多-相册 */
+ (UIImage *)udDefaultChatBarMorePhotoImage;
/** 更多-相机 */
+ (UIImage *)udDefaultChatBarMoreCameraImage;
/** 更多-评价 */
+ (UIImage *)udDefaultChatBarMoreSurveyImage;
/** 更多-地理位置 */
+ (UIImage *)udDefaultChatBarMoreLocationImage;
/** 更多-视频通话 */
+ (UIImage *)udDefaultChatBarMoreVideoCallImage;
/** 取消发送 */
+ (UIImage *)udDefaultVoiceRevokeImage;

/** 发送语音时话筒图片 */
+ (UIImage *)udDefaultVoiceSpeakImage;

/** 语音太短 */
+ (UIImage *)udDefaultVoiceTooShortImage;

/** 自定义工具栏 满意度评价 */
+ (UIImage *)udDefaultCustomToolBarSurveyImage;

/** 满意度评价关闭按钮 */
+ (UIImage *)udDefaultSurveyCloseImage;

/** 满意度评价文本模式未选择 */
+ (UIImage *)udDefaultSurveyTextNotSelectImage;

/** 满意度评价文本模式选择 */
+ (UIImage *)udDefaultSurveyTextSelectedImage;

/** 满意度评价表情 满意 */
+ (UIImage *)udDefaultSurveyExpressionSatisfiedImage;

/** 满意度评价表情 一般 */
+ (UIImage *)udDefaultSurveyExpressionGeneralImage;

/** 满意度评价表情 不满意 */
+ (UIImage *)udDefaultSurveyExpressionUnsatisfactoryImage;

/** 满意度评价表情 空星 */
+ (UIImage *)udDefaultSurveyStarEmptyImage;

/** 满意度评价表情 实星 */
+ (UIImage *)udDefaultSurveyStarFilledImage;

/** 向上箭头 */
+ (UIImage *)udDefaultUpArrow;

/** 向下箭头 */
+ (UIImage *)udDefaultDownArrow;

/** 列表标签（。） */
+ (UIImage *)udDefaultListTag;

/** 机器人答案有用 */
+ (UIImage *)udDefaultUseful;

/** 机器人答案有用已选择 */
+ (UIImage *)udDefaultUsefulSelected;

/** 机器人答案无用 */
+ (UIImage *)udDefaultUseless;

/** 机器人答案无用已选择 */
+ (UIImage *)udDefaultUselessSelected;

@end
