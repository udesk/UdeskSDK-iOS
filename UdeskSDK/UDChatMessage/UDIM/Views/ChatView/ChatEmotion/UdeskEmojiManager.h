//
//  UdeskEmojiManager.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/26.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UdeskEmojiPanelModel.h"

@interface UdeskEmojiManager : NSObject

@property (nonatomic, strong, readonly) NSArray<UdeskEmojiPanelModel *> *emojiPanels;
@property (nonatomic, strong, readonly) NSArray<UdeskEmojiPage *> *emojiContents;

@end
