//
//  UdeskChatTitleView.m
//  UdeskSDK
//
//  Created by xuchen on 2017/8/25.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskChatTitleView.h"
#import "UdeskAgent.h"
#import "UdeskSDKConfig.h"
#import "UdeskUtils.h"
#import "UdeskStringSizeUtil.h"
#import "UdeskViewExt.h"

@implementation UdeskChatTitleView {

    UdeskSDKConfig *_sdkConfig;
}

- (instancetype)initWithFrame:(CGRect)frame sdkConfig:(UdeskSDKConfig *)sdkConfig
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _sdkConfig = sdkConfig;
        [self setup];
    }
    return self;
}

- (void)setup {

    _titleLabel = [[UILabel alloc] initWithFrame:self.frame];
    _titleLabel.textColor = _sdkConfig.sdkStyle.titleColor;
    _titleLabel.font = _sdkConfig.sdkStyle.titleFont;
    _titleLabel.text = getUDLocalizedString(@"udesk_connecting_agent");
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self addSubview:_imageView];
}

- (void)updateTitle:(UdeskAgent *)agent {

    NSString *titleText;
    if (agent.code == UDAgentStatusResultOnline) {
        titleText = agent.nick;
    }
    else if (agent.code == UDAgentStatusResultOffline) {
        titleText = agent.nick?agent.nick:getUDLocalizedString(@"udesk_agent_offline");
    }
    else {
        titleText = agent.message;
    }
    
    CGSize titleSize = [UdeskStringSizeUtil textSize:titleText withFont:_sdkConfig.sdkStyle.titleFont withSize:CGSizeMake(self.ud_width, self.ud_height)];
    UIImage *titleImage;
    switch (agent.code) {
        case UDAgentStatusResultOnline:
            titleImage = [UIImage ud_defaultAgentOnlineImage];
            break;
        case UDAgentStatusResultQueue:
            titleImage = [UIImage ud_defaultAgentBusyImage];
            break;
        case UDAgentStatusResultOffline:
        case UDAgentStatusResultLeaveMessage:
            titleImage = [UIImage ud_defaultAgentOfflineImage];
            break;
        default:
            break;
    }
    _titleLabel.text = titleText;
    CGFloat spilth = titleSize.width > 200 ? 0 : 20;
    _titleLabel.frame = CGRectMake((self.ud_width-titleSize.width)/2-spilth, 0, titleSize.width, self.ud_height);
    
    _imageView.image = titleImage;
    _imageView.frame = CGRectMake(_titleLabel.ud_right+5, (self.ud_height-7)/2, 7, 7);
}

@end
