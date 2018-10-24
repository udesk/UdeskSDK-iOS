//
//  UdeskEmojiKeyboardControl.m
//  UdeskSDK
//
//  Created by xuchen on 2018/3/24.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskEmojiKeyboardControl.h"
#import "UdeskEmojiPackagePanel.h"
#import "UdeskEmojiCollectionView.h"
#import "UdeskEmojiManager.h"
#import "UdeskEmojiCollectionViewFlowLayout.h"
#import "UdeskBundleUtils.h"
#import "UdeskSDKMacro.h"

@interface UdeskEmojiKeyboardControl()<UdeskEmojiCollectionViewActionDelegate>

@property (nonatomic, strong) UdeskEmojiManager *emojiManager;
@property (nonatomic, strong) UIView   *bottomView;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UdeskEmojiPackagePanel *packagePanel;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UdeskEmojiCollectionView *emojiCollectionView;

@end

@implementation UdeskEmojiKeyboardControl

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    _bottomView = [[UIView alloc] initWithFrame:CGRectZero];
    _bottomView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_bottomView];
    
    _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_sendButton setTitle:getUDLocalizedString(@"udesk_send") forState:UIControlStateNormal];
    _sendButton.backgroundColor = [UIColor colorWithRed:0.035f  green:0.482f  blue:1 alpha:1];
    _sendButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sendButton addTarget:self action:@selector(sendEmojiAction) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_sendButton];
    
    _packagePanel = [[UdeskEmojiPackagePanel alloc] initWithFrame:CGRectZero];
    _packagePanel.emojiPanels = self.emojiManager.emojiPanels;
    [_bottomView addSubview:_packagePanel];
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
    _pageControl.hidesForSinglePage = YES;
    _pageControl.enabled = NO;
    _pageControl.defersCurrentPageDisplay = YES;
    _pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:0.545f  green:0.545f  blue:0.545f alpha:1];
    _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:0.733f  green:0.733f  blue:0.733f alpha:1];
    
    _emojiCollectionView = [[UdeskEmojiCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[UdeskEmojiCollectionViewFlowLayout new]];
    _emojiCollectionView.pageControl = _pageControl;
    [self addSubview:_emojiCollectionView];
    [_emojiCollectionView updateEmojiContents:self.emojiManager.emojiContents emojiPanels:self.emojiManager.emojiPanels];
    
    _emojiCollectionView.udActionDelegate = self;
    _emojiCollectionView.udDelegate = (id<UdeskEmojiCollectionViewDelegate>)_packagePanel;
    _packagePanel.udDelegate = (id<UdeskEmojiPackagePanelDelegate>)_emojiCollectionView;
    
    [self addSubview:_pageControl];
}

- (void)sendEmojiAction {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(emojiViewDidPressSend)]) {
        [self.delegate emojiViewDidPressSend];
    }
}

#pragma mark - @protocol UdeskEmojiCollectionViewActionDelegate
- (void)emojiViewDidPressEmojiWithResource:(NSString *)resource {
    if (!resource || resource == (id)kCFNull) return ;
    if (![resource isKindOfClass:[NSString class]]) return ;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(emojiViewDidPressEmojiWithResource:)]) {
        [self.delegate emojiViewDidPressEmojiWithResource:resource];
    }
}

- (void)emojiViewDidPressStickerWithResource:(NSString *)resource {
    if (!resource || resource == (id)kCFNull) return ;
    if (![resource isKindOfClass:[NSString class]]) return ;

    if (self.delegate && [self.delegate respondsToSelector:@selector(emojiViewDidPressStickerWithResource:)]) {
        [self.delegate emojiViewDidPressStickerWithResource:resource];
    }
}

- (void)emojiViewDidPressDelete {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(emojiViewDidPressDelete)]) {
        [self.delegate emojiViewDidPressDelete];
    }
}

- (UdeskEmojiManager *)emojiManager {
    if (!_emojiManager) {
        _emojiManager = [[UdeskEmojiManager alloc] init];
    }
    return _emojiManager;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat spacing = (udIsIPhoneXSeries ? 34 : 0);
    self.bottomView.frame = CGRectMake(0, CGRectGetHeight(self.frame)-UdeskEmojiPackagePanelHeight-spacing, CGRectGetWidth(self.frame), UdeskEmojiPackagePanelHeight+spacing);
    self.sendButton.frame = CGRectMake(CGRectGetWidth(self.bottomView.frame)-70, 0, 70, UdeskEmojiPackagePanelHeight);
    self.packagePanel.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame)-CGRectGetWidth(self.sendButton.frame), UdeskEmojiPackagePanelHeight);
    self.pageControl.frame = CGRectMake(0, CGRectGetHeight(self.frame)-UdeskEmojiPackagePanelHeight-10-8-spacing, CGRectGetWidth(self.frame), 10);
    self.emojiCollectionView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-UdeskEmojiPackagePanelHeight-10-spacing);
}

- (void)dealloc {
    
    _emojiCollectionView.udActionDelegate = nil;
    _emojiCollectionView.udDelegate = nil;
    _packagePanel.udDelegate = nil;
}

@end
