//
//  UdeskPreviewNavBar.h
//  UdeskImagePickerController
//
//  Created by xuchen on 2018/3/9.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UdeskButton.h"
@class UdeskPreviewNavBar;

@protocol UdeskPreviewNavBarDelegate <NSObject>

- (void)previewNavBarDidSelectBackButton:(UdeskPreviewNavBar *)navBar;
- (void)previewNavBarDidSelectAsset:(UdeskPreviewNavBar *)navBar;

@end

@interface UdeskPreviewNavBar : UIView

@property (nonatomic, strong) UdeskButton *backButton;
@property (nonatomic, strong) UdeskButton *selectButton;

@property (nonatomic, weak  ) id<UdeskPreviewNavBarDelegate> delegate;

@property (nonatomic, assign) NSInteger selectionIndex;

@end
