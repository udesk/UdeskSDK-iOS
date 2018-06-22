//
//  UdeskEmojiCollectionView.m
//  UdeskSDK
//
//  Created by xuchen on 2018/3/24.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskEmojiCollectionView.h"
#import "UdeskEmojiCollectionViewCell.h"
#import "UdeskEmojiCollectionViewFlowLayout.h"

static NSString *kUdeskEmojiCellReuseIdentifier = @"kUdeskEmojiCellReuseIdentifier";

@interface UdeskEmojiCollectionView()<UICollectionViewDelegate,UICollectionViewDataSource,UdeskEmojiCollectionViewCellDelegate>

@property(nonatomic, strong) UdeskEmojiPanelModel *currentPackage;

@end

@implementation UdeskEmojiCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    
    self.showsHorizontalScrollIndicator = NO;
    self.pagingEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
    self.showsVerticalScrollIndicator = NO;
    self.dataSource = self;
    self.delegate = self;
    [self registerClass:[UdeskEmojiCollectionViewCell class] forCellWithReuseIdentifier:kUdeskEmojiCellReuseIdentifier];
    
    return self;
}

- (void)updateEmojiContents:(NSArray *)emojiContents emojiPanels:(NSArray *)emojiPanels {
    self.emojiContents = emojiContents;
    self.emojiPanels = emojiPanels;
    
    [((UdeskEmojiCollectionViewFlowLayout *)self.collectionViewLayout) updatePageContent:emojiPanels];
    [self reloadData];
}

#pragma mark - @protocol UICollectionViewDataSource && UICollectionViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    @try {
     
        NSInteger page = ceil(self.contentOffset.x/self.frame.size.width);
        if (page >= self.emojiContents.count) {
            return;
        }
        
        UdeskEmojiPage *pageObject = [self.emojiContents objectAtIndex:page];
        
        [self updatePageControl:pageObject.pageIndex totalPageCount:pageObject.pageCount];
        
        if (self.currentPackage != pageObject.panelInfo) {
            if (self.udDelegate && [self.udDelegate respondsToSelector:@selector(onScrolledToNewPackage:)]) {
                [self.udDelegate onScrolledToNewPackage:[self.emojiPanels indexOfObject:pageObject.panelInfo]];
            }
            self.currentPackage = pageObject.panelInfo;
        }
        
        if (self.udDelegate && [self.udDelegate respondsToSelector:@selector(adjustPanelPositionAtIndex:)]) {
            [self.udDelegate adjustPanelPositionAtIndex:[self.emojiPanels indexOfObject:pageObject.panelInfo]];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger pageNumber = 0;
    for (UdeskEmojiPanelModel *panelModel in self.emojiPanels) {
        pageNumber += [panelModel pageCount];
    };
    return pageNumber;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UdeskEmojiCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kUdeskEmojiCellReuseIdentifier forIndexPath:indexPath];
    
    cell.delegate = self;
    UdeskEmojiPage *currentPage = [self.emojiContents objectAtIndex:indexPath.row];
    [cell updateEmojiPanel:currentPage.panelInfo atIndex:currentPage.pageIndex];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.frame.size;
}

#pragma mark - Cell Padding
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - UdeskEmojiCollectionViewCellDelegate
- (void)didSelectEmojiWithType:(UdeskEmojiType)emojiType resource:(NSString *)resource {
    
    switch (emojiType) {
        case UdeskEmojiTypeDefault:
            
            if (self.udActionDelegate && [self.udActionDelegate respondsToSelector:@selector(emojiViewDidPressEmojiWithResource:)]) {
                [self.udActionDelegate emojiViewDidPressEmojiWithResource:resource];
            }
            
            break;
        case UdeskEmojiTypeSticker:

            if (self.udActionDelegate && [self.udActionDelegate respondsToSelector:@selector(emojiViewDidPressStickerWithResource:)]) {
                [self.udActionDelegate emojiViewDidPressStickerWithResource:resource];
            }
            
            break;
            
        default:
            break;
    }
}

- (void)emojiViewDidPressDelete {
    
    if (self.udActionDelegate && [self.udActionDelegate respondsToSelector:@selector(emojiViewDidPressDelete)]) {
        [self.udActionDelegate emojiViewDidPressDelete];
    }
}

#pragma mark - Panel Tapping
- (void)tapPackagePaneAtIndex:(NSInteger)packageIndex {
    
    if ([self.emojiPanels indexOfObject:self.currentPackage] == packageIndex) {
        return;
    }
    
    @try {
        
        float scrollX = 0;
        
        for (int index = 0; index < packageIndex; index++) {
            UdeskEmojiPanelModel *panel = [self.emojiPanels objectAtIndex:index];
            scrollX += [panel pageCount] * [UIScreen mainScreen].bounds.size.width;
        }
        self.currentPackage = [self.emojiPanels objectAtIndex:packageIndex];
        [self setContentOffset:CGPointMake(scrollX, 0) animated:NO];
        self.pageControl.currentPage = 0;
        [self updatePageControl:0 totalPageCount:[self.currentPackage pageCount]];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

#pragma mark - Page Control
- (void)updatePageControl:(NSInteger)index totalPageCount:(NSInteger)totalPageCount {
    self.pageControl.currentPage = index;
    self.pageControl.numberOfPages = totalPageCount;
}

@end
