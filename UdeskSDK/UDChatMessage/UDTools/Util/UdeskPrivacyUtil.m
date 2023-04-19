//
//  UdeskPrivacyUtil.m
//  UdeskSDK
//
//  Created by xuchen on 2018/3/21.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskPrivacyUtil.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "UdeskSDKMacro.h"
#import "UdeskBundleUtils.h"
#import <Photos/Photos.h>

@implementation UdeskPrivacyUtil

+ (void)checkPermissionsOfAlbum:(void(^)(void))completion {
    
    // 查询权限
    if (@available(iOS 14, *)) {
        PHAccessLevel level = PHAccessLevelReadWrite;
        // 请求权限，需注意 limited 权限尽在 accessLevel 为 readAndWrite 时生效
        [PHPhotoLibrary requestAuthorizationForAccessLevel:level handler:^(PHAuthorizationStatus status) {
            [self reloadUI:status completion:completion];
        }];
    } else {
        // Fallback on earlier versions
        PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
        if (authStatus == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                [self reloadUI:status completion:completion];
            }];
        } else {
            [self reloadUI:authStatus completion:completion];
        }

    }
}

+ (void)reloadUI:(PHAuthorizationStatus)status completion:(void(^)(void))completion {
    switch (status) {
        case PHAuthorizationStatusLimited:
        case PHAuthorizationStatusAuthorized:{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion();
                }
            });
            break;
        }
        case PHAuthorizationStatusDenied:
            NSLog(@"denied");
            dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                [[[UIAlertView alloc] initWithTitle:nil
                                            message:getUDLocalizedString(@"udesk_album_denied")
                                           delegate:nil
                                  cancelButtonTitle:getUDLocalizedString(@"udesk_close")
                                  otherButtonTitles:nil] show];
#pragma clang diagnostic pop
            });
            break;
        default:
            break;
    }
}

+ (void)checkPermissionsOfCamera:(void(^)(void))completion {
    
//    //模拟器
//    if (TARGET_IPHONE_SIMULATOR) {
//        NSLog(@"UdeskSDK：模拟器无法使用拍摄功能");
//        return;
//    }
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                if (completion) {
                    completion();
                }
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    [[[UIAlertView alloc] initWithTitle:nil
                                                message:getUDLocalizedString(@"udesk_camera_denied")
                                               delegate:nil
                                      cancelButtonTitle:getUDLocalizedString(@"udesk_close")
                                      otherButtonTitles:nil] show];
#pragma clang diagnostic pop
                });
                
            }
        });
    }];
}

+ (void)checkPermissionsOfAudio:(void(^)(void))completion {
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                if (completion) {
                    completion();
                }
            }
            else {
                // 可以显示一个提示框告诉用户这个app没有得到允许？
                dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    [[[UIAlertView alloc] initWithTitle:nil
                                                message:getUDLocalizedString(@"udesk_microphone_denied")
                                               delegate:nil
                                      cancelButtonTitle:getUDLocalizedString(@"udesk_close")
                                      otherButtonTitles:nil] show];
#pragma clang diagnostic pop
                });
            }
        });
    }];
}

+ (void)checkPermissionsOfMicrophone:(void(^)(void))completion {
    
//    //模拟器
//    if (TARGET_IPHONE_SIMULATOR) {
//        NSLog(@"UdeskSDK：模拟器无法使用录音功能");
//        return;
//    }
    
    if (ud_isIOS7) {
        
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (granted) {
                // 用户同意获取数据
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion();
                    }
                });
                
            } else {
                // 可以显示一个提示框告诉用户这个app没有得到允许？
                dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    [[[UIAlertView alloc] initWithTitle:nil
                                                message:getUDLocalizedString(@"udesk_microphone_denied")
                                               delegate:nil
                                      cancelButtonTitle:getUDLocalizedString(@"udesk_close")
                                      otherButtonTitles:nil] show];
#pragma clang diagnostic pop
                });
                
            }
        }];
    }
    else {
        if (completion) {
            completion();
        }
    }
}

//仅检查音频权限状态
+ (BOOL)hasPermissionsOfAudio{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    BOOL isOK = NO;
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined://没有询问是否开启麦克风
        case AVAuthorizationStatusRestricted://未授权，家长限制
        case AVAuthorizationStatusDenied://玩家未授权
            isOK = NO;
        break;
        case AVAuthorizationStatusAuthorized:
            isOK = YES;
        break;
        default:
        break;
    }
    return isOK;
}

@end
