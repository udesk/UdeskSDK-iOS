//
//  UdeskButtonConfigViewController.m
//  UdeskSDK
//
//  Created by xuchen on 2018/6/14.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskButtonConfigViewController.h"
#import "Udesk.h"
#import "UdeskCustomButtonTestViewController.h"

@interface UdeskButtonConfigViewController ()
@property (strong, nonatomic) IBOutlet UISwitch *albumSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *cameraSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *smallVideoSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *voiceSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *emotionSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *locationSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *sendVideoSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *imagePickerSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *customButtonSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *customButtonSurveySwitch;

@end

@implementation UdeskButtonConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"功能设置";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pushSDK:(id)sender {
    
    UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
    sdkConfig.showVoiceEntry = self.voiceSwitch.isOn;
    sdkConfig.showEmotionEntry = self.emotionSwitch.isOn;
    sdkConfig.showCameraEntry = self.cameraSwitch.isOn;
    sdkConfig.showAlbumEntry = self.albumSwitch.isOn;
    sdkConfig.showLocationEntry = self.locationSwitch.isOn;
    sdkConfig.allowShootingVideo = self.sendVideoSwitch.isOn;
    sdkConfig.smallVideoEnabled = self.smallVideoSwitch.isOn;
    sdkConfig.imagePickerEnabled = self.imagePickerSwitch.isOn;
    sdkConfig.showTopCustomButtonSurvey = self.customButtonSurveySwitch.isOn;
    sdkConfig.showCustomButtons = self.customButtonSwitch.isOn;
    
    UdeskCustomButtonConfig *buttonConfig1 = [[UdeskCustomButtonConfig alloc] initWithTitle:@"自定义按钮" image:nil type:UdeskCustomButtonConfigTypeInInputTop clickBlock:^(UdeskCustomButtonConfig *customButton, UdeskChatViewController *viewController) {
        
        UdeskProductOrdersViewController *orders = [[UdeskProductOrdersViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:orders];
        [viewController presentViewController:nav animated:YES completion:nil];
        
        orders.didSendOrderBlock = ^(UdeskOrderSendType sendType) {
            [UdeskCustomButtonTestViewController sendOrderWithType:sendType viewController:viewController];
        };
    }];
    
    UdeskCustomButtonConfig *buttonConfig2 = [[UdeskCustomButtonConfig alloc] initWithTitle:@"断开Socket" image:nil type:UdeskCustomButtonConfigTypeInInputTop clickBlock:^(UdeskCustomButtonConfig *customButton, UdeskChatViewController *viewController) {
        
        [UdeskManager setupCustomerOffline];
    }];
    
    UdeskCustomButtonConfig *buttonConfig3 = [[UdeskCustomButtonConfig alloc] initWithTitle:@"连接Socket" image:nil type:UdeskCustomButtonConfigTypeInInputTop clickBlock:^(UdeskCustomButtonConfig *customButton, UdeskChatViewController *viewController) {
        
        [UdeskManager setupCustomerOnline];
    }];
    
    sdkConfig.customButtons = @[buttonConfig1,buttonConfig2,buttonConfig3];
    
    //初始化sdk
    UdeskSDKManager *chatViewManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle] sdkConfig:sdkConfig];
    [chatViewManager pushUdeskInViewController:self completion:nil];
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
