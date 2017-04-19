//
//  UdeskMessage+UdeskChatMessage.h
//  UdeskSDK
//
//  Created by Udesk on 16/8/16.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskMessage.h"
#import "UdeskChatMessage.h"

@interface UdeskMessage (UdeskChatMessage)

- (instancetype)initWithChatMessage:(UdeskChatMessage *)chatMessage;

- (instancetype)initWithProductMessage:(NSDictionary *)productMessage;
- (instancetype)initTextChatMessage:(UdeskChatMessage *)chatMessage text:(NSString *)text;
- (instancetype)initImageChatMessage:(UdeskChatMessage *)chatMessage image:(UIImage *)image;
- (instancetype)initVoiceChatMessage:(UdeskChatMessage *)chatMessage voiceData:(NSData *)voiceData;

@end
