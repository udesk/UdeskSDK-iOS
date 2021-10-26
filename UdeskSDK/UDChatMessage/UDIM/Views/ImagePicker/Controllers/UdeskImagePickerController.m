//
//  UdeskImagePickerController.m
//  UdeskImagePickerController
//
//  Created by xuchen on 2018/3/6.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskImagePickerController.h"
#import "UdeskAssetsPickerController.h"
#import "UdeskSDKConfig.h"

@interface UdeskImagePickerController ()

@end

@implementation UdeskImagePickerController

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [UdeskSDKConfig customConfig].orientationMask;
}

- (instancetype)init
{
    UdeskAssetsPickerController *albumsVC = [[UdeskAssetsPickerController alloc] init];
    self = [super initWithRootViewController:albumsVC];
    if (self) {
        
        [self setup];
    }
    return self;
}

- (void)setup {

    NSDictionary *attr = @{NSForegroundColorAttributeName : [UdeskSDKConfig customConfig].sdkStyle.albumTitleColor};
    self.navigationBar.titleTextAttributes = attr;
    self.navigationBar.barTintColor = [UdeskSDKConfig customConfig].sdkStyle.albumNavBgColor;
//    self.navigationBar.tintColor = [UdeskSDKConfig customConfig].sdkStyle.albumBackColor;
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        appearance.backgroundColor = [UdeskSDKConfig customConfig].sdkStyle.albumNavBgColor;
        appearance.backgroundEffect = nil;
        appearance.titleTextAttributes = @{NSForegroundColorAttributeName:[UdeskSDKConfig customConfig].sdkStyle.albumTitleColor};
        self.navigationBar.scrollEdgeAppearance = appearance;
        self.navigationBar.standardAppearance = appearance;
    }
    
    self.quality = [UdeskSDKConfig customConfig].quality;
    self.maxImagesCount = [UdeskSDKConfig customConfig].maxImagesCount;
    self.allowPickingVideo = [UdeskSDKConfig customConfig].allowPickingVideo;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray<UdeskAssetModel *> *)selectedModels {
    if (!_selectedModels) {
        _selectedModels = [NSMutableArray array];
    }
    return _selectedModels;
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
