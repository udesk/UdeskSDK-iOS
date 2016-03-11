//
//  UDMessageBubbleFactory.m
//  Udesk
//
//  Created by xuchen on 15/8/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import "UDMessageBubbleFactory.h"
#import "UIImage+UDMessage.h"

@implementation UDMessageBubbleFactory

+ (UIImage *)bubbleImageViewForType:(UDMessageFromType)type
                                  style:(UDBubbleImageViewStyle)style
                              meidaType:(UDMessageMediaType)mediaType {
    UIImage *bubbleImage;
    
    switch (type) {
        case UDMessageTypeSending:
            // 发送
            bubbleImage = [UIImage ud_bubbleSendImage];
            break;
        case UDMessageTypeReceiving:
            // 接收
            bubbleImage = [UIImage ud_bubbleReceiveImage];
            break;
        default:
            break;
    }
    
    UIImage *edgeBubbleImage = [bubbleImage stretchableImageWithLeftCapWidth:bubbleImage.size.width / 2 topCapHeight:bubbleImage.size.height / 2];
    return edgeBubbleImage;
}

@end
