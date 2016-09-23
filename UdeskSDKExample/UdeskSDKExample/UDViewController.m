//
//  UDViewController.m
//  UdeskSDK
//
//  Created by xuchen on 16/8/26.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UDViewController.h"
#import "UDFunctionViewController.h"
#import "UdeskManager.h"
#import "UdeskFoundationMacro.h"
#import "UIColor+UdeskSDK.h"
#import "UdeskViewExt.h"

@interface UDViewController()

@property (nonatomic, strong) UITextField *domainTextField;
@property (nonatomic, strong) UITextField *appKeyTextField;

@end

@implementation UDViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake((UD_SCREEN_WIDTH-226)/2, 70, 226, 91)];
    logo.image = [UIImage imageNamed:@"backGroundLogo"];
    [self.view addSubview:logo];
    
    UIView *accountTextFieldBackGroundView = [[UIView alloc] initWithFrame:CGRectMake(20, logo.ud_bottom+50, UD_SCREEN_WIDTH-40, 50)];
    accountTextFieldBackGroundView.backgroundColor = [UIColor colorWithHexString:@"3CA0D9"];
    UDViewRadius(accountTextFieldBackGroundView, 5);
    [self.view addSubview:accountTextFieldBackGroundView];
    
    
    //账号
    _domainTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, UD_SCREEN_WIDTH-100, 50)];
    _domainTextField.keyboardType = UIKeyboardTypeEmailAddress;
    
    NSString *domain;
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"domain"]) {
        domain = [[NSUserDefaults standardUserDefaults] stringForKey:@"domain"];
    }
    else {
        domain = @"showshow.udesk.cn";
    }
    
    _domainTextField.backgroundColor = [UIColor clearColor];
    _domainTextField.placeholder = @"域名";
    _domainTextField.textColor = [UIColor whiteColor];
    _domainTextField.text = domain;
    
    _domainTextField.text = @"udesksdk.udesk.cn";

    [accountTextFieldBackGroundView addSubview:_domainTextField];
    
    UIView *passwordTextFieldBackGroundView = [[UIView alloc] initWithFrame:CGRectMake(20, accountTextFieldBackGroundView.ud_bottom+11, UD_SCREEN_WIDTH-40, 50)];
    passwordTextFieldBackGroundView.backgroundColor = [UIColor colorWithHexString:@"3CA0D9"];
    UDViewRadius(passwordTextFieldBackGroundView, 5);
    [self.view addSubview:passwordTextFieldBackGroundView];
    
    
    //密码
    _appKeyTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 0, UD_SCREEN_WIDTH-100, 50)];
    _appKeyTextField.backgroundColor = [UIColor clearColor];
    _appKeyTextField.placeholder = @"APP Key";
    _appKeyTextField.textColor = [UIColor whiteColor];
    
    NSString *key;
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"key"]) {
        key = [[NSUserDefaults standardUserDefaults] stringForKey:@"key"];
    }
    else {
        key = @"c18d023ff18902fdfdb6ce15a11ef47b";
    }
    
    _appKeyTextField.text = key;
    
    _appKeyTextField.text = @"6c37f775019907785d85c027e29dae4e";

    [passwordTextFieldBackGroundView addSubview:_appKeyTextField];
    
    //登录
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginButton setTitle:@"开启" forState:UIControlStateNormal];
    loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:19];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginButton setBackgroundColor:[UIColor colorWithHexString:@"#00CDFF"]];
    loginButton.frame = CGRectMake(20, passwordTextFieldBackGroundView.ud_bottom+40, (UD_SCREEN_WIDTH-40), 50);
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
        
        [UdeskManager initWithAppkey:self.appKeyTextField.text domianName:self.domainTextField.text];
        
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
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
    
    return valid;
}

- (void)showTextMessage:(NSString *)text {

    NSString *newText = [NSString stringWithFormat:@"请输入%@",text];
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:nil message:newText delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [view show];
}

@end
