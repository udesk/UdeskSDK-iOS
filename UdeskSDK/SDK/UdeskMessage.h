//
//  UdeskMessage.h
//  UdeskSDK
//
//  Created by xuchen on 15/8/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UDMessageFromType) {
    UDMessageTypeSending = 0, // 发送
    UDMessageTypeReceiving = 1, // 接收
    UDMessageTypeCenter = 2, //自定义
};

typedef NS_ENUM(NSUInteger, UDBubbleImageViewStyle) {
    UDBubbleImageViewStyleUDChat = 0
};

typedef NS_ENUM(NSInteger, UDMessageMediaType) {
    UDMessageMediaTypeText    = 0,
    UDMessageMediaTypePhoto   = 1,
    UDMessageMediaTypeVoice   = 2,
    UDMessageMediaTypeProduct = 3,
    UDMessageMediaTypeRedirect = 4,
    UDMessageMediaTypeRich = 5,
};

typedef NS_ENUM(NSInteger,UDMessageSendStatus) {
    
    UDMessageSending = 0,
    UDMessageFailed = 1,
    UDMessageSuccess = 2,
    
};

@interface UdeskMessage : NSObject
/**
 *  消息文本
 */
@property (nonatomic, copy  ) NSString                 *text;
/**
 *  消息图片
 */
@property (nonatomic, strong) UIImage                  *photo;
/**
 *  消息图片链接
 */
@property (nonatomic, copy  ) NSString                 *photoUrl;
/**
 *  图片width
 */
@property (nonatomic, copy  ) NSString                 *width;
/**
 *  图片height
 */
@property (nonatomic, copy  ) NSString                 *height;

/**
 *  语音本地地址
 */
@property (nonatomic, copy  ) NSString                 *voicePath;
/**
 *  语音链接
 */
@property (nonatomic, copy  ) NSString                 *voiceUrl;
/**
 *  语音时长
 */
@property (nonatomic, copy  ) NSString                 *voiceDuration;
/**
 *  消息ID
 */
@property (nonatomic, copy  ) NSString                 *contentId;
/**
 *  消息时间
 */
@property (nonatomic, strong) NSDate                   *timestamp;
/**
 *  消息类型
 */
@property (nonatomic, assign) UDMessageMediaType       messageType;
/**
 *  消息发送者
 */
@property (nonatomic, assign) UDMessageFromType        messageFrom;
/**
 *  消息发送状态
 */
@property (nonatomic, assign) UDMessageSendStatus      messageStatus;
/**
 *  消息发送对象
 */
@property (nonatomic, strong) NSString                *agent_jid;
/**
 *  咨询对象链接
 */
@property (nonatomic, strong) NSString                *product_url;
/**
 *  咨询对象标题
 */
@property (nonatomic, strong) NSString                *product_title;
/**
 *  咨询对象图片链接
 */
@property (nonatomic, strong) NSString                *product_imageUrl;
/**
 *  咨询对象副标题
 */
@property (nonatomic, strong) NSString                *product_detail;

/**
 *  超链接的文本
 */
@property (nonatomic, strong) NSArray                 *richArray;
/**
 *  超链接
 */
@property (nonatomic, strong) NSDictionary            *richURLDictionary;

/**
 *  初始化文本消息
 *
 *  @param text   发送的目标文本
 *  @param date   发送的时间
 *
 *  @return 返回Message model 对象
 */
- (instancetype)initWithText:(NSString *)text
                        timestamp:(NSDate *)timestamp;

/**
 *  初始化图片类型的消息
 *
 *  @param photo          目标图片
 *  @param sender         发送者
 *  @param date           发送时间
 *
 *  @return 返回Message model 对象
 */
- (instancetype)initWithPhoto:(UIImage *)photo
                    timestamp:(NSDate *)timestamp;

/**
 *  初始化语音类型的消息
 *
 *  @param voicePath        目标语音的本地路径
 *  @param voiceDuration    目标语音的时长
 *  @param date             发送时间
 *
 *  @return 返回Message model 对象
 */
- (instancetype)initWithVoicePath:(NSString *)voicePath
                    voiceDuration:(NSString *)voiceDuration
                        timestamp:(NSDate *)timestamp;

/**
 *  初始化咨询对象消息
 *
 *  @param productData 咨询对象数据
 *
 *  @return 返回Message model 对象
 */
- (instancetype)initWithProduct:(NSDictionary *)productData;

@end
