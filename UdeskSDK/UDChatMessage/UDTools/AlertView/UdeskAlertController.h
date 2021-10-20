//
//  UdeskAlertController.h
//  Udesk
//
//  Created by xuchen on 2019/1/28.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UdeskAlertActionStyle) {
    UdeskAlertActionStyleDefault = 0,
    UdeskAlertActionStyleCancel,
    UdeskAlertActionStyleDestructive
};

typedef NS_ENUM(NSInteger, UdeskAlertControllerStyle) {
    UdeskAlertControllerStyleActionSheet = 0,
    UdeskAlertControllerStyleAlert
};

@interface UdeskAlertAction : NSObject

+ (instancetype)actionWithTitle:(NSString *)title style:(UdeskAlertActionStyle)style handler:(void (^)(UdeskAlertAction *action))handler;

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) UdeskAlertActionStyle style;
@property (nonatomic, getter=isEnabled) BOOL enabled;

@end

@interface UdeskAlertController : UIViewController

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(UdeskAlertControllerStyle)preferredStyle;
+ (instancetype)alertControllerWithTitle:(NSString *)title attributedMessage:(NSAttributedString *)attributedMessage preferredStyle:(UdeskAlertControllerStyle)preferredStyle;

- (void)addAction:(UdeskAlertAction *)action;
@property (nonatomic, readonly) NSArray<UdeskAlertAction *> *actions;

- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *textField))configurationHandler;
@property (nonatomic, readonly) NSArray<UITextField *> *textFields;

@property (nonatomic, copy) NSString *alertTitle;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSAttributedString *attributedMessage;

@property (nonatomic, readonly) UdeskAlertControllerStyle preferredStyle;

@end
