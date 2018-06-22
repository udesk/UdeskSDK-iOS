//
//  UdeskLocationResultDataSource.h
//  UdeskSDK
//
//  Created by xuchen on 2017/8/17.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class UdeskNearbyModel;

@interface UdeskLocationResultDataSource : NSObject<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, copy) void(^didSeledctSearchResultBlock)(UdeskNearbyModel *model);
@property (nonatomic, copy) void(^scrollViewWillBeginDraggingBlock)(UIScrollView *scrollView);

- (void)searchPlace:(NSString *)place completion:(void(^)(void))completion;

@end
