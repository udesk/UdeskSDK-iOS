//
//  UdeskImageMessage.h
//  UdeskSDK
//
//  Created by xuchen on 2017/5/17.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskBaseMessage.h"

/** 聊天气泡和其中的图片水平间距 */
extern const CGFloat kUDBubbleToImageHorizontalSpacing;

@interface UdeskImageMessage : UdeskBaseMessage

//图片frame(包括下方留白)
@property (nonatomic, assign, readonly) CGRect  imageFrame;

@end
