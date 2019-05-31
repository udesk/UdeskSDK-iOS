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
#import "UdeskGoodsModel.h"
#import "UdeskSDKUtil.h"

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
        if ([productMessage.allKeys containsObject:@"productTitle"]) {
            self.content = productMessage[@"productTitle"];
        }
        else if ([productMessage.allKeys containsObject:@"productURL"]) {
            self.content = productMessage[@"productURL"];
        }
        else {
            self.content = @"productTitle";
        }
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

- (instancetype)initWithGoods:(UdeskGoodsModel *)model {
    
    self = [super init];
    if (self) {
        
        @try {
         
            self.messageId = [[NSUUID UUID] UUIDString];
            self.messageType = UDMessageContentTypeGoods;
            self.messageFrom = UDMessageTypeSending;
            self.messageStatus = UDMessageSendStatusSending;
            self.timestamp = [NSDate date];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            if (![UdeskSDKUtil isBlankString:model.name]) {
                [dict setObject:model.name forKey:@"name"];
            }
            if (![UdeskSDKUtil isBlankString:model.url]) {
                [dict setObject:model.url forKey:@"url"];
            }
            if (![UdeskSDKUtil isBlankString:model.imgUrl]) {
                [dict setObject:model.imgUrl forKey:@"imgUrl"];
            }
            if ([model.goodsId isKindOfClass:[NSString class]] && ![UdeskSDKUtil isBlankString:model.goodsId]) {
                [dict setObject:model.goodsId forKey:@"id"];
            }
            
            NSMutableArray *array = [NSMutableArray array];
            for (UdeskGoodsParamModel *paramModel in model.params) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                if (![UdeskSDKUtil isBlankString:paramModel.text]) {
                    [dict setObject:paramModel.text forKey:@"text"];
                }
                if (![UdeskSDKUtil isBlankString:paramModel.color]) {
                    [dict setObject:paramModel.color forKey:@"color"];
                }
                if (paramModel.fold) {
                    [dict setObject:paramModel.fold forKey:@"fold"];
                }
                if (paramModel.udBreak) {
                    [dict setObject:paramModel.udBreak forKey:@"break"];
                }
                if (paramModel.size) {
                    [dict setObject:paramModel.size forKey:@"size"];
                }
                [array addObject:dict];
            }
            if (array.count) {
                [dict setObject:array forKey:@"params"];
            }
            
            self.content = [UdeskSDKUtil JSONWithDictionary:dict];
            
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
    }
    
    return self;
}

- (instancetype)initWithQueue:(NSString *)content showLeaveMsgBtn:(BOOL)showLeaveMsgBtn {

    self = [super init];
    if (self) {

        self.messageId = [[NSUUID UUID] UUIDString];
        self.messageType = UDMessageContentTypeQueueEvent;
        self.messageFrom = UDMessageTypeCenter;
        self.messageStatus = UDMessageSendStatusSuccess;
        self.timestamp = [NSDate date];
        self.content = content;
        self.showLeaveMsgBtn = showLeaveMsgBtn;
    }

    return self;
}

@end
