//
//  UdeskMessage.h
//  UdeskSDK
//
//  Created by Udesk on 15/8/26.
//  Copyright (c) 2015年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UDMessageFromType) {
    UDMessageTypeSending = 0, // 发送
    UDMessageTypeReceiving = 1, // 接收
    UDMessageTypeCenter = 2, //自定义
};

typedef NS_ENUM(NSInteger, UDMessageContentType) {
    UDMessageContentTypeText       = 0,//文字
    UDMessageContentTypeImage      = 1,//图片
    UDMessageContentTypeVoice      = 2,//语音
    UDMessageContentTypeProduct    = 3,//咨询对象
    UDMessageContentTypeRedirect   = 4,//转接
    UDMessageContentTypeRich       = 5,//欢迎语
    UDMessageContentTypeStruct     = 6,//结构化消息
    UDMessageContentTypeLeaveEvent = 7,//离线留言事件
    UDMessageContentTypeVideo      = 8,//视频
    UDMessageContentTypeRollback   = 9,//消息撤回
    UDMessageContentTypeLocation   = 10,//地理位置消息
    UDMessageContentTypeLeaveMsg   = 11,//离线留言消息
    UDMessageContentTypeVideoCall  = 12,//视频聊天
    UDMessageContentTypeGoods      = 13,//商品消息
    UDMessageContentTypeQueueEvent = 14,//排队事件消息
};

typedef NS_ENUM(NSInteger,UDMessageSendStatus) {
    
    UDMessageSendStatusSending = 0,//发送中
    UDMessageSendStatusFailed  = 1,//发送失败
    UDMessageSendStatusSuccess = 2,//发送成功
    UDMessageSendStatusOffSending = 3,//离线发送
};

@interface UdeskMessage : NSObject

/** 消息内容 */
@property (nonatomic, copy  ) NSString             *content;
/** 图片消息 */
@property (nonatomic, strong) UIImage              *image;
/** 图片原始数据 */
@property (nonatomic, strong) NSData               *imageData;
/** 语音消息 */
@property (nonatomic, strong) NSData               *voiceData;
/** 视频消息 */
@property (nonatomic, strong) NSData               *videoData;
/** 消息ID */
@property (nonatomic, copy  ) NSString             *messageId;
/** 消息时间 */
@property (nonatomic, copy  ) NSDate               *timestamp;
/** 客服JID */
@property (nonatomic, copy  ) NSString             *agentJid;
/** 消息发送人头像 */
@property (nonatomic, copy  ) NSString             *avatar;
/** 消息发送人昵称 */
@property (nonatomic, copy  ) NSString             *nickName;
/** 语音时长 */
@property (nonatomic, assign) CGFloat              voiceDuration;
/** 视频时长 */
@property (nonatomic, assign) CGFloat              videoDuration;
/** 图片宽度 */
@property (nonatomic, assign) CGFloat              width;
/** 图片高度 */
@property (nonatomic, assign) CGFloat              height;
/** 图片是否是GIF */
@property (nonatomic, assign) BOOL                 isGif;
/** 是否显示客户留言事件 */
@property (nonatomic, assign) BOOL                 leaveMsgFlag;
/** 消息类型 */
@property (nonatomic, assign) UDMessageContentType messageType;
/** 消息发送者 */
@property (nonatomic, assign) UDMessageFromType    messageFrom;
/** 消息发送状态 */
@property (nonatomic, assign) UDMessageSendStatus  messageStatus;
/** 咨询对象 */
@property (nonatomic, strong) NSDictionary         *productMessage;
/** 用户会话id */
@property (nonatomic, copy  ) NSString             *imSubSessionId;
/** 会话序号 */
@property (nonatomic, assign) NSInteger            seqNum;
/** 显示l留言按钮 */
@property (nonatomic, assign) BOOL                 showLeaveMsgBtn;

@end
