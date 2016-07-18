//
//  UdeskNavigationView.m
//  UdeskSDK
//
//  Created by xuchen on 16/6/15.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskNavigationView.h"
#import "UdeskUtils.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskGeneral.h"
#import "UdeskFoundationMacro.h"
#import "UdeskViewExt.h"
#import "UdeskAgentModel.h"
#import "UdeskTools.h"

@interface UdeskNavigationView() {

    NSString *_nick;
}

@property (nonatomic, weak) UILabel  *titleLabel;
@property (nonatomic, weak) UILabel  *describeTitleLabel;
@property (nonatomic, weak) UIButton *rightButton;
@property (nonatomic, weak) UIButton *backButton;

@end

@implementation UdeskNavigationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = UdeskUIConfig.iMNavigationColor;
        
        CGFloat backButtonY = ud_isIOS6?0:10;
        //返回按钮
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(5, (frame.size.height-30)/2+backButtonY, 60, 30);
        [backButton setTitleColor:UdeskUIConfig.iMBackButtonColor forState:UIControlStateNormal];
        [backButton setImage:[UIImage ud_defaultBackImage] forState:UIControlStateNormal];
        [backButton setTitle:@"返回" forState:UIControlStateNormal];
        backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:backButton];
        _backButton = backButton;
        
        CGFloat titleLabelY = ud_isIOS6?0:20;
        //标题
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, titleLabelY, 0, 44)];
        titleLabel.text = getUDLocalizedString(@"会话");
        titleLabel.font = [UIFont systemFontOfSize:18];
        titleLabel.textColor = UdeskUIConfig.iMTitleColor;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:titleLabel];
        
        _titleLabel = titleLabel;
        
        UILabel *describeTitleLabel = [[UILabel alloc] init];
        describeTitleLabel.font = [UIFont systemFontOfSize:11];
        describeTitleLabel.textColor = UdeskUIConfig.agentStatusTitleColor;
        describeTitleLabel.textAlignment = NSTextAlignmentCenter;
        describeTitleLabel.backgroundColor = [UIColor clearColor];
        describeTitleLabel.hidden = YES;
        [self addSubview:describeTitleLabel];
        
        _describeTitleLabel = describeTitleLabel;
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        rightButton.frame = CGRectMake(self.ud_right-70, (frame.size.height-30)/2+backButtonY, 60, 30);
        rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(rightAction) forControlEvents:UIControlEventTouchUpInside];
        rightButton.hidden = YES;
        [self addSubview:rightButton];
        
        _rightButton = rightButton;
        
    }
    return self;
}

- (void)backAction {

    if (self.navigationBackBlcok) {
        self.navigationBackBlcok();
    }
}

- (void)rightAction {

    if (self.navigationRightBlcok) {
        self.navigationRightBlcok();
    }
}

- (void)showNativeNavigationView {

    self.backgroundColor = [UIColor clearColor];
    CGFloat agentStatusTitleLength = [[UIScreen mainScreen] bounds].size.width>320?200:170;
    self.frame = CGRectMake(0, 0, agentStatusTitleLength, 44);
    
    self.titleLabel.frame = CGRectMake((200-self.titleLabel.ud_width)/2, 0, self.titleLabel.ud_width, 44);
    [self.backButton removeFromSuperview];
}

- (void)changeTitle:(NSString *)title {

    CGSize titleSize = [UdeskGeneral.store textSize:title fontOfSize:[UIFont systemFontOfSize:18] ToSize:CGSizeMake(self.ud_width, 44)];
    self.titleLabel.ud_x = (self.ud_width-titleSize.width)/2;
    self.titleLabel.ud_width = titleSize.width;
    self.titleLabel.text = title;
}

- (void)showRightButtonWithName:(NSString *)name {

    [self.rightButton setTitle:name forState:UIControlStateNormal];
    self.rightButton.hidden = NO;
}

- (void)showAgentOnlineStatus:(UdeskAgentModel *)agentModel {
    
    _nick = agentModel.nick;
    
    if (agentModel.code) {
        
        //改变title frame
        [self changeTitleFrame];
        
        CGSize describeSize = [UdeskGeneral.store textSize:agentModel.message fontOfSize:[UIFont systemFontOfSize:11] ToSize:CGSizeMake(self.ud_width, 44)];
        
        CGRect describeFrame = CGRectMake((self.ud_width-describeSize.width)/2, _titleLabel.ud_bottom-3, describeSize.width, 14);
        
        _describeTitleLabel.frame = describeFrame;
        
        _describeTitleLabel.hidden = NO;
        
        //显示名字，显示在线状态
        _describeTitleLabel.text = agentModel.message;
        
    }
    
}


//客服上下线改变状态
- (void)agentOnlineOrNotOnline:(NSString *)statusType {
    
    [self changeTitleFrame];
    
    if ([UdeskTools isBlankString:_nick]) {
        _nick = @"";
    }
    
    if ([statusType isEqualToString:@"available"]) {
        
        NSString *describeTieleStr = [NSString stringWithFormat:@"客服 %@ 在线",_nick];
        
        CGSize describeSize = [UdeskGeneral.store textSize:describeTieleStr fontOfSize:[UIFont systemFontOfSize:11] ToSize:CGSizeMake(self.ud_width, 44)];
        
        _describeTitleLabel.frame = CGRectMake((self.ud_width-describeSize.width)/2, 27, describeSize.width, 14);;
        _describeTitleLabel.text = describeTieleStr;
        
    }
    else if ([statusType isEqualToString:@"unavailable"]) {
        
        NSString *describeTieleStr = [NSString stringWithFormat:@"客服 %@ 离线了",_nick];
        
        CGSize describeSize = [UdeskGeneral.store textSize:describeTieleStr fontOfSize:[UIFont systemFontOfSize:11] ToSize:CGSizeMake(self.ud_width, 44)];
        
        _describeTitleLabel.frame = CGRectMake((self.ud_width-describeSize.width)/2, _titleLabel.ud_bottom-3, describeSize.width, 14);
        
        _describeTitleLabel.text = describeTieleStr;
        
    }
    else if ([statusType isEqualToString:@"notNetwork"]) {
        
        NSString *describeTieleStr = @"网络断开链接了";
        
        CGSize describeSize = [UdeskGeneral.store textSize:describeTieleStr fontOfSize:[UIFont systemFontOfSize:11] ToSize:CGSizeMake(self.ud_width, 44)];
        
        _describeTitleLabel.frame = CGRectMake((self.ud_width-describeSize.width)/2, _titleLabel.ud_bottom-3, describeSize.width, 14);
        
        _describeTitleLabel.text = describeTieleStr;
    }
}

//改变title frame
- (void)changeTitleFrame {
    
    CGRect newframe = _titleLabel.frame;
    newframe.size.height = 30;
    _titleLabel.frame = newframe;
}

@end
