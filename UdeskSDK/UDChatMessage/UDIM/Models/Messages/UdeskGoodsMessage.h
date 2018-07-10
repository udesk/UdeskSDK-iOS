//
//  UdeskGoodsMessage.h
//  UdeskSDK
//
//  Created by xuchen on 2018/6/23.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskBaseMessage.h"

@interface UdeskGoodsMessage : UdeskBaseMessage

/** id */
@property (nonatomic, copy, readonly) NSString *goodsId;
/** 名称 */
@property (nonatomic, copy, readonly) NSString *name;
/** 链接 */
@property (nonatomic, copy, readonly) NSString *url;
/** 图片 */
@property (nonatomic, copy, readonly) NSString *imgUrl;
/** 其他文本参数 */
@property (nonatomic, strong, readonly) NSAttributedString  *paramsAttributedString;

@property (nonatomic, assign, readonly) CGRect imgFrame;
@property (nonatomic, assign, readonly) CGRect paramsFrame;

@end
