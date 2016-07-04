//
//  UdeskChatViewController.h
//  UdeskSDK
//
//  Created by xuchen on 15/11/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import "UdeskBaseViewController.h"

@interface UdeskChatViewController : UdeskBaseViewController
/**
 *  客服组id
 */
@property (nonatomic, strong) NSString             *group_id;
/**
 *  客服id
 */
@property (nonatomic, strong) NSString             *agent_id;

/**
 *  展示咨询对象
 *
 *  @param productDic 咨询对象信息
 */
- (void)showProductViewWithDictionary:(NSDictionary *)productDic;

@end
