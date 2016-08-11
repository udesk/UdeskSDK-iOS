//
//  UdeskMessageBubbleFactory.m
//  UdeskSDK
//
//  Created by xuchen on 15/8/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import "UdeskMessageBubbleFactory.h"
#import "UIImage+UdeskSDK.h"

@implementation UdeskMessageBubbleFactory

+ (UIImage *)bubbleImageViewForType:(UDMessageFromType)type
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
