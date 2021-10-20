//
//  UdeskSmallViewTestViewController.m
//  UdeskSDK
//
//  Created by xuchen on 2018/4/3.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskSmallViewTestViewController.h"
#import "Udesk.h"

@interface UdeskSmallViewTestViewController ()
@property (strong, nonatomic) IBOutlet UITextField *durationTextField;
@property (strong, nonatomic) IBOutlet UIButton *resolutionButton;
@property (strong, nonatomic) IBOutlet UILabel *resolutionLabel;

@property (nonatomic, assign) UDSmallVideoResolutionType type;

@end

@implementation UdeskSmallViewTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"小视频";
    self.view.backgroundColor = [UIColor whiteColor];
}

- (IBAction)resolutionAction:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请选择分辨率" preferredStyle:UIAlertControllerStyleActionSheet];
    if (ud_isPad) {
        //ipad适配
        [alert setModalPresentationStyle:UIModalPresentationPopover];
        UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
        popPresenter.sourceView = self.view;
        popPresenter.sourceRect = CGRectMake(self.view.center.x, 74, 1, 1);
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:@"640x480" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.resolutionLabel.text = @"640x480";
        self.type = UDSmallVideoResolutionType640x480;
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"1280x720" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.resolutionLabel.text = @"1280x720";
        self.type = UDSmallVideoResolutionType1280x720;
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"1920x1080" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.resolutionLabel.text = @"1920x1080";
        self.type = UDSmallVideoResolutionType1920x1080;
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"最高分辨率" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.resolutionLabel.text = @"最高分辨率";
        self.type = UDSmallVideoResolutionTypePhoto;
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)pushSDK:(id)sender {
 
    UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
    sdkConfig.smallVideoDuration = self.durationTextField.text.floatValue;
    sdkConfig.smallVideoResolution = self.type;
    
    //初始化sdk
    UdeskSDKManager *chatViewManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle customStyle] sdkConfig:sdkConfig];
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
