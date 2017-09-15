//
//  UdeskCustomLocationDataSource.h
//  UdeskSDK
//
//  Created by xuchen on 2017/9/7.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UdeskCustomLocationDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, strong) NSArray *items;

@end
