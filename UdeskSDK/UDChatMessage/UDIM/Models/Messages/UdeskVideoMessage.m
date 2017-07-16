//
//  UdeskVideoMessage.m
//  UdeskSDK
//
//  Created by xuchen on 2017/5/16.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskVideoMessage.h"
#import "UdeskVideoCell.h"

/** 视频宽度 */
const CGFloat kUDVideoMessageWidth = 180;
/** 视频高度 */
const CGFloat kUDVideoMessageHeight = 80;
/** 视频名称水平距离 */
const CGFloat kUDVideoNameToHorizontalEdgeSpacing = 8;
/** 视频名称垂直距离 */
const CGFloat kUDVideoNameToVerticalEdgeSpacing = 3;
/** 视频名称宽度 */
const CGFloat kUDVideoNameWith = 164;
/** 视频名称高度 */
const CGFloat kUDVideoNameHeight = 30;
/** 视频进度条水平距离 */
const CGFloat kUDVideoProgressToHorizontalEdgeSpacing = 8;
/** 视频进度条宽度 */
const CGFloat kUDVideoProgressWith = 164;
/** 视频进度条高度 */
const CGFloat kUDVideoProgressHeight = 5;
/** 视频大小水平距离 */
const CGFloat kUDVideoSizeToHorizontalEdgeSpacing = 8;
/** 视频大小垂直距离 */
const CGFloat kUDVideoSizeToVerticalEdgeSpacing = 8;
/** 视频大小宽度 */
const CGFloat kUDVideoSizeWith = 50;
/** 视频大小高度 */
const CGFloat kUDVideoSizeHeight = 35;
/** 视频百分比水平距离 */
const CGFloat kUDVideoProgressPercentToHorizontalEdgeSpacing = 8;
/** 视频百分比垂直距离 */
const CGFloat kUDVideoProgressPercentToVerticalEdgeSpacing = 8;
/** 视频百分比宽度 */
const CGFloat kUDVideoProgressPercentWith = 50;
/** 视频百分比高度 */
const CGFloat kUDVideoProgressPercentHeight = 35;

@interface UdeskVideoMessage()

/** 视频文件frame */
@property (nonatomic, assign, readwrite) CGRect videoFrame;
/** 视频文件名称frame */
@property (nonatomic, assign, readwrite) CGRect videoNameFrame;
/** 视频文件大小frame */
@property (nonatomic, assign, readwrite) CGRect videoSizeLaeblFrame;
/** 视频文件进度条frame */
@property (nonatomic, assign, readwrite) CGRect videoProgressFrame;
/** 视频文件百分比frame */
@property (nonatomic, assign, readwrite) CGRect videoProgressPercentFrame;

@end

@implementation UdeskVideoMessage

- (instancetype)initWithMessage:(UdeskMessage *)message displayTimestamp:(BOOL)displayTimestamp
{
    self = [super initWithMessage:message displayTimestamp:displayTimestamp];
    if (self) {

        [self layoutVideoMessage];
    }
    return self;
}

- (void)layoutVideoMessage {

    switch (self.message.messageFrom) {
        case UDMessageTypeSending:{
            
            //视频文件位置
            self.videoFrame = CGRectMake(self.avatarFrame.origin.x-kUDAvatarToBubbleSpacing-kUDVideoMessageWidth, self.avatarFrame.origin.y, kUDVideoMessageWidth, kUDVideoMessageHeight);
            //发送中
            self.loadingFrame = CGRectMake(self.videoFrame.origin.x-kUDBubbleToSendStatusSpacing-kUDSendStatusDiameter, self.videoFrame.origin.y+kUDCellBubbleToIndicatorSpacing, kUDSendStatusDiameter, kUDSendStatusDiameter);
            //发送失败
            self.failureFrame = self.loadingFrame;
            
            break;
        }
        case UDMessageTypeReceiving:{
            
            //视频文件位置
            self.videoFrame = CGRectMake(CGRectGetMaxX(self.avatarFrame)+kUDAvatarToBubbleSpacing+kUDAvatarToBubbleSpacing, self.avatarFrame.origin.y, kUDVideoMessageWidth, kUDVideoMessageHeight);
            
            break;
        }
            
        default:
            break;
    }
    
    //视频文件名称位置
    self.videoNameFrame = CGRectMake(kUDVideoNameToHorizontalEdgeSpacing, kUDVideoNameToVerticalEdgeSpacing, kUDVideoNameWith, kUDVideoNameHeight);
    //视频进度条位置
    self.videoProgressFrame = CGRectMake(kUDVideoProgressToHorizontalEdgeSpacing, self.videoFrame.size.height/2, kUDVideoProgressWith, kUDVideoProgressHeight);
    //视频文件大小位置
    self.videoSizeLaeblFrame = CGRectMake(kUDVideoSizeToHorizontalEdgeSpacing, self.videoFrame.size.height-kUDVideoSizeHeight, kUDVideoSizeWith, kUDVideoSizeHeight);
    //视频文件进度百分比位置
    self.videoProgressPercentFrame = CGRectMake(self.videoFrame.size.width-kUDVideoProgressPercentToHorizontalEdgeSpacing-kUDVideoProgressPercentWith, self.videoFrame.size.height-kUDVideoProgressPercentHeight, kUDVideoProgressPercentWith, kUDVideoProgressPercentHeight);
    
    //cell高度
    self.cellHeight = self.videoFrame.size.height+self.videoFrame.origin.y+kUDCellBottomMargin;
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    
    return [[UdeskVideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
