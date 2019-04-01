//
//  UdeskStructView.h
//  UdeskSDK
//
//  Created by xuchen on 17/1/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UdeskStructAction : NSObject

+ (instancetype _Nonnull )actionWithTitle:(nullable NSString *)title handler:(void (^ __nullable)(UdeskStructAction * _Nullable action))handler;

@property (nullable, nonatomic, readonly) NSString *title;
@property (nonatomic, getter=isEnabled) BOOL enabled;

@end

@interface UdeskStructView : UIView

@property (nonatomic, readonly) NSArray<UdeskStructAction *> * _Nullable actions;
@property (nullable, nonatomic, strong) UIImage *image;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *message;
@property (nonatomic, strong) NSMutableArray * _Nullable mutableActions;

- (instancetype _Nullable )initWithImage:(nullable UIImage *)image
                                   title:(nullable NSString *)title
                                 message:(nullable NSString *)message
                                 buttons:(nullable NSArray<UdeskStructAction *> *)buttons
                                  origin:(CGPoint)origin;

@end
