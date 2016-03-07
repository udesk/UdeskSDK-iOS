//
//  UDProblemModel.h
//  UdeskSDK
//
//  Created by xuchen on 15/11/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import "UDBaseModel.h"

@interface UDProblemModel : UDBaseModel
/**
 *  文章id
 */
@property (nonatomic, copy) NSString *Article_Id;
/**
 *  文章标题
 */
@property (nonatomic, copy) NSString *subject;

@end
