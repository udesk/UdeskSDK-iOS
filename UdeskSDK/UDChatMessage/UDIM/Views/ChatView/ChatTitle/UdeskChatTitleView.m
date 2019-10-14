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
#import "UdeskBundleUtils.h"
#import "UdeskSDKUtil.h"

@implementation UdeskChatTitleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setup];
    }
    return self;
}

- (void)setup {

    _titleLabel = [[UILabel alloc] initWithFrame:self.frame];
    _titleLabel.textColor = [UdeskSDKConfig customConfig].sdkStyle.titleColor;
    _titleLabel.font = [UdeskSDKConfig customConfig].sdkStyle.titleFont;
    _titleLabel.text = getUDLocalizedString(@"udesk_connecting");
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];
}

- (void)updateTitle:(UdeskAgent *)agent {

    NSString *titleText = @"";
    if (agent.statusType == UDAgentStatusResultOnline) {
        titleText = agent.nick;
    }
    else if (agent.statusType == UDAgentStatusResultOffline) {

        if (agent.sessionType == UDAgentSessionTypeInSession) {
            titleText = agent.nick?agent.nick:getUDLocalizedString(@"udesk_leave_msg");
        }
        else if (agent.sessionType == UDAgentSessionTypeHasOver) {
            titleText = getUDLocalizedString(@"udesk_chat_end");
        }
        else {
            titleText = getUDLocalizedString(@"udesk_leave_msg");
        }
    }
    else if (agent.statusType == UDAgentStatusResultQueue) {
        titleText = getUDLocalizedString(@"udesk_queue");
    }
    else {
        titleText = agent.message;
    }
    
    //容错处理
    if ([UdeskSDKUtil isBlankString:titleText]) {
        titleText = getUDLocalizedString(@"udesk_agent");
    }
    
    UIImage *titleImage;
    switch (agent.statusType) {
        case UDAgentStatusResultOnline:
            titleImage = [UIImage udDefaultAgentOnlineImage];
            break;
        case UDAgentStatusResultQueue:
            titleImage = [UIImage udDefaultAgentBusyImage];
            break;
        case UDAgentStatusResultOffline:
            titleImage = [UIImage udDefaultAgentOfflineImage];
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
    
    _titleLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}

@end
