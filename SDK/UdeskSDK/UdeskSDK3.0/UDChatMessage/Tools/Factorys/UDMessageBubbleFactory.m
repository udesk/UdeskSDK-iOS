//
//  UDMessageBubbleFactory.m
//  Udesk
//
//  Created by xuchen on 15/8/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import "UDMessageBubbleFactory.h"

@implementation UDMessageBubbleFactory

+ (UIImage *)bubbleImageViewForType:(UDMessageFromType)type
                                  style:(UDBubbleImageViewStyle)style
                              meidaType:(UDMessageMediaType)mediaType {
    NSString *messageTypeString;
    
    switch (style) {
        case UDBubbleImageViewStyleUDChat:
            messageTypeString = @"uDChatBubble";
            break;
        default:
            break;
    }
    
    switch (type) {
        case UDMessageTypeSending:
            // 发送
            messageTypeString = [messageTypeString stringByAppendingString:@"_Sending"];
            break;
        case UDMessageTypeReceiving:
            // 接收
            messageTypeString = [messageTypeString stringByAppendingString:@"_Receiving"];
            break;
        default:
            break;
    }
    
    switch (mediaType) {
        case UDMessageMediaTypePhoto:
        case UDMessageMediaTypeText:
        case UDMessageMediaTypeVoice:
            messageTypeString = [messageTypeString stringByAppendingString:@"_Solid.png"];
            break;
        default:
            break;
    }
    
    UIImage *bublleImage = [UIImage imageWithContentsOfFile:getMyBundlePath(messageTypeString)];
    UIImage *edgeBubbleImage = [bublleImage stretchableImageWithLeftCapWidth:bublleImage.size.width / 2 topCapHeight:bublleImage.size.height / 2];
    return edgeBubbleImage;
}

@end
