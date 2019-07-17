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
- (void)didTapGoodsMessageWithModel:(UdeskGoodsModel *)goodsModel;
/** 点击视频通话消息 */
- (void)didTapUdeskVideoCallMessage:(UdeskMessage *)message;
/** 重新发送消息 */
- (void)didResendMessage:(UdeskMessage *)resendMessage;
/** 点击了留言 */
- (void)didTapLeaveMessageButton:(UdeskMessage *)message;
/** 发送机器人消息 */
- (void)didSendRobotMessage:(UdeskMessage *)message;
/** 点击了转人工 */
- (void)didTapTransferAgentServer:(UdeskMessage *)message;
/** 答案已评价 */
- (void)aswerHasSurvey;
/** 刷新 */
- (void)reloadTableViewAtCell:(UITableViewCell *)cell;

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

/** 机器人答案有用按钮 */
@property (nonatomic, strong, readonly) UIButton    *usefulButton;
/** 机器人答案无用按钮 */
@property (nonatomic, strong, readonly) UIButton    *uselessButton;
/** 机器人转人工按钮 */
@property (nonatomic, strong, readonly) UIButton    *transferButton;

/** 布局 */
@property (nonatomic, strong) UdeskBaseMessage  *baseMessage;

- (void)updateCellWithMessage:(UdeskBaseMessage *)baseMessage;

//更新消息状态
- (void)updateMessageSendStatus:(UDMessageSendStatus)sendStatus;

- (void)callPhoneNumber:(NSString *)phoneNumber;
- (void)flowMessageWithText:(NSString *)text flowContent:(NSString *)flowContent;
- (void)udOpenURL:(NSURL *)URL;

@end
