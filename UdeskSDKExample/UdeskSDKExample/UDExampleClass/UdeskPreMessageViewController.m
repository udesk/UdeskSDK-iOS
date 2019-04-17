//
//  UdeskPreMessageViewController.m
//  UdeskSDK
//
//  Created by xuchen on 2018/6/14.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskPreMessageViewController.h"
#import "UdeskHPGrowingTextView.h"
#import "Udesk.h"
#import "UdeskImagePickerController.h"

@interface UdeskPreMessageViewController ()<UdeskImagePickerControllerDelegate>
@property (strong, nonatomic) IBOutlet UIButton *albumButton;
@property (strong, nonatomic) IBOutlet UITextField *preTextField;

@end

@implementation UdeskPreMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)openAlbum:(id)sender {
    
    UdeskImagePickerController *imagePicker = [[UdeskImagePickerController alloc] init];
    imagePicker.maxImagesCount = 1;
    imagePicker.allowPickingVideo = NO;
    imagePicker.quality = 0.5f;
    imagePicker.pickerDelegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

// 如果选择发送了图片，下面的handle会被执行
- (void)imagePickerController:(UdeskImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos {
    
    UIImage *image = photos.firstObject;
    [self.albumButton setTitle:nil forState:UIControlStateNormal];
    [self.albumButton setImage:image forState:UIControlStateNormal];
}

- (IBAction)cleanPreImage:(id)sender {
 
    [self.albumButton setTitle:@"相册" forState:UIControlStateNormal];
    [self.albumButton setImage:nil forState:UIControlStateNormal];
}

- (IBAction)pushSDK:(id)sender {
    
    UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];

    NSMutableArray *array = [NSMutableArray array];
    if (self.preTextField.text.length > 0) {
        [array addObject:self.preTextField.text];
    }
    if (self.albumButton.imageView.image) {
        [array addObject:self.albumButton.imageView.image];
    }
    sdkConfig.preSendMessages = array;
    
    //初始化sdk
    UdeskSDKManager *chatViewManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle customStyle] sdkConfig:sdkConfig];
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
