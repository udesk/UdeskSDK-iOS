//
//  UdeskSDKMacro.h
//  UdeskSDK
//
//  Created by xuchen on 2018/4/14.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#ifndef UdeskSDKMacro_h
#define UdeskSDKMacro_h

#define LANGUAGE_SET @"udLangeuageset"

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

// 当前版本
#define FUDSystemVersion          ([[[UIDevice currentDevice] systemVersion] floatValue])

// 是否IOS13
#define ud_isIOS13                 ([[[UIDevice currentDevice]systemVersion]floatValue] >= 13.0)
// 是否IOS12
#define ud_isIOS12                 ([[[UIDevice currentDevice]systemVersion]floatValue] >= 12.0)
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

//刘海系列
#define udIsIPhoneXSeries ([UIScreen instancesRespondToSelector:@selector(currentMode)] ?\
(\
CGSizeEqualToSize(CGSizeMake(375, 812),[UIScreen mainScreen].bounds.size)\
||\
CGSizeEqualToSize(CGSizeMake(414, 896),[UIScreen mainScreen].bounds.size)\
)\
:\
NO)

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

#endif /* UdeskSDKMacro_h */
