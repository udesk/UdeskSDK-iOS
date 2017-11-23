//
//  UdeskFoundationMacro.h
//  UdeskSDK
//
//  Created by Udesk on 16/1/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#ifndef UDFoundationMacro_pch
#define UDFoundationMacro_pch

#pragma mark - Funtion Method (宏 方法)

//语音最大时长
#define UdeskVoiceRecorderTotalTime 60.0

#define UdeskTouchProductUrlSendButton        @"UdeskTouchProductUrlSendButton"


// image STRETCH
#define UD_STRETCH_IMAGE(image, edgeInsets) ([image resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch])

// block self

#ifndef    udWeakify
#if __has_feature(objc_arc)

#define udWeakify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
autoreleasepool{} __weak __typeof__(x) __weak_##x##__ = x; \
_Pragma("clang diagnostic pop")

#else

#define udWeakify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
autoreleasepool{} __block __typeof__(x) __block_##x##__ = x; \
_Pragma("clang diagnostic pop")

#endif
#endif

#ifndef    udStrongify
#if __has_feature(objc_arc)

#define udStrongify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
try{} @finally{} __typeof__(x) x = __weak_##x##__; \
_Pragma("clang diagnostic pop")

#else

#define udStrongify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
try{} @finally{} __typeof__(x) x = __block_##x##__; \
_Pragma("clang diagnostic pop")

#endif
#endif


// Size
#define UD_SCREEN_WIDTH  [[UIScreen mainScreen] bounds].size.width
#define UD_SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

// 系统控件默认高度
#define kUDStatusBarHeight        [[UIApplication sharedApplication] statusBarFrame].size.height

// 颜色(RGB)
#define UDRGBCOLOR(r, g, b)       [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define UDRGBACOLOR(r, g, b, a)   [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

#define UDHSB(h,s,b) [UIColor colorWithHue:h/360.0f saturation:s/100.0f brightness:b/100.0f alpha:1.0]


// 当前版本
#define FUDSystemVersion          ([[[UIDevice currentDevice] systemVersion] floatValue])

// 是否iPhone5
#define ud_isiPhone5               ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? \
                                CGSizeEqualToSize(CGSizeMake(640, 1136), \
                                [[UIScreen mainScreen] currentMode].size) : \
                                NO)
// 是否iPhone4
#define ud_isiPhone4               ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? \
                                CGSizeEqualToSize(CGSizeMake(640, 960), \
                                [[UIScreen mainScreen] currentMode].size) : \
                                NO)

// 是否IOS11
#define ud_isIOS11                 ([[[UIDevice currentDevice]systemVersion]floatValue] >= 11.0)
// 是否IOS10
#define ud_isIOS10                 ([[[UIDevice currentDevice]systemVersion]floatValue] >= 10.0)
// 是否IOS9
#define ud_isIOS9                  ([[[UIDevice currentDevice]systemVersion]floatValue] >= 9.0)
// 是否IOS8
#define ud_isIOS8                  ([[[UIDevice currentDevice]systemVersion]floatValue] >= 8.0)
// 是否IOS7
#define ud_isIOS7                  ([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0)
// 是否IOS6
#define ud_isIOS6                  ([[[UIDevice currentDevice]systemVersion]floatValue] < 7.0)


// 是否iPad
#define ud_isPad                   (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

// View 圆角和加边框
#define UDViewBorderRadius(View, Radius, Width, Color)\
                                \
                                [View.layer setCornerRadius:(Radius)];\
                                [View.layer setMasksToBounds:YES];\
                                [View.layer setBorderWidth:(Width)];\
                                [View.layer setBorderColor:[Color CGColor]]

// View 圆角
#define UDViewRadius(View, Radius)\
                                \
                                [View.layer setCornerRadius:(Radius)];\
                                [View.layer setMasksToBounds:YES]
#endif
