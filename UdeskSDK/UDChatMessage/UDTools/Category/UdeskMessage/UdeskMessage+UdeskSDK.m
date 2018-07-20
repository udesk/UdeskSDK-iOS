//
//  UdeskMessage+UdeskSDK.m
//  UdeskSDK
//
//  Created by Udesk on 16/8/16.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskMessage+UdeskSDK.h"
#import "UdeskImageUtil.h"
#import "UdeskLocationModel.h"

@implementation UdeskMessage (UdeskSDK)

- (instancetype)initWithText:(NSString *)text {

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

- (instancetype)initWithRich:(NSString *)text {
    
    self = [super init];
    if (self) {
        
        self.messageId = [[NSUUID UUID] UUIDString];
        self.messageType = UDMessageContentTypeRich;
        self.messageFrom = UDMessageTypeReceiving;
        self.messageStatus = UDMessageSendStatusSuccess;
        self.timestamp = [NSDate date];
        self.content = text;
    }
    
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    
    self = [super init];
    if (self) {
     
        self.messageId = [[NSUUID UUID] UUIDString];
        self.messageType = UDMessageContentTypeImage;
        self.messageFrom = UDMessageTypeSending;
        self.messageStatus = UDMessageSendStatusSending;
        self.timestamp = [NSDate date];
        self.image = image;
        CGSize size = [UdeskImageUtil udImageSize:image];
        self.height = size.height;
        self.width = size.width;
        self.content = self.messageId;
    }
    
    return self;
}

- (instancetype)initWithGIF:(NSData *)gifData {
    
    self = [super init];
    if (self) {
        
        self.messageId = [[NSUUID UUID] UUIDString];
        self.messageType = UDMessageContentTypeImage;
        self.messageFrom = UDMessageTypeSending;
        self.messageStatus = UDMessageSendStatusSending;
        self.timestamp = [NSDate date];
        self.isGif = YES;
        self.imageData = gifData;
        self.content = self.messageId;
    }
    
    return self;
}

- (instancetype)initWithVoice:(NSData *)voiceData duration:(NSString *)duration {
    
    self = [super init];
    if (self) {
        
        self.messageId = [[NSUUID UUID] UUIDString];
        self.messageType = UDMessageContentTypeVoice;
        self.messageFrom = UDMessageTypeSending;
        self.messageStatus = UDMessageSendStatusSending;
        self.timestamp = [NSDate date];
        self.voiceData = voiceData;
        self.voiceDuration = duration.floatValue;
        self.content = self.messageId;
    }
    
    return self;
}

- (instancetype)initWithVideo:(NSData *)videoData {

    self = [super init];
    if (self) {
        
        self.messageId = [[NSUUID UUID] UUIDString];
        self.messageType = UDMessageContentTypeVideo;
        self.messageFrom = UDMessageTypeSending;
        self.messageStatus = UDMessageSendStatusSending;
        self.timestamp = [NSDate date];
        self.videoData = videoData;
        self.content = self.messageId;
    }
    
    return self;
}

- (instancetype)initWithProduct:(NSDictionary *)productMessage {

    self = [super init];
    if (self) {
        
        self.messageId = [[NSUUID UUID] UUIDString];
        self.messageType = UDMessageContentTypeProduct;
        self.productMessage = productMessage;
    }
    return self;
}

- (instancetype)initWithLeaveEventMessage:(NSString *)text {

    self = [super init];
    if (self) {
        
        self.messageId = [[NSUUID UUID] UUIDString];
        self.messageType = UDMessageContentTypeLeaveEvent;
        self.messageFrom = UDMessageTypeCenter;
        self.messageStatus = UDMessageSendStatusSuccess;
        self.timestamp = [NSDate date];
        self.content = text;
    }
    
    return self;
}

- (instancetype)initWithLeaveMessage:(NSString *)text leaveMessageFlag:(BOOL)leaveMsgFlag {
    
    self = [super init];
    if (self) {
        
        self.messageId = [[NSUUID UUID] UUIDString];
        self.messageType = UDMessageContentTypeLeaveMsg;
        self.messageFrom = UDMessageTypeSending;
        self.messageStatus = UDMessageSendStatusSending;
        self.timestamp = [NSDate date];
        self.content = text;
        self.leaveMsgFlag = leaveMsgFlag;
    }
    
    return self;
}

- (instancetype)initWithRollback:(NSString *)text {
    
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

- (instancetype)initWithLocation:(UdeskLocationModel *)model {

    self = [super init];
    if (self) {
        
        self.messageId = [[NSUUID UUID] UUIDString];
        self.messageType = UDMessageContentTypeLocation;
        self.messageFrom = UDMessageTypeSending;
        self.messageStatus = UDMessageSendStatusSending;
        self.timestamp = [NSDate date];
        self.image = model.image;
        self.content = [NSString stringWithFormat:@"%f;%f;%ld;%@;%@",model.latitude,model.longitude,(long)model.zoomLevel,model.name,model.thoroughfare];
    }
    
    return self;
}

- (instancetype)initWithVideoCall:(NSString *)text {
    
    self = [super init];
    if (self) {
        
        self.messageId = [[NSUUID UUID] UUIDString];
        self.messageType = UDMessageContentTypeVideoCall;
        self.messageFrom = UDMessageTypeSending;
        self.messageStatus = UDMessageSendStatusSuccess;
        self.timestamp = [NSDate date];
        self.content = text;
    }
    
    return self;
}

@end
