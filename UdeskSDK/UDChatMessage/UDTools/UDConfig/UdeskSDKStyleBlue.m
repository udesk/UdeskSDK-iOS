//
//  UdeskSDKStyleBlue.m
//  UdeskSDK
//
//  Created by xuchen on 16/8/29.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskSDKStyleBlue.h"

@implementation UdeskSDKStyleBlue

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        //customer
        self.customerTextColor = [UIColor whiteColor];
        self.customerBubbleColor = [UIColor colorWithHexString:@"#0093FF"];
        self.customerBubbleImage = [UIImage ud_bubbleSendImage];
        self.customerVoiceDurationColor = [UIColor colorWithHexString:@"#999999"];;
        
        //agent
        self.agentTextColor = [UIColor colorWithHexString:@"#313F48"];
        self.agentBubbleColor = [UIColor colorWithHexString:@"#ECEFF1"];
        self.agentBubbleImage = [UIImage ud_bubbleReceiveImage];
        self.agentVoiceDurationColor = [UIColor colorWithHexString:@"#999999"];
        
        //im
        self.tableViewBackGroundColor = [UIColor whiteColor];
        self.chatTimeColor = [UIColor colorWithHexString:@"#C3CDD4"];
        self.inputViewColor = [UIColor whiteColor];
        self.textViewColor = [UIColor whiteColor];
        self.messageContentFont = [UIFont systemFontOfSize:16];
        self.messageTimeFont = [UIFont systemFontOfSize:12];
        
        //nav
        self.navBackButtonColor = [UIColor whiteColor];
        self.navBackButtonImage = [UIImage ud_defaultWhiteBackImage];
        self.navigationColor = [UIColor colorWithHexString:@"#0093FF"];
        self.navBarBackgroundImage = nil;
        
        //title
        self.titleFont = [UIFont systemFontOfSize:16];
        self.titleColor = [UIColor whiteColor];
        
        //right
        self.transferButtonColor = [UIColor colorWithHexString:@"#0B84FE"];
        
        //record
        self.recordViewColor = [UIColor colorWithHexString:@"#F2F2F7"];
        
        //faq
        self.searchCancleButtonColor = UDRGBCOLOR(32, 104, 235);
        self.searchContactUsColor = UDRGBCOLOR(32, 104, 235);
        self.contactUsBorderColor = UDRGBCOLOR(32, 104, 235);
        self.promptTextColor = [UIColor darkGrayColor];
        
        //product
        self.productBackGroundColor = [UIColor colorWithHexString:@"#ECEFF1"];
        self.productTitleColor = [UIColor colorWithHexString:@"#313F48"];
        self.productDetailColor = [UIColor colorWithHexString:@"#FF3B30"];
        self.productSendBackGroundColor = [UIColor colorWithHexString:@"#FF3B30"];
        self.productSendTitleColor = [UIColor whiteColor];
    }
    return self;
}

@end
