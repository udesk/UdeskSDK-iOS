//
//  UdeskNavigationView.h
//  UdeskSDK
//
//  Created by xuchen on 16/6/15.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UdeskAgentModel;

@interface UdeskNavigationView : UIView

@property (nonatomic, copy) void (^navigationBackBlcok)();

@property (nonatomic, copy) void (^navigationRightBlcok)();

- (void)showAgentOnlineStatus:(UdeskAgentModel *)agentModel;
- (void)showRightButtonWithName:(NSString *)name;
- (void)showNativeNavigationView;
- (void)changeTitle:(NSString *)title;

@end
