//
//  UdeskMessageVoiceFactory.h
//  UdeskSDK
//
//  Created by xuchen on 15/8/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UdeskMessageBubbleFactory.h"

@interface UdeskMessageVoiceFactory : NSObject

+ (UIImageView *)messageVoiceAnimationImageViewWithBubbleMessageType:(UDMessageFromType)type;

@end
