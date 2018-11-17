//
//  UdeskQueueMessage.m
//  UdeskSDK
//
//  Created by xuchen on 2018/11/12.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskQueueMessage.h"
#import "UdeskQueueCell.h"
#import "UdeskSDKUtil.h"
#import "UdeskBundleUtils.h"
#import "UdeskSDKMacro.h"
#import "UdeskStringSizeUtil.h"

/** 排队事件标题height */
static CGFloat const kUDQueueTitleHeight = 25;
/** 排队事件按钮height */
static CGFloat const kUDQueueButtonHeight = 25;
/** 排队事件距离屏幕水平边沿距离 */
static CGFloat const kUDQueueToHorizontalEdgeSpacing = 10.0;
/** 排队事件距离屏幕垂直边沿距离 */
static CGFloat const kUDQueueToVerticalEdgeSpacing = 8.0;

/** 排队事件标题距离屏幕水平边沿距离 */
static CGFloat const kUDQueueTitleToHorizontalEdgeSpacing = 10.0;
/** 排队事件标题距离屏幕垂直边沿距离 */
static CGFloat const kUDQueueTitleToVerticalEdgeSpacing = 8.0;

/** 排队事件内容距离屏幕水平边沿距离 */
static CGFloat const kUDQueueContentToHorizontalEdgeSpacing = 10.0;
/** 排队事件内容距离屏幕垂直边沿距离 */
static CGFloat const kUDQueueContentToVerticalEdgeSpacing = 8.0;

/** 排队事件按钮距离屏幕水平边沿距离 */
static CGFloat const kUDQueueButtonToHorizontalEdgeSpacing = 10.0;
/** 排队事件按钮距离屏幕垂直边沿距离 */
static CGFloat const kUDQueueButtonToVerticalEdgeSpacing = 8.0;

@interface UdeskQueueMessage()

@property (nonatomic, assign, readwrite) BOOL showLeaveMsgBtn;
@property (nonatomic, copy  , readwrite) NSString *titleText;
@property (nonatomic, copy  , readwrite) NSString *buttonText;

@property (nonatomic, assign, readwrite) CGRect backGroundFrame;
@property (nonatomic, assign, readwrite) CGRect titleFrame;
@property (nonatomic, assign, readwrite) CGRect contentFrame;
@property (nonatomic, assign, readwrite) CGRect buttonFrame;

@end

@implementation UdeskQueueMessage

- (instancetype)initWithMessage:(UdeskMessage *)message displayTimestamp:(BOOL)displayTimestamp
{
    self = [super initWithMessage:message displayTimestamp:displayTimestamp];
    if (self) {
        [self layoutQueueEvent];
    }
    return self;
}

- (void)layoutQueueEvent {
    
    if (!self.message.content || [NSNull isEqual:self.message.content]) return;
    if ([UdeskSDKUtil isBlankString:self.message.content]) return;
    
    self.titleText = getUDLocalizedString(@"udesk_queue");
    self.buttonText = getUDLocalizedString(@"udesk_leave_msg");
    self.contentText = self.message.content;
    self.showLeaveMsgBtn = self.message.showLeaveMsgBtn;
    
    //内容高度
    CGFloat height = [UdeskStringSizeUtil textSize:self.contentText withFont:[UIFont systemFontOfSize:16] withSize:CGSizeMake(UD_SCREEN_WIDTH-(kUDQueueToHorizontalEdgeSpacing*2+kUDQueueContentToHorizontalEdgeSpacing*2), MAXFLOAT)].height;
    
    //背景
    self.backGroundFrame = CGRectMake(kUDQueueToHorizontalEdgeSpacing, kUDQueueToVerticalEdgeSpacing, UD_SCREEN_WIDTH-(kUDQueueToHorizontalEdgeSpacing*2), height+kUDQueueTitleHeight+(self.showLeaveMsgBtn?(kUDQueueButtonHeight+kUDQueueToVerticalEdgeSpacing):0)+(kUDQueueToVerticalEdgeSpacing*3));
    //标题
    self.titleFrame = CGRectMake(kUDQueueTitleToHorizontalEdgeSpacing, kUDQueueTitleToVerticalEdgeSpacing, CGRectGetWidth(self.backGroundFrame)-(kUDQueueTitleToHorizontalEdgeSpacing*2), kUDQueueTitleHeight);
    //内容
    self.contentFrame = CGRectMake(kUDQueueContentToHorizontalEdgeSpacing, CGRectGetMaxY(self.titleFrame)+kUDQueueContentToVerticalEdgeSpacing, CGRectGetWidth(self.backGroundFrame)-(kUDQueueContentToHorizontalEdgeSpacing*2), height);
    //按钮
    if (self.showLeaveMsgBtn) {
        self.buttonFrame = CGRectMake(kUDQueueButtonToHorizontalEdgeSpacing, CGRectGetMaxY(self.contentFrame)+kUDQueueButtonToVerticalEdgeSpacing, CGRectGetWidth(self.backGroundFrame)-(kUDQueueButtonToHorizontalEdgeSpacing*2), kUDQueueButtonHeight);
    }
    
    //cell高度
    self.cellHeight = self.backGroundFrame.size.height+self.backGroundFrame.origin.y+kUDCellBottomMargin;
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[UdeskQueueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
