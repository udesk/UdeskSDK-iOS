//
//  UDSDKFunctionViewController.m
//  UdeskSDK
//
//  Created by Udesk on 16/8/26.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UDFunctionViewController.h"
#import "Udesk.h"
#import "Masonry.h"
#import "UDDeveloperViewController.h"
#import "UdeskTicketViewController.h"
#import "UdeskCustomLocationViewController.h"

@interface UDFunctionViewController()

@property (strong, nonatomic) UIImageView *logoImage;
@property (strong, nonatomic) UIView *functionBackGroundView;
@property (strong, nonatomic) UIButton *faqButton;
@property (strong, nonatomic) UILabel *faqLabel;
@property (strong, nonatomic) UIButton *contactUsButton;
@property (strong, nonatomic) UILabel *contactUsLabel;
@property (strong, nonatomic) UIButton *ticketButton;
@property (strong, nonatomic) UILabel *ticketLabel;
@property (strong, nonatomic) UIButton *developerButton;
@property (strong, nonatomic) UILabel *developerLabel;
@property (strong, nonatomic) UIButton *resetButton;

@property (strong, nonatomic) UIView *horizontalLineView;
@property (strong, nonatomic) UIView *verticalLineView;

@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) NSString *url;

@end

@implementation UDFunctionViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    double text1 = 533/2/675.0f;
    CGFloat logoHeight = CGRectGetHeight(self.view.frame)*text1;

    _logoImage = [[UIImageView alloc] initWithFrame:CGRectZero];
    _logoImage.image = [UIImage imageNamed:@"logo"];
    [self.view addSubview:_logoImage];
    
    _functionBackGroundView = [[UIView alloc] initWithFrame:CGRectZero];
    _functionBackGroundView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_functionBackGroundView];
    
    _resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _resetButton.backgroundColor = [UIColor udColorWithHexString:@"#F9FAFF"];
    [_resetButton setTitle:@"重置域名和APP Key" forState:UIControlStateNormal];
    [_resetButton setTitleColor:[UIColor udColorWithHexString:@"#0093FF"] forState:UIControlStateNormal];
    [_resetButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_resetButton];
    
    [self.logoImage mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.height.mas_equalTo(logoHeight);
        make.width.mas_equalTo(self.view.mas_width);
    }];
    
    [self.resetButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(self.view.mas_bottom);
        make.height.mas_equalTo(64);
        make.width.mas_equalTo(self.view.mas_width);
    }];
    
    [self.functionBackGroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(_logoImage.mas_bottom);
        make.bottom.equalTo(_resetButton.mas_top);
        make.width.mas_equalTo(self.view.mas_width);
    }];
    
    _horizontalLineView = [[UIView alloc] initWithFrame:CGRectZero];
    _horizontalLineView.backgroundColor = [UIColor grayColor];
    _horizontalLineView.alpha = 0.2f;
    [_functionBackGroundView addSubview:_horizontalLineView];
    
    _verticalLineView = [[UIView alloc] initWithFrame:CGRectZero];
    _verticalLineView.backgroundColor = [UIColor grayColor];
    _verticalLineView.alpha = 0.2f;
    [_functionBackGroundView addSubview:_verticalLineView];
    
    [self.horizontalLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.functionBackGroundView.mas_left).offset(25);
        make.centerY.equalTo(self.functionBackGroundView.mas_centerY);
        make.right.equalTo(self.functionBackGroundView.mas_right).offset(-25);
        make.height.mas_equalTo(0.5f);
    }];
    
    [self.verticalLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.functionBackGroundView.mas_top).offset(25);
        make.centerX.equalTo(self.functionBackGroundView.mas_centerX);
        make.bottom.equalTo(self.functionBackGroundView.mas_bottom).offset(-25);
        make.width.mas_equalTo(0.5f);
    }];
    
    _faqButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_faqButton setImage:[UIImage imageNamed:@"faq"] forState:UIControlStateNormal];
    [self.functionBackGroundView addSubview:_faqButton];
    
    _faqLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _faqLabel.text = @"帮助中心";
    [self.functionBackGroundView addSubview:_faqLabel];
    
    _contactUsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_contactUsButton setImage:[UIImage imageNamed:@"contactUs"] forState:UIControlStateNormal];
    [self.functionBackGroundView addSubview:_contactUsButton];
    
    _contactUsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _contactUsLabel.text = @"咨询客服";
    [self.functionBackGroundView addSubview:_contactUsLabel];
    
    _ticketButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_ticketButton setImage:[UIImage imageNamed:@"ticket"] forState:UIControlStateNormal];
    [self.functionBackGroundView addSubview:_ticketButton];
    
    _ticketLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _ticketLabel.text = @"留言表单";
    [self.functionBackGroundView addSubview:_ticketLabel];
    
    _developerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_developerButton setImage:[UIImage imageNamed:@"developer"] forState:UIControlStateNormal];
    [self.functionBackGroundView addSubview:_developerButton];
    
    _developerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _developerLabel.text = @"开发者功能";
    [self.functionBackGroundView addSubview:_developerLabel];
    
    [self.faqButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.functionBackGroundView.mas_centerY).multipliedBy(0.5).offset(-20);
        make.centerX.equalTo(self.functionBackGroundView.mas_centerX).multipliedBy(0.5);
        make.width.and.height.mas_equalTo(75);
    }];
    
    [self.faqLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.faqButton.mas_bottom).offset(20);
        make.centerX.equalTo(self.faqButton.mas_centerX);
    }];
    
    [self.contactUsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.functionBackGroundView.mas_centerY).multipliedBy(0.5).offset(-20);
        make.centerX.equalTo(self.functionBackGroundView.mas_centerX).multipliedBy(1.5);
        make.width.and.height.mas_equalTo(75);
    }];
    
    [self.contactUsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.contactUsButton.mas_bottom).offset(20);
        make.centerX.equalTo(self.contactUsButton.mas_centerX);
    }];
    
    [self.ticketButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.functionBackGroundView.mas_centerY).multipliedBy(1.5).offset(-20);
        make.centerX.equalTo(self.functionBackGroundView.mas_centerX).multipliedBy(0.5);
        make.width.and.height.mas_equalTo(75);
    }];
    
    [self.ticketLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.ticketButton.mas_bottom).offset(20);
        make.centerX.equalTo(self.ticketButton.mas_centerX);
    }];
    
    [self.developerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.functionBackGroundView.mas_centerY).multipliedBy(1.5).offset(-20);
        make.centerX.equalTo(self.functionBackGroundView.mas_centerX).multipliedBy(1.5);
        make.width.and.height.mas_equalTo(75);
    }];
    
    [self.developerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.developerButton.mas_bottom).offset(20);
        make.centerX.equalTo(self.developerButton.mas_centerX);
    }];
    
    [self.faqButton addTarget:self action:@selector(faq:) forControlEvents:UIControlEventTouchUpInside];
    [self.contactUsButton addTarget:self action:@selector(contactUs:) forControlEvents:UIControlEventTouchUpInside];
    [self.ticketButton addTarget:self action:@selector(ticket:) forControlEvents:UIControlEventTouchUpInside];
    [self.developerButton addTarget:self action:@selector(developer:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UD_RECEIVED_NEW_MESSAGES_NOTIFICATION object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        //获取sdk发送的未读消息通知内容
        if ([note.object isKindOfClass:[UdeskMessage class]]) {
            UdeskMessage *message = (UdeskMessage *)note.object;
            NSLog(@"未读消息内容%@",message.content);
        }
        
        //延迟获取sdk存在db的未读消息
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"未读消息数:%ld",[UdeskManager getLocalUnreadeMessagesCount]);
            NSLog(@"未读消息:%@",[UdeskManager getLocalUnreadeMessages]);
        });
    }];
}

- (void)backButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)faq:(id)sender {
    
    UdeskSDKManager *chatViewManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle customStyle] sdkConfig:[UdeskSDKConfig customConfig]];
    [chatViewManager showFAQInViewController:self transiteAnimation:UDTransiteAnimationTypePush completion:nil];
}

- (void)contactUs:(id)sender {

    UdeskSDKStyle *style = [UdeskSDKStyle customStyle];
    UdeskSDKConfig *config = [UdeskSDKConfig customConfig];
    
    //初始化sdk
    UdeskSDKManager *chatViewManager = [[UdeskSDKManager alloc] initWithSDKStyle:style sdkConfig:config sdkActionConfig:nil];
    [chatViewManager pushUdeskInViewController:self completion:nil];
}

- (void)ticket:(id)sender {
    
    UdeskSDKManager *chatViewManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle customStyle] sdkConfig:[UdeskSDKConfig customConfig]];
    [chatViewManager presentTicketInViewController:self completion:nil];
}

- (void)developer:(id)sender {
    
    UDDeveloperViewController *developer = [[UDDeveloperViewController alloc] init];
    [self.navigationController pushViewController:developer animated:YES];
}

@end
