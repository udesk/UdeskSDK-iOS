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
    UDMessageContentTypeRich       = 5,//富文本
    UDMessageContentTypeStruct     = 6,//结构化消息
    UDMessageContentTypeLeaveEvent = 7,//离线留言事件
    UDMessageContentTypeVideo      = 8,//视频
    UDMessageContentTypeRollback   = 9,//消息撤回
    UDMessageContentTypeLocation   = 10,//地理位置消息
    UDMessageContentTypeVideoCall  = 11,//视频聊天
    UDMessageContentTypeGoods      = 12,//商品消息
    UDMessageContentTypeQueueEvent = 13,//排队事件消息
    UDMessageContentTypeRobotTransfer = 14,//机器人转接
    UDMessageContentTypeRobotEvent    = 15,//机器人服务事件
    UDMessageContentTypeLink          = 16,//链接消息（机器人）
    UDMessageContentTypeNews          = 17,//图文消息（机器人）
    UDMessageContentTypeTopAsk        = 18,//常见问题（机器人）
    UDMessageContentTypeTable         = 19,//表格消息（机器人）
    UDMessageContentTypeList          = 20,//列表消息（机器人）
    UDMessageContentTypeShowProduct       = 21,//商品消息（机器人）
    UDMessageContentTypeSelectiveProduct  = 22,//商品选择消息（机器人）
    UDMessageContentTypeReplyProduct      = 23,//商品回复消息（机器人）
    UDMessageContentTypeTemplate      = 24,//模版消息
};

typedef NS_ENUM(NSInteger,UDMessageSendStatus) {
    
    UDMessageSendStatusSending = 0,//发送中
    UDMessageSendStatusFailed  = 1,//发送失败
    UDMessageSendStatusSuccess = 2,//发送成功
    UDMessageSendStatusOffSending = 3,//离线发送
};

typedef NS_ENUM(NSInteger,UDMessageSendType) {
    
    UDMessageSendTypeNormal = 0,//普通消息
    UDMessageSendTypeQueue  = 1,//排队消息
    UDMessageSendTypeLeave  = 2,//离线消息
    UDMessageSendTypeRobot  = 3,//机器人消息
    UDMessageSendTypeHit    = 4,//用户点击消息（常见问题、建议问题、流程问题、智能提示）
    UDMessageSendTypeBoard  = 5,//工作台消息
};

@interface UdeskMessageProductInfo : NSObject

@property (nonatomic, strong) NSNumber *boldFlag;
@property (nonatomic, copy  ) NSString *info;
@property (nonatomic, copy  ) NSString *color;

@end

@interface UdeskMessageProduct : NSObject

@property (nonatomic, strong) NSNumber *productId;
@property (nonatomic, copy  ) NSString *url;
@property (nonatomic, copy  ) NSString *name;
@property (nonatomic, copy  ) NSString *imageURL;
@property (nonatomic, copy  ) NSString *origin;

@property (nonatomic, strong) NSArray<UdeskMessageProductInfo *> *infoList;

@end

@interface UdeskMessageOption : NSObject

@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *valueId;

@end

@interface UdeskMessageTopAsk : NSObject

@property (nonatomic, copy) NSString *questionType;
@property (nonatomic, copy) NSString *questionTypeId;
@property (nonatomic, strong) NSArray<UdeskMessageOption *> *optionsList;
@property (nonatomic, assign) BOOL isUnfold;

@end

@interface UdeskMessage : NSObject

/** 消息内容 */
@property (nonatomic, copy  ) NSString *content;
/** 资源数据（image/voice/video） */
@property (nonatomic, strong) NSData   *sourceData;
/** 时长（voice/video） */
@property (nonatomic, assign) CGFloat  duration;
/** 消息ID */
@property (nonatomic, copy  ) NSString *messageId;
/** 消息时间 */
@property (nonatomic, copy  ) NSDate   *timestamp;

/** 图片消息 */
@property (nonatomic, strong) UIImage  *image;
/** 图片宽度 */
@property (nonatomic, assign) CGFloat  width;
/** 图片高度 */
@property (nonatomic, assign) CGFloat  height;

/** 客服JID */
@property (nonatomic, copy  ) NSString *agentJid;
/** 消息发送人头像 */
@property (nonatomic, copy  ) NSString *avatar;
/** 消息发送人昵称 */
@property (nonatomic, copy  ) NSString *nickName;

/** 显示留言按钮 */
@property (nonatomic, assign) BOOL showLeaveMsgBtn;
/** 显示有用/无用按钮 */
@property (nonatomic, assign) BOOL showUseful;
/** 显示转人工按钮 */
@property (nonatomic, assign) BOOL showTransfer;
/** 咨询对象 */
@property (nonatomic, strong) NSDictionary *productMessage;
/** 用户会话id */
@property (nonatomic, copy  ) NSString     *imSubSessionId;
/** 会话序号 */
@property (nonatomic, assign) NSInteger    seqNum;
/** 气泡类型 */
@property (nonatomic, copy  ) NSString     *bubbleType;

/*  ---------机器人相关---------  */

/** 链接消息参数 */
@property (nonatomic, copy) NSString *linkIconUrl;
@property (nonatomic, copy) NSString *linkAnswerUrl;
@property (nonatomic, copy) NSString *linkTitle;

/** 机器人问题 */
@property (nonatomic, copy) NSString *robotQuestion;
@property (nonatomic, copy) NSString *robotQuestionId;
@property (nonatomic, copy) NSString *robotType;
@property (nonatomic, copy) NSString *robotQueryType;
@property (nonatomic, copy) NSString *flowId;
@property (nonatomic, copy) NSString *switchStaffTips;
@property (nonatomic, copy) NSString *switchStaffType;

/** 图文消息 */
@property (nonatomic, copy) NSString *newsContent;
@property (nonatomic, copy) NSString *newsCoverUrl;
@property (nonatomic, copy) NSString *newsDescription;
@property (nonatomic, copy) NSString *newsAnswerUrl;

/** 机器人常见问题 */
@property (nonatomic, strong) NSArray<UdeskMessageTopAsk *> *topAsk;
/** 列表消息 */
@property (nonatomic, strong) NSArray<UdeskMessageOption *> *list;
/** 表格消息 */
@property (nonatomic, strong) NSArray<UdeskMessageOption *> *table;
/** 商品消息列表 */
@property (nonatomic, strong) NSArray<UdeskMessageProduct *> *productList;
/** 商品消息 */
@property (nonatomic, strong) UdeskMessageProduct *replyProduct;

/** 答案评价 */
@property (nonatomic, copy  ) NSString *answerEvaluation;
/** 答案标题 */
@property (nonatomic, copy  ) NSString *answerTitle;
/** 表格消息 行数 */
@property (nonatomic, strong) NSNumber *rowNumber;
/** 表格消息 列数 */
@property (nonatomic, strong) NSNumber *columnNumber;
/** 商品消息显示个数 */
@property (nonatomic, strong) NSNumber *showSize;
/** 是否显示“换一批” */
@property (nonatomic, strong) NSNumber *turnFlag;
/** 答案的消息id */
@property (nonatomic, strong) NSString *logId;
/** 这个参数表示该消息是不存储db的，需要暂时存到内存 */
@property (nonatomic, assign) BOOL     tempStore;

/** 消息类型 */
@property (nonatomic, assign) UDMessageContentType messageType;
/** 消息发送者 */
@property (nonatomic, assign) UDMessageFromType    messageFrom;
/** 消息发送状态 */
@property (nonatomic, assign) UDMessageSendStatus  messageStatus;
/** 消息发送类型 */
@property (nonatomic, assign) UDMessageSendType    sendType;

@end
