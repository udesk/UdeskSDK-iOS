//
//  UdeskLocationMessage.m
//  UdeskSDK
//
//  Created by xuchen on 2017/8/16.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskLocationMessage.h"
#import "UdeskLocationCell.h"

/** 地理位置宽度 */
const CGFloat kUDLocationMessageWidth = 180;
/** 地理位置高度 */
const CGFloat kUDLocationMessageHeight = 120;
/** 地理位置快照宽度 */
const CGFloat kUDLocationSnapshotMessageWidth = 180;
/** 地理位置快照高度 */
const CGFloat kUDLocationSnapshotMessageHeight = 90;
/** 地理位置名称高度 */
const CGFloat kUDLocationNameMessageHeight = 20;
/** 地理位置名称水平距离 */
const CGFloat kUDLocationNameToHorizontalEdgeSpacing = 8;
/** 地理位置名称垂直距离 */
const CGFloat kUDLocationNameToVerticalEdgeSpacing = 5;
/** 地理位置快照水平距离 */
const CGFloat kUDLocationSnapshotToHorizontalEdgeSpacing = 0;
/** 地理位置快照垂直距离 */
const CGFloat kUDLocationSnapshotToVerticalEdgeSpacing = 5;

@interface UdeskLocationMessage()

/** 地理位置frame */
@property (nonatomic, assign, readwrite) CGRect locatioFrame;
/** 地理位置名称frame */
@property (nonatomic, assign, readwrite) CGRect locationNameFrame;
/** 地理位置快照frame */
@property (nonatomic, assign, readwrite) CGRect locationSnapshotFrame;

@end

@implementation UdeskLocationMessage

- (instancetype)initWithMessage:(UdeskMessage *)message displayTimestamp:(BOOL)displayTimestamp
{
    self = [super initWithMessage:message displayTimestamp:displayTimestamp];
    if (self) {
        
        [self layoutLocationMessage];
    }
    return self;
}

- (void)layoutLocationMessage {
    
    switch (self.message.messageFrom) {
        case UDMessageTypeSending:{
            
            //图片气泡位置
            self.locatioFrame = CGRectMake(self.avatarFrame.origin.x-kUDAvatarToBubbleSpacing-kUDLocationMessageWidth, self.avatarFrame.origin.y, kUDLocationMessageWidth, kUDLocationMessageHeight);
            //地图名称位置
            self.locationNameFrame = CGRectMake(kUDLocationNameToHorizontalEdgeSpacing, kUDLocationNameToVerticalEdgeSpacing, kUDLocationMessageWidth-kUDLocationNameToHorizontalEdgeSpacing*2, kUDLocationNameMessageHeight);
            //地图图片位置
            self.locationSnapshotFrame = CGRectMake(kUDLocationSnapshotToHorizontalEdgeSpacing, CGRectGetMaxY(self.locationNameFrame)+ kUDLocationSnapshotToVerticalEdgeSpacing, kUDLocationSnapshotMessageWidth, kUDLocationSnapshotMessageHeight);
            //发送中frame
            self.loadingFrame = CGRectMake(self.bubbleFrame.origin.x-kUDBubbleToSendStatusSpacing-kUDSendStatusDiameter, self.bubbleFrame.origin.y+kUDCellBubbleToIndicatorSpacing, kUDSendStatusDiameter, kUDSendStatusDiameter);
            //发送失败frame
            self.failureFrame = self.loadingFrame;
            
            break;
        }
            
        default:
            break;
    }
    
    //cell高度
    self.cellHeight = self.locatioFrame.size.height+self.locatioFrame.origin.y+kUDCellBottomMargin;
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    
    return [[UdeskLocationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
