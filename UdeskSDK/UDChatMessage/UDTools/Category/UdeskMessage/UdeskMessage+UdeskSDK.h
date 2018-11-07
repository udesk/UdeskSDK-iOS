//
//  UdeskMessage+UdeskSDK.h
//  UdeskSDK
//
//  Created by Udesk on 16/8/16.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskMessage.h"
@class UdeskLocationModel;
@class UdeskGoodsModel;

@interface UdeskMessage (UdeskSDK)

- (instancetype)initWithProduct:(NSDictionary *)productMessage;
- (instancetype)initWithText:(NSString *)text;
- (instancetype)initWithRich:(NSString *)text;
- (instancetype)initWithImage:(UIImage *)image;
- (instancetype)initWithGIF:(NSData *)gifData;
- (instancetype)initWithVoice:(NSData *)voiceData duration:(NSString *)duration;
- (instancetype)initWithVideo:(NSData *)videoData;
- (instancetype)initWithLeaveMessage:(NSString *)text leaveMessageFlag:(BOOL)leaveMsgFlag;
- (instancetype)initWithLeaveEventMessage:(NSString *)text;
- (instancetype)initWithRollback:(NSString *)text;
- (instancetype)initWithLocation:(UdeskLocationModel *)model;
- (instancetype)initWithVideoCall:(NSString *)text;
- (instancetype)initWithGoods:(UdeskGoodsModel *)model;
- (instancetype)initWithQueue:(NSString *)content showLeaveMsgBtn:(BOOL)showLeaveMsgBtn;

@end
