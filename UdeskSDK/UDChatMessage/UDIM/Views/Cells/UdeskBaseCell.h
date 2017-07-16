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

- (void)didSelectImageCell;

- (void)sendProductURL:(NSString *)url;

- (void)didSelectStructButton;

- (void)resendMessageInCell:(UITableViewCell *)cell resendMessage:(UdeskMessage *)resendMessage;

@end

@interface UdeskBaseCell : UITableViewCell

@property (nonatomic, weak) id<UdeskCellDelegate> delegate;

/** 客户头像 */
@property (nonatomic, strong) UIImageView *avatarImageView;
/** 气泡 */
@property (nonatomic, strong) UIImageView *bubbleImageView;
/** 时间 */
@property (nonatomic, strong) UILabel     *dateLabel;
/** 重发 */
@property (nonatomic, strong) UIButton    *resetButton;
/** 菊花 */
@property (nonatomic, strong) UIActivityIndicatorView *sendingIndicator;
/** 布局 */
@property (nonatomic, strong) UdeskBaseMessage  *baseMessage;

- (void)updateCellWithMessage:(UdeskBaseMessage *)baseMessage;

- (void)setActivityIndicatorViewFrameWithSendStatus:(UDMessageSendStatus)sendStatus;

@end
