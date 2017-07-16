//
//  UdeskVideoMessage.h
//  UdeskSDK
//
//  Created by xuchen on 2017/5/16.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskBaseMessage.h"

/** 视频宽度 */
extern const CGFloat kUDVideoMessageWidth;
/** 视频高度 */
extern const CGFloat kUDVideoMessageHeight;
/** 视频名称水平距离 */
extern const CGFloat kUDVideoNameToHorizontalEdgeSpacing;
/** 视频名称垂直距离 */
extern const CGFloat kUDVideoNameToVerticalEdgeSpacing;
/** 视频名称宽度 */
extern const CGFloat kUDVideoNameWith;
/** 视频名称高度 */
extern const CGFloat kUDVideoNameHeight;
/** 视频进度条水平距离 */
extern const CGFloat kUDVideoProgressToHorizontalEdgeSpacing;
/** 视频进度条宽度 */
extern const CGFloat kUDVideoProgressWith;
/** 视频进度条高度 */
extern const CGFloat kUDVideoProgressHeight;
/** 视频大小水平距离 */
extern const CGFloat kUDVideoSizeToHorizontalEdgeSpacing;
/** 视频大小垂直距离 */
extern const CGFloat kUDVideoSizeToVerticalEdgeSpacing;
/** 视频大小宽度 */
extern const CGFloat kUDVideoSizeWith;
/** 视频大小高度 */
extern const CGFloat kUDVideoSizeHeight;
/** 视频百分比水平距离 */
extern const CGFloat kUDVideoProgressPercentToHorizontalEdgeSpacing;
/** 视频百分比垂直距离 */
extern const CGFloat kUDVideoProgressPercentToVerticalEdgeSpacing;
/** 视频百分比宽度 */
extern const CGFloat kUDVideoProgressPercentWith;
/** 视频百分比高度 */
extern const CGFloat kUDVideoProgressPercentHeight;

@interface UdeskVideoMessage : UdeskBaseMessage

/** 视频文件frame */
@property (nonatomic, assign, readonly) CGRect videoFrame;
/** 视频文件名称frame */
@property (nonatomic, assign, readonly) CGRect videoNameFrame;
/** 视频文件大小frame */
@property (nonatomic, assign, readonly) CGRect videoSizeLaeblFrame;
/** 视频文件进度条frame */
@property (nonatomic, assign, readonly) CGRect videoProgressFrame;
/** 视频文件百分比frame */
@property (nonatomic, assign, readonly) CGRect videoProgressPercentFrame;

@end
