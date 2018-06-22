//
//  UdeskAlertController.h
//  UdeskSDK
//
//  Created by 许晨 on 17/1/18.
//  Copyright © 2017年 bestdew. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 跟系统的UIAlertController使用方法完全一样...
 */
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, UDAlertActionStyle) {
    UDAlertActionStyleDefault = 0,
    UDAlertActionStyleCancel,
    UDAlertActionStyleDestructive
};

typedef NS_ENUM(NSInteger, UDAlertControllerStyle) {
    UDAlertControllerStyleActionSheet = 0, // 暂未实现😂，有待后续开发...
    UDAlertControllerStyleAlert
};

@interface UdeskAlertAction : NSObject

+ (instancetype)actionWithTitle:(nullable NSString *)title style:(UDAlertActionStyle)style handler:(void (^ __nullable)(UdeskAlertAction *action))handler;

@property (nullable, nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) UDAlertActionStyle udStyle;
@property (nonatomic, getter=isEnabled) BOOL enabled;

@end

@interface UdeskAlertController : UIViewController

@property (nonatomic, readonly) NSArray<UdeskAlertAction *> *actions;
@property (nullable, nonatomic, readonly) NSArray<UITextField *> *textFields;
@property (nonatomic, readonly) UDAlertControllerStyle preferredStyle;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSAttributedString *attributedMessage;
@property (nonatomic, assign) NSTextAlignment messageAlignment;

+ (instancetype)alertControllerWithTitle:(nullable NSString *)title attributedMessage:(nullable NSAttributedString *)attributedMessage preferredStyle:(UDAlertControllerStyle)preferredStyle;
- (void)addAction:(UdeskAlertAction *)action;
- (void)addTextFieldWithConfigurationHandler:(void (^ __nullable)(UITextField *textField))configurationHandler;

@end

NS_ASSUME_NONNULL_END
