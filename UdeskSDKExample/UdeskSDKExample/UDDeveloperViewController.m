//
//  UDDeveloperViewController.m
//  UdeskSDK
//
//  Created by xuchen on 16/8/27.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UDDeveloperViewController.h"
#import "UdeskAlertController.h"
#import "Udesk.h"
#import "UIColor+UdeskSDK.h"
#import "UdeskTransitioningAnimation.h"
#import "UDCustomClientInfoViewController.h"
#import "UdeskSDKConfig.h"
#import "UDLanguageViewController.h"

@interface UDDeveloperViewController() {

    NSArray *developerDataArray;
    NSArray *developerImageArray;
}

@end

@implementation UDDeveloperViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    developerDataArray = @[
                       @"指定分配客服",
                       @"指定分配客服组",
                       @"获取未读消息",
                       @"获取未读消息数量",
                       @"自定义客户信息",
                       @"更换UI模版",
                       @"客服导航栏菜单",
                       @"添加咨询对象",
                       @"切换语言",
                       ];
    
    developerImageArray = @[
                            [UIImage imageNamed:@"agent"],
                            [UIImage imageNamed:@"group"],
                            [UIImage imageNamed:@"notReadMessage"],
                            [UIImage imageNamed:@"notReadCount"],
                            [UIImage imageNamed:@"custom"],
                            [UIImage imageNamed:@"changeUI"],
                            [UIImage imageNamed:@"agentMenu"],
                            [UIImage imageNamed:@"product"],
                            [UIImage imageNamed:@"product"],
                            ];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, 10.f)];
    footerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footerView;
    self.tableView.rowHeight = 60;
    UIScreenEdgePanGestureRecognizer *popRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePopRecognizer:)];
    popRecognizer.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:popRecognizer];
}
//滑动返回
- (void)handlePopRecognizer:(UIScreenEdgePanGestureRecognizer*)recognizer {

    CGPoint translation = [recognizer translationInView:self.view];
    CGFloat xPercent = translation.x / CGRectGetWidth(self.view.bounds) * 0.7;
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            [UdeskTransitioningAnimation setInteractive:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case UIGestureRecognizerStateChanged:
            [UdeskTransitioningAnimation updateInteractiveTransition:xPercent];
            break;
        default:
            if (xPercent < .25) {
                [UdeskTransitioningAnimation cancelInteractiveTransition];
            } else {
                [UdeskTransitioningAnimation finishInteractiveTransition];
            }
            [UdeskTransitioningAnimation setInteractive:NO];
            break;
    }
    
}
//点击返回
- (void)dismissChatViewController {

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.view.window.layer addAnimation:[UdeskTransitioningAnimation createDismissingTransiteAnimation:UDTransiteAnimationTypePush] forKey:nil];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return developerDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *developerCellId =  @"developerCellId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:developerCellId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:developerCellId];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.image = developerImageArray[indexPath.row];
    cell.textLabel.text = developerDataArray[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //取消点击效果
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0: {
            
            NSString *title = @"指定分配客服";
            
            UdeskAlertController *inputAgentIdAlert = [UdeskAlertController alertWithTitle:title message:@"注意：如果你已经与客服对话并且客服没有结束你的会话，指定分配客服将会无效。"];
            __weak UdeskAlertController *weakInputAgentIdAlert = inputAgentIdAlert;
            
            [inputAgentIdAlert addCloseActionWithTitle:@"取消" Handler:^(UdeskAlertAction * _Nonnull action) {
                [weakInputAgentIdAlert.textField resignFirstResponder];
            }];
            [inputAgentIdAlert addAction:[UdeskAlertAction actionWithTitle:@"确定" handler:^(UdeskAlertAction * _Nonnull action) {
                
                if (weakInputAgentIdAlert.textField.text.length) {
                    
                    UdeskSDKManager *chatViewManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle]];
                    [chatViewManager setScheduledAgentId:weakInputAgentIdAlert.textField.text];
                    [chatViewManager pushUdeskViewControllerWithType:UdeskIM viewController:self];
                }
                else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入ID" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                    [alertView show];
                }
            }]];
            
            [inputAgentIdAlert addTextFieldWithConfigurationHandler:nil];
            [inputAgentIdAlert showWithSender:nil controller:nil animated:YES completion:NULL];
            
            break;
        }
        case 1: {
            
            NSString *title = @"指定分配客服组";
            
            UdeskAlertController *inputGroupIdAlert = [UdeskAlertController alertWithTitle:title message:@"注意：如果你已经与客服对话并且客服没有结束你的会话，指定分配客服将会无效。"];
            __weak UdeskAlertController *weakInputGroupIdAlert = inputGroupIdAlert;
            
            [inputGroupIdAlert addCloseActionWithTitle:@"取消" Handler:^(UdeskAlertAction * _Nonnull action) {
                [weakInputGroupIdAlert.textField resignFirstResponder];
            }];
            
            [inputGroupIdAlert addAction:[UdeskAlertAction actionWithTitle:@"确定" handler:^(UdeskAlertAction * _Nonnull action) {
                
                [weakInputGroupIdAlert.textField resignFirstResponder];
                
                if (weakInputGroupIdAlert.textField.text.length) {
                    
                    UdeskSDKManager *chatViewManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle]];
                    [chatViewManager setScheduledGroupId:weakInputGroupIdAlert.textField.text];
                    [chatViewManager pushUdeskViewControllerWithType:UdeskIM viewController:self];
                }
                else {
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入ID" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                    [alertView show];
                }
            }]];
            
            [inputGroupIdAlert addTextFieldWithConfigurationHandler:nil];
            
            [inputGroupIdAlert showWithSender:nil controller:nil animated:YES completion:NULL];
            
            break;
        }
        case 2: {
        
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

             UdeskAlertController *unreadeMessagesAlert = [UdeskAlertController alertWithTitle:@"未读消息(这里只展示最近10条)" message:message];
            [unreadeMessagesAlert addCloseActionWithTitle:@"取消" Handler:nil];
            [unreadeMessagesAlert showWithSender:nil controller:nil animated:YES completion:NULL];
            
            break;
        }
            
        case 3: {
            
            NSString *title = [NSString stringWithFormat:@"当前会话有 %ld 条未读",(long)[UdeskManager getLocalUnreadeMessagesCount]];
            
            UdeskAlertController *notNetworkAlert = [UdeskAlertController alertWithTitle:title message:nil];
            [notNetworkAlert addCloseActionWithTitle:@"确定" Handler:NULL];
            [notNetworkAlert showWithSender:nil controller:nil animated:YES completion:NULL];
            
            break;
        }
        case 4: {
        
            UDCustomClientInfoViewController *custom = [[UDCustomClientInfoViewController alloc] init];
            [self presentOnViewController:self udeskViewController:custom transiteAnimation:UDTransiteAnimationTypePush];
            
            break;
        }
            
        case 5: {
            
            UdeskAlertController *changeUIAlert = [UdeskAlertController alertControllerWithTitle:@"更换UI模版" message:nil preferredStyle:UDAlertControllerStyleActionSheet];
            [changeUIAlert addCloseActionWithTitle:@"取消" Handler:nil];
            [changeUIAlert addAction:[UdeskAlertAction actionWithTitle:@"原生" handler:^(UdeskAlertAction * _Nonnull action) {
                
                UdeskSDKManager *manager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle]];
                
                [manager pushUdeskViewControllerWithType:UdeskIM viewController:self];
                
            }]];
            [changeUIAlert addAction:[UdeskAlertAction actionWithTitle:@"经典" handler:^(UdeskAlertAction * _Nonnull action) {
                
                UdeskSDKManager *manager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle blueStyle]];
                
                [manager pushUdeskViewControllerWithType:UdeskIM viewController:self];
            }]];
            
            [changeUIAlert showWithSender:nil controller:self animated:YES completion:NULL];
            
            break;
        }
            
        case 6: {
            
            UdeskSDKManager *chatViewManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle]];
            
            [chatViewManager pushUdeskViewControllerWithType:UdeskMenu viewController:self];
            
            break;
        }
        case 7: {
            
            UdeskSDKManager *chatViewManager = [[UdeskSDKManager alloc] initWithSDKStyle:[UdeskSDKStyle defaultStyle]];
            
            NSDictionary *dict = @{
                                   @"productImageUrl":@"http://img.club.pchome.net/kdsarticle/2013/11small/21/fd548da909d64a988da20fa0ec124ef3_1000x750.jpg",
                                   @"productTitle":@"测试测试测试测你测试测试测你测试测试测你测试测试测你测试测试测你测试测试测你！",
                                   @"productDetail":@"¥88888.088888.088888.0",
                                   @"productURL":@"http://www.baidu.com"
                                   };
            [chatViewManager setProductMessage:dict];
            [chatViewManager pushUdeskViewControllerWithType:UdeskIM viewController:self];
            
            break;
        }
        case 8: {
        
            UDLanguageViewController *language = [[UDLanguageViewController alloc] init];
            [self presentOnViewController:self udeskViewController:language transiteAnimation:UDTransiteAnimationTypePush];
        }
            
        default:
            break;
    }
    
}

- (void)presentOnViewController:(UIViewController *)rootViewController udeskViewController:(id)udeskViewController transiteAnimation:(UDTransiteAnimationType)animation {
    
    
    UIViewController *viewController = nil;
    if (animation == UDTransiteAnimationTypePush) {
        viewController = [self createNavigationControllerWithWithAnimationSupport:udeskViewController presentedViewController:rootViewController];
        BOOL shouldUseUIKitAnimation = [[[UIDevice currentDevice] systemVersion] floatValue] >= 7;
        [rootViewController presentViewController:viewController animated:shouldUseUIKitAnimation completion:nil];
    } else {
        viewController = [[UINavigationController alloc] initWithRootViewController:udeskViewController];
        [self updateNavAttributesWithViewController:udeskViewController navigationController:(UINavigationController *)viewController defaultNavigationController:rootViewController.navigationController isPresentModalView:true];
        [rootViewController presentViewController:viewController animated:YES completion:nil];
    }
}

- (UINavigationController *)createNavigationControllerWithWithAnimationSupport:(UIViewController *)rootViewController presentedViewController:(UIViewController *)presentedViewController{
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:rootViewController];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [self updateNavAttributesWithViewController:rootViewController navigationController:(UINavigationController *)navigationController defaultNavigationController:rootViewController.navigationController isPresentModalView:true];
        [navigationController setTransitioningDelegate:[UdeskTransitioningAnimation transitioningDelegateImpl]];
        [navigationController setModalPresentationStyle:UIModalPresentationCustom];
    } else {
        [self updateNavAttributesWithViewController:rootViewController navigationController:(UINavigationController *)navigationController defaultNavigationController:rootViewController.navigationController isPresentModalView:true];
        [rootViewController.view.window.layer addAnimation:[UdeskTransitioningAnimation createPresentingTransiteAnimation:UDTransiteAnimationTypePush] forKey:nil];
    }
    return navigationController;
}

//修改导航栏属性
- (void)updateNavAttributesWithViewController:(UIViewController *)viewController
                         navigationController:(UINavigationController *)navigationController
                  defaultNavigationController:(UINavigationController *)defaultNavigationController
                           isPresentModalView:(BOOL)isPresentModalView {
    
    if (defaultNavigationController.navigationBar.titleTextAttributes) {
        navigationController.navigationBar.titleTextAttributes = defaultNavigationController.navigationBar.titleTextAttributes;
    } else {
        UIColor *color = [UIColor whiteColor];
        UIFont *font = [UIFont systemFontOfSize:17];
        NSDictionary *attr = @{NSForegroundColorAttributeName : color, NSFontAttributeName : font};
        navigationController.navigationBar.titleTextAttributes = attr;
    }
    
    UIButton *leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBarButton.frame = CGRectMake(0, 0, 20, 30);
    UIImage *backImage = [UIImage imageNamed:@"back"];
    [leftBarButton setImage:backImage forState:UIControlStateNormal];
    [leftBarButton addTarget:viewController action:@selector(dismissChatViewController) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *otherNavigationItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
    
    viewController.navigationItem.leftBarButtonItem = otherNavigationItem;
    
    navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"#0093FF"];
    
    viewController.navigationItem.title = @"自定义客户信息";
}

- (void)viewDidDisappear:(BOOL)animated {

    [super viewDidDisappear:animated];
    [UdeskSDKConfig sharedConfig].productDictionary = nil;
}

@end
