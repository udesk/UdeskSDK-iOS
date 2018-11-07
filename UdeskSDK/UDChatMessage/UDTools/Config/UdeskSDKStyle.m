//
//  UdeskSDKStyle.m
//  UdeskSDK
//
//  Created by Udesk on 16/8/29.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskSDKStyle.h"
#import "UdeskSDKStyleBlue.h"

@implementation UdeskSDKStyle

+ (instancetype)createWithStyle:(UDChatViewStyleType)type {
    switch (type) {
        case UDChatViewStyleTypeBlue:
            return [UdeskSDKStyleBlue new];
        default:
            return [UdeskSDKStyle new];
    }
}

+ (instancetype)customStyle {
    return [self createWithStyle:(UDChatViewStyleTypeDefault)];
}

+ (instancetype)defaultStyle {
    return [self createWithStyle:(UDChatViewStyleTypeDefault)];
}

+ (instancetype)blueStyle {
    return [self createWithStyle:(UDChatViewStyleTypeBlue)];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        //customer
        self.customerTextColor = [UIColor whiteColor];
        self.customerBubbleImage = [UIImage udBubbleSendImage];
        self.customerVoiceDurationColor = [UIColor udColorWithHexString:@"#8E8E93"];;
        
        //agent
        self.agentTextColor = [UIColor blackColor];
        self.agentBubbleImage = [UIImage udBubbleReceiveImage];
        self.agentVoiceDurationColor = [UIColor udColorWithHexString:@"#8E8E93"];
        
        //im
        self.tableViewBackGroundColor = [UIColor udColorWithHexString:@"#F0F2F2"];
        self.chatViewControllerBackGroundColor = [UIColor udColorWithHexString:@"#F0F2F2"];
        self.chatTimeColor = [UIColor udColorWithHexString:@"#8E8E93"];
        self.inputViewColor = [UIColor whiteColor];
        self.textViewColor = [UIColor whiteColor];
        self.messageContentFont = [UIFont systemFontOfSize:16];
        self.messageTimeFont = [UIFont systemFontOfSize:12];
        self.linkColor = [UIColor blueColor];
        self.activeLinkColor = [UIColor redColor];
        self.agentNicknameFont = [UIFont systemFontOfSize:12];
        self.agentNicknameColor = [UIColor udColorWithHexString:@"#8E8E93"];
        self.goodsNameFont = [UIFont boldSystemFontOfSize:14];
        self.goodsNameTextColor = [UIColor whiteColor];
        
        //nav
        self.navBackButtonColor = [UIColor udColorWithHexString:@"#007AFF"];
        self.navRightButtonColor = [UIColor udColorWithHexString:@"#007AFF"];
        self.navBackButtonImage = nil;
        self.navigationColor = [UIColor colorWithRed:0.976f  green:0.976f  blue:0.976f alpha:1];
        self.navBarBackgroundImage = nil;
        
        //title
        self.titleFont = [UIFont systemFontOfSize:16];
        self.titleColor = [UIColor blackColor];
        
        //right
        self.transferButtonColor = [UIColor udColorWithHexString:@"#0B84FE"];
        
        //record
        self.recordViewColor = [UIColor udColorWithHexString:@"#FAFAFA"];
        
        //faq
        self.searchCancleButtonColor = [UIColor colorWithRed:32/255.0f green:104/255.0f blue:235/255.0f alpha:1];
        self.searchContactUsColor = [UIColor colorWithRed:32/255.0f green:104/255.0f blue:235/255.0f alpha:1];
        self.contactUsBorderColor = [UIColor colorWithRed:32/255.0f green:104/255.0f blue:235/255.0f alpha:1];
        self.promptTextColor = [UIColor darkGrayColor];
        //product
        self.productBackGroundColor = [UIColor whiteColor];
        self.productTitleColor = [UIColor udColorWithHexString:@"#000000"];
        self.productDetailColor = [UIColor udColorWithHexString:@"#FF3B30"];
        self.productSendBackGroundColor = [UIColor udColorWithHexString:@"#FF3B30"];
        self.productSendTitleColor = [UIColor whiteColor];
        
        self.customerImage = [UIImage udDefaultCustomerImage];
        
    }
    return self;
}

@end
