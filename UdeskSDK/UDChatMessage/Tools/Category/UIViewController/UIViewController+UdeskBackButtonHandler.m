//
//  UIViewController+UdeskBackButtonHandler.m
//  UdeskSDK
//
//  Created by xuchen on 16/6/15.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UIViewController+UdeskBackButtonHandler.h"
#import <objc/runtime.h>

@implementation UIViewController (UdeskBackButtonHandler)

@end

static NSString *const kOriginDelegate = @"kOriginDelegate";

static NSString *const kBackButtonBlock = @"kBackButtonBlock";

@implementation UINavigationController (UdeskShouldPopOnBackButton)

@dynamic gestureBack;

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originSelector = @selector(viewDidLoad);
        SEL swizzledSelector = @selector(new_viewDidLoad);
        
        Method originMethod = class_getInstanceMethod(class, originSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod = class_addMethod(class,
                                            originSelector,
                                            method_getImplementation(swizzledMethod),
                                            method_getTypeEncoding(swizzledMethod));
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originMethod),
                                method_getTypeEncoding(originMethod));
        } else {
            method_exchangeImplementations(originMethod, swizzledMethod);
        }
    });
}

- (void)new_viewDidLoad
{
    [self new_viewDidLoad];
    
    if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0) {
        
        objc_setAssociatedObject(self, [kOriginDelegate UTF8String], self.interactivePopGestureRecognizer.delegate, OBJC_ASSOCIATION_ASSIGN);
        self.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    }
}

#pragma mark - 手势
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    
    if (self.viewControllers.count <= 1) {
        return NO;
    }
    
    if ([[self valueForKey:@"_isTransitioning"] boolValue]) {
        return NO;
    }
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        
        id<UIGestureRecognizerDelegate> originDelegate = objc_getAssociatedObject(self, [kOriginDelegate UTF8String]);
        
        BOOL gestureBool = [originDelegate gestureRecognizerShouldBegin:gestureRecognizer];
        
        if (self.gestureBack) {
            self.gestureBack();
        }
        
        return gestureBool;
    }
    
    return YES;
}

- (void)setGestureBack:(UDGestureBackAnimationBlock)gestureBack {

    objc_setAssociatedObject(self, @selector(gestureBack), gestureBack, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UDGestureBackAnimationBlock)gestureBack {

    id object = objc_getAssociatedObject(self, @selector(gestureBack));
    
    return object;
}

@end
