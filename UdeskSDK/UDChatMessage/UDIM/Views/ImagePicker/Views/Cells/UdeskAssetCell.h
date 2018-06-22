//
//  UdeskAssetCell.h
//  UdeskImagePickerController
//
//  Created by xuchen on 2018/3/6.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UdeskButton.h"
@class UdeskAssetModel;
@class UdeskAssetCell;

@protocol UdeskAssetCellDelegate <NSObject>

- (void)assetCell:(UdeskAssetCell *)assetCell didSelectAsset:(BOOL)isSelected;

@end

@interface UdeskAssetCell : UICollectionViewCell

@property (nonatomic, strong) UdeskButton  *selectAssetButton;
@property (nonatomic, strong) UdeskAssetModel *assetModel;
@property (nonatomic, assign) int32_t imageRequestID;

@property (nonatomic, assign) NSInteger selectionIndex;

@property (nonatomic, weak) id<UdeskAssetCellDelegate> udDelegate;

@end
