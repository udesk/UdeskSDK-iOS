//
//  UDMessageTableView.m
//  UdeskSDK
//
//  Created by xuchen on 15/12/22.
//  Copyright © 2015年 xuchen. All rights reserved.
//

#import "UDMessageTableView.h"
#import "UDMessageTableViewCell.h"
#import "UDChatViewModel.h"
#import "UDFoundationMacro.h"
#import "NSArray+UDMessage.h"

@interface UDMessageTableView() <UDMessageTableViewCellDelegate>
@end

@implementation UDMessageTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        
        self.dataSource = self;
        self.delegate = self;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.separatorColor = [UIColor clearColor];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        //添加单击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMessageTableView:)];

        [self addGestureRecognizer:tap];
        
        
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UD_SCREEN_WIDTH, 25)];
        headView.backgroundColor = [UIColor clearColor];
        
        UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [headView addSubview:activity];
        activity.frame = CGRectMake(headView.frame.size.width/2-10, 5, 20, 25);
        
        self.tableHeaderView = headView;
        headView.hidden = YES;
        
        _headView = headView;
        _activity = activity;
        
        _isRefresh = YES;
        
    }
    return self;
}


#pragma mark - Table View Data Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chatViewModel.messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UDMessage * message = [self.chatViewModel.messageArray objectAtIndexCheck:indexPath.row];
    
    BOOL displayTimestamp = [self.chatViewModel shouldDisplayTimeForRowAtIndexPath:indexPath];
    
    static NSString *cellIdentifier = @"UDMessageTableViewCell";
    
    UDMessageTableViewCell *messageTableViewCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!messageTableViewCell) {

        messageTableViewCell = [[UDMessageTableViewCell alloc] initWithMessage:message displaysTimestamp:displayTimestamp reuseIdentifier:cellIdentifier];
        
        messageTableViewCell.delegate = self;
    }
    
    messageTableViewCell.indexPath = indexPath;
    
    [messageTableViewCell configureCellWithMessage:message displaysTimestamp:displayTimestamp];
    [messageTableViewCell setBackgroundColor:tableView.backgroundColor];
    
    return messageTableViewCell;
}

#pragma mark - Table View Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UDMessage *message = [self.chatViewModel.messageArray objectAtIndexCheck:indexPath.row];
    
    CGFloat calculateCellHeight = [self calculateCellHeightWithMessage:message atIndexPath:indexPath];
    
    return calculateCellHeight;
}

#pragma mark - 计算cell的高度
- (CGFloat)calculateCellHeightWithMessage:(UDMessage *)message atIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellHeight = 0;
    
    BOOL displayTimestamp = [self.chatViewModel shouldDisplayTimeForRowAtIndexPath:indexPath];
    
    cellHeight = [UDMessageTableViewCell calculateCellHeightWithMessage:message displaysTimestamp:displayTimestamp];
    
    return cellHeight;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

    if (self.chatTableViewDelegate) {
        if ([self.chatTableViewDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
            [self.chatTableViewDelegate scrollViewWillBeginDragging:scrollView];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (self.chatTableViewDelegate) {
        if ([self.chatTableViewDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
            [self.chatTableViewDelegate scrollViewDidScroll:scrollView];
        }
    }

}

#pragma mark - UDTableViewCellDelegate
- (void)didSelectedOnMessage:(UDMessage *)message indexPath:(NSIndexPath *)indexPath messageTableViewCell:(UDMessageTableViewCell *)messageTableViewCell {
    
    if (self.chatTableViewDelegate) {
        if ([self.chatTableViewDelegate respondsToSelector:@selector(didSelectedOnMessage:indexPath:messageTableViewCell:)]) {
            [self.chatTableViewDelegate didSelectedOnMessage:message indexPath:indexPath messageTableViewCell:messageTableViewCell];
        }
    }

}

//点击了TableView
- (void)tapMessageTableView:(id)sender {

    if (self.chatTableViewDelegate) {
        if ([self.chatTableViewDelegate respondsToSelector:@selector(didTapChatTableView:)]) {
            [self.chatTableViewDelegate didTapChatTableView:self];
        }
    }
}
//设置ContentSize
- (void)setContentSize:(CGSize)contentSize
{
    if (!CGSizeEqualToSize(self.contentSize, CGSizeZero))
    {
        if (contentSize.height > self.contentSize.height)
        {
            CGPoint offset = self.contentOffset;
            offset.y += (contentSize.height - self.contentSize.height);
            self.contentOffset = offset;
        }
    }
    [super setContentSize:contentSize];
}

//开始下拉
- (void)startLoadingMoreMessages {

    self.headView.hidden = NO;
    [self.activity startAnimating];
    _isRefresh = NO;
    
}
//下拉结束
- (void)finishLoadingMoreMessages:(NSInteger)count {

    //消息小于20条移除菊花
    if (count<20) {
        
        //没有更多消息停止刷新
        [self.activity stopAnimating];
        self.headView.hidden = YES;
        [self.headView removeFromSuperview];
        [self.activity removeFromSuperview];
        self.tableHeaderView = nil;
        
        _isRefresh = NO;
        
    }else {
    
        _isRefresh = YES;
    }
    
}

//设置TabelView bottom
- (void)setTableViewInsetsWithBottomValue:(CGFloat)bottom {
    UIEdgeInsets insets = [self tableViewInsetsWithBottomValue:bottom];
    self.contentInset = insets;
    self.scrollIndicatorInsets = insets;
}

- (UIEdgeInsets)tableViewInsetsWithBottomValue:(CGFloat)bottom {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    
    insets.bottom = bottom;
    
    return insets;
}

//滚动TableView
- (void)scrollToBottomAnimated:(BOOL)animated {
    
    NSInteger rows = [self numberOfRowsInSection:0];
    
    if (rows > 0) {
        [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                                     atScrollPosition:UITableViewScrollPositionBottom
                                             animated:animated];
    }
}

@end
