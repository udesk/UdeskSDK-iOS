//
//  UdeskFAQViewController.h
//  UdeskSDK
//
//  Created by xuchen on 16/6/20.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskBaseViewController.h"

@interface UdeskFAQViewController : UdeskBaseViewController<UITableViewDataSource,UITableViewDelegate>

/**
 *  帮助中心表示图
 */
@property (nonatomic, strong) UITableView *faqTableView;
/**
 *  帮助中心数据数组
 */
@property (nonatomic, strong) NSArray      *problemData;

@end
