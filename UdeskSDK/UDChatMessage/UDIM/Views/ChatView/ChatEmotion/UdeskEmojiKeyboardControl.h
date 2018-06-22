//
//  UdeskEmojiKeyboardControl.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/24.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UdeskEmojiKeyboardControlDelegate <NSObject>

@optional
- (void)emojiViewDidPressEmojiWithResource:(NSString *)resource;
- (void)emojiViewDidPressStickerWithResource:(NSString *)resource;
- (void)emojiViewDidPressDelete;
- (void)emojiViewDidPressSend;

@end

@interface UdeskEmojiKeyboardControl : UIView

@property (nonatomic, weak) id<UdeskEmojiKeyboardControlDelegate> delegate;

@end
