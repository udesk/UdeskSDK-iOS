//
//  UdeskMessageTableView.m
//  UdeskSDK
//
//  Created by Udesk on 15/12/22.
//  Copyright © 2015年 Udesk. All rights reserved.
//

#import "UdeskMessageTableView.h"
#import "UdeskSDKMacro.h"

@interface UdeskMessageTableView()
@end

@implementation UdeskMessageTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.separatorColor = [UIColor clearColor];
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.scrollsToTop = NO;
        if (ud_isIOS11) {
            self.estimatedRowHeight = 0;
            self.estimatedSectionHeaderHeight = 0;
            self.estimatedSectionFooterHeight = 0;
        }
        
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UD_SCREEN_WIDTH, 25)];
        _headView.backgroundColor = [UIColor clearColor];
        
        _loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _loading.hidden = NO;
        _loading.frame = CGRectMake(_headView.frame.size.width/2-10, 5, 20, 25);
        [_headView addSubview:_loading];
        
        self.tableHeaderView = _headView;
        
        self.canRefresh = YES;
    }
    return self;
}

//设置ContentSize
- (void)setContentSize:(CGSize)contentSize
{
    @try {
     
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
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

//开始下拉
- (void)startLoadingMoreMessages {

    self.headView.hidden = NO;
    [self.loading startAnimating];
    self.canRefresh = NO;
}

//下拉结束
- (void)finishLoadingMoreMessages:(BOOL)isShowRefresh {
    //没有更多，移除菊花
    if (!isShowRefresh) {
        //没有更多消息停止刷新
        [self.loading stopAnimating];
        self.headView.hidden = YES;
        [self.headView removeFromSuperview];
        [self.loading removeFromSuperview];
        self.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];;
    }
    
    self.canRefresh = isShowRefresh;
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
    
    @try {
        
        NSInteger rows = [self numberOfRowsInSection:0];
        
        if (rows > 0) {
            [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                        atScrollPosition:UITableViewScrollPositionBottom
                                animated:animated];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

@end
