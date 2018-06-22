//
//  UdeskBaseMessage.h
//  UdeskSDK
//
//  Created by Udesk on 16/9/1.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UdeskMessage.h"

/** 头像距离屏幕水平边沿距离 */
extern const CGFloat kUDAvatarToHorizontalEdgeSpacing;
/** 头像距离屏幕垂直边沿距离 */
extern const CGFloat kUDAvatarToVerticalEdgeSpacing;
/** 头像与聊天气泡之间的距离 */
extern const CGFloat kUDAvatarToBubbleSpacing;
/** 聊天气泡和Indicator的间距 */
extern const CGFloat kUDCellBubbleToIndicatorSpacing;
/** 聊天头像大小 */
extern const CGFloat kUDAvatarDiameter;
/** 时间高度 */
extern const CGFloat kUDChatMessageDateCellHeight;
/** 发送状态大小 */
extern const CGFloat kUDSendStatusDiameter;
/** 发送状态与气泡的距离 */
extern const CGFloat kUDBubbleToSendStatusSpacing;
/** 时间 Y */
extern const CGFloat kUDChatMessageDateLabelY;
/** 气泡箭头宽度 */
extern const CGFloat kUDArrowMarginWidth;
/** 底部留白 */
extern const CGFloat kUDCellBottomMargin;
/** 客服昵称高度 */
extern const CGFloat kUDAgentNicknameHeight;

@interface UdeskBaseMessage : NSObject

/** 消息气泡frame */
@property (nonatomic, assign) CGRect     bubbleFrame;
/** 头像frame */
@property (nonatomic, assign) CGRect     avatarFrame;
/** 客服昵称frame */
@property (nonatomic, assign) CGRect     nicknameFrame;
/** 发送失败图片frame */
@property (nonatomic, assign) CGRect     failureFrame;
/** 发送中frame */
@property (nonatomic, assign) CGRect     loadingFrame;
/** 时间frame */
@property (nonatomic, assign) CGRect     dateFrame;
/** 消息ID */
@property (nonatomic, copy, readonly) NSString   *messageId;
/** 消息发送人头像 */
@property (nonatomic, copy, readonly) NSString   *avatarURL;
/** 消息发送人头像 */
@property (nonatomic, strong, readonly) UIImage  *avatarImage;
/** cell高度 */
@property (nonatomic, assign) CGFloat  cellHeight;
/** 消息model */
@property (nonatomic, strong) UdeskMessage *message;

- (instancetype)initWithMessage:(UdeskMessage *)message displayTimestamp:(BOOL)displayTimestamp;

/**
 *  通过重用的名字初始化cell
 *  @return 初始化了一个cell
 */
- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer;

@end
