//
//  UdeskSearchController.h
//  UdeskSDK
//
//  Created by Udesk on 15/11/26.
//  Copyright (c) 2015年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UdeskContentController;

@interface UdeskSearchController : NSObject
/**
 *  搜索
 */
@property (nonatomic, strong) UISearchDisplayController *searchDisplayController;
/**
 *  搜索数据
 */
@property (nonatomic, strong) NSArray                   *searchData;


- (instancetype)initWithSearchBar:(UISearchBar *)searchBar contentsController:(UIViewController *)viewController;


@end
