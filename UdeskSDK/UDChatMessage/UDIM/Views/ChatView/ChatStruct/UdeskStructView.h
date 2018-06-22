//
//  UdeskStructView.h
//  UdeskSDK
//
//  Created by 许晨 on 17/1/18.
//  Copyright © 2017年 xushichen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UdeskStructAction : NSObject

+ (instancetype)actionWithTitle:(nullable NSString *)title handler:(void (^ __nullable)(UdeskStructAction *action))handler;

@property (nullable, nonatomic, readonly) NSString *title;
@property (nonatomic, getter=isEnabled) BOOL enabled;

@end

@interface UdeskStructView : UIView

@property (nonatomic, readonly) NSArray<UdeskStructAction *> *actions;
@property (nullable, nonatomic, strong) UIImage *image;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *message;
@property (nonatomic, strong) NSMutableArray *mutableActions;

- (instancetype)initWithImage:(nullable UIImage *)image
                        title:(nullable NSString *)title
                      message:(nullable NSString *)message
                      buttons:(nullable NSArray<UdeskStructAction *> *)buttons
                       origin:(CGPoint)origin;

@end

NS_ASSUME_NONNULL_END
