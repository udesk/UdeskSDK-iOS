//
//  UdeskSDKConfig.m
//  UdeskSDK
//
//  Created by Udesk on 16/1/16.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskSDKConfig.h"
#import "UdeskLanguageConfig.h"
#import "UdeskBundleUtils.h"

@implementation UdeskSDKActionConfig

@end

@implementation UdeskSDKConfig

+ (instancetype)customConfig {

    static UdeskSDKConfig *udConfig = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        udConfig = [[UdeskSDKConfig alloc] init];
    });
    
    return udConfig;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setConfigToDefault];
    }
    return self;
}

-(void)setLanguage:(NSString *)language{
    [UdeskLanguageConfig sharedConfig].language = language;
}

- (void)setConfigToDefault {
    
    self.agentId = nil;
    self.groupId = nil;
    self.menuId = nil;
    self.productDictionary = nil;
    self.imTitle = nil;
    self.robotTtile = nil;
    self.faqTitle = nil;
    self.ticketTitle = nil;
    self.articleTitle = nil;
    self.agentMenuTitle = nil;
    self.productSendText = nil;
    self.customButtons = nil;
    self.customEmojis = nil;
    self.preSendMessages = nil;
    self.showAlbumEntry = YES;
    self.showVoiceEntry = YES;
    self.showCameraEntry = YES;
    self.showEmotionEntry = YES;
    self.showLocationEntry = NO;
    self.allowShootingVideo = YES;
    self.imagePickerEnabled = YES;
    
    self.sdkStyle = [UdeskSDKStyle customStyle];
    self.maxImagesCount = 9;
    self.quality = 0.5;
    self.allowPickingVideo = YES;
    self.showCustomButtons = NO;
    self.smallVideoEnabled = YES;
    self.smallVideoResolution = UDSmallVideoResolutionTypePhoto;
    self.smallVideoDuration = 15;
    self.orientationMask = UIInterfaceOrientationMaskPortrait;
    self.robotWelcomeMessage = getUDLocalizedString(@"udesk_robot_welcome_message");
}

- (NSString *)quitQueueString {
    
    switch (self.quitQueueType) {
        case UDQuitQueueTypeForceMark:
            return @"mark";
            break;
        case UDQuitQueueTypeForce:
            return @"force_quit";
            break;
            
        default:
            break;
    }
}

@end
