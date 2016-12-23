//
//  UdeskMessage+UdeskChatMessage.m
//  UdeskSDK
//
//  Created by xuchen on 16/8/16.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskMessage+UdeskChatMessage.h"

@implementation UdeskMessage (UdeskChatMessage)

- (instancetype)initWithChatMessage:(UdeskChatMessage *)chatMessage
{
    self = [super init];
    if (self) {
     
        self.messageId = chatMessage.messageId;
        self.messageType = chatMessage.messageType;
        self.messageFrom = chatMessage.messageFrom;
        self.messageStatus = chatMessage.messageStatus;
        self.timestamp = chatMessage.date;
        self.image = chatMessage.image;
        self.voiceData = chatMessage.voiceData;
        self.content = chatMessage.text;
    }
    return self;
}

- (instancetype)initTextChatMessage:(UdeskChatMessage *)chatMessage text:(NSString *)text
{
    self = [super init];
    if (self) {
        
        self.messageId = chatMessage.messageId;
        self.messageType = chatMessage.messageType;
        self.messageFrom = chatMessage.messageFrom;
        self.messageStatus = chatMessage.messageStatus;
        self.timestamp = chatMessage.date;
        self.content = text;
    }
    return self;
}

- (instancetype)initImageChatMessage:(UdeskChatMessage *)chatMessage image:(UIImage *)image
{
    self = [super init];
    if (self) {
        
        self.messageId = chatMessage.messageId;
        self.messageType = chatMessage.messageType;
        self.messageFrom = chatMessage.messageFrom;
        self.messageStatus = chatMessage.messageStatus;
        self.timestamp = chatMessage.date;
        self.image = image;
    }
    return self;
}

- (instancetype)initVoiceChatMessage:(UdeskChatMessage *)chatMessage voiceData:(NSData *)voiceData
{
    self = [super init];
    if (self) {
        
        self.messageId = chatMessage.messageId;
        self.messageType = chatMessage.messageType;
        self.messageFrom = chatMessage.messageFrom;
        self.messageStatus = chatMessage.messageStatus;
        self.timestamp = chatMessage.date;
        self.voiceData = voiceData;
    }
    return self;
}

- (instancetype)initWithProductMessage:(NSDictionary *)productMessage {

    self = [super init];
    if (self) {
        
        self.messageType = UDMessageContentTypeProduct;
        self.productMessage = productMessage;
    }
    return self;
}


@end
