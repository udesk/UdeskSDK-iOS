//
//  UdeskBaseMessage.m
//  UdeskSDK
//
//  Created by Udesk on 16/9/1.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskBaseMessage.h"
#import "UdeskDateUtil.h"
#import "UdeskSDKMacro.h"
#import "UdeskSDKConfig.h"
#import "UdeskSDKUtil.h"

/** 头像距离屏幕水平边沿距离 */
const CGFloat kUDAvatarToHorizontalEdgeSpacing = 8.0;
/** 头像距离屏幕垂直边沿距离 */
const CGFloat kUDAvatarToVerticalEdgeSpacing = 8.0;
/** 头像与聊天气泡之间的距离 */
const CGFloat kUDAvatarToBubbleSpacing = 6.0;
/** 聊天气泡和Indicator的间距 */
const CGFloat kUDCellBubbleToIndicatorSpacing = 5.0;
/** 聊天头像大小 */
const CGFloat kUDAvatarDiameter = 40.0;
/** 时间高度 */
const CGFloat kUDChatMessageDateCellHeight = 14.0f;
/** 发送状态大小 */
const CGFloat kUDSendStatusDiameter = 20.0;
/** 发送状态与气泡的距离 */
const CGFloat kUDBubbleToSendStatusSpacing = 10.0;
/** 时间 Y */
const CGFloat kUDChatMessageDateLabelY   = 10.0f;
/** 气泡箭头宽度 */
const CGFloat kUDArrowMarginWidth        = 10.5f;
/** 底部留白 */
const CGFloat kUDCellBottomMargin = 10.0;
/** 客服昵称高度 */
const CGFloat kUDAgentNicknameHeight = 15.0;

@interface UdeskBaseMessage()

/** 是否显示时间 */
@property (nonatomic, assign) BOOL       displayTimestamp;
/** date高度 */
@property (nonatomic, assign) CGFloat    dateHeight;
/** 消息发送人昵称 */
@property (nonatomic, copy  ) NSString   *nickName;
/** 聊天气泡图片 */
@property (nonatomic, strong) UIImage    *bubbleImage;
/** 重发图片 */
@property (nonatomic, strong) UIImage    *failureImage;
/** 消息发送人头像 */
@property (nonatomic, copy, readwrite) NSString   *avatarURL;
/** 消息发送人头像 */
@property (nonatomic, strong, readwrite) UIImage  *avatarImage;

@end

@implementation UdeskBaseMessage

- (instancetype)initWithMessage:(UdeskMessage *)message displayTimestamp:(BOOL)displayTimestamp
{
    self = [super init];
    if (self) {
        
        _message = message;
        _messageId = message.messageId;
        _displayTimestamp = displayTimestamp;
        
        [self defaultLayout];
    }
    return self;
}

- (void)defaultLayout {
    
    [self layoutDate];
    [self layoutAvatar];
    
    //重发按钮图片
    self.failureImage = [UIImage udDefaultRefreshImage];
    
    _cellHeight += _dateHeight;
    _cellHeight += kUDCellBottomMargin;
}

//时间
- (void)layoutDate {
    
    _dateHeight = 0;
    NSString *time = [[UdeskDateUtil sharedFormatter] udStyleDateForDate:self.message.timestamp];
    if (time.length == 0) return;
    
    if (_displayTimestamp) {
        
        _dateFrame = CGRectMake(0, kUDChatMessageDateLabelY, UD_SCREEN_WIDTH, kUDChatMessageDateCellHeight);
        _dateHeight = kUDChatMessageDateCellHeight;
    }
}

//头像
- (void)layoutAvatar {
    
    //布局
    if (self.message.messageFrom == UDMessageTypeReceiving) {
        //用户头像frame
        self.avatarFrame = CGRectMake(kUDAvatarToHorizontalEdgeSpacing, self.dateFrame.origin.y+self.dateFrame.size.height+kUDAvatarToVerticalEdgeSpacing, kUDAvatarDiameter, kUDAvatarDiameter);
        if (![UdeskSDKUtil isBlankString:self.message.nickName]) {
            self.nicknameFrame = CGRectMake(CGRectGetMaxX(self.avatarFrame)+kUDAvatarToBubbleSpacing, CGRectGetMinY(self.avatarFrame), UD_SCREEN_WIDTH>320?235:180, kUDAgentNicknameHeight);
        }
        self.avatarImage = [UIImage udDefaultAgentImage];
        self.avatarURL = self.message.avatar;
    }
    else if (self.message.messageFrom == UDMessageTypeSending) {
    
        self.avatarFrame = CGRectMake(UD_SCREEN_WIDTH-kUDAvatarToHorizontalEdgeSpacing-kUDAvatarDiameter, self.dateFrame.origin.y+self.dateFrame.size.height+ kUDAvatarToVerticalEdgeSpacing, kUDAvatarDiameter, kUDAvatarDiameter);
        //数据
        self.avatarImage = [UdeskSDKConfig customConfig].sdkStyle.customerImage;
        self.avatarURL = [UdeskSDKConfig customConfig].sdkStyle.customerImageURL;
    }
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {

    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
