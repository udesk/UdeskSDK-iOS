//
//  UdeskEmojiPanelModel.m
//  UdeskSDK
//
//  Created by xuchen on 2018/3/26.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskEmojiPanelModel.h"

static CGFloat kEmojiSize = 35;
static CGFloat kStickerSize = 52;

@implementation UdeskEmojiPanelModel

- (NSInteger)rowCount {
 
    if (self.emojiType == UdeskEmojiTypeDefault) {
        return 3;
    }
    else {
        return 2;
    }
}

- (NSInteger)columnCount {
    
    if (self.emojiType == UdeskEmojiTypeDefault) {
        return 7;
    }
    else {
        return 4;
    }
}

- (NSInteger)pageCount {
    
    return ceilf((float)(self.contentArray.count) / ([self columnCount] * [self rowCount]));
}

- (CGFloat)horizontalSpacing {
    
    if (self.emojiType == UdeskEmojiTypeDefault) {
        return ([UIScreen mainScreen].bounds.size.width - [self columnCount] * kEmojiSize)/ ([self columnCount] + 1);
    }
    else {
        return ([UIScreen mainScreen].bounds.size.width - [self columnCount] * kStickerSize)/ ([self columnCount] + 1);
    }
}

- (CGFloat)verticalSpacing {
    
    if (self.emojiType == UdeskEmojiTypeDefault) {
        return 16.0f;
    } else {
        return 13.0f;
    }
}

- (CGFloat)itemSize {
    
    if ((self.emojiType == UdeskEmojiTypeDefault)) {
        return kEmojiSize;
    }
    else {
        return kStickerSize;
    }
}

- (NSArray *)checkItemsAtIndexedPage:(NSInteger)pageIndex {
    
    if (pageIndex >= [self pageCount]) {
        return [NSArray new];
    }
    
    NSInteger numberOfIconPerpage = 0;
    if (self.emojiType == UdeskEmojiTypeDefault) {
        numberOfIconPerpage = [self columnCount] * [self rowCount] -1;
    }
    else {
        numberOfIconPerpage = [self columnCount] * [self rowCount];
    }
    
    NSArray* stickerIcons;
    if (pageIndex == ([self pageCount] -1)) {
        stickerIcons = [self.contentArray subarrayWithRange:NSMakeRange(numberOfIconPerpage * pageIndex, self.contentArray.count - numberOfIconPerpage * pageIndex)];
    } else {
        stickerIcons = [self.contentArray subarrayWithRange:NSMakeRange(numberOfIconPerpage * pageIndex, numberOfIconPerpage)];
    }
    
    return stickerIcons;
}

@end

@implementation UdeskEmojiPage

@end

@implementation UdeskEmojiContentModel

- (NSInteger)checkCurrentPageInPackage:(UdeskEmojiPanelModel *)panel {
    return (int)[panel.contentArray indexOfObject:self] / ([panel rowCount] * [panel columnCount]  -1);
}

- (NSInteger)checkIndexInPage:(UdeskEmojiPanelModel *)panel {
    return [panel.contentArray indexOfObject:self] % ([panel rowCount] * [panel columnCount]  - 1);
}

@end
