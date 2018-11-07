//
//  UdeskBaseCell.h
//  UdeskSDK
//
//  Created by Udesk on 16/8/17.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UdeskBaseMessage.h"

@protocol UdeskCellDelegate <NSObject>

/** 点击了聊天的图片 */
- (void)didTapChatImageView;
/** 点击结构化消息按钮 */
- (void)didTapStructMessageButtonWithValue:(NSString *)value callbackName:(NSString *)callbackName;
/** 点击了地理位置消息 */
- (void)didTapLocationMessage:(UdeskMessage *)message;
/** 商品消息 */
- (void)didTapGoodsMessageWithURL:(NSString *)goodsURL goodsId:(NSString *)goodsId;
/** 发送咨询对象连接 */
- (void)didSendProductURL:(NSString *)url;
/** 点击视频通话消息 */
- (void)didTapUdeskVideoCallMessage:(UdeskMessage *)message;
/** 重新发送消息 */
- (void)didResendMessage:(UdeskMessage *)resendMessage;
/** 点击了留言 */
- (void)didTapLeaveMessageButton:(UdeskMessage *)message;

@end

@interface UdeskBaseCell : UITableViewCell

@property (nonatomic, weak) id<UdeskCellDelegate> delegate;

/** 客户头像 */
@property (nonatomic, strong, readonly) UIImageView *avatarImageView;
/** 气泡 */
@property (nonatomic, strong, readonly) UIImageView *bubbleImageView;
/** 客服昵称 */
@property (nonatomic, strong, readonly) UILabel     *nicknameLabel;
/** 时间 */
@property (nonatomic, strong, readonly) UILabel     *dateLabel;
/** 重发 */
@property (nonatomic, strong, readonly) UIButton    *resetButton;
/** 菊花 */
@property (nonatomic, strong, readonly) UIActivityIndicatorView *sendingIndicator;
/** 布局 */
@property (nonatomic, strong) UdeskBaseMessage  *baseMessage;

- (void)updateCellWithMessage:(UdeskBaseMessage *)baseMessage;

//更新消息状态
- (void)updateMessageSendStatus:(UDMessageSendStatus)sendStatus;

@end
