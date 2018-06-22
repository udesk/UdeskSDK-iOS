//
//  UdeskChatTitleView.h
//  UdeskSDK
//
//  Created by xuchen on 2017/8/25.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UdeskAgent;

@interface UdeskChatTitleView : UIView

@property (nonatomic, strong) UILabel *titleLabel;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)updateTitle:(UdeskAgent *)agent;

@end
