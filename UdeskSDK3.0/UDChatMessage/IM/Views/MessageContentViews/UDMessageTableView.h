//
//  UDMessageTableView.h
//  UdeskSDK
//
//  Created by xuchen on 15/12/22.
//  Copyright © 2015年 xuchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UDChatViewModel;
@class UDMessageTableViewCell;
@class UDMessage;

@protocol UDChatTableViewDelegate <NSObject>

/**
 *  点击了视图回调
 *
 *  @param tableView 点击的视图
 */
- (void)didTapChatTableView:(UITableView *)tableView;
/**
 *  视图滚动回调
 *
 *  @param UIScrollView 滚动的视图
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
/**
 *  处理下拉刷新
 *
 *  @param UIScrollView UIScrollView
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

/**
 *  点击消息
 *
 *  @param message              消息
 *  @param indexPath            消息的indexPath
 *  @param messageTableViewCell 消息对应的cell
 */
- (void)didSelectedOnMessage:(UDMessage *)message indexPath:(NSIndexPath *)indexPath messageTableViewCell:(UDMessageTableViewCell *)messageTableViewCell;

@end

@interface UDMessageTableView : UITableView <UITableViewDataSource,UITableViewDelegate>
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
 *  数据源
 */
@property (nonatomic, strong) UDChatViewModel      *chatViewModel;

@property (nonatomic, weak  ) id<UDChatTableViewDelegate> chatTableViewDelegate;

/**
 *  开始加载更多消息
 */
- (void)startLoadingMoreMessages;
/**
 *  加载结束更多消息
 */
- (void)finishLoadingMoreMessages:(NSInteger)count;
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
