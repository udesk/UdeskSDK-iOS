//
//  UdeskVideoMessage.h
//  UdeskSDK
//
//  Created by xuchen on 2017/5/16.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskBaseMessage.h"

/** 播放按钮宽度 */
extern const CGFloat kUDVideoPlayButtonWidth;
/** 播放按钮高度 */
extern const CGFloat kUDVideoPlayButtonHeight;
/** 下载按钮宽度 */
extern const CGFloat kUDVideoDownloadButtonWidth;
/** 下载按钮高度 */
extern const CGFloat kUDVideoDownloadButtonHeight;

/** 视频时间宽度 */
extern const CGFloat kUDVideoDurationWidth;
/** 视频时间高度 */
extern const CGFloat kUDVideoDurationHeight;

/** 视频时间水平边缘间隙 */
extern const CGFloat kUDVideoDurationHorizontalEdgeSpacing;
/** 视频时间垂直边缘间隙 */
extern const CGFloat kUDVideoDurationVerticalEdgeSpacing;

/** 下载进度宽度 */
extern const CGFloat kUDVideoUploadProgressWidth;
/** 下载进度高度 */
extern const CGFloat kUDVideoUploadProgressHeight;

@interface UdeskVideoMessage : UdeskBaseMessage

@property (nonatomic, assign, readonly) CGRect previewFrame;
@property (nonatomic, assign, readonly) CGRect playFrame;
@property (nonatomic, assign, readonly) CGRect downloadFrame;
@property (nonatomic, assign, readonly) CGRect videoDurationFrame;

@property (nonatomic, assign, readonly) CGRect uploadProgressFrame;

@property (nonatomic, strong, readonly) UIImage *previewImage;
@property (nonatomic, copy  , readonly) NSString *videoDuration;

@end
