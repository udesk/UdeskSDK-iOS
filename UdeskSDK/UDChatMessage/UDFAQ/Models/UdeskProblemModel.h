//
//  UdeskProblemModel.h
//  UdeskSDK
//
//  Created by Udesk on 15/11/26.
//  Copyright (c) 2015年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UdeskProblemModel : NSObject
/**
 *  文章id
 */
@property (nonatomic, copy) NSString *articleId;
/**
 *  文章标题
 */
@property (nonatomic, copy) NSString *subject;

- (instancetype)initModelWithJSON:(id)json;

@end
