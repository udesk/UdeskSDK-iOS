//
//  UdeskMessage+UdeskChatMessage.m
//  UdeskSDK
//
//  Created by Udesk on 16/8/16.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskMessage+UdeskChatMessage.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskTools.h"

@implementation UdeskMessage (UdeskChatMessage)

- (instancetype)initTextChatMessage:(NSString *)text {

    self = [super init];
    if (self) {
    
        self.messageId = [[NSUUID UUID] UUIDString];
        self.messageType = UDMessageContentTypeText;
        self.messageFrom = UDMessageTypeSending;
        self.messageStatus = UDMessageSendStatusSending;
        self.timestamp = [NSDate date];
        self.content = text;
    }
    
    return self;
}

- (instancetype)initImageChatMessage:(UIImage *)image {
    
    self = [super init];
    if (self) {
     
        self.messageId = [[NSUUID UUID] UUIDString];
        self.messageType = UDMessageContentTypeImage;
        self.messageFrom = UDMessageTypeSending;
        self.messageStatus = UDMessageSendStatusSending;
        self.timestamp = [NSDate date];
        self.image = image;
        CGSize size = [UdeskTools neededSizeForPhoto:image];
        self.height = size.height;
        self.width = size.width;
    }
    
    return self;
}

- (instancetype)initGIFImageChatMessage:(NSData *)gifData {
    
    self = [super init];
    if (self) {
        
        self.messageId = [[NSUUID UUID] UUIDString];
        self.messageType = UDMessageContentTypeImage;
        self.messageFrom = UDMessageTypeSending;
        self.messageStatus = UDMessageSendStatusSending;
        self.timestamp = [NSDate date];
        self.isGif = YES;
        self.imageData = gifData;
    }
    
    return self;
}

- (instancetype)initVoiceChatMessage:(NSData *)voiceData duration:(NSString *)duration {
    
    self = [super init];
    if (self) {
        
        self.messageId = [[NSUUID UUID] UUIDString];
        self.messageType = UDMessageContentTypeVoice;
        self.messageFrom = UDMessageTypeSending;
        self.messageStatus = UDMessageSendStatusSending;
        self.timestamp = [NSDate date];
        self.voiceData = voiceData;
        self.voiceDuration = duration.floatValue;
    }
    
    return self;
}

- (instancetype)initVideoChatMessage:(NSData *)videoData videoName:(NSString *)videoName {

    self = [super init];
    if (self) {
        
        self.messageId = [[NSUUID UUID] UUIDString];
        self.messageType = UDMessageContentTypeVideo;
        self.messageFrom = UDMessageTypeSending;
        self.messageStatus = UDMessageSendStatusSending;
        self.timestamp = [NSDate date];
        self.videoData = videoData;
        if ([UdeskTools isBlankString:videoName]) {
            videoName = self.messageId;
        }
        self.content = videoName;
    }
    
    return self;
}

- (instancetype)initWithProductMessage:(NSDictionary *)productMessage {

    self = [super init];
    if (self) {
        
        self.messageId = [[NSUUID UUID] UUIDString];
        self.messageType = UDMessageContentTypeProduct;
        self.productMessage = productMessage;
    }
    return self;
}

- (instancetype)initLeaveChatMessage:(NSString *)text {

    self = [super init];
    if (self) {
        
        self.messageId = [[NSUUID UUID] UUIDString];
        self.messageType = UDMessageContentTypeLeave;
        self.messageFrom = UDMessageTypeCenter;
        self.messageStatus = UDMessageSendStatusSuccess;
        self.timestamp = [NSDate date];
        self.content = text;
    }
    
    return self;
}

- (instancetype)initRollbackChatMessage:(NSString *)text {
    
    self = [super init];
    if (self) {
        
        self.messageId = [[NSUUID UUID] UUIDString];
        self.messageType = UDMessageContentTypeRollback;
        self.messageFrom = UDMessageTypeCenter;
        self.messageStatus = UDMessageSendStatusSuccess;
        self.timestamp = [NSDate date];
        self.content = text;
    }
    
    return self;
}

@end
