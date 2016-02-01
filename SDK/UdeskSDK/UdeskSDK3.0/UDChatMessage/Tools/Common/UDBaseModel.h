//
//  BaseModel.h
//  01 Movie
//
//  Created by lyb on 14-10-14.
//  Copyright (c) 2014年 imac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UDBaseModel : NSObject

//自定义初始化方法
- (id)initWithContentsOfDic:(NSDictionary *)dic;

//创建映射关系
- (NSDictionary *)keyToAtt:(NSDictionary *)dic;

@end
