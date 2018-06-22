//
//  UdeskPrivacyUtil.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/21.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UdeskPrivacyUtil : NSObject

//检查相册权限
+ (void)checkPermissionsOfAlbum:(void(^)(void))completion;
//检查相机权限
+ (void)checkPermissionsOfCamera:(void(^)(void))completion;
+ (void)checkPermissionsOfAudio:(void(^)(void))completion;
//检查麦克风权限
+ (void)checkPermissionsOfMicrophone:(void(^)(void))completion;

@end
