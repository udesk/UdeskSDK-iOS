//
//  UdeskConfig.m
//  UdeskSDK
//
//  Created by xuchen on 16/1/16.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskConfig.h"
#import "UdeskTools.h"
#import "UdeskFoundationMacro.h"

@implementation UdeskConfig

+ (instancetype)sharedUDConfig {

    static UdeskConfig *udConfig = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       
        udConfig = [[UdeskConfig alloc] init];
    });
    
    return udConfig;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self setDefaultConfig];
    }
    return self;
}

//默认配置
- (void)setDefaultConfig {

    self.userTextColor = [UIColor whiteColor];
    self.agentTextColor = [UIColor blackColor];
    self.chatTimeColor = [UIColor grayColor];
    self.inputViewColor = [UIColor whiteColor];
    self.textViewColor = [UIColor whiteColor];
    self.contentFontSize = 16;
    self.timeFontSize = 12;
    self.iMBackButtonColor = [UIColor whiteColor];
    self.iMNavigationColor = [UdeskTools colorWithHexString:@"3565df"];
    self.iMTitleColor = [UIColor whiteColor];
    self.faqNavigationColor = [UdeskTools colorWithHexString:@"3565df"];
    self.faqTitleColor = [UIColor whiteColor];
    self.faqBackButtonColor = [UIColor whiteColor];
    self.articleContentNavigationColor = [UdeskTools colorWithHexString:@"3565df"];
    self.articleBackButtonColor = [UIColor whiteColor];
    self.articleContentTitleColor = [UIColor whiteColor];
    self.searchCancleButtonColor = UDRGBCOLOR(32, 104, 235);
    self.searchContactUsColor = UDRGBCOLOR(32, 104, 235);
    self.contactUsBorderColor = UDRGBCOLOR(32, 104, 235);
    self.promptTextColor = [UIColor darkGrayColor];
    self.ticketNavigationColor = [UdeskTools colorWithHexString:@"3565df"];
    self.ticketBackButtonColor = [UIColor whiteColor];
    self.ticketTitleColor = [UIColor whiteColor];
    self.agentStatusTitleColor = [UIColor whiteColor];
    self.robotNavigationColor = [UdeskTools colorWithHexString:@"3565df"];
    self.robotBackButtonColor = [UIColor whiteColor];
    self.robotTitleColor = [UIColor whiteColor];
    self.agentMenuBackButtonColor = [UIColor whiteColor];
    self.agentMenuNavigationColor = [UdeskTools colorWithHexString:@"3565df"];
    self.agentMenuTitleColor = [UIColor whiteColor];
//    NSString *imageUrl = @"http://img5.duitang.com/uploads/item/201409/15/20140915205358_tz8Y3.jpeg";
//    
//    //缓存image
//    NSString *newURL = [imageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:newURL]];
//    
//    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        
//        self.headImage = [UIImage imageWithData:data];
//        //缓存头像
//        [[UDCache sharedUDCache] storeImage:self.headImage forKey:imageUrl];
//    }];
//    
//    [dataTask resume];
    
//    self.oneSelfNavcigtionColor
}

@end
