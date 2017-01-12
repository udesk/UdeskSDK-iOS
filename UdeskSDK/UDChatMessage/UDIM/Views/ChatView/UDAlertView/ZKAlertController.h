//
//  ZKAlertController.h
//  ZKAlertController
//
//  Created by 张日奎 on 16/10/14.
//  Copyright © 2016年 bestdew. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 跟系统的UIAlertController使用方法完全一样...
 */
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ZKAlertActionStyle) {
    ZKAlertActionStyleDefault = 0,
    ZKAlertActionStyleCancel,
    ZKAlertActionStyleDestructive
};

typedef NS_ENUM(NSInteger, ZKAlertControllerStyle) {
    ZKAlertControllerStyleActionSheet = 0, // 暂未实现😂，有待后续开发...
    ZKAlertControllerStyleAlert
};

@interface ZKAlertAction : NSObject

+ (instancetype)actionWithTitle:(nullable NSString *)title style:(ZKAlertActionStyle)style handler:(void (^ __nullable)(ZKAlertAction *action))handler;

@property (nullable, nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) ZKAlertActionStyle style;
@property (nonatomic, getter=isEnabled) BOOL enabled;

@end

@interface ZKAlertController : UIViewController

@property (nonatomic, readonly) NSArray<ZKAlertAction *> *actions;
@property (nullable, nonatomic, readonly) NSArray<UITextField *> *textFields;
@property (nonatomic, readonly) ZKAlertControllerStyle preferredStyle;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *message;
@property (nonatomic, assign) NSTextAlignment messageAlignment;

+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(ZKAlertControllerStyle)preferredStyle;
- (void)addAction:(ZKAlertAction *)action;
- (void)addTextFieldWithConfigurationHandler:(void (^ __nullable)(UITextField *textField))configurationHandler;

@end

NS_ASSUME_NONNULL_END
