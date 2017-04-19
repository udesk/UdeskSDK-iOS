//
//  UdeskProblemModel.m
//  UdeskSDK
//
//  Created by Udesk on 15/11/26.
//  Copyright (c) 2015年 Udesk. All rights reserved.
//

#import "UdeskProblemModel.h"

@implementation UdeskProblemModel

- (id)initWithContentsOfDic:(NSDictionary *)dic {
    
    self = [super initWithContentsOfDic:dic];
    if (self) {
        self.articleId = dic[@"id"];
    }
    
    return self;
}


@end
