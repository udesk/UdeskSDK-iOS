//
//  UDViewController.m
//  UdeskSDK
//
//  Created by Udesk on 16/8/26.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UDViewController.h"
#import "UDFunctionViewController.h"
#import "UdeskSDKMacro.h"
#import "UIView+UdeskSDK.h"
#import "Udesk.h"

@interface UDViewController()

@property (nonatomic, strong) UITextField *domainTextField;
@property (nonatomic, strong) UITextField *appKeyTextField;
@property (nonatomic, strong) UITextField *appIdTextField;

/** 会话ID */
@property (nonatomic, strong) NSNumber             *imSubSessionId;
/** 会话序号 */
@property (nonatomic, strong) NSNumber             *seqNum;

@end

@implementation UDViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake((UD_SCREEN_WIDTH-226)/2, 70, 226, 91)];
    logo.image = [UIImage imageNamed:@"backGroundLogo"];
    [self.view addSubview:logo];
    
    UIView *accountTextFieldBackGroundView = [[UIView alloc] initWithFrame:CGRectMake(20, logo.udBottom+50, UD_SCREEN_WIDTH-40, 50)];
    accountTextFieldBackGroundView.backgroundColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:0.1f];
    UDViewBorderRadius(accountTextFieldBackGroundView, 1, 1, [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:0.5f]);
    [self.view addSubview:accountTextFieldBackGroundView];
    
    //账号
    _domainTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, UD_SCREEN_WIDTH-100, 50)];
    _domainTextField.keyboardType = UIKeyboardTypeEmailAddress;
    //获取登录账号密码 (自动登录)
    _domainTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"domain"];
    _domainTextField.backgroundColor = [UIColor clearColor];
    _domainTextField.placeholder = @"域名";
    _domainTextField.textColor = [UIColor whiteColor];

    [accountTextFieldBackGroundView addSubview:_domainTextField];
    
    UIView *passwordTextFieldBackGroundView = [[UIView alloc] initWithFrame:CGRectMake(20, accountTextFieldBackGroundView.udBottom+11, UD_SCREEN_WIDTH-40, 50)];
    passwordTextFieldBackGroundView.backgroundColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:0.1f];
    UDViewBorderRadius(passwordTextFieldBackGroundView, 1, 1, [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:0.5f]);
    [self.view addSubview:passwordTextFieldBackGroundView];
    
    //密码
    _appKeyTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, UD_SCREEN_WIDTH-100, 50)];
    _appKeyTextField.backgroundColor = [UIColor clearColor];
    _appKeyTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"key"];
    _appKeyTextField.placeholder = @"APP Key";
    _appKeyTextField.textColor = [UIColor whiteColor];
    
    [passwordTextFieldBackGroundView addSubview:_appKeyTextField];
    
    UIView *appIdTextFieldBackGroundView = [[UIView alloc] initWithFrame:CGRectMake(20, passwordTextFieldBackGroundView.udBottom+11, UD_SCREEN_WIDTH-40, 50)];
    appIdTextFieldBackGroundView.backgroundColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:0.1f];
    UDViewBorderRadius(appIdTextFieldBackGroundView, 1, 1, [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:0.5f]);
    [self.view addSubview:appIdTextFieldBackGroundView];
    
    //密码
    _appIdTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, UD_SCREEN_WIDTH-100, 50)];
    _appIdTextField.backgroundColor = [UIColor clearColor];
    _appIdTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"appId"];
    _appIdTextField.placeholder = @"APP ID";
    _appIdTextField.textColor = [UIColor whiteColor];

//    _domainTextField.text = @"brazil0326.udesk.cn";
//    _appKeyTextField.text = @"fd1656154e010248434234d7b59aeee9";
//    _appIdTextField.text = @"38f5b2b0c68ac679";
    
//    _domainTextField.text = @"rd-dota0326.udesk.cn";
//    _appKeyTextField.text = @"3521453cdb70eabb125fd406a136b1cf";
//    _appIdTextField.text = @"04ad2dd06c5f5614";
    
//    _domainTextField.text = @"reocar.udeskdog.com";
//    _appKeyTextField.text = @"bdb76d84753f4afa70d4158a8798bbd4";
//    _appIdTextField.text = @"1727f609ae08f73a";
    
//    _domainTextField.text = @"reocar.udeskmonkey.com";
//    _appKeyTextField.text = @"f855bf60be6605fddb9d1236aeb532f2";
//    _appIdTextField.text = @"5fc1b2cc2d6fffb9";
    
//    _appKeyTextField.text = @"be591e8a8602d6de3a42802615a24bae";
//    _appIdTextField.text = @"428953553ae5ec0e";
//    _domainTextField.text = @"icarbonx.udesk.cn";
    
    _domainTextField.text = @"udesksdk.udesk.cn";
    _appKeyTextField.text = @"6c37f775019907785d85c027e29dae4e";
    _appIdTextField.text = @"cdc6da4fa97efc2c";
    
//    _domainTextField.text = @"udesksdk.udesk.cn";
//    _appKeyTextField.text = @"08919a2194e9844795c8f589854ad559";
//    _appIdTextField.text = @"6a424855941db2d1";
    
//    _domainTextField.text = @"brazil0326.udesk.cn";
//    _appKeyTextField.text = @"69b41d0ac1e71765a7cc0329fd739a72";
//    _appIdTextField.text = @"18eeecb7e45260ea";

//    _domainTextField.text = @"bdkj.udesk.cn";
//    _appKeyTextField.text = @"6ab28a0c2dc9695dcf8a199d5088f590";
//    _appIdTextField.text = @"5bebc87d68a7e425";
    
//    _domainTextField.text = @"reocar.udeskb1.com";
//    _appKeyTextField.text = @"61a9c9f960fc7262ec19ad49f5059dec";
//    _appIdTextField.text = @"dc3c5b073962fe29";
    
//    _domainTextField.text = @"reocar.tryudesk.com";
//    _appKeyTextField.text = @"0e7a8f4b856d062962620167c957548e";
//    _appIdTextField.text = @"87e0474c9aadabe1";
    
//    _domainTextField.text = @"reocar.udeskt3.com";
//    _appKeyTextField.text = @"a24ab9d44ecce6d028dc2f04759c129a";
//    _appIdTextField.text = @"2cdab9b756805a0b";


//    _domainTextField.text = @"reocar.udeskb3.com";
//    _appKeyTextField.text = @"a4033168606fb67b0afc749e10b56631";
//    _appIdTextField.text = @"3e045475e1f74112";
    
//    _domainTextField.text = @"rd-dota.udesk.cn";
//    _appKeyTextField.text = @"3521453cdb70eabb125fd406a136b1cf";
//    _appIdTextField.text = @"04ad2dd06c5f5614";
    
//    _domainTextField.text = @"reocar.udeskt1.com";
//    _appKeyTextField.text = @"9937cd5b63e98ecc34b984c658af60f2";
//    _appIdTextField.text = @"1966f16ac072ea71";
    
//    _domainTextField.text = @"udeskdemo8732.udesk.cn";
//    _appKeyTextField.text = @"5bef76d133a6c69c6d95287a26ccbc7f";
//    _appIdTextField.text = @"07c7cb9df80efc81";

    [appIdTextFieldBackGroundView addSubview:_appIdTextField];
    
    //登录
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginButton setTitle:@"开启" forState:UIControlStateNormal];
    loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:19];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginButton setBackgroundColor:[UIColor udColorWithHexString:@"#00CDFF"]];
    loginButton.frame = CGRectMake(20, appIdTextFieldBackGroundView.udBottom+40, (UD_SCREEN_WIDTH-40), 50);
    loginButton.titleLabel.textAlignment = UITextFieldViewModeAlways;
    [loginButton addTarget:self action:@selector(openUdesk:) forControlEvents:UIControlEventTouchUpInside];
    UDViewRadius(loginButton, 5);
    [self.view addSubview:loginButton];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView)];
    [self.view addGestureRecognizer:tap];
}

- (void)tapView {
    [self.view endEditing:YES];
}

- (void)openUdesk:(id)sender {
    
    if ([self checkInputValid]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:self.domainTextField.text forKey:@"domain"];
        [[NSUserDefaults standardUserDefaults] setObject:self.appKeyTextField.text forKey:@"key"];
        [[NSUserDefaults standardUserDefaults] setObject:self.appIdTextField.text forKey:@"appId"];
        
        NSString *sdk_token = [NSString stringWithFormat:@"%u",arc4random()];
       
        UdeskOrganization *organization = [[UdeskOrganization alloc] initWithDomain:self.domainTextField.text
                                                                             appKey:self.appKeyTextField.text
                                                                              appId:self.appIdTextField.text];
        
        UdeskCustomer *customer = [UdeskCustomer new];
        customer.sdkToken = sdk_token;
//        customer.nickName = @"测试一下";
        
//        UdeskCustomerCustomField *textField = [UdeskCustomerCustomField new];
//        textField.fieldKey = @"TextField_390";
//        textField.fieldValue = @"测试";
//
//        UdeskCustomerCustomField *selectField = [UdeskCustomerCustomField new];
//        selectField.fieldKey = @"SelectField_455";
//        selectField.fieldValue = @[@0];
//
//        customer.customField = @[textField,selectField];
        
        //初始化sdk
        [UdeskManager initWithOrganization:organization customer:customer];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UDFunctionViewController *function = [storyboard instantiateViewControllerWithIdentifier:@"UDFunctionViewControllerID"];
        
        [self.navigationController pushViewController:function animated:YES];
    }
    
}

//判断登录参数是否合法
- (BOOL)checkInputValid
{
    BOOL valid = YES;
    
    if (self.domainTextField.text.length == 0) {
        [self showTextMessage:self.domainTextField.placeholder];
        [self.domainTextField becomeFirstResponder];
        valid = NO;
    }
    else if (self.appKeyTextField.text.length == 0) {
        [self showTextMessage:self.appKeyTextField.placeholder];
        [self.appKeyTextField becomeFirstResponder];
        valid = NO;
    }
    else if (self.appIdTextField.text.length == 0) {
        [self showTextMessage:self.appIdTextField.placeholder];
        [self.appIdTextField becomeFirstResponder];
        valid = NO;
    }
    
    return valid;
}

- (void)showTextMessage:(NSString *)text {

    NSString *newText = [NSString stringWithFormat:@"请输入%@",text];
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:nil message:newText delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [view show];
}

@end
