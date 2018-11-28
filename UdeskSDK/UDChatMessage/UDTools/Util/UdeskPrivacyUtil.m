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
#import <AssetsLibrary/ALAssetsLibrary.h>
#import "UdeskSDKMacro.h"
#import "UdeskBundleUtils.h"

@implementation UdeskPrivacyUtil

+ (void)checkPermissionsOfAlbum:(void(^)(void))completion {
    
    if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined) {
        
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            
            if (*stop) {
                //点击“好”回调方法
                //检查客服状态
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion();
                    }
                });
                return;
            }
            *stop = TRUE;
            
        } failureBlock:^(NSError *error) {
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
        }];
    }
    else if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized) {
        
        if (completion) {
            completion();
        }
    }
    else if([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied){
        
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
    }
}

+ (void)checkPermissionsOfCamera:(void(^)(void))completion {
    
    //模拟器
    if (TARGET_IPHONE_SIMULATOR) {
        NSLog(@"UdeskSDK：模拟器无法使用拍摄功能");
        return;
    }
    
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
    
    //模拟器
    if (TARGET_IPHONE_SIMULATOR) {
        NSLog(@"UdeskSDK：模拟器无法使用录音功能");
        return;
    }
    
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

@end
