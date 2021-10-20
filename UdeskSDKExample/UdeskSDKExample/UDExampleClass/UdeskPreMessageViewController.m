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
@property (strong, nonatomic) IBOutlet UIButton *goodsMessageButton;

@end

@implementation UdeskPreMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //适配ios15
    if (@available(iOS 15.0, *)) {
        if(self.navigationController){
            UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
            // 背景色
            appearance.backgroundColor = [UIColor whiteColor];
            // 去掉半透明效果
            appearance.backgroundEffect = nil;
            // 去除导航栏阴影（如果不设置clear，导航栏底下会有一条阴影线）
            //        appearance.shadowColor = [UIColor clearColor];
            appearance.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
            self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
            self.navigationController.navigationBar.standardAppearance = appearance;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)appendGoodsMessage:(id)sender {
    [self.goodsMessageButton setTitle:@"商品消息+1" forState:UIControlStateNormal];
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
    if ([self.goodsMessageButton.titleLabel.text isEqualToString:@"商品消息+1"]) {
        [array addObject:[self getGoodsModel]];
    }
    sdkConfig.preSendMessages = array;
    
    //初始化sdk
    UdeskSDKManager *chatViewManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle customStyle] sdkConfig:sdkConfig];
    [chatViewManager pushUdeskInViewController:self completion:nil];
}

- (UdeskGoodsModel *)getGoodsModel {
    
    UdeskGoodsModel *goodsModel = [[UdeskGoodsModel alloc] init];
    goodsModel.name = @"订单：121看 谁的粉丝的疯狂";
    goodsModel.url = @"https://item.jd.com/6748052.html";
    goodsModel.imgUrl = @"https://img12.360buyimg.com/n1/s450x450_jfs/t10675/253/1344769770/66891/92d54ca4/59df2e7fN86c99a27.jpg";
    goodsModel.customParameters = @{@"type":@"测试啦",
                                    @"order":@"123"
                                    };
    
    UdeskGoodsParamModel *paramModel0 = [UdeskGoodsParamModel new];
    paramModel0.text = @" ";
    paramModel0.udBreak = @(1);
    
    UdeskGoodsParamModel *paramModel1 = [UdeskGoodsParamModel new];
    paramModel1.text = @"美丽新中国";
    paramModel1.color = @"#FF0000";
    paramModel1.fold = @(1);
    paramModel1.udBreak = @(1);
    paramModel1.size = @(13);
    
    UdeskGoodsParamModel *paramModel2 = [UdeskGoodsParamModel new];
    paramModel2.text = @"东风21₹2508kUDGoodsImageHorizontalSpacing";
    paramModel2.color = @"#c2fcc3";
    paramModel2.udBreak = @(1);
    paramModel2.size = @(13);
    paramModel2.fold = @(0);
    
    UdeskGoodsParamModel *paramModel3 = [UdeskGoodsParamModel new];
    paramModel3.text = @"-27% ";
    paramModel3.color = @"#ffffff";
    paramModel3.fold = @(0);
    paramModel3.udBreak = @(1);
    paramModel3.size = @(13);
    
    UdeskGoodsParamModel *paramModel4 = [UdeskGoodsParamModel new];
    paramModel4.text = @"1000+ Sold";
    paramModel4.color = @"#ffffff";
    paramModel4.fold = @(0);
    paramModel4.udBreak = @(0);
    paramModel4.size = @(13);
    
//    UdeskGoodsParamModel *paramModel1 = [UdeskGoodsParamModel new];
//    paramModel1.text = @"￥6999.00";
//    paramModel1.color = @"#FF0000";
//    paramModel1.fold = @(1);
//    paramModel1.udBreak = @(1);
//    paramModel1.size = @(14);
//
//    UdeskGoodsParamModel *paramModel2 = [UdeskGoodsParamModel new];
//    paramModel2.text = @"满1999元立减30元";
//    paramModel2.color = @"#c2fcc3";
//    paramModel2.fold = @(1);
//    paramModel2.size = @(12);
//
//    UdeskGoodsParamModel *paramModelx = [UdeskGoodsParamModel new];
//    paramModelx.text = @"还有优惠券";
//    paramModelx.color = @"#ffffff";
//    paramModelx.fold = @(1);
////    paramModelx.size = @(13);
//    paramModelx.udBreak = @(1);
    
//    goodsModel.params = @[paramModel1,paramModel2,paramModel3];
    goodsModel.params = @[paramModel1,paramModel2,paramModel3,paramModel4];

    return goodsModel;
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
