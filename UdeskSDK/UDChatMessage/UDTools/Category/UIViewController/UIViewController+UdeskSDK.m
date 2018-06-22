//
//  UIViewController+UdeskSDK.m
//  UdeskSDK
//
//  Created by Udesk on 16/3/2.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UIViewController+UdeskSDK.h"
#import <objc/runtime.h>

static void *UDAnimationsBlockAssociationKey = &UDAnimationsBlockAssociationKey;
static void *UDBeforeAnimationsBlockAssociationKey = &UDBeforeAnimationsBlockAssociationKey;
static void *UDAnimationsCompletionBlockAssociationKey = &UDAnimationsCompletionBlockAssociationKey;

@implementation UIViewController (UdeskSDK)

#pragma mark public

- (void)udSubscribeKeyboardWithAnimations:(UDAnimationsWithKeyboardBlock)animations
                                completion:(UDCompletionKeyboardAnimations)completion {
    [self udSubscribeKeyboardWithBeforeAnimations:nil animations:animations completion:completion];
}

- (void)udSubscribeKeyboardWithBeforeAnimations:(UDBeforeAnimationsWithKeyboardBlock)beforeAnimations
                                      animations:(UDAnimationsWithKeyboardBlock)animations
                                      completion:(UDCompletionKeyboardAnimations)completion {
    // we shouldn't check for nil because it does nothing with nil
    objc_setAssociatedObject(self, UDBeforeAnimationsBlockAssociationKey, beforeAnimations, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, UDAnimationsBlockAssociationKey, animations, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, UDAnimationsCompletionBlockAssociationKey, completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    // subscribe to keyboard animations
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(udHandleWillShowKeyboardNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(udHandleWillHideKeyboardNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)udUnsubscribeKeyboard {
    // remove assotiated blocks
    objc_setAssociatedObject(self, UDAnimationsBlockAssociationKey, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, UDAnimationsCompletionBlockAssociationKey, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    // unsubscribe from keyboard animations
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark private

// ----------------------------------------------------------------
- (void)udHandleWillShowKeyboardNotification:(NSNotification *)notification {
    [self udKeyboardWillShowHide:notification isShowing:YES];
}

// ----------------------------------------------------------------
- (void)udHandleWillHideKeyboardNotification:(NSNotification *)notification {
    [self udKeyboardWillShowHide:notification isShowing:NO];
}

- (void)udKeyboardWillShowHide:(NSNotification *)notification isShowing:(BOOL)isShowing {
    // getting keyboard animation attributes
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSTimeInterval duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // getting passed blocks
    UDAnimationsWithKeyboardBlock animationsBlock = objc_getAssociatedObject(self, UDAnimationsBlockAssociationKey);
    UDBeforeAnimationsWithKeyboardBlock beforeAnimationsBlock = objc_getAssociatedObject(self, UDBeforeAnimationsBlockAssociationKey);
    UDCompletionKeyboardAnimations completionBlock = objc_getAssociatedObject(self, UDAnimationsCompletionBlockAssociationKey);
    
    if (beforeAnimationsBlock) beforeAnimationsBlock(keyboardRect, duration, isShowing);
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [UIView setAnimationCurve:curve];
                         if (animationsBlock) animationsBlock(keyboardRect, duration, isShowing);
                     }
                     completion:completionBlock];
}

@end
