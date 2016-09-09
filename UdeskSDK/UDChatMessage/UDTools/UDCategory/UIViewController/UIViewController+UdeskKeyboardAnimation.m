//
// UIViewController+KeyboardAnimation.m
//
// Copyright (c) 2015 Anton Gaenko
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "UIViewController+UdeskKeyboardAnimation.h"
#import <objc/runtime.h>

static void *UDAnimationsBlockAssociationKey = &UDAnimationsBlockAssociationKey;
static void *UDBeforeAnimationsBlockAssociationKey = &UDBeforeAnimationsBlockAssociationKey;
static void *UDAnimationsCompletionBlockAssociationKey = &UDAnimationsCompletionBlockAssociationKey;

@implementation UIViewController (UDKeyboardAnimation)

#pragma mark public

- (void)ud_subscribeKeyboardWithAnimations:(UDAnimationsWithKeyboardBlock)animations
                                completion:(UDCompletionKeyboardAnimations)completion {
    [self ud_subscribeKeyboardWithBeforeAnimations:nil animations:animations completion:completion];
}

- (void)ud_subscribeKeyboardWithBeforeAnimations:(UDBeforeAnimationsWithKeyboardBlock)beforeAnimations
                                      animations:(UDAnimationsWithKeyboardBlock)animations
                                      completion:(UDCompletionKeyboardAnimations)completion {
    // we shouldn't check for nil because it does nothing with nil
    objc_setAssociatedObject(self, UDBeforeAnimationsBlockAssociationKey, beforeAnimations, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, UDAnimationsBlockAssociationKey, animations, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, UDAnimationsCompletionBlockAssociationKey, completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    // subscribe to keyboard animations
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ud_handleWillShowKeyboardNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ud_handleWillHideKeyboardNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)ud_unsubscribeKeyboard {
    // remove assotiated blocks
    objc_setAssociatedObject(self, UDAnimationsBlockAssociationKey, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, UDAnimationsCompletionBlockAssociationKey, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    // unsubscribe from keyboard animations
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark private

// ----------------------------------------------------------------
- (void)ud_handleWillShowKeyboardNotification:(NSNotification *)notification {
    [self ud_keyboardWillShowHide:notification isShowing:YES];
}

// ----------------------------------------------------------------
- (void)ud_handleWillHideKeyboardNotification:(NSNotification *)notification {
    [self ud_keyboardWillShowHide:notification isShowing:NO];
}

- (void)ud_keyboardWillShowHide:(NSNotification *)notification isShowing:(BOOL)isShowing {
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
