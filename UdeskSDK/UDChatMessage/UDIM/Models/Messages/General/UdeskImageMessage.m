//
//  UdeskImageMessage.m
//  UdeskSDK
//
//  Created by xuchen on 2017/5/17.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskImageMessage.h"
#import "UdeskImageCell.h"
#import "Udesk_YYWebImage.h"

/** 聊天气泡和其中的图片水平间距 */
static CGFloat const kUDBubbleToImageHorizontalSpacing = 5.0;
static CGFloat const kUDImageUploadProgressHeight = 15.0;

@interface UdeskImageMessage()

//图片frame(包括下方留白)
@property (nonatomic, assign, readwrite) CGRect  imageFrame;
@property (nonatomic, assign, readwrite) CGRect  shadowFrame;
@property (nonatomic, assign, readwrite) CGRect  imageLoadingFrame;
@property (nonatomic, assign, readwrite) CGRect  imageProgressFrame;

@end

@implementation UdeskImageMessage

- (instancetype)initWithMessage:(UdeskMessage *)message displayTimestamp:(BOOL)displayTimestamp
{
    self = [super initWithMessage:message displayTimestamp:displayTimestamp];
    if (self) {
        
        if (!message.image) {
            if ([[Udesk_YYWebImageManager sharedManager].cache containsImageForKey:message.messageId]) {
                self.message.image = [[Udesk_YYWebImageManager sharedManager].cache getImageForKey:message.messageId];
            }
        }
        
        [self layoutImageMessage];
    }
    return self;
}

- (void)layoutImageMessage {

    CGSize imageSize = CGSizeMake(self.message.width, self.message.height);
    if (self.message.width==0 || self.message.height==0) {
        imageSize = CGSizeMake(150, 150);
    }
    
    switch (self.message.messageFrom) {
        case UDMessageTypeSending:{
         
            //图片气泡位置
            CGFloat bubbleX = UD_SCREEN_WIDTH-kUDBubbleToHorizontalEdgeSpacing-imageSize.width;
            self.bubbleFrame = CGRectMake(bubbleX, CGRectGetMaxY(self.avatarFrame)+kUDAvatarToBubbleSpacing, imageSize.width, imageSize.height);
            //图片位置
            self.imageFrame = CGRectMake(0, 0, imageSize.width, imageSize.height);
            //阴影
            self.shadowFrame = self.imageFrame;
            //loading
            self.imageLoadingFrame = CGRectMake((CGRectGetWidth(self.imageFrame)-kUDSendStatusDiameter)/2, (CGRectGetHeight(self.imageFrame)-kUDSendStatusDiameter)/2-kUDImageUploadProgressHeight, kUDSendStatusDiameter, kUDSendStatusDiameter);
            //进度
            self.imageProgressFrame = CGRectMake(0, CGRectGetMaxY(self.imageLoadingFrame)+kUDBubbleToImageHorizontalSpacing, CGRectGetWidth(self.imageFrame), kUDImageUploadProgressHeight);
            //发送中frame
            self.loadingFrame = CGRectMake(self.bubbleFrame.origin.x-kUDBubbleToSendStatusSpacing-kUDSendStatusDiameter, self.bubbleFrame.origin.y+kUDCellBubbleToIndicatorSpacing, kUDSendStatusDiameter, kUDSendStatusDiameter);
            //发送失败frame
            self.failureFrame = self.loadingFrame;
            
            break;
        }
        case UDMessageTypeReceiving: {
        
            //图片气泡frame
            self.bubbleFrame = CGRectMake(kUDBubbleToHorizontalEdgeSpacing, CGRectGetMaxY(self.avatarFrame)+kUDAvatarToBubbleSpacing, imageSize.width, imageSize.height);
            //图片frame
            self.imageFrame = CGRectMake(0, 0, imageSize.width, imageSize.height);
            
            break;
        }
            
        default:
            break;
    }
    
    //cell高度
    self.cellHeight = self.bubbleFrame.size.height+self.bubbleFrame.origin.y+kUDCellBottomMargin;
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    
    return [[UdeskImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
