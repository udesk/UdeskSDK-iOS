//
//  UDMessageBubbleFactory.h
//  Udesk
//
//  Created by xuchen on 15/8/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UDMessage.h"

@interface UDMessageBubbleFactory : NSObject

+ (UIImage *)bubbleImageViewForType:(UDMessageFromType)type
                                  style:(UDBubbleImageViewStyle)style
                              meidaType:(UDMessageMediaType)mediaType;


@end
