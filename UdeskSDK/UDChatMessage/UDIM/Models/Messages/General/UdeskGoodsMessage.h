//
//  UdeskGoodsMessage.h
//  UdeskSDK
//
//  Created by xuchen on 2018/6/23.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskBaseMessage.h"
#import "UdeskGoodsModel.h"

@interface UdeskGoodsMessage : UdeskBaseMessage

/** model */
@property (nonatomic, strong, readonly) UdeskGoodsModel *goodsModel;
/** 其他文本参数 */
@property (nonatomic, strong, readonly) NSAttributedString  *paramsAttributedString;

@property (nonatomic, assign, readonly) CGRect imgFrame;
@property (nonatomic, assign, readonly) CGRect paramsFrame;

@end
