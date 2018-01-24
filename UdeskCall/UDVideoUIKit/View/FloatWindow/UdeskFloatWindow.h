//
//  UdeskFloatWindow.h
//  UdeskSDK
//
//  Created by mincj on 2017/3/29.
//  Copyright © 2017年 Sina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UdeskDraggalbeView.h"

@class UdeskFloatWindow;

@protocol WBFloatWindowProtcol <NSObject>

@required
- (void)recoverFloatWindow:(UdeskFloatWindow *)floatWindow;

@end

@interface UdeskFloatWindow : NSObject{
    @protected
    UIView* _showView;
    CGRect _moveInRect;
}

+ (instancetype)floatWindow;

- (void)showView:(UIView*)view delegate:(id<WBFloatWindowProtcol>)delegate;

@property(assign, nonatomic)CGRect moveInRect;
@property(readonly, assign, nonatomic)BOOL hasFloatWindow;

@property(weak, nonatomic)id<WBFloatWindowProtcol> delegate;
@property(strong, nonatomic)UIView *showView;
@property(strong, nonatomic)UdeskDraggalbeView *dragView;
@end


