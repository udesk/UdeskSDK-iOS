//
//  UdeskRobotCustomInfoViewController.m
//  UdeskSDK
//
//  Created by xuchen on 2018/5/24.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskRobotCustomInfoViewController.h"
#import "Udesk.h"

@interface UdeskRobotCustomInfoViewController ()
@property (strong, nonatomic) IBOutlet UITextField *name;
@property (strong, nonatomic) IBOutlet UITextField *email;
@property (strong, nonatomic) IBOutlet UITextField *phone;
@property (strong, nonatomic) IBOutlet UITextField *desc;
@property (strong, nonatomic) IBOutlet UITextField *org;
@property (strong, nonatomic) IBOutlet UITextField *tag;
@property (strong, nonatomic) IBOutlet UITextField *owner;
@property (strong, nonatomic) IBOutlet UITextField *leave;
@property (strong, nonatomic) IBOutlet UITextField *ownerGroup;
@property (strong, nonatomic) IBOutlet UITextField *otherEmail;
@property (strong, nonatomic) IBOutlet UITextField *oneCustomFieldTitle;
@property (strong, nonatomic) IBOutlet UITextField *oneCustomFieldValue;
@property (strong, nonatomic) IBOutlet UITextField *twoCustomFieldTitle;
@property (strong, nonatomic) IBOutlet UITextField *twoCustomFieldValue;

@end

@implementation UdeskRobotCustomInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"进入SDK" style:UIBarButtonItemStylePlain target:self action:@selector(pushUdeskSDK)];
}

- (void)pushUdeskSDK {
    
    NSString *robotCustomerInfo = @"";
    if (self.name.text.length > 0) {
        robotCustomerInfo = [NSString stringWithFormat:@"c_name=%@",self.name.text];
    }
    
    if (self.email.text.length > 0) {
        robotCustomerInfo = [robotCustomerInfo stringByAppendingString:[NSString stringWithFormat:@"&c_email=%@",self.email.text]];
    }
    
    if (self.phone.text.length > 0) {
        robotCustomerInfo = [robotCustomerInfo stringByAppendingString:[NSString stringWithFormat:@"&c_phone=%@",self.phone.text]];
    }
    
    if (self.desc.text.length > 0) {
        robotCustomerInfo = [robotCustomerInfo stringByAppendingString:[NSString stringWithFormat:@"&c_desc=%@",self.desc.text]];
    }
    
    if (self.org.text.length > 0) {
        robotCustomerInfo = [robotCustomerInfo stringByAppendingString:[NSString stringWithFormat:@"&c_org=%@",self.org.text]];
    }
    
    if (self.tag.text.length > 0) {
        robotCustomerInfo = [robotCustomerInfo stringByAppendingString:[NSString stringWithFormat:@"&c_tags=%@",self.tag.text]];
    }
    
    if (self.owner.text.length > 0) {
        robotCustomerInfo = [robotCustomerInfo stringByAppendingString:[NSString stringWithFormat:@"&c_owner=%@",self.owner.text]];
    }
    
    if (self.leave.text.length > 0) {
        robotCustomerInfo = [robotCustomerInfo stringByAppendingString:[NSString stringWithFormat:@"&c_vip=%@",self.leave.text]];
    }
    
    if (self.ownerGroup.text.length > 0) {
        robotCustomerInfo = [robotCustomerInfo stringByAppendingString:[NSString stringWithFormat:@"&c_owner_group=%@",self.ownerGroup.text]];
    }
    
    if (self.otherEmail.text.length > 0) {
        robotCustomerInfo = [robotCustomerInfo stringByAppendingString:[NSString stringWithFormat:@"&c_other_emails=%@",self.otherEmail.text]];
    }
    
    if (self.oneCustomFieldTitle.text.length > 0 && self.oneCustomFieldValue.text.length > 0) {
        robotCustomerInfo = [robotCustomerInfo stringByAppendingString:[NSString stringWithFormat:@"&c_cf_%@=%@",self.oneCustomFieldTitle.text,self.oneCustomFieldValue.text]];
    }
    
    if (self.twoCustomFieldTitle.text.length > 0 && self.twoCustomFieldValue.text.length > 0) {
        robotCustomerInfo = [robotCustomerInfo stringByAppendingString:[NSString stringWithFormat:@"&c_cf_%@=%@",self.twoCustomFieldTitle.text,self.twoCustomFieldValue.text]];
    }
    
    UdeskOrganization *organization = [[UdeskOrganization alloc] initWithDomain:[UdeskManager domain]
                                                                         appKey:[UdeskManager key]
                                                                          appId:[UdeskManager appId]];
    
    UdeskCustomer *customer = [UdeskCustomer new];
    customer.nickName = self.name.text;
    customer.sdkToken = [NSString stringWithFormat:@"%u",arc4random()];
    //初始化sdk
    [UdeskManager initWithOrganization:organization customer:customer];
    
    [UdeskManager updateCustomer:customer completion:nil];
    
    UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
    sdkConfig.robotCustomerInfo = robotCustomerInfo;
    
    //初始化sdk
    UdeskSDKManager *chatViewManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle] sdkConfig:sdkConfig];
    [chatViewManager pushUdeskInViewController:self completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
