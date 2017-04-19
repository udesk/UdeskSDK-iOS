//
//  UdeskMessageTableView.h
//  UdeskSDK
//
//  Created by Udesk on 15/12/22.
//  Copyright © 2015年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UdeskChatViewModel;
@class UdeskMessage;


@interface UdeskMessageTableView : UITableView
/**
 *  菊花头视图
 */
@property (nonatomic, weak  ) UIView                  *headView;
/**
 *  菊花
 */
@property (nonatomic, weak  ) UIActivityIndicatorView *activity;
/**
 *  记录刷新状态
 */
@property (nonatomic, assign) BOOL                    isRefresh;

/**
 *  开始加载更多消息
 */
- (void)startLoadingMoreMessages;
/**
 *  加载结束更多消息
 */
- (void)finishLoadingMoreMessages:(BOOL)isShowRefresh;
/**
 *  设置TableView bottom
 *
 *  @param bottom bottom
 */
- (void)setTableViewInsetsWithBottomValue:(CGFloat)bottom;
/**
 *  TableView 滚到底部
 *
 *  @param animated 是否动画
 */
- (void)scrollToBottomAnimated:(BOOL)animated;

@end
