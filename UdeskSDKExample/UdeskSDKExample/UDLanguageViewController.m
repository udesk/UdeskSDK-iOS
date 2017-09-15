//
//  UDLanguageViewController.m
//  UdeskSDK
//
//  Created by xuchen on 16/9/5.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UDLanguageViewController.h"
#import "UdeskFoundationMacro.h"
#import "UdeskTransitioningAnimation.h"
#import "UdeskLanguageTool.h"

#define SELECTLANGUAGE @"SELECTLANGUAGE"

@implementation UDLanguageViewController {

    NSArray *dataArray;
    NSIndexPath *_indexPath;
}

- (void)viewDidLoad {

    [super viewDidLoad];
    
    self.title = @"多语言";
    
    dataArray = @[@"简体中文",@"English"];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, 10.f)];
    footerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footerView;
    
    UIButton *leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBarButton.frame = CGRectMake(0, 0, 50, 30);
    [leftBarButton setTitle:@"取消" forState:UIControlStateNormal];
    [leftBarButton addTarget:self action:@selector(dismissChatViewController) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *otherNavigationItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    
    // 调整 leftBarButtonItem 在 iOS7 下面的位置
    if((FUDSystemVersion>=7.0)){
        
        negativeSpacer.width = -13;
        
        self.navigationItem.leftBarButtonItems = @[negativeSpacer,otherNavigationItem];
        
    }else
        self.navigationItem.leftBarButtonItem = otherNavigationItem;
    

    UIButton *navBarRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navBarRightButton setTitle:@"保存" forState:UIControlStateNormal];
    navBarRightButton.frame = CGRectMake(0, 0, 50, 30);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [navBarRightButton addTarget:self action:@selector(didSelectNavigationRightButton) forControlEvents:UIControlEventTouchUpInside];
#pragma clang diagnostic pop
    UIBarButtonItem *rightOtherNavigationItem = [[UIBarButtonItem alloc] initWithCustomView:navBarRightButton];
    
    UIBarButtonItem *rightNegativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    
    // 调整 leftBarButtonItem 在 iOS7 下面的位置
    if((FUDSystemVersion>=7.0)){
        
        rightNegativeSpacer.width = -13;
        self.navigationItem.rightBarButtonItems = @[rightNegativeSpacer,rightOtherNavigationItem];
        
    }else
        self.navigationItem.rightBarButtonItem = rightOtherNavigationItem;

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


- (void)didSelectNavigationRightButton {

    NSNumber *selectIndex = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTLANGUAGE];
    
    if ([dataArray[selectIndex.integerValue] isEqualToString:@"English"]) {
        [[UdeskLanguageTool sharedInstance] setNewLanguage:UDLanguageTypeEN];
    }
    else {
        [[UdeskLanguageTool sharedInstance] setNewLanguage:UDLanguageTypeCN];
    }
    
    [self dismissChatViewController];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *developerCellId =  @"developerCellId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:developerCellId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:developerCellId];
    }
    
    NSString *tmp = [[NSUserDefaults standardUserDefaults] objectForKey:@"udLangeuageset"];
    if ([tmp isEqualToString:@"en"]) {
        if (indexPath.row == 1) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.textLabel.textColor=[UIColor colorWithHexString:@"#0093FF"];
        }
    }
    else {
    
        if (indexPath.row == 0) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.textLabel.textColor=[UIColor colorWithHexString:@"#0093FF"];
        }
    }
    
    cell.textLabel.text = dataArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //取消点击效果
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *array = [tableView visibleCells];
    for (UITableViewCell *cell in array) {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        cell.textLabel.textColor=[UIColor blackColor];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:SELECTLANGUAGE];
    }
    UITableViewCell *cell=[self.tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.textColor=[UIColor colorWithHexString:@"#0093FF"];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    
    [[NSUserDefaults standardUserDefaults] setObject:@(indexPath.row) forKey:SELECTLANGUAGE];
}

@end
