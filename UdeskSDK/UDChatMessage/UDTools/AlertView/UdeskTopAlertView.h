//
//  UdeskTopAlertView.h
//  UdeskSDK
//
//  Created by Udesk on 16/1/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UdeskAgent;

typedef enum : NSUInteger {
    UDAlertTypeGreen,
    UDAlertTypeOrange,
    UDAlertTypeSkyBlue,
    UDAlertTypeRed
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

+ (UdeskTopAlertView *)showAlertType:(UDAlertType)type
                         withMessage:(NSString *)message
                          parentView:(UIView*)parentView;

+ (void)showWithCode:(NSInteger)code
         withMessage:(NSString *)message
          parentView:(UIView*)parentView;

@end
