//
//  UdeskConfigurationHelper.h
//  UdeskSDK
//
//  Created by Udesk on 16/1/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UdeskConfigurationHelper : NSObject

@property (nonatomic, strong, readonly) NSArray *popMenuTitles;

+ (instancetype)appearance;
/**
 *  设置长按显示的菜单
 *
 *  @param popMenuTitles 需要显示的菜单内容
 */
- (void)setupPopMenuTitles:(NSArray *)popMenuTitles;

@end
