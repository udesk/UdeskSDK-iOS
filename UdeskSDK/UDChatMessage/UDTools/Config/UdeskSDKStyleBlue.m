//
//  UdeskSDKStyleBlue.m
//  UdeskSDK
//
//  Created by Udesk on 16/8/29.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskSDKStyleBlue.h"

@implementation UdeskSDKStyleBlue

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        //customer
        self.customerTextColor = [UIColor whiteColor];
        self.customerBubbleColor = [UIColor udColorWithHexString:@"#0093FF"];
        self.customerBubbleImage = [UIImage udBubbleSendImage];
        self.customerVoiceDurationColor = [UIColor udColorWithHexString:@"#999999"];;
        
        //agent
        self.agentTextColor = [UIColor udColorWithHexString:@"#313F48"];
        self.agentBubbleColor = [UIColor udColorWithHexString:@"#ECEFF1"];
        self.agentBubbleImage = [UIImage udBubbleReceiveImage];
        self.agentVoiceDurationColor = [UIColor udColorWithHexString:@"#999999"];
        
        //im
        self.tableViewBackGroundColor = [UIColor whiteColor];
        self.chatTimeColor = [UIColor udColorWithHexString:@"#C3CDD4"];
        self.inputViewColor = [UIColor whiteColor];
        self.textViewColor = [UIColor whiteColor];
        self.messageContentFont = [UIFont systemFontOfSize:16];
        self.messageTimeFont = [UIFont systemFontOfSize:12];
        
        //nav
        self.navBackButtonColor = [UIColor whiteColor];
        self.navBackButtonImage = [UIImage udDefaultWhiteBackImage];
        self.navigationColor = [UIColor udColorWithHexString:@"#0093FF"];
        self.navBarBackgroundImage = nil;
        
        //title
        self.titleFont = [UIFont systemFontOfSize:16];
        self.titleColor = [UIColor whiteColor];
        
        //right
        self.transferButtonColor = [UIColor whiteColor];
        
        //record
        self.recordViewColor = [UIColor udColorWithHexString:@"#F2F2F7"];
        
        //faq
        self.searchCancleButtonColor = [UIColor colorWithRed:32/255.0f green:104/255.0f blue:235/255.0f alpha:1];
        self.searchContactUsColor = [UIColor colorWithRed:32/255.0f green:104/255.0f blue:235/255.0f alpha:1];
        self.contactUsBorderColor = [UIColor colorWithRed:32/255.0f green:104/255.0f blue:235/255.0f alpha:1];
        self.promptTextColor = [UIColor darkGrayColor];
        
        //product
        self.productBackGroundColor = [UIColor udColorWithHexString:@"#ECEFF1"];
        self.productTitleColor = [UIColor udColorWithHexString:@"#313F48"];
        self.productDetailColor = [UIColor udColorWithHexString:@"#FF3B30"];
        self.productSendBackGroundColor = [UIColor udColorWithHexString:@"#FF3B30"];
        self.productSendTitleColor = [UIColor whiteColor];
    }
    return self;
}

@end
