//
//  UdeskPaserdKeyword.h
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UdeskPaserdKeyword : NSObject

@property (nonatomic, copy) NSString* keyword;
@property (nonatomic, assign) NSRange range;

- (instancetype)initWithKeyword:(NSString *)keyword atRange:(NSRange)range;

@end
