//
//  UDProblemModel.m
//  UdeskSDK
//
//  Created by xuchen on 15/11/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import "UDProblemModel.h"

@implementation UDProblemModel

- (id)initWithContentsOfDic:(NSDictionary *)dic {
    
    self = [super initWithContentsOfDic:dic];
    if (self) {
        self.Article_Id = dic[@"id"];
    }
    
    return self;
}


@end
