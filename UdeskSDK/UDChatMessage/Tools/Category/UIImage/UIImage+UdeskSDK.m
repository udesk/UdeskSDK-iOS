//
//  UIImage+UdeskSDK.m
//  UdeskSDK
//
//  Created by xuchen on 16/3/2.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UIImage+UdeskSDK.h"
#import "UdeskUtils.h"

@implementation UIImage (UdeskSDK)

+ (UIImage *)ud_bubbleSendImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"ud_ChatBubble_Sending_Solid.png")];
}

+ (UIImage *)ud_bubbleReceiveImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"ud_ChatBubble_Receiving_Solid.png")];
}

+ (UIImage *)ud_defaultDeleteImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"ud_deleteMessage_Button@2x.png")];
}

+ (UIImage *)ud_defaultDeleteHighlightedImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"ud_deleteMessage_ButtonH@2x.png")];
}

+ (UIImage *)ud_defaultRefreshImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"ud_refresh_Button.png")];
}

+ (UIImage *)ud_defaultVoiceImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"ud_voice_Button.png")];
}

+ (UIImage *)ud_defaultVoiceHighlightedImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"ud_voice_ButtonH.png")];
}

+ (UIImage *)ud_defaultVoiceInputImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"ud_voice_background.png")];
}

+ (UIImage *)ud_defaultVoiceInputHighlightedImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"ud_voice_backgroundH.png")];
}

+ (UIImage *)ud_defaultKeyboardImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"ud_keyboard_Button.png")];
}

+ (UIImage *)ud_defaultPhotoImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"ud_photo_Button.png")];
}

+ (UIImage *)ud_defaultPhotoHighlightedImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"ud_photo_ButtonH.png")];
}

+ (UIImage *)ud_defaultSmileImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"ud_smile_Button.png")];
}

+ (UIImage *)ud_defaultSmileHighlightedImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"ud_smile_ButtonH.png")];
}

+ (UIImage *)ud_defaultCustomerImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"ud_customer.png")];
}

+ (UIImage *)ud_defaultAgentImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"ud_agent.png")];
}

+ (UIImage *)ud_defaultVoiceSpeakImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"ud_voicerecord.png")];
}

+ (UIImage *)ud_defaultRecordingImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"ud_Recording_Signal001.png")];
}

+ (UIImage *)ud_defaultVoiceRevokeImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"ud_voicecancelsend.png")];
}

+ (UIImage *)ud_defaultBackImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"ud_back.png")];
}

+ (UIImage *)ud_defaultVoiceTooShortImage {

    return [UIImage imageWithContentsOfFile:getUDBundlePath(@"ud_voicetooshort.png")];
}

@end
