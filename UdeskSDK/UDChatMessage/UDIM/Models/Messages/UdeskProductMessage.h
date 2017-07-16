//
//  UdeskProductMessage.h
//  UdeskSDK
//
//  Created by Udesk on 16/8/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskBaseMessage.h"

@interface UdeskProductMessage : UdeskBaseMessage

/** 咨询对象URL */
@property (nonatomic, copy  ) NSString *productURL;
/** 咨询对象标题 */
@property (nonatomic, copy  ) NSString *productTitle;
/** 咨询对象副标题 */
@property (nonatomic, copy  ) NSString *productDetail;
/** 咨询对象发送文字 */
@property (nonatomic, copy  ) NSString *productSendText;
/** 咨询对象图片 */
@property (nonatomic, strong) UIImage  *productImage;
/** 咨询对象图片 */
@property (nonatomic, copy  ) NSString  *productImageURL;
/** 咨询对象标题Frame */
@property (nonatomic, assign, readonly) CGRect   productTitleFrame;
/** 咨询对象副标题Frame */
@property (nonatomic, assign, readonly) CGRect   productDetailFrame;
/** 咨询对象发送文字Frame */
@property (nonatomic, assign, readonly) CGRect   productSendFrame;
/** 咨询对象图片Frame */
@property (nonatomic, assign, readonly) CGRect   productImageFrame;
/** 咨询对象Frame */
@property (nonatomic, assign, readonly) CGRect   productFrame;

@end
