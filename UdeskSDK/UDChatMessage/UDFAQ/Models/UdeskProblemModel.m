//
//  UdeskProblemModel.m
//  UdeskSDK
//
//  Created by Udesk on 15/11/26.
//  Copyright (c) 2015年 Udesk. All rights reserved.
//

#import "UdeskProblemModel.h"

@implementation UdeskProblemModel

- (instancetype)initModelWithJSON:(id)json
{
    self = [super init];
    if (self) {
        
        self.articleId = json[@"id"];
        self.subject = json[@"subject"];
    }
    return self;
}

@end
