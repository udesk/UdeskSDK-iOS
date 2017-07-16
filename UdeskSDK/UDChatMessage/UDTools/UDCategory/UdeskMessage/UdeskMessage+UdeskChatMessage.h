//
//  UdeskMessage+UdeskChatMessage.h
//  UdeskSDK
//
//  Created by Udesk on 16/8/16.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskMessage.h"

@interface UdeskMessage (UdeskChatMessage)

- (instancetype)initWithProductMessage:(NSDictionary *)productMessage;
- (instancetype)initTextChatMessage:(NSString *)text;
- (instancetype)initImageChatMessage:(UIImage *)image;
- (instancetype)initGIFImageChatMessage:(NSData *)gifData;
- (instancetype)initVoiceChatMessage:(NSData *)voiceData duration:(NSString *)duration;
- (instancetype)initVideoChatMessage:(NSData *)videoData videoName:(NSString *)videoName;
- (instancetype)initLeaveChatMessage:(NSString *)text;
- (instancetype)initRollbackChatMessage:(NSString *)text;

@end
