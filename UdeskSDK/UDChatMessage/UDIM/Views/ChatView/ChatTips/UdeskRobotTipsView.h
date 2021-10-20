//
//  UdeskRobotTipsView.h
//  UdeskSDK
//
//  Created by xuchen on 2019/1/21.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UdeskMessage;
@class UdeskChatInputToolBar;

@interface UdeskRobotTipsView : UIView

@property (nonatomic, copy) void(^didTapRobotTipsBlock)(UdeskMessage *message);

- (instancetype)initWithFrame:(CGRect)frame chatInputToolBar:(UdeskChatInputToolBar *)chatInputToolBar;
- (void)updateWithKeyword:(NSString *)keyword;

@end
