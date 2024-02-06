//
//  UDDeveloperViewController.m
//  UdeskSDK
//
//  Created by Udesk on 16/8/27.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UDDeveloperViewController.h"
#import "Udesk.h"
#import "UDAgentWebViewController.h"
#import "UdeskCustomButtonTestViewController.h"
#import "UdeskSmallViewTestViewController.h"
#import "UdeskButtonConfigViewController.h"
#import "UdeskPreMessageViewController.h"
#import "UdeskCustomCustomerTableViewController.h"

static NSString *kUdeskDeveloperCellId = @"kUdeskDeveloperCellId";

@interface UDDeveloperViewController()<UIActionSheetDelegate> {

    NSArray *_developerDataArray;
}

@end

@implementation UDDeveloperViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"UdeskSDK";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _developerDataArray = @[
                       @"指定分配客服",
                       @"指定分配客服组",
                       @"获取未读消息",
                       @"获取未读消息数量",
                       @"清空未读消息",
                       @"自定义客户信息",
                       @"添加咨询对象",
                       @"切换语言",
                       @"web客服",
                       @"配置自定义按钮",
                       @"小视频",
                       @"横竖屏兼容",
                       @"自定义表情",
                       @"其他功能配置",
                       @"放弃排队方式",
                       @"预发消息",
                       ];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.rowHeight = 60;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kUdeskDeveloperCellId];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _developerDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kUdeskDeveloperCellId forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = _developerDataArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //取消点击效果
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
            //指定分配客服
            [self assignedAgent];
            break;
        case 1:
            //指定分配客服组
            [self assignedGroup];
            break;
        case 2:
            //显示未读消息
            [self unreadMessage];
            break;
        case 3:
            //未读消息条数
            [self unreadMsgCount];
            break;
        case 4:
            //清空未读消息
            [self markUnreadMsg];
            break;
        case 5:
            //自定义客户信息
            [self customCustomerInfo];
            break;
        case 6:
            //咨询对象
            [self sdkProduct];
            break;
        case 7:
            //更换
            [self replaceLanguage];
            break;
        case 8:
            //web客服
            [self webAgent];
            break;
        case 9:
            //配置自定义按钮
            [self configCustomButton];
            break;
        case 10:
            //配置小视频
            [self configSmartVideo];
            break;
        case 11:
            //配置转向
            [self configSDKOrientation];
            break;
        case 12:
            //自定义表情
            [self customEmoji];
            break;
        case 13:
            //配置其他功能
            [self sdkConfigOtherFeatures];
            break;
        case 14:
            //放弃排队方式
            [self configQuitQueueType];
            break;
        case 15:
            //配置预发
            [self configPreMessage];
            break;
        default:
            break;
    }
    
}

//指定分配客服
- (void)assignedAgent {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"指定分配客服" message:@"注意：如果你已经与客服对话并且客服没有结束你的会话，指定分配客服将会无效。\n如果需要设置本地指定分配，请关闭后台配置的客服导航栏菜单" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addTextFieldWithConfigurationHandler:nil];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField *textField = alert.textFields.firstObject;
        if (textField.text.length) {
            
            UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
            sdkConfig.agentId = textField.text;
            
            UdeskSDKManager *chatViewManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle customStyle] sdkConfig:sdkConfig];
            [chatViewManager pushUdeskInViewController:self completion:nil];
        }
        else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请输入ID" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

//指定分配客服组
- (void)assignedGroup {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"指定分配客服组" message:@"注意：如果你已经与客服对话并且客服没有结束你的会话，指定分配客服将会无效。\n如果需要设置本地指定分配，请关闭后台配置的客服导航栏菜单" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addTextFieldWithConfigurationHandler:nil];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField *textField = alert.textFields.firstObject;
        if (textField.text.length) {
            
            UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
            sdkConfig.groupId = textField.text;
            
            UdeskSDKManager *chatViewManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle customStyle] sdkConfig:sdkConfig];
            [chatViewManager pushUdeskInViewController:self completion:nil];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入ID" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertView show];
        }
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

//未读消息
- (void)unreadMessage {
    
    NSArray *array = [UdeskManager getLocalUnreadeMessages];
    NSString *message;
    
    for (int i = 0; i<array.count; i++) {
        if (i<10) {
            UdeskMessage *model = array[i];
            if (!message) {
                message = [NSString stringWithFormat:@"1.%@",model.content];
            }
            else {
                message = [NSString stringWithFormat:@"%@\n%d.%@",message,i+1,model.content];
            }
        }
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"未读消息(这里只展示最近10条)" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alertView show];
}

//未读消息条数
- (void)unreadMsgCount {
    
    NSString *title = [NSString stringWithFormat:@"当前会话有 %ld 条未读",(long)[UdeskManager getLocalUnreadeMessagesCount]];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alertView show];
}

//清空未读消息
- (void)markUnreadMsg {
    
    [UdeskManager markAllMessagesAsRead];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"清空成功" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alertView show];
}

//自定义客户信息
- (void)customCustomerInfo {
    
    UdeskCustomCustomerTableViewController *custom = [[UdeskCustomCustomerTableViewController alloc] init];
    [self.navigationController pushViewController:custom animated:YES];
}

//咨询对象
- (void)sdkProduct {
    
    NSDictionary *dict = @{
                           @"productImageUrl":@"http://qn-im.udesk.cn/IMG_2884_1535020704_288.JPG",
                           @"productTitle":@"测试测试测试测你测试测试测你测试测试测你测试测试测你测试测试测你测试测试测你！",
                           @"productDetail":@"¥88888.088888.088888.0",
                           @"productURL":@"http://www.baidu.com"
                           };
    UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
    sdkConfig.productDictionary = dict;
    
    UdeskSDKManager *chatViewManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle customStyle] sdkConfig:sdkConfig];
    [chatViewManager pushUdeskInViewController:self completion:nil];
}

- (void)replaceLanguage{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"设置多语言" message:@"注意:多语言同时需要后端支持, 前后端默认值逻辑不同; 常用设置如下 zh-cn:中文简体;ar:阿拉伯语;en-us:英语;es:西班牙语;fr:法语;ja:日语;ko:朝鲜语/韩语;th:泰语;id:印度尼西亚语;zh-TW:繁体中文;pt:葡萄牙语;ru:俄语;" preferredStyle:UIAlertControllerStyleAlert];
    if (ud_isPad) {
        //ipad适配
        [alert setModalPresentationStyle:UIModalPresentationPopover];
        UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
        popPresenter.sourceView = self.view;
        popPresenter.sourceRect = CGRectMake(self.view.center.x, 74, 1, 1);
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addTextFieldWithConfigurationHandler:nil];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField *textField = alert.textFields.firstObject;
        if (textField.text.length) {
            [UdeskSDKConfig customConfig].language = textField.text;
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入语言代码" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertView show];
        }
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

//web客服
- (void)webAgent {
    
    UDAgentWebViewController *web = [[UDAgentWebViewController alloc] init];
    [self.navigationController pushViewController:web animated:YES];
}

//自定义配置按钮
- (void)configCustomButton {
    
    UdeskCustomButtonTestViewController *custom = [[UdeskCustomButtonTestViewController alloc] init];
    [self.navigationController pushViewController:custom animated:YES];
}

//配置小视频
- (void)configSmartVideo {
    
    UdeskSmallViewTestViewController *custom = [[UdeskSmallViewTestViewController alloc] init];
    [self.navigationController pushViewController:custom animated:YES];
}

//配置方向
- (void)configSDKOrientation {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"强制横竖屏" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (ud_isPad) {
        //ipad适配
        [alert setModalPresentationStyle:UIModalPresentationPopover];
        UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
        popPresenter.sourceView = self.view;
        popPresenter.sourceRect = CGRectMake(self.view.center.x, 74, 1, 1);
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:@"竖屏" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
        sdkConfig.orientationMask = UIInterfaceOrientationMaskPortrait;
        
        UdeskSDKManager *chatViewManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle customStyle] sdkConfig:sdkConfig];
        [chatViewManager presentUdeskInViewController:self completion:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"横屏" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
        sdkConfig.orientationMask = UIInterfaceOrientationMaskLandscape;
        UdeskSDKManager *chatViewManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle customStyle] sdkConfig:sdkConfig];
        [chatViewManager presentUdeskInViewController:self completion:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

//自定义表情
- (void)customEmoji {
    
    UdeskEmojiPanelModel *model = [UdeskEmojiPanelModel new];
    model.emojiIcon = [UIImage imageNamed:@"likeSticker"];
    model.stickerPaths = @[
                           [[NSBundle mainBundle] pathForResource:@"angry"ofType:@"png"],
                           [[NSBundle mainBundle] pathForResource:@"cry"ofType:@"png"],
                           [[NSBundle mainBundle] pathForResource:@"dead"ofType:@"png"],
                           [[NSBundle mainBundle] pathForResource:@"embarrass"ofType:@"png"],
                           [[NSBundle mainBundle] pathForResource:@"happy"ofType:@"png"],
                           [[NSBundle mainBundle] pathForResource:@"joy"ofType:@"png"],
                           [[NSBundle mainBundle] pathForResource:@"love"ofType:@"png"],
                           [[NSBundle mainBundle] pathForResource:@"sad"ofType:@"png"],
                           [[NSBundle mainBundle] pathForResource:@"shy"ofType:@"png"],
                           [[NSBundle mainBundle] pathForResource:@"sleepy"ofType:@"png"],
                           [[NSBundle mainBundle] pathForResource:@"surprise"ofType:@"png"],
                           [[NSBundle mainBundle] pathForResource:@"wink"ofType:@"png"],
                           ];
    model.stickerTitles = @[@"愤怒",@"愤怒",@"哭泣",@"糟糕",@"冷汗",@"大笑",@"可爱",@"爱",@"流汗",@"害羞",@"睡觉",@"惊讶",@"调皮"];
    
    UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
    sdkConfig.customEmojis = @[model];
    
    //初始化sdk
    UdeskSDKManager *chatViewManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle customStyle] sdkConfig:sdkConfig];
    [chatViewManager pushUdeskInViewController:self completion:nil];
}

//配置其他功能
- (void)sdkConfigOtherFeatures {
    
    UdeskButtonConfigViewController *config = [[UdeskButtonConfigViewController alloc] init];
    [self.navigationController pushViewController:config animated:YES];
}

//放弃排队方式
- (void)configQuitQueueType {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"放弃排队方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (ud_isPad) {
        //ipad适配
        [alert setModalPresentationStyle:UIModalPresentationPopover];
        UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
        popPresenter.sourceView = self.view;
        popPresenter.sourceRect = CGRectMake(self.view.center.x, 74, 1, 1);
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"标记放弃" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
        sdkConfig.quitQueueMode = @"mark";
        UdeskSDKManager *chatViewManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle customStyle] sdkConfig:sdkConfig];
        [chatViewManager pushUdeskInViewController:self completion:nil];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消标记" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
        sdkConfig.quitQueueMode = @"cannel_mark";
        UdeskSDKManager *chatViewManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle customStyle] sdkConfig:sdkConfig];
        [chatViewManager pushUdeskInViewController:self completion:nil];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"强制立即放弃" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UdeskSDKConfig *sdkConfig = [UdeskSDKConfig customConfig];
        sdkConfig.quitQueueMode = @"force_quit";
        UdeskSDKManager *chatViewManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle customStyle] sdkConfig:sdkConfig];
        [chatViewManager pushUdeskInViewController:self completion:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

//配置预发消息
- (void)configPreMessage {
    
    UdeskPreMessageViewController *config = [[UdeskPreMessageViewController alloc] init];
    [self.navigationController pushViewController:config animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}


@end
