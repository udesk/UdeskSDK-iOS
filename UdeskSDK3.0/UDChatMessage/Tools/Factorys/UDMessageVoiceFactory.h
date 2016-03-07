//
//  UDMessageVoiceFactory.h
//  Udesk
//
//  Created by xuchen on 15/8/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UDMessageBubbleFactory.h"

@interface UDMessageVoiceFactory : NSObject

+ (UIImageView *)messageVoiceAnimationImageViewWithBubbleMessageType:(UDMessageFromType)type;

@end
