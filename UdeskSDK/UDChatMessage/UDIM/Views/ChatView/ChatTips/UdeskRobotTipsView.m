//
//  UdeskRobotTipsView.m
//  UdeskSDK
//
//  Created by xuchen on 2019/1/21.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskRobotTipsView.h"
#import "UdeskSDKMacro.h"
#import "UIView+UdeskSDK.h"
#import "UdeskMessage.h"
#import "UdeskManager.h"
#import "UdeskSDKUtil.h"
#import "UdeskChatInputToolBar.h"
#import "UdeskThrottleUtil.h"

static NSString *kUDTipsCellIdentifier = @"kUDTipsCellIdentifier";

@interface UdeskRobotTipsView()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UdeskChatInputToolBar *chatInputToolBar;
@property (nonatomic, strong) UITableView *tipsTableView;
@property (nonatomic, strong) NSString *keyword;
@property (nonatomic, strong) NSArray *tipsResult;

@end

@implementation UdeskRobotTipsView

- (instancetype)initWithFrame:(CGRect)frame chatInputToolBar:(UdeskChatInputToolBar *)chatInputToolBar
{
    self = [super initWithFrame:frame];
    if (self) {
     
        _chatInputToolBar = chatInputToolBar;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    self.backgroundColor = [UIColor colorWithRed:0.949f  green:0.957f  blue:0.961f alpha:1];
    
    _tipsTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    _tipsTableView.delegate = self;
    _tipsTableView.dataSource = self;
    _tipsTableView.backgroundColor = [UIColor colorWithRed:0.949f  green:0.957f  blue:0.961f alpha:1];
    [self addSubview:_tipsTableView];
    
    [_tipsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kUDTipsCellIdentifier];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tipsResult.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kUDTipsCellIdentifier forIndexPath:indexPath];

    UdeskMessage *message = self.tipsResult[indexPath.row];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:message.robotQuestion];
    
    if (![UdeskSDKUtil isBlankString:self.keyword]) {
        NSRange range = [message.robotQuestion rangeOfString:self.keyword];
        if (range.location != NSNotFound) {
            [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:1  green:0.467f  blue:0 alpha:1] range:range];
        }
    }
    
    cell.textLabel.attributedText = attributedText;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UdeskMessage *message = self.tipsResult[indexPath.row];
    
    if (self.didTapRobotTipsBlock) {
        self.didTapRobotTipsBlock(message);
    }
    
    [self closeRobotTipsView];
}

- (void)updateWithKeyword:(NSString *)keyword {
    _keyword = keyword;
    
    self.udBottom = CGRectGetMinY(self.chatInputToolBar.frame);
    ud_dispatch_throttle(1.0, ^{
        if ([UdeskSDKUtil isBlankString:keyword]) {
            [self closeRobotTipsView];
            return;
        }
        
        [UdeskManager fetchRobotTips:keyword completion:^(NSArray *result) {
            
            if (!result || result.count == 0) {
                [self closeRobotTipsView];
                return ;
            }
            
            self.alpha = 1;
            self.udHeight = (result.count>5?5:result.count) * 44;
            self.udBottom = CGRectGetMinY(self.chatInputToolBar.frame);
            self.tipsTableView.frame = self.bounds;
            
            self.tipsResult = result;
            [self.tipsTableView reloadData];
        }];
    });
}

- (void)closeRobotTipsView {
    
    self.alpha = 0;
    self.udY = UD_SCREEN_HEIGHT;
    self.tipsResult = nil;
    [self.tipsTableView reloadData];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
