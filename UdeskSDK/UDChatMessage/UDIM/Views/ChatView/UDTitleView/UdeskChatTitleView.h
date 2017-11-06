//
//  UdeskChatTitleView.h
//  UdeskSDK
//
//  Created by xuchen on 2017/8/25.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UdeskAgent;
@class UdeskSDKConfig;

@interface UdeskChatTitleView : UIView

@property (nonatomic, strong) UILabel     *titleLabel;

- (instancetype)initWithFrame:(CGRect)frame sdkConfig:(UdeskSDKConfig *)sdkConfig;

- (void)updateTitle:(UdeskAgent *)agent;

@end
