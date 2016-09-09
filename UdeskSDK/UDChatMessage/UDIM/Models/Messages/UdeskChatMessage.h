//
//  UdeskChatMessage.h
//  UdeskSDK
//
//  Created by xuchen on 16/8/12.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskBaseMessage.h"
#import "UdeskMessage.h"

@interface UdeskChatMessage : UdeskBaseMessage

/** 是否显示时间 */
@property (nonatomic, assign) BOOL                 displayTimestamp;
/** 消息发送人昵称 */
@property (nonatomic, copy  ) NSString             *nickName;
/** 消息发送人头像 */
@property (nonatomic, copy  ) NSString             *avatar;
/** 文本消息 */
@property (nonatomic, copy  ) NSString             *text;
/** 图片消息 */
@property (nonatomic, strong) UIImage              *image;
/** 语音消息 */
@property (nonatomic, strong) NSData               *voiceData;
/** 语音时长 */
@property (nonatomic, copy  ) NSString             *voiceDuration;
/** 资源文件url */
@property (nonatomic, copy  ) NSString             *mediaURL;
/** 消息发送人头像 */
@property (nonatomic, strong) UIImage              *avatarImage;
/** 聊天气泡图片 */
@property (nonatomic, strong) UIImage              *bubbleImage;
/** 重发图片 */
@property (nonatomic, strong) UIImage              *failureImage;
/** 语音播放image */
@property (nonatomic, strong) UIImage              *animationVoiceImage;
/** 语音播放动画图片数组 */
@property (nonatomic, strong) NSMutableArray       *animationVoiceImages;
/** 需要高亮的文字 */
@property (nonatomic, strong) NSArray              *matchArray;
/** 高亮文字对应的超链接 */
@property (nonatomic, strong) NSDictionary         *richURLDictionary;
/** 消息气泡frame */
@property (nonatomic, assign, readonly) CGRect     bubbleImageFrame;
/** 时间frame */
@property (nonatomic, assign, readonly) CGRect     dateFrame;
/** 文本frame */
@property (nonatomic, assign, readonly) CGRect     textFrame;
/** 图片frame */
@property (nonatomic, assign, readonly) CGRect     imageFrame;
/** 语音frame */
@property (nonatomic, assign, readonly) CGRect     voiceDurationFrame;
/** 头像frame */
@property (nonatomic, assign, readonly) CGRect     avatarFrame;
/** 发送失败图片frame */
@property (nonatomic, assign, readonly) CGRect     failureFrame;
/** 发送中frame */
@property (nonatomic, assign, readonly) CGRect     activityIndicatorFrame;
/** 语音播放图片frame */
@property (nonatomic, assign, readonly) CGRect     animationVoiceFrame;

/**
 *  UdeskMessage转换成UdeskChatMessage
 *
 *  @param message          UdeskMessage
 *  @param displayTimestamp 是否显示时间
 *
 *  @return 自己
 */
- (instancetype)initWithModel:(UdeskMessage *)message withDisplayTimestamp:(BOOL)displayTimestamp;
/**
 *  初始化文本消息model
 *
 *  @param text             文本
 *  @param displayTimestamp 是否显示时间label
 *
 *  @return 自己
 */
- (instancetype)initWithText:(NSString *)text withDisplayTimestamp:(BOOL)displayTimestamp;
/**
 *  初始化图片消息model
 *
 *  @param image            图片
 *  @param displayTimestamp 是否显示时间label
 *
 *  @return 自己
 */
- (instancetype)initWithImage:(UIImage *)image withDisplayTimestamp:(BOOL)displayTimestamp;
/**
 *  初始化语音消息model
 *
 *  @param image            语音
 *  @param displayTimestamp 是否显示时间label
 *
 *  @return 自己
 */
- (instancetype)initWithVoicePath:(NSString *)voicePath withDisplayTimestamp:(BOOL)displayTimestamp;

@end
