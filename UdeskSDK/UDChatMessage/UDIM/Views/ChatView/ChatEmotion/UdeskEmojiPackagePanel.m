//
//  UdeskEmojiPackagePanel.m
//  UdeskSDK
//
//  Created by xuchen on 2018/3/24.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskEmojiPackagePanel.h"
#import "UdeskEmojiPanelModel.h"

static CGFloat kPackagePanelWidth = 54;

@interface UdeskEmojiPackagePanel()

@property(nonatomic, strong) UIView *currentHighlightView;

@end

@implementation UdeskEmojiPackagePanel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.alwaysBounceHorizontal = NO;
        self.bounces = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
    }
    return self;
}

- (void)setEmojiPanels:(NSArray *)emojiPanels {
    if (!emojiPanels || emojiPanels == (id)kCFNull) return ;
    if (![emojiPanels isKindOfClass:[NSArray class]]) return ;
    _emojiPanels = emojiPanels;
    
    float offsetX = 0;
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (UdeskEmojiPanelModel *panelModel in emojiPanels) {
        
        UIButton *panelTab = [UIButton buttonWithType:UIButtonTypeCustom];
        panelTab.tag = [emojiPanels indexOfObject:panelModel] + 1024;
        panelTab.frame = CGRectMake(offsetX, 0, kPackagePanelWidth, UdeskEmojiPackagePanelHeight);
        [panelTab setImage:panelModel.emojiIcon forState:UIControlStateNormal];
        [panelTab addTarget:self action:@selector(panelTabAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:panelTab];
        
        offsetX += kPackagePanelWidth;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.emojiPanels firstObject] == panelModel) {
                [self selectTag:panelTab fireDelegate:YES];
            }
        });
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentSize = CGSizeMake(self.emojiPanels.count *  kPackagePanelWidth, UdeskEmojiPackagePanelHeight);
}

#pragma mark - Panel Click
- (void)selectTag:(UIView *)panelTab fireDelegate:(BOOL)needFire {
    @try {
        
        if (panelTab.tag - 1024 >= self.emojiPanels.count ||
            panelTab == self.currentHighlightView) {
            return;
        }
        
        [self scrollRectToVisible:panelTab.frame animated:YES];
        
        if (needFire) {
            if (self.udDelegate && [self.udDelegate respondsToSelector:@selector(tapPackagePaneAtIndex:)]) {
                [self.udDelegate tapPackagePaneAtIndex:panelTab.tag-1024];
            }
        }
        
        [self.currentHighlightView setBackgroundColor:[UIColor whiteColor]];
        self.currentHighlightView = panelTab;
        
        panelTab.backgroundColor = [UIColor colorWithWhite:0.961 alpha:1.000];
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)panelTabAction:(UIButton *)button {
    [self selectTag:button fireDelegate:YES];
}

#pragma mark Scroll Content Delegate
- (void)onScrolledToNewPackage:(int)index {
    UIView *tab = [self viewWithTag:index+1024];
    [self selectTag:tab fireDelegate:NO];
}

- (void)adjustPanelPositionAtIndex:(int)index {
    UIView *tab = [self viewWithTag:index+1024];
    [self scrollRectToVisible:tab.frame animated:YES];
}

@end
