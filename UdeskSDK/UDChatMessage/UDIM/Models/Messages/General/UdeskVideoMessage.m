//
//  UdeskVideoMessage.m
//  UdeskSDK
//
//  Created by xuchen on 2017/5/16.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskVideoMessage.h"
#import "UdeskVideoCell.h"
#import "UdeskCacheUtil.h"
#import "UdeskVideoUtil.h"
#import "UdeskImageUtil.h"

/** 播放按钮宽度 */
static CGFloat const kUDVideoPlayButtonWidth = 48;
/** 播放按钮高度 */
static CGFloat const kUDVideoPlayButtonHeight = 48;
/** 下载按钮宽度 */
static CGFloat const kUDVideoDownloadButtonWidth = 48;
/** 下载按钮高度 */
static CGFloat const kUDVideoDownloadButtonHeight = 48;

/** 视频时间宽度 */
static CGFloat const kUDVideoDurationWidth = 30;
/** 视频时间高度 */
static CGFloat const kUDVideoDurationHeight = 20;
/** 视频时间水平边缘间隙 */
static CGFloat const kUDVideoDurationHorizontalEdgeSpacing = 5;
/** 视频时间垂直边缘间隙 */
static CGFloat const kUDVideoDurationVerticalEdgeSpacing = 5;

/** 下载进度宽度 */
static CGFloat const kUDVideoUploadProgressWidth = 48;
/** 下载进度高度 */
static CGFloat const kUDVideoUploadProgressHeight = 48;

@interface UdeskVideoMessage()

/** 视频文件frame */
//@property (nonatomic, assign, readwrite) CGRect videoFrame;
/** 视频文件名称frame */
@property (nonatomic, assign, readwrite) CGRect videoNameFrame;
/** 视频文件大小frame */
@property (nonatomic, assign, readwrite) CGRect videoSizeLaeblFrame;
/** 视频文件进度条frame */
@property (nonatomic, assign, readwrite) CGRect videoProgressFrame;
/** 视频文件百分比frame */
@property (nonatomic, assign, readwrite) CGRect videoProgressPercentFrame;

@property (nonatomic, assign, readwrite) CGRect previewFrame;
@property (nonatomic, assign, readwrite) CGRect playFrame;
@property (nonatomic, assign, readwrite) CGRect downloadFrame;
@property (nonatomic, assign, readwrite) CGRect videoDurationFrame;

@property (nonatomic, assign, readwrite) CGRect uploadProgressFrame;

@property (nonatomic, strong, readwrite) UIImage *previewImage;
@property (nonatomic, copy  , readwrite) NSString *videoDuration;

@end

@implementation UdeskVideoMessage

- (instancetype)initWithMessage:(UdeskMessage *)message displayTimestamp:(BOOL)displayTimestamp
{
    self = [super initWithMessage:message displayTimestamp:displayTimestamp];
    if (self) {

        if ([[UdeskCacheUtil sharedManager] containsObjectForKey:message.messageId]) {
            NSString *path = [[UdeskCacheUtil sharedManager] filePathForkey:message.messageId];
            self.message.sourceData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path]];
        }
        
        [self layoutVideoMessage];
    }
    return self;
}

- (void)layoutVideoMessage {

    if ([[UdeskCacheUtil sharedManager] containsObjectForKey:self.message.messageId]) {
        NSString *path = [[UdeskCacheUtil sharedManager] filePathForkey:self.message.messageId];
        NSURL *URL = [NSURL fileURLWithPath:path];
        self.previewImage = [UdeskVideoUtil videoPreViewImageWithURL:URL.absoluteString];
        self.videoDuration = [UdeskVideoUtil videoTimeFromDurationSecond:[UdeskVideoUtil videoDurationWithURL:URL.absoluteString]];
        
        if (!self.previewImage) {
            [self serviceVideoData];
        }
    }
    else {
        [self serviceVideoData];
    }
    
    CGSize previewSize = CGSizeMake(150, 150);
    if (self.previewImage) {
        previewSize = [UdeskImageUtil udImageSize:self.previewImage];
    }
    
    switch (self.message.messageFrom) {
        case UDMessageTypeSending:{
            
            CGFloat previewX = UD_SCREEN_WIDTH-kUDBubbleToHorizontalEdgeSpacing-previewSize.width;
            self.previewFrame = CGRectMake(previewX, CGRectGetMaxY(self.avatarFrame)+kUDAvatarToBubbleSpacing, previewSize.width, previewSize.height);
            //发送中
            self.loadingFrame = CGRectMake(self.previewFrame.origin.x-kUDBubbleToSendStatusSpacing-kUDSendStatusDiameter, self.previewFrame.origin.y+kUDCellBubbleToIndicatorSpacing, kUDSendStatusDiameter, kUDSendStatusDiameter);
            //发送失败
            self.failureFrame = self.loadingFrame;
            
            break;
        }
        case UDMessageTypeReceiving:{
            
            //视频
            self.previewFrame = CGRectMake(kUDBubbleToHorizontalEdgeSpacing, CGRectGetMaxY(self.avatarFrame)+kUDAvatarToBubbleSpacing, previewSize.width, previewSize.height);
            
            break;
        }
            
        default:
            break;
    }
    
    self.playFrame = CGRectMake((CGRectGetWidth(self.previewFrame)-kUDVideoPlayButtonWidth)/2, (CGRectGetHeight(self.previewFrame)-kUDVideoPlayButtonWidth)/2, kUDVideoPlayButtonWidth, kUDVideoPlayButtonHeight);
    self.downloadFrame = CGRectMake((CGRectGetWidth(self.previewFrame)-kUDVideoDownloadButtonWidth)/2, (CGRectGetHeight(self.previewFrame)-kUDVideoDownloadButtonHeight)/2, kUDVideoDownloadButtonWidth, kUDVideoDownloadButtonHeight);
    self.videoDurationFrame = CGRectMake(CGRectGetWidth(self.previewFrame)-kUDVideoDurationWidth-kUDVideoDurationHorizontalEdgeSpacing, CGRectGetHeight(self.previewFrame)-kUDVideoDurationHeight-kUDVideoDurationVerticalEdgeSpacing, kUDVideoDurationWidth, kUDVideoDurationHeight);
    self.uploadProgressFrame = CGRectMake((CGRectGetWidth(self.previewFrame)-kUDVideoUploadProgressWidth)/2, (CGRectGetHeight(self.previewFrame)-kUDVideoUploadProgressHeight)/2, kUDVideoUploadProgressWidth, kUDVideoUploadProgressHeight);
    
    //cell高度
    self.cellHeight = self.previewFrame.size.height+self.previewFrame.origin.y+kUDCellBottomMargin;
}

- (void)serviceVideoData {
    
    self.previewImage = [UdeskVideoUtil videoPreViewImageWithURL:self.message.content] ? : [UIImage udDefaultLoadingImage];
    self.videoDuration = [UdeskVideoUtil videoTimeFromDurationSecond:[UdeskVideoUtil videoDurationWithURL:self.message.content]];
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    
    return [[UdeskVideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
