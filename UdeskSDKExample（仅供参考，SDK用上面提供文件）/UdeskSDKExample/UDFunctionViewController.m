//
//  UDSDKFunctionViewController.m
//  UdeskSDK
//
//  Created by xuchen on 16/8/26.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UDFunctionViewController.h"
#import "Udesk.h"
#import "UdeskViewExt.h"
#import "Masonry.h"
#import "UIColor+UdeskSDK.h"
#import "UDDeveloperViewController.h"
#import "UdeskTransitioningAnimation.h"
#import "UdeskTools.h"
#import "UdeskLanguageTool.h"
#import "UDStatus.h"

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

@end

@implementation UDFunctionViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
//    self.navigationController.navigationBarHidden = YES;
    
    NSString *nick_name = [NSString stringWithFormat:@"sdk用户%u",arc4random()];
    NSString *sdk_token = [NSString stringWithFormat:@"%u",arc4random()];
    
//    NSDictionary *parameters = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"parameters"];
//    
//    if (parameters) {
//        //创建用户
//        [UdeskManager createCustomerWithCustomerInfo:parameters];
//    }
//    else {
    
        NSDictionary *parameters = @{
                                     @"user" :    @{
                                             @"nick_name":nick_name,
                                             @"sdk_token":sdk_token,
                                             }
                                     };
    

    
        //创建用户
        [UdeskManager createCustomerWithCustomerInfo:parameters];
        
//        [[NSUserDefaults standardUserDefaults] setObject:parameters forKey:@"parameters"];
//    }
    
    
    double text1 = 533/2/675.0f;
    CGFloat logoHeight = self.view.ud_height*text1;

    _logoImage = [[UIImageView alloc] initWithFrame:CGRectZero];
    _logoImage.image = [UIImage imageNamed:@"logo"];
    [self.view addSubview:_logoImage];
    
    _functionBackGroundView = [[UIView alloc] initWithFrame:CGRectZero];
    _functionBackGroundView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_functionBackGroundView];
    
    _resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _resetButton.backgroundColor = [UIColor colorWithHexString:@"#F9FAFF"];
    [_resetButton setTitle:@"重置域名和APP Key" forState:UIControlStateNormal];
    [_resetButton setTitleColor:[UIColor colorWithHexString:@"#0093FF"] forState:UIControlStateNormal];
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
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMsg:) name:UD_RECEIVED_NEW_MESSAGES_NOTIFICATION object:nil];
    
    
    [UdeskManager getCustomerFields:^(id responseObject, NSError *error) {
        
        NSLog(@"%@",responseObject);
    }];
}

- (void)receiveMsg:(NSNotification *)notif {

    NSLog(@"%@",notif.object);
}

- (void)backButtonAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)faq:(id)sender {
    
//    [UdeskManager initWithAppkey:@"key" domianName:@"domain"];
//    
//    NSDictionary *parameters = @{
//                                 @"user" :    @{
//                                         @"nick_name":nick_name,
//                                         @"sdk_token":sdk_token
//                                         }
//                                 };
//    
//    //创建用户
//    [UdeskManager createCustomerWithCustomerInfo:parameters];
    
    UdeskSDKStyle *customStyle = [UdeskSDKStyle customStyle];
//    customStyle.customerBubbleColor
//    //导航栏颜色
    customStyle.navigationColor = [self colorWithHexString:@"#FE6000"];
//    //设置客服气泡图片
//    customStyle.agentBubbleImage = [UIImage imageNamed:@"客服气泡"];
//    //客户气泡图片
//    customStyle.customerBubbleImage = [UIImage imageNamed:@"客户气泡"];
//    //返回图片
//    customStyle.navBackButtonImage = [UIImage imageNamed:@"backTwo"];
    
    UdeskSDKManager *chatViewManager = [[UdeskSDKManager alloc] initWithSDKStyle:customStyle];
    
    [chatViewManager presentUdeskViewControllerWithType:UdeskFAQ viewController:self completion:nil];
}

- (void)contactUs:(id)sender {

/***************  旧版本方法   ******************/

//    UdeskSDKManager *chatViewManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle]];
//    [chatViewManager setGroupName:@"Decade"];
//    UdeskType type = UdeskRobot;
//
//    [chatViewManager setTransferToAgentMenu:YES];
//    if ([UdeskManager customersAreSession]) {
//        type = UdeskIM;
//    }
//
//    [chatViewManager pushUdeskViewControllerWithType:type viewController:self completion:^{
//
//    }];

/***************   新版本方法（根据后台的配置执行）   *********************/

    UdeskSDKManager *chatViewManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle]];

    // 设置组名
    [chatViewManager setGroupName:@"售后组"];

    // 设置放弃排队
    [chatViewManager setQuitQueueType:UdeskForce_quit];

   // [chatViewManager setTicketUrl:@"https://github.com/udesk/UdeskSDK-iOS"];

    // 调用后台配置的push方法
    [chatViewManager presentUdeskViewControllerWith:self completion:^{

    }];

}

- (void)ticket:(id)sender {

    UdeskSDKManager *chatViewManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle]];
    // 添加自定义的留言地址，如果不调用默认进系统留言
   // [chatViewManager setTicketUrl:@"https://github.com/udesk/UdeskSDK-iOS"];
    [chatViewManager pushUdeskViewControllerWithType:UdeskTicket viewController:self completion:nil];
}
- (void)developer:(id)sender {
    
    UDDeveloperViewController *developer = [[UDDeveloperViewController alloc] init];
    [self presentOnViewController:self udeskViewController:developer transiteAnimation:UDTransiteAnimationTypePush];
}

- (void)presentOnViewController:(UIViewController *)rootViewController udeskViewController:(id)udeskViewController transiteAnimation:(UDTransiteAnimationType)animation {
    
    UIViewController *viewController = nil;
    if (animation == UDTransiteAnimationTypePush) {
        viewController = [self createNavigationControllerWithWithAnimationSupport:udeskViewController presentedViewController:rootViewController];
        BOOL shouldUseUIKitAnimation = [[[UIDevice currentDevice] systemVersion] floatValue] >= 7;
        [rootViewController presentViewController:viewController animated:shouldUseUIKitAnimation completion:nil];
    } else {
        viewController = [[UINavigationController alloc] initWithRootViewController:udeskViewController];
        [self updateNavAttributesWithViewController:udeskViewController navigationController:(UINavigationController *)viewController defaultNavigationController:rootViewController.navigationController isPresentModalView:true];
        [rootViewController presentViewController:viewController animated:YES completion:nil];
    }
}

- (UINavigationController *)createNavigationControllerWithWithAnimationSupport:(UIViewController *)rootViewController presentedViewController:(UIViewController *)presentedViewController{
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:rootViewController];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [self updateNavAttributesWithViewController:rootViewController navigationController:(UINavigationController *)navigationController defaultNavigationController:rootViewController.navigationController isPresentModalView:true];
        [navigationController setTransitioningDelegate:[UdeskTransitioningAnimation transitioningDelegateImpl]];
        [navigationController setModalPresentationStyle:UIModalPresentationCustom];
    } else {
        [self updateNavAttributesWithViewController:rootViewController navigationController:(UINavigationController *)navigationController defaultNavigationController:rootViewController.navigationController isPresentModalView:true];
        [rootViewController.view.window.layer addAnimation:[UdeskTransitioningAnimation createPresentingTransiteAnimation:UDTransiteAnimationTypePush] forKey:nil];
    }
    return navigationController;
}

//修改导航栏属性
- (void)updateNavAttributesWithViewController:(UIViewController *)viewController
                         navigationController:(UINavigationController *)navigationController
                  defaultNavigationController:(UINavigationController *)defaultNavigationController
                           isPresentModalView:(BOOL)isPresentModalView {
    
    if (defaultNavigationController.navigationBar.titleTextAttributes) {
        navigationController.navigationBar.titleTextAttributes = defaultNavigationController.navigationBar.titleTextAttributes;
    } else {
        UIColor *color = [UIColor whiteColor];
        UIFont *font = [UIFont systemFontOfSize:17];
        NSDictionary *attr = @{NSForegroundColorAttributeName : color, NSFontAttributeName : font};
        navigationController.navigationBar.titleTextAttributes = attr;
    }
    
    UIButton *leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBarButton.frame = CGRectMake(0, 0, 20, 30);
    UIImage *backImage = [UIImage imageNamed:@"back"];
    [leftBarButton setImage:backImage forState:UIControlStateNormal];
    [leftBarButton addTarget:viewController action:@selector(dismissChatViewController) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *otherNavigationItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];

    viewController.navigationItem.leftBarButtonItem = otherNavigationItem;
    
    navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"#0093FF"];
    
    viewController.navigationItem.title = @"开发者功能";
}

//16进制颜色转换
- (UIColor *)colorWithHexString: (NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}


- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
//    _button.alpha = 1;
//    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:_button];
}

@end
