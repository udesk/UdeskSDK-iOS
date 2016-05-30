//
//  UdeskMessageBubbleFactory.h
//  UdeskSDK
//
//  Created by xuchen on 15/8/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UdeskMessage.h"

@interface UdeskMessageBubbleFactory : NSObject

+ (UIImage *)bubbleImageViewForType:(UDMessageFromType)type
                                  style:(UDBubbleImageViewStyle)style
                              meidaType:(UDMessageMediaType)mediaType;


@end
