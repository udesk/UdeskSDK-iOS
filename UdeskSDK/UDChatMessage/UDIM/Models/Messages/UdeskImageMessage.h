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
extern const CGFloat kUDImageUploadProgressHeight;

@interface UdeskImageMessage : UdeskBaseMessage

@property (nonatomic, assign, readonly) CGRect  imageFrame;
@property (nonatomic, assign, readonly) CGRect  shadowFrame;
@property (nonatomic, assign, readonly) CGRect  imageLoadingFrame;
@property (nonatomic, assign, readonly) CGRect  imageProgressFrame;

@end
