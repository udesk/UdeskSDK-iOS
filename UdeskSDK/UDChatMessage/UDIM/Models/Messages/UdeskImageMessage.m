//
//  UdeskImageMessage.m
//  UdeskSDK
//
//  Created by xuchen on 2017/5/17.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskImageMessage.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskImageCell.h"

/** 聊天气泡和其中的图片水平间距 */
const CGFloat kUDBubbleToImageHorizontalSpacing = 5.0;

@interface UdeskImageMessage()

//图片frame(包括下方留白)
@property (nonatomic, assign, readwrite) CGRect  imageFrame;

@end

@implementation UdeskImageMessage

- (instancetype)initWithMessage:(UdeskMessage *)message displayTimestamp:(BOOL)displayTimestamp
{
    self = [super initWithMessage:message displayTimestamp:displayTimestamp];
    if (self) {
        
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
            self.bubbleFrame = CGRectMake(self.avatarFrame.origin.x-kUDArrowMarginWidth-kUDBubbleToImageHorizontalSpacing*2-kUDAvatarToBubbleSpacing-imageSize.width, self.avatarFrame.origin.y, imageSize.width+(kUDBubbleToImageHorizontalSpacing*4), imageSize.height+(kUDBubbleToImageHorizontalSpacing*2));
            //图片位置
            self.imageFrame = CGRectMake(0, 0, CGRectGetWidth(self.bubbleFrame), CGRectGetHeight(self.bubbleFrame));
            //发送中frame
            self.loadingFrame = CGRectMake(self.bubbleFrame.origin.x-kUDBubbleToSendStatusSpacing-kUDSendStatusDiameter, self.bubbleFrame.origin.y+kUDCellBubbleToIndicatorSpacing, kUDSendStatusDiameter, kUDSendStatusDiameter);
            //发送失败frame
            self.failureFrame = self.loadingFrame;
            
            break;
        }
        case UDMessageTypeReceiving: {
        
            //图片气泡frame
            self.bubbleFrame = CGRectMake(self.avatarFrame.origin.x+kUDAvatarDiameter+kUDAvatarToBubbleSpacing, self.dateFrame.origin.y+self.dateFrame.size.height+kUDAvatarToVerticalEdgeSpacing, imageSize.width+(kUDBubbleToImageHorizontalSpacing*4), imageSize.height+(kUDBubbleToImageHorizontalSpacing*2));
            //图片frame
            self.imageFrame = CGRectMake(0, 0, CGRectGetWidth(self.bubbleFrame), CGRectGetHeight(self.bubbleFrame));
            
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
