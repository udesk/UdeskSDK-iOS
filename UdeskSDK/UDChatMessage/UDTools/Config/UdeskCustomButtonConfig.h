//
//  UdeskCustomButtonConfig.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/21.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class UdeskCustomButtonConfig;
@class UdeskChatViewController;

typedef NS_ENUM(NSUInteger, UdeskCustomButtonConfigType) {
    UdeskCustomButtonConfigTypeInInputTop,   //在输入栏上方
    UdeskCustomButtonConfigTypeInMoreView, //在更多view里面
};

//点击回调，返回按钮所在的控制器
typedef void(^CustomButtonClickBlock)(UdeskCustomButtonConfig *customButton,UdeskChatViewController *viewController);

@interface UdeskCustomButtonConfig : NSObject

@property (nonatomic, copy  ) NSString *title;
@property (nonatomic, strong) UIImage  *image;
@property (nonatomic, assign) UdeskCustomButtonConfigType type;
@property (nonatomic, copy  ) CustomButtonClickBlock clickBlock;

/**
 初始化自定义按钮

 @param title 按钮标题（如果type是InMoreView则文本长度最大限制为5）
 @param image 按钮图片，需要60x60的图片（如果type是InInputTop则image会忽略）
 @param type 按钮的位置
 @param clickBlock 点击回调
 @return 自定义按钮
 */
- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image type:(UdeskCustomButtonConfigType)type clickBlock:(CustomButtonClickBlock)clickBlock;

@end
