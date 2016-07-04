//
//  UdeskTopAlertView.h
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UdeskAgentModel;

typedef enum : NSUInteger {
    UDAlertTypeOnline,
    UDAlertTypeOffline,
    UDAlertTypeQueue,
    UDAlertTypeError
} UDAlertType;

@interface UdeskTopAlertView : UIView

@property(nonatomic, assign)BOOL autoHide;
@property(nonatomic, assign)NSInteger duration;

/*
 * action after dismiss
 */
@property (nonatomic, copy) dispatch_block_t dismissBlock;

+ (BOOL)hasViewWithParentView:(UIView*)parentView;
+ (void)hideViewWithParentView:(UIView*)parentView;
+ (UdeskTopAlertView*)viewWithParentView:(UIView*)parentView;

//+ (UDTopAlertView*)showWithType:(UDAlertType)type text:(NSString*)text parentView:(UIView*)parentView;
+ (UdeskTopAlertView *)showWithAgentModel:(UdeskAgentModel *)agentModel parentView:(UIView*)parentView navView:(UIView *)navView;

@end
