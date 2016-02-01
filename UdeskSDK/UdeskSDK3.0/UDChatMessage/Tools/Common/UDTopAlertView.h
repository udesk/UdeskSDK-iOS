//
//  UDTopAlertView.h
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    UDAlertTypeOnline,
    UDAlertTypeOffline,
    UDAlertTypeQueue,
    UDAlertTypeError
} UDAlertType;

@interface UDTopAlertView : UIView

@property(nonatomic, assign)BOOL autoHide;
@property(nonatomic, assign)NSInteger duration;

/*
 * action after dismiss
 */
@property (nonatomic, copy) dispatch_block_t dismissBlock;

+ (BOOL)hasViewWithParentView:(UIView*)parentView;
+ (void)hideViewWithParentView:(UIView*)parentView;
+ (UDTopAlertView*)viewWithParentView:(UIView*)parentView;

+ (UDTopAlertView*)showWithType:(UDAlertType)type text:(NSString*)text parentView:(UIView*)parentView;

@end
