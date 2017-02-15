//
//  UdeskBaseMessage.h
//  UdeskSDK
//
//  Created by xuchen on 16/9/1.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UdeskMessage.h"

@protocol UdeskMessageDelegate <NSObject>

/**
 * 该委托定义了cell中有数据更新，通知tableView可以进行cell的刷新了；
 * @param messageId 该cell中的消息id
 */
- (void)didUpdateCellDataWithMessageId:(NSString *)messageId;

@end

@interface UdeskBaseMessage : NSObject

/** 消息ID */
@property (nonatomic, copy) NSString *messageId;
/** 时间 */
@property (nonatomic, copy) NSDate   *date;
/** cell高度 */
@property (nonatomic, assign) CGFloat  cellHeight;
/** 消息类型 */
@property (nonatomic, assign) UDMessageContentType messageType;
/** 消息发送者 */
@property (nonatomic, assign) UDMessageFromType    messageFrom;
/** 消息发送状态 */
@property (nonatomic, assign) UDMessageSendStatus  messageStatus;

@property (nonatomic, weak) id <UdeskMessageDelegate> delegate;

/**
 *  通过重用的名字初始化cell
 *  @return 初始化了一个cell
 */
- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer;

@end
