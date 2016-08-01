//
//  UdeskMessageTableViewCell.h
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UdeskConfigurationHelper.h"
#import "UdeskMessageContentView.h"
#import "UdeskMessage.h"

@class UdeskMessageTableViewCell;

@protocol UDMessageTableViewCellDelegate <NSObject>

@optional
/**
 *  点击多媒体消息的时候统一触发这个回调
 *
 *  @param message   被操作的目标消息Model
 *  @param indexPath 该目标消息在哪个IndexPath里面
 *  @param messageTableViewCell 目标消息在该Cell上
 */
- (void)didSelectedOnMessage:(UdeskMessage *)message
                   indexPath:(NSIndexPath *)indexPath
        messageTableViewCell:(UdeskMessageTableViewCell *)messageTableViewCell;

@end

@interface UdeskMessageTableViewCell : UITableViewCell

@property (nonatomic, weak  ) id <UDMessageTableViewCellDelegate> delegate;

/**
 *  自定义多媒体消息内容View
 */
@property (nonatomic, weak  ) UdeskMessageContentView            *messageContentView;

/**
 *  头像按钮
 */
@property (nonatomic, weak  ) UIImageView                        *headImageView;

/**
 *  时间轴Label
 */
@property (nonatomic, weak  ) UILabel                            *timestampLabel;

/**
 *  Cell所在的位置，用于Cell delegate回调
 */
@property (nonatomic, strong) NSIndexPath                        *indexPath;

/**
 *  获取消息类型
 *
 *  @return 返回消息类型，比如是发送消息，又或者是接收消息
 */
- (UDMessageFromType)bubbleMessageType;

/**
 *  初始化Cell的方法，必须先调用这个，不然不会初始化显示控件
 *
 *  @param message          需显示的目标消息Model
 *  @param displayTimestamp 预先告知是否需要显示时间轴Label
 *  @param cellIdentifier   重用Cell的标识
 *
 *  @return 返回消息Cell对象
 */
- (instancetype)initWithMessage:(UdeskMessage *)message
              displaysTimestamp:(BOOL)displayTimestamp
                reuseIdentifier:(NSString *)cellIdentifier;

/**
 *  根据消息Model配置Cell的显示内容
 *
 *  @param message          目标消息Model
 *  @param displayTimestamp 配置的时候告知是否需要显示时间轴Label
 */
- (void)configureCellWithMessage:(UdeskMessage *)message
               displaysTimestamp:(BOOL)displayTimestamp;

/**
 *  根据消息Model计算Cell的高度
 *
 *  @param message          目标消息Model
 *  @param displayTimestamp 是否显示时间轴Label
 *
 *  @return 返回Cell所需要的高度
 */
+ (CGFloat)calculateCellHeightWithMessage:(UdeskMessage *)message
                        displaysTimestamp:(BOOL)displayTimestamp;


@end
