//
//  UdeskGoodsModel.h
//  UdeskSDK
//
//  Created by xuchen on 2018/6/23.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UdeskGoodsParamModel : NSObject

/** 文本 */
@property (nonatomic, copy  ) NSString *text;
/** 颜色 */
@property (nonatomic, copy  ) NSString *color;
/** 加粗 (1加粗-0不加粗) */
@property (nonatomic, strong) NSNumber *fold;
/** 换行（该段文本结束后换行，1换行-0不换行） */
@property (nonatomic, strong) NSNumber *udBreak;
/** 字体大小（单位px） */
@property (nonatomic, strong) NSNumber *size;

@end

@interface UdeskGoodsModel : NSObject

/** 商品消息ID（可传可不传，主要用于在点击商品消息时回调给开发者） */
@property (nonatomic, copy) NSString *goodsId;
/** 名称（必传） */
@property (nonatomic, copy) NSString *name;
/** 链接 */
@property (nonatomic, copy) NSString *url;
/** 图片 */
@property (nonatomic, copy) NSString *imgUrl;
/** 其他文本参数 */
@property (nonatomic, strong) NSArray<UdeskGoodsParamModel *>  *params;

@end
