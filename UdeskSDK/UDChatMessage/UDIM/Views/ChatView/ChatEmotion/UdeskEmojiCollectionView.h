//
//  UdeskEmojiCollectionView.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/24.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UdeskEmojiCollectionViewDelegate <NSObject>

@required
- (void)onScrolledToNewPackage:(NSInteger)index;
- (void)adjustPanelPositionAtIndex:(NSInteger)index;

@end

@protocol UdeskEmojiCollectionViewActionDelegate <NSObject>

@optional
- (void)emojiViewDidPressEmojiWithResource:(NSString *)resource;
- (void)emojiViewDidPressStickerWithResource:(NSString *)resource;
- (void)emojiViewDidPressDelete;

@end

@interface UdeskEmojiCollectionView : UICollectionView

@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSArray *emojiPanels;
@property (nonatomic, strong) NSArray *emojiContents;

@property (nonatomic, weak  ) id<UdeskEmojiCollectionViewDelegate> udDelegate;
@property (nonatomic, weak  ) id<UdeskEmojiCollectionViewActionDelegate> udActionDelegate;

- (void)updateEmojiContents:(NSArray *)emojiContents emojiPanels:(NSArray *)emojiPanels;

@end
