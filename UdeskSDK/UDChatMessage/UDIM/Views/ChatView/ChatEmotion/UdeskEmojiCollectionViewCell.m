//
//  UdeskEmojiCollectionViewCell.m
//  UdeskSDK
//
//  Created by xuchen on 2018/3/26.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskEmojiCollectionViewCell.h"
#import "UdeskBundleUtils.h"
#import "UIView+UdeskSDK.h"

@interface UdeskEmojiCollectionViewCell ()

@property(nonatomic, strong) UIView *pageContentView;
@property(nonatomic, weak  ) UdeskEmojiPanelModel *currentEmojiPanel;

@end

@implementation UdeskEmojiCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self checkPageView];
    }
    return self;
}

- (void)checkPageView {
    
    if (self.pageContentView) {
        [[self.pageContentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.pageContentView removeFromSuperview];
    }
    
    _pageContentView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:_pageContentView];
}

- (void)updateEmojiPanel:(UdeskEmojiPanelModel *)emojiPanel atIndex:(NSInteger)index {
    
    [[self.pageContentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.currentEmojiPanel = emojiPanel;
    
    NSArray *emojiContents = [emojiPanel checkItemsAtIndexedPage:index];
    NSInteger coloumnPerpage =  [emojiPanel columnCount];
    CGFloat horizontalSpacing = [emojiPanel horizontalSpacing];
    CGFloat verticalSpacing = [emojiPanel verticalSpacing];
    CGFloat itemSize = [emojiPanel itemSize];
    
    for (UdeskEmojiContentModel *emojiContent in emojiContents) {
        NSInteger pageIndex = [emojiContents indexOfObject:emojiContent];
        NSInteger rowPosition = (pageIndex) / coloumnPerpage;
        NSInteger coloumnPosition = (pageIndex) % coloumnPerpage;
        
        CGFloat emojiViewX = horizontalSpacing + coloumnPosition * (itemSize + horizontalSpacing);
        CGFloat emojiViewY = verticalSpacing + (verticalSpacing + itemSize) * rowPosition;

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = [emojiPanel.contentArray indexOfObject:emojiContent];
        button.frame = CGRectMake(emojiViewX, emojiViewY, itemSize, itemSize);
        button.titleLabel.font = [UIFont fontWithName:@"Apple color emoji" size:30];
        [self.pageContentView addSubview:button];
        
        if (emojiContent.emojiType == UdeskEmojiTypeDefault) {
            [button setTitle:emojiContent.resource forState:UIControlStateNormal];
        }
        else {
            
            if (rowPosition > 0) {
                button.udTop += 18;
            }
            
            [button setImage:emojiContent.stickerImage forState:UIControlStateNormal];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(emojiViewX, button.udBottom+6, itemSize, 12)];
            label.font = [UIFont systemFontOfSize:12];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor colorWithRed:0.541f  green:0.541f  blue:0.541f alpha:1];
            label.text = emojiContent.stickerTitle;
            [self.pageContentView addSubview:label];
        }
        
        [button addTarget:self action:@selector(emojiViewTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (emojiPanel.emojiType == UdeskEmojiTypeDefault) {
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteButton.frame = CGRectMake(horizontalSpacing + (coloumnPerpage - 1) * (itemSize + horizontalSpacing), verticalSpacing + (verticalSpacing + itemSize)* ([emojiPanel rowCount] - 1), itemSize, itemSize);
        [deleteButton setImage:[UIImage imageWithContentsOfFile:getUDBundlePath(@"udEmojiDelete.png")] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        deleteButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
        [self.pageContentView addSubview:deleteButton];
    }
}

- (void)deleteButtonAction:(UIButton *)button {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(emojiViewDidPressDelete)]) {
        [self.delegate emojiViewDidPressDelete];
    }
}

- (void)emojiViewTapped:(UIButton *)button {
    
    @try {
     
        UdeskEmojiPanelModel *emojiPanel = self.currentEmojiPanel;
        
        if ([emojiPanel.contentArray count] > button.tag) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectEmojiWithType:resource:)]) {
                UdeskEmojiContentModel *model = [emojiPanel.contentArray objectAtIndex:button.tag];
                [self.delegate didSelectEmojiWithType:model.emojiType resource:model.resource];
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

@end
