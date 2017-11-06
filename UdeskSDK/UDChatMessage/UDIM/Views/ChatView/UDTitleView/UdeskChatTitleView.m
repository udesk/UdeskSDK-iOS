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
    
    //创建富文本
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ",titleText]];
    //NSTextAttachment可以将要插入的图片作为特殊字符处理
    NSTextAttachment *attch = [[NSTextAttachment alloc] init];
    //定义图片内容及位置和大小
    attch.image = titleImage;
    attch.bounds = CGRectMake(0, 2, 7, 7);
    //创建带有图片的富文本
    NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attch];
    //将图片放在最后一位
    [attri appendAttributedString:string];
    _titleLabel.attributedText = attri;
    
    _titleLabel.frame = CGRectMake(0, 0, self.ud_width, self.ud_height);
}

@end
