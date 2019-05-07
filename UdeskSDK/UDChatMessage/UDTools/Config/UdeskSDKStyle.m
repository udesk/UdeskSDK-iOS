//
//  UdeskSDKStyle.m
//  UdeskSDK
//
//  Created by Udesk on 16/8/29.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskSDKStyle.h"

@implementation UdeskSDKStyle

+ (instancetype)customStyle {
    return [UdeskSDKStyle new];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        //customer
        self.customerTextColor = [UIColor whiteColor];
        self.customerBubbleImage = [UIImage udBubbleSend01Image];
        self.customerVoiceDurationColor = [UIColor whiteColor];
        
        //agent
        self.agentTextColor = [UIColor blackColor];
        self.agentBubbleImage = [UIImage udBubbleReceive01Image];
        self.agentVoiceDurationColor = [UIColor colorWithRed:0.129f  green:0.129f  blue:0.129f alpha:1];
        
        //im
        self.tableViewBackGroundColor = [UIColor colorWithRed:0.949f  green:0.957f  blue:0.961f alpha:1];
        self.chatViewControllerBackGroundColor = [UIColor colorWithRed:0.949f  green:0.957f  blue:0.961f alpha:1];
        self.chatTimeColor = [UIColor udColorWithHexString:@"#8E8E93"];
        self.textViewColor = [UIColor whiteColor];
        self.messageContentFont = [UIFont systemFontOfSize:15];
        self.messageTimeFont = [UIFont systemFontOfSize:12];
        self.linkColor = [UIColor blueColor];
        self.activeLinkColor = [UIColor redColor];
        self.agentNicknameFont = [UIFont systemFontOfSize:12];
        self.agentNicknameColor = [UIColor udColorWithHexString:@"#8E8E93"];
        self.goodsNameFont = [UIFont boldSystemFontOfSize:14];
        self.goodsNameTextColor = [UIColor whiteColor];
        self.customerAvatarImage = [UIImage udDefaultCustomerAvatarImage];
        
        //nav
        self.navBackButtonColor = [UIColor udColorWithHexString:@"#007AFF"];
        self.navRightButtonColor = [UIColor udColorWithHexString:@"#007AFF"];
        self.navBackButtonImage = [UIImage udDefaultBackImage];
        self.navigationColor = [UIColor colorWithRed:0.976f  green:0.976f  blue:0.976f alpha:1];
        self.navBarBackgroundImage = nil;
        
        //title
        self.titleFont = [UIFont systemFontOfSize:16];
        self.titleColor = [UIColor blackColor];
        
        //right
        self.transferButtonColor = [UIColor colorWithRed:0.459f  green:0.459f  blue:0.459f alpha:1];
        
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
        
    }
    return self;
}

@end
