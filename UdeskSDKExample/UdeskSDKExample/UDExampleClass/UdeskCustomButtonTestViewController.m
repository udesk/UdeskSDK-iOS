//
//  UdeskCustomButtonTestViewController.m
//  UdeskSDK
//
//  Created by xuchen on 2018/3/23.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskCustomButtonTestViewController.h"
#import "Udesk.h"
#import "UdeskImagePickerController.h"

@interface UdeskCustomButtonTestViewController ()<UdeskImagePickerControllerDelegate>

@property (nonatomic, strong) NSMutableArray *customButtons;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;

@end

@implementation UdeskCustomButtonTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _customButtons = [NSMutableArray array];
    
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCustomButtonAction)];
    UIBarButtonItem *sdk = [[UIBarButtonItem alloc] initWithTitle:@"进入SDK" style:UIBarButtonItemStylePlain target:self action:@selector(pushUdesk)];
    
    self.navigationItem.rightBarButtonItems = @[add,sdk];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    self.tableView.tableFooterView = [UIView new];
}

- (void)pushUdesk {
    
    UdeskSDKConfig *config = [UdeskSDKConfig customConfig];
    config.showCustomButtons = YES;
    config.showTopCustomButtonSurvey = YES;
    config.customButtons = self.customButtons;
    
    UdeskSDKActionConfig *action = [UdeskSDKActionConfig new];
    action.goodsMessageClickBlock = ^(UdeskChatViewController *viewController, UdeskGoodsModel *goodsModel) {
        NSLog(@"%@",goodsModel.customParameters);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:goodsModel.url]];
    };
    
    //初始化sdk
    UdeskSDKManager *chatViewManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle customStyle] sdkConfig:config sdkActionConfig:action];
    [chatViewManager pushUdeskInViewController:self completion:nil];
}

- (void)addCustomButtonAction {
    
    UdeskCustomButtonConfig *buttonConfig = [[UdeskCustomButtonConfig alloc] initWithTitle:@"自定义按钮" image:nil type:UdeskCustomButtonConfigTypeInInputTop clickBlock:^(UdeskCustomButtonConfig *customButton, UdeskChatViewController *viewController) {
    
        UdeskProductOrdersViewController *orders = [[UdeskProductOrdersViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:orders];
        [viewController presentViewController:nav animated:YES completion:nil];

        orders.didSendOrderBlock = ^(UdeskOrderSendType sendType,UdeskGoodsModel *goodsModel) {
            [UdeskCustomButtonTestViewController sendOrderWithType:sendType viewController:viewController goodsModel:goodsModel];
        };
    }];
    [self.customButtons insertObject:buttonConfig atIndex:0];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请选择按钮位置" preferredStyle:0];
    if (ud_isPad) {
        //ipad适配
        [alert setModalPresentationStyle:UIModalPresentationPopover];
        UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
        popPresenter.sourceView = self.view;
        popPresenter.sourceRect = CGRectMake(self.view.center.x, 74, 1, 1);
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"输入栏上方" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        buttonConfig.type = UdeskCustomButtonConfigTypeInInputTop;
        [self.tableView reloadData];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"更多内部" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        buttonConfig.type = UdeskCustomButtonConfigTypeInMoreView;
        [self.tableView reloadData];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

+ (void)sendOrderWithType:(UdeskOrderSendType)sendType viewController:(UdeskChatViewController *)viewController goodsModel:(UdeskGoodsModel *)goodsModel {
    
    //以下数据都是伪造的，实际开发已真实为例
    switch (sendType) {
        case UdeskOrderSendTypeText:
            
            [viewController sendTextMessageWithContent:@"测试自定义按钮回调发送文本信息"];
            break;
        case UdeskOrderSendTypeImage:
            
            [viewController sendImageMessageWithImage:[UIImage imageNamed:@"avatar"]];
            break;
        case UdeskOrderSendTypeVideo:
            
            [viewController sendVideoMessageWithVideoFile:[[NSBundle mainBundle] pathForResource:@"889" ofType:@"mp4"]];
            break;
        case UdeskOrderSendTypeVoice:
            
            [viewController sendVoiceMessageWithVoicePath:[[NSBundle mainBundle] pathForResource:@"002" ofType:@"aac"] voiceDuration:@"3"];
            break;
        case UdeskOrderSendTypeGIF:{
            
            NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"001" ofType:@"gif"]];
            [viewController sendGIFMessageWithGIFData:data];
            break;
        }
        case UdeskOrderSendTypeLocation:{
            
            UdeskLocationModel *model = [[UdeskLocationModel alloc] init];
            model.name = @"成铭大厦";
            model.image = [UIImage imageNamed:@"003"];
            model.longitude = 116.356796;
            model.latitude = 39.939559;
            [viewController sendLoactionMessageWithModel:model];
            break;
        }
        case UdeskOrderSendTypeGoods:{
            
            [viewController sendGoodsMessageWithModel:goodsModel];
            break;
        }
        default:
            break;
    }
}

- (UdeskGoodsModel *)getGoodsModel {
    
    UdeskGoodsModel *goodsModel = [[UdeskGoodsModel alloc] init];
    goodsModel.name = @"Apple iPhone X (A1903) 64GB 深空灰色 移动联通4G手机";
    goodsModel.url = @"https://item.jd.com/6748052.html";
    goodsModel.imgUrl = @"http://img12.360buyimg.com/n1/s450x450_jfs/t10675/253/1344769770/66891/92d54ca4/59df2e7fN86c99a27.jpg";
    
    UdeskGoodsParamModel *paramModel1 = [UdeskGoodsParamModel new];
    paramModel1.text = @"￥6999.00";
    paramModel1.color = @"#FF0000";
    paramModel1.fold = @(1);
    paramModel1.udBreak = @(1);
    paramModel1.size = @(14);
    
    UdeskGoodsParamModel *paramModel2 = [UdeskGoodsParamModel new];
    paramModel2.text = @"满1999元立减30元";
    paramModel2.color = @"#c2fcc3";
    paramModel2.fold = @(1);
    paramModel2.size = @(12);
    
    UdeskGoodsParamModel *paramModel3 = [UdeskGoodsParamModel new];
    paramModel3.text = @"还有优惠券";
    paramModel3.color = @"#ffffff";
    paramModel3.fold = @(1);
    paramModel3.size = @(20);
    
    goodsModel.params = @[paramModel1,paramModel2,paramModel3];
    
    return goodsModel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.customButtons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    UdeskCustomButtonConfig *config = self.customButtons[indexPath.row];
    cell.imageView.image = config.image;
    
    if (config.type == UdeskCustomButtonConfigTypeInInputTop) {
        cell.textLabel.text = [config.title stringByAppendingPathComponent:@"（我在输入框上面）"];
    }
    else {
        cell.textLabel.text = [config.title stringByAppendingPathComponent:@"（我在更多里面）"];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.customButtons removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    _currentIndexPath = indexPath;
    
    UdeskCustomButtonConfig *config = self.customButtons[_currentIndexPath.row];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请选择需要修改的内容" preferredStyle:0];
    if (ud_isPad) {
        //ipad适配
        [alert setModalPresentationStyle:UIModalPresentationPopover];
        UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
        popPresenter.sourceView = self.view;
        popPresenter.sourceRect = CGRectMake(self.view.center.x, 74, 1, 1);
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
        UdeskImagePickerController *imagePicker = [[UdeskImagePickerController alloc] init];
        imagePicker.maxImagesCount = 1;
        imagePicker.allowPickingVideo = NO;
        imagePicker.quality = sdkConfig.quality;
        imagePicker.pickerDelegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"标题" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请输入标题" preferredStyle:1];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UITextField *textField = alert.textFields.firstObject;
            config.title = textField.text;
            [self.tableView reloadData];
        }]];
        
        [alert addTextFieldWithConfigurationHandler:nil];
        
        [self presentViewController:alert animated:YES completion:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

// 如果选择发送了图片，下面的handle会被执行
- (void)imagePickerController:(UdeskImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos {
    
    UIImage *image = photos.firstObject;
    UdeskCustomButtonConfig *config = self.customButtons[_currentIndexPath.row];
    config.image = image;
    [self.tableView reloadData];
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
