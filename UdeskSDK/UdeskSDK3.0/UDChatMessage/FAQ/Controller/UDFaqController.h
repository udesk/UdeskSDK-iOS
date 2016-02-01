//
//  UDFaqController.h
//  UdeskSDK
//
//  Created by xuchen on 15/11/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UDFaqController : UIViewController<UITableViewDataSource,UITableViewDelegate>

/**
 *  帮助中心表示图
 */
@property (nonatomic, strong) UITableView *faqTableView;
/**
 *  帮助中心数据数组
 */
@property (nonatomic, strong) NSArray      *problemData;
/**
 *  记录导航栏使用情况
 */
@property (nonatomic, assign) BOOL         navigationBarHidden;

@end
