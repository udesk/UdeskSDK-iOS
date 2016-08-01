//
//  UdeskBaseViewController.m
//  UdeskSDK
//
//  Created by xuchen on 16/6/15.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskBaseViewController.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskUtils.h"
#import "UdeskFoundationMacro.h"
#import "UIViewController+UdeskBackButtonHandler.h"

@interface UdeskBaseViewController()

@end

@implementation UdeskBaseViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    _udNavView = [[UdeskNavigationView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, ud_isIOS6?44:64)];
    
    if (self.navigationController.navigationBarHidden) {
        
        [self.view addSubview:_udNavView];
        [self.view bringSubviewToFront:_udNavView];
    }
    else {
    
        [self setCloseNavigationItem];
        [_udNavView showNativeNavigationView];
        self.navigationItem.titleView = _udNavView;
    }
    
    @udWeakify(self);
    _udNavView.navigationBackBlcok = ^{
        
        @udStrongify(self);
        [self backButtonAction];
    };
    
    _udNavView.navigationRightBlcok = ^{
        
        @udStrongify(self);
        [self rightButtonAction];
    };
    
}

- (void)setCloseNavigationItem {
    //取消按钮
    UIButton * closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(0, 0, 70, 40);
    [closeButton setTitle:@"返回" forState:UIControlStateNormal];
    [closeButton setImage:[UIImage ud_defaultBackImage] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *closeNavigationItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    
    // 调整 leftBarButtonItem 在 iOS7 下面的位置
    if((FUDSystemVersion>=7.0)){
        
        negativeSpacer.width = -19;
        self.navigationItem.leftBarButtonItems = @[negativeSpacer,closeNavigationItem];
    }else
        self.navigationItem.leftBarButtonItem = closeNavigationItem;
    
}

- (void)backButtonAction {

}

- (void)rightButtonAction {

}

@end
