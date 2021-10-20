//
//  UdeskTrack.h
//  UdeskSDK
//
//  Created by xuchen on 2019/5/29.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UdeskTrackParams : NSObject

/** 参数文本 */
@property (nonatomic, copy) NSString *text;
/** 参数颜色（只支持16进制） */
@property (nonatomic, copy) NSString *color;
/** 字体大小 */
@property (nonatomic, copy) NSString *size;
/** 是否粗体 */
@property (nonatomic, strong) NSNumber *fold;
/** 是否换行 */
@property (nonatomic, strong) NSNumber *udBreak;

@end

@interface UdeskTrack : NSObject

/** 跟踪类型（商品：product，目前只有一种，请不要传其他！！！ 该参数必填！！！） */
@property (nonatomic, copy) NSString *type;
/** 名称（必填！！！） */
@property (nonatomic, copy) NSString *name;
/** 跳转链接 */
@property (nonatomic, copy) NSString *url;
/** 图片url */
@property (nonatomic, copy) NSString *imageUrl;
/** 访问时间(请只精确到秒 yyyy-MM-dd HH:mm:ss) */
@property (nonatomic, copy) NSString *date;
/** 参数列表 */
@property (nonatomic, copy) NSArray<UdeskTrackParams *> *params;

@end

@interface UdeskOrder : NSObject

/** 编号（必填！！！） */
@property (nonatomic, copy) NSString *number;
/** 名称（必填！！！） */
@property (nonatomic, copy) NSString *name;
/** 跳转链接 */
@property (nonatomic, copy) NSString *url;
/** 价格（必填！！！） */
@property (nonatomic, assign) float price;
/** 下单时间（必填！！！） */
@property (nonatomic, copy) NSString *orderAt;
/** 付款时间 */
@property (nonatomic, copy) NSString *payAt;
/** 订单状态(待付款: 'wait_pay'、已付款: 'paid'、已关闭: 'closed')（必填！！！） */
@property (nonatomic, copy) NSString *status;
/** 备注 */
@property (nonatomic, copy) NSString *remark;

@end
