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
    
    _domainTextField.text = @"udesksdk.udesk.cn";
    _appKeyTextField.text = @"6c37f775019907785d85c027e29dae4e";
    _appIdTextField.text = @"cdc6da4fa97efc2c";

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
