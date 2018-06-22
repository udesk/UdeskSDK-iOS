//
//  UdeskEmojiCollectionViewFlowLayout.m
//  UdeskSDK
//
//  Created by xuchen on 2018/3/26.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskEmojiCollectionViewFlowLayout.h"
#import "UdeskEmojiPanelModel.h"
#import "UdeskEmojiPackagePanel.h"

static CGFloat kEmojiKeyboardHeight = 220;

@interface UdeskEmojiCollectionViewFlowLayout()

@property(assign, nonatomic)int numberOfPage;

@end

@implementation UdeskEmojiCollectionViewFlowLayout

- (instancetype)init {
    self = [super init];
    
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, kEmojiKeyboardHeight);
    self.sectionInset = UIEdgeInsetsZero;
    self.minimumInteritemSpacing = 0.0;
    self.minimumLineSpacing = 0.0;
    return self;
}

- (void)updatePageContent:(NSArray *)packageList {
    int numberOfPage = 0;
    for (UdeskEmojiPanelModel *stickerPackage in packageList) {
        numberOfPage += [stickerPackage pageCount];
    }
    
    self.numberOfPage = numberOfPage;
}

- (CGSize)collectionViewContentSize {
    
    return CGSizeMake(self.numberOfPage * [UIScreen mainScreen].bounds.size.width, kEmojiKeyboardHeight - UdeskEmojiPackagePanelHeight);
}

@end
