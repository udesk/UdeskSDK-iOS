//
//  UdeskEmojiCollectionViewCell.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/26.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UdeskEmojiPanelModel.h"

@protocol UdeskEmojiCollectionViewCellDelegate <NSObject>

- (void)didSelectEmojiWithType:(UdeskEmojiType)emojiType resource:(NSString *)resource;
- (void)emojiViewDidPressDelete;

@end

@interface UdeskEmojiCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id<UdeskEmojiCollectionViewCellDelegate> delegate;

- (void)updateEmojiPanel:(UdeskEmojiPanelModel *)emojiPanel atIndex:(NSInteger)index;

@end
