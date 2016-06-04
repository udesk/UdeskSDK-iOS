//
//  DomainKeyViewController.m
//  UdeskSDK
//
//  Created by xuchen on 16/3/25.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "DomainKeyViewController.h"
#import "UdeskFoundationMacro.h"
#import "UdeskViewExt.h"
#import "ViewController.h"
#import "UDManager.h"

#define UD_DOMAIN        @"UD_DOMAIN"
#define UD_KEY       @"UD_KEY"

@interface DomainKeyViewController()

@property (nonatomic, strong)UITextField *accountTextField;
@property (nonatomic, strong)UITextField *passwordTextField;

@end

@implementation DomainKeyViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(tapAction)];
    [self.view addGestureRecognizer:tapGesture];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    self.accountTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 20, UD_SCREEN_WIDTH, 50)];
    self.accountTextField.keyboardType = UIKeyboardTypeEmailAddress;
    self.accountTextField.backgroundColor = [UIColor whiteColor];
    self.accountTextField.placeholder = @"请输入公司域名";
    self.accountTextField.clearButtonMode = UITextFieldViewModeAlways;
    self.accountTextField.textAlignment = NSTextAlignmentCenter;
    
    self.accountTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:UD_DOMAIN];
    
    [self.view addSubview:self.accountTextField];
    
    self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, self.accountTextField.ud_bottom+20, UD_SCREEN_WIDTH, 50)];
    self.passwordTextField.keyboardType = UIKeyboardTypeEmailAddress;
    self.passwordTextField.backgroundColor = [UIColor whiteColor];
    self.passwordTextField.placeholder = @"请输入公司密钥";
    self.passwordTextField.clearButtonMode = UITextFieldViewModeAlways;
    self.passwordTextField.textAlignment = NSTextAlignmentCenter;
    self.passwordTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:UD_KEY];
    
    [self.view addSubview:self.passwordTextField];
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.frame = CGRectMake((UD_SCREEN_WIDTH-130)/2, self.passwordTextField.ud_bottom+20, 130, 40);
    [loginButton setTitle:@"确定" forState:0];
    loginButton.backgroundColor = UDRGBCOLOR(31, 166, 255);
    UDViewRadius(loginButton, 3);
    [loginButton addTarget:self action:@selector(loginButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    
    
}

- (void)tapAction {
    
    [self.accountTextField resignFirstResponder];
    
    [self.passwordTextField resignFirstResponder];
}

- (BOOL)checkInputValid
{
    BOOL valid = YES;
    
    if (self.accountTextField.text.length == 0) {

        [self.accountTextField becomeFirstResponder];
        valid = NO;
    }
    else if (self.passwordTextField.text.length == 0) {

        [self.passwordTextField becomeFirstResponder];
        valid = NO;
    }
    
    return valid;
}


- (void)loginButtonAction {

    if ([self checkInputValid]) {
        
        [self setField:self.passwordTextField forKey:UD_KEY];
        [self setField:self.accountTextField forKey:UD_DOMAIN];
        
        [UDManager initWithAppkey:self.passwordTextField.text domianName:self.accountTextField.text];
        
        ViewController *vc = [[ViewController alloc] init];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (void)setField:(UITextField *)field forKey:(NSString *)key
{
    if (field.text != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:field.text forKey:key];
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (ud_isIOS6) {
        self.navigationController.navigationBar.tintColor = Config.iMNavigationColor;
    } else {
        self.navigationController.navigationBar.barTintColor = Config.iMNavigationColor;
        self.navigationController.navigationBar.tintColor = Config.iMBackButtonColor;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    
    if (ud_isIOS6) {
        self.navigationController.navigationBar.tintColor = Config.oneSelfNavcigtionColor;
    } else {
        self.navigationController.navigationBar.barTintColor = Config.oneSelfNavcigtionColor;
    }
    
}


@end
