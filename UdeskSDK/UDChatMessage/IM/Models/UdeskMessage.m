//
//  UdeskMessage.m
//  UdeskSDK
//
//  Created by xuchen on 15/8/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import "UdeskMessage.h"
#import "UdeskTools.h"

@implementation UdeskMessage

- (instancetype)initWithText:(NSString *)text
                        timestamp:(NSDate *)timestamp {
    self = [super init];
    if (self) {
        self.text = text;
        
        self.timestamp = timestamp;
        
        self.contentId = [UdeskTools soleString];
        
        self.messageType = UDMessageMediaTypeText;
        
        self.messageFrom = UDMessageTypeSending;
        self.messageStatus = UDMessageSending;
        
    }
    return self;
}

/**
 *  初始化图片类型的消息
 *
 *  @param photo          目标图片
 *  @param thumbnailUrl   目标图片在服务器的缩略图地址
 *  @param originPhotoUrl 目标图片在服务器的原图地址
 *  @param sender         发送者
 *  @param date           发送时间
 *
 *  @return 返回Message model 对象
 */
- (instancetype)initWithPhoto:(UIImage *)photo
                    timestamp:(NSDate *)timestamp {
    self = [super init];
    if (self) {
        
        self.photo = photo;
        
        self.timestamp = timestamp;
        
        self.contentId = [UdeskTools soleString];
        
        self.messageType = UDMessageMediaTypePhoto;
        
        self.messageFrom = UDMessageTypeSending;
        
        self.messageStatus = UDMessageSending;
    }
    return self;
}

/**
 *  初始化语音类型的消息
 *
 *  @param voicePath        目标语音的本地路径
 *  @param voiceUrl         目标语音在服务器的地址
 *  @param voiceDuration    目标语音的时长
 *  @param sender           发送者
 *  @param date             发送时间
 *
 *  @return 返回Message model 对象
 */
- (instancetype)initWithVoicePath:(NSString *)voicePath
                    voiceDuration:(NSString *)voiceDuration
                        timestamp:(NSDate *)timestamp {
    
    self = [super init];
    if (self) {
        
        self.voicePath = voicePath;
        self.voiceDuration = voiceDuration;
        
        self.timestamp = timestamp;
        
        self.contentId = [UdeskTools soleString];
        
        self.messageType = UDMessageMediaTypeVoice;
        
        self.messageFrom = UDMessageTypeSending;
        
        self.messageStatus = UDMessageSending;
    }
    return self;
}

- (void)dealloc {
    _text = nil;
    
    _contentId = nil;
    
    _photo = nil;
    _photoUrl = nil;
    
    _voicePath = nil;
    _voiceUrl = nil;
    _voiceDuration = nil;
    
    _timestamp = nil;
}

@end
