//
//  UDAgentStatusView.m
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UDAgentStatusView.h"
#import "UDAgentModel.h"

@interface UDAgentStatusView ()

/**
 *  客服名字
 */
@property (nonatomic, copy) NSString *nick;

@end

@implementation UDAgentStatusView

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
    
    CGSize titleSize = [UDGeneral.store textSize:getUDLocalizedString(@"反馈") fontOfSize:[UIFont systemFontOfSize:18] ToSize:CGSizeMake(self.ud_width, 44)];
    
    titleLabel.frame = CGRectMake((self.ud_width-titleSize.width)/2, 0, titleSize.width, 44);
    
    titleLabel.text = getUDLocalizedString(@"反馈");
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.textColor = Config.iMTitleColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:titleLabel];
    _titleLabel = titleLabel;
    
    UILabel *describeTitle = [[UILabel alloc] init];
    describeTitle.font = [UIFont systemFontOfSize:11];
    describeTitle.hidden = YES;
    describeTitle.textColor = Config.agentStatusTitleColor;
    describeTitle.textAlignment = NSTextAlignmentCenter;
    describeTitle.backgroundColor = [UIColor clearColor];
    [self addSubview:describeTitle];
    _describeTitle = describeTitle;
    
}

//客服上下线改变状态
- (void)agentOnlineOrNotOnline:(NSString *)statusType {

    if ([statusType isEqualToString:@"available"]) {
    
        NSString *describeTieleStr = [NSString stringWithFormat:@"客服 %@ 在线",_nick];
        
        CGSize describeSize = [UDGeneral.store textSize:describeTieleStr fontOfSize:[UIFont systemFontOfSize:11] ToSize:CGSizeMake(self.ud_width, 44)];
        
        _describeTitle.frame = CGRectMake((self.ud_width-describeSize.width)/2, 27, describeSize.width, 14);;
        _describeTitle.text = describeTieleStr;
        
    } else if ([statusType isEqualToString:@"unavailable"]) {
        
        NSString *describeTieleStr = [NSString stringWithFormat:@"客服 %@ 离线了",_nick];
        
        CGSize describeSize = [UDGeneral.store textSize:describeTieleStr fontOfSize:[UIFont systemFontOfSize:11] ToSize:CGSizeMake(self.ud_width, 44)];
        
        _describeTitle.frame = CGRectMake((self.ud_width-describeSize.width)/2, 27, describeSize.width, 14);
        
        _describeTitle.text = describeTieleStr;

    } else if ([statusType isEqualToString:@"notNetwork"]) {
    
        NSString *describeTieleStr = @"网络断开链接了";
        
        CGSize describeSize = [UDGeneral.store textSize:describeTieleStr fontOfSize:[UIFont systemFontOfSize:11] ToSize:CGSizeMake(self.ud_width, 44)];
        
        _describeTitle.frame = CGRectMake((self.ud_width-describeSize.width)/2, 27, describeSize.width, 14);
        
        _describeTitle.text = describeTieleStr;
    }
}

//改变title frame
- (void)changeTitleFrame {

    CGRect newframe = _titleLabel.frame;
    newframe.size.height = 30;
    _titleLabel.frame = newframe;
}

//显示客服状态
//- (void)bindDataWithAgentModel:(UDAgentViewModel *)viewModel {
//
//    _nick = viewModel.agentModel.nick;
//    
//    //改变title frame
//    [self changeTitleFrame];
//    
//    if (viewModel.agentModel.code  == 2000) {
//        
//        //显示在线状态
//        _describeTitle.hidden = NO;
//        CGSize describeSize = [UDGeneral.store textSize:viewModel.agentModel.message fontOfSize:[UIFont systemFontOfSize:18] ToSize:CGSizeMake(self.ud_width, 44)];
//        
//        CGRect describeFrame = CGRectMake((self.ud_width-describeSize.width)/2, 27, describeSize.width, 14);
//        
//        _describeTitle.frame = describeFrame;
//        
//        //显示名字，显示在线状态
//        _describeTitle.text = viewModel.agentModel.message;
//
//    }
//    else if (viewModel.agentModel.code == 2001) {
//        
//        _describeTitle.hidden = NO;
//        CGSize describeSize = [UDGeneral.store textSize:viewModel.agentModel.message fontOfSize:[UIFont systemFontOfSize:11] ToSize:CGSizeMake(self.ud_width, 44)];
//        
//        _describeTitle.frame = CGRectMake((self.ud_width-describeSize.width)/2, 27, describeSize.width, 14);
//        
//        _describeTitle.text = viewModel.agentModel.message;
//        
//    }
//    else {
//        
//        _describeTitle.hidden = NO;
//        CGSize describeSize = [UDGeneral.store textSize:viewModel.agentModel.message fontOfSize:[UIFont systemFontOfSize:11] ToSize:CGSizeMake(self.ud_width, 44)];
//        
//        _describeTitle.frame = CGRectMake((self.ud_width-describeSize.width)/2, 27, describeSize.width, 14);
//        
//        _describeTitle.text = viewModel.agentModel.message;
//        
//    }
//    
//}

- (void)bindDataWithAgentModel:(UDAgentModel *)agentModel {

    _nick = agentModel.nick;
    
    //改变title frame
    [self changeTitleFrame];
    
    if (agentModel.code  == 2000) {
        
        //显示在线状态
        _describeTitle.hidden = NO;
        CGSize describeSize = [UDGeneral.store textSize:agentModel.message fontOfSize:[UIFont systemFontOfSize:18] ToSize:CGSizeMake(self.ud_width, 44)];
        
        CGRect describeFrame = CGRectMake((self.ud_width-describeSize.width)/2, 27, describeSize.width, 14);
        
        _describeTitle.frame = describeFrame;
        
        //显示名字，显示在线状态
        _describeTitle.text = agentModel.message;
        
    }
    else if (agentModel.code == 2001) {
        
        _describeTitle.hidden = NO;
        CGSize describeSize = [UDGeneral.store textSize:agentModel.message fontOfSize:[UIFont systemFontOfSize:11] ToSize:CGSizeMake(self.ud_width, 44)];
        
        _describeTitle.frame = CGRectMake((self.ud_width-describeSize.width)/2, 27, describeSize.width, 14);
        
        _describeTitle.text = agentModel.message;
        
    }
    else {
        
        _describeTitle.hidden = NO;
        CGSize describeSize = [UDGeneral.store textSize:agentModel.message fontOfSize:[UIFont systemFontOfSize:11] ToSize:CGSizeMake(self.ud_width, 44)];
        
        _describeTitle.frame = CGRectMake((self.ud_width-describeSize.width)/2, 27, describeSize.width, 14);
        
        _describeTitle.text = agentModel.message;
        
    }
}

@end
