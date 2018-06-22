//
//  UIViewController+UdeskSDK.h
//  UdeskSDK
//
//  Created by Udesk on 16/3/2.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (UdeskSDK)

//键盘监听
typedef void(^UDAnimationsWithKeyboardBlock)(CGRect keyboardRect, NSTimeInterval duration, BOOL isShowing);
typedef void(^UDBeforeAnimationsWithKeyboardBlock)(CGRect keyboardRect, NSTimeInterval duration, BOOL isShowing);
typedef void(^UDCompletionKeyboardAnimations)(BOOL finished);

- (void)udSubscribeKeyboardWithAnimations:(UDAnimationsWithKeyboardBlock)animations
                                completion:(UDCompletionKeyboardAnimations)completion;

- (void)udSubscribeKeyboardWithBeforeAnimations:(UDBeforeAnimationsWithKeyboardBlock)beforeAnimations
                                      animations:(UDAnimationsWithKeyboardBlock)animations
                                completion:(UDCompletionKeyboardAnimations)completion;

- (void)udUnsubscribeKeyboard;

@end
