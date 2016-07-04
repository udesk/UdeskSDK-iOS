//
//  UdeskAgentStatusView.m
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskAgentStatusView.h"
#import "UdeskAgentModel.h"
#import "UdeskGeneral.h"
#import "UdeskFoundationMacro.h"
#import "UdeskUtils.h"
#import "UdeskViewExt.h"
#import "UdeskTools.h"

@interface UdeskAgentStatusView ()

/**
 *  客服名字
 */
@property (nonatomic, copy) NSString *nick;

@end

@implementation UdeskAgentStatusView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        
        [self setUp];
    }
    return self;
}

- (void)setUp {
    
    UILabel *titleLabel = [[UILabel alloc] init];
    
    CGSize titleSize = [UdeskGeneral.store textSize:getUDLocalizedString(@"会话") fontOfSize:[UIFont systemFontOfSize:18] ToSize:CGSizeMake(self.ud_width, 44)];
    
    titleLabel.frame = CGRectMake((self.ud_width-titleSize.width)/2, 0, titleSize.width, 44);
    
    titleLabel.text = getUDLocalizedString(@"会话");
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.textColor = UdeskUIConfig.iMTitleColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:titleLabel];
    _titleLabel = titleLabel;
    
    UILabel *describeTitle = [[UILabel alloc] init];
    describeTitle.font = [UIFont systemFontOfSize:11];
    describeTitle.textColor = UdeskUIConfig.agentStatusTitleColor;
    describeTitle.textAlignment = NSTextAlignmentCenter;
    describeTitle.backgroundColor = [UIColor clearColor];
    [self addSubview:describeTitle];
    _describeTitle = describeTitle;
    
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
        
        _describeTitle.frame = CGRectMake((self.ud_width-describeSize.width)/2, 27, describeSize.width, 14);;
        _describeTitle.text = describeTieleStr;
        
    }
    else if ([statusType isEqualToString:@"unavailable"]) {
        
        NSString *describeTieleStr = [NSString stringWithFormat:@"客服 %@ 离线了",_nick];
        
        CGSize describeSize = [UdeskGeneral.store textSize:describeTieleStr fontOfSize:[UIFont systemFontOfSize:11] ToSize:CGSizeMake(self.ud_width, 44)];
        
        _describeTitle.frame = CGRectMake((self.ud_width-describeSize.width)/2, _titleLabel.ud_bottom-3, describeSize.width, 14);
        
        _describeTitle.text = describeTieleStr;

    }
    else if ([statusType isEqualToString:@"notNetwork"]) {
    
        NSString *describeTieleStr = @"网络断开链接了";
        
        CGSize describeSize = [UdeskGeneral.store textSize:describeTieleStr fontOfSize:[UIFont systemFontOfSize:11] ToSize:CGSizeMake(self.ud_width, 44)];
        
        _describeTitle.frame = CGRectMake((self.ud_width-describeSize.width)/2, _titleLabel.ud_bottom-3, describeSize.width, 14);
        
        _describeTitle.text = describeTieleStr;
    }
}

//改变title frame
- (void)changeTitleFrame {

    CGRect newframe = _titleLabel.frame;
    newframe.size.height = 30;
    _titleLabel.frame = newframe;
    
}

- (void)bindDataWithAgentModel:(UdeskAgentModel *)agentModel {

    _nick = agentModel.nick;
    
    if (agentModel.code) {
        
        //改变title frame
        [self changeTitleFrame];
        
        CGSize describeSize = [UdeskGeneral.store textSize:agentModel.message fontOfSize:[UIFont systemFontOfSize:11] ToSize:CGSizeMake(self.ud_width, 44)];
        
        CGRect describeFrame = CGRectMake((self.ud_width-describeSize.width)/2, _titleLabel.ud_bottom-3, describeSize.width, 14);
        
        _describeTitle.frame = describeFrame;
        
        //显示名字，显示在线状态
        _describeTitle.text = agentModel.message;
        
    }    
    
}

@end
