//
//  UdeskPreviewNavBar.m
//  UdeskImagePickerController
//
//  Created by xuchen on 2018/3/9.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskPreviewNavBar.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskSDKUtil.h"
#import "UdeskSDKMacro.h"

@implementation UdeskPreviewNavBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    _backButton = [[UdeskButton alloc] initWithFrame:CGRectZero];
    [_backButton setImage:[UIImage udDefaultWhiteBackImage] forState:UIControlStateNormal];
    [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_backButton];
    
    _selectButton = [[UdeskButton alloc] initWithFrame:CGRectZero];
    [_selectButton setImage:[UIImage udDefaultImagePickerNotSelected] forState:UIControlStateNormal];
    [_selectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _selectButton.titleLabel.font = [UIFont systemFontOfSize:15];
    _selectButton.layer.masksToBounds = YES;
    _selectButton.layer.cornerRadius = 11;
    [_selectButton addTarget:self action:@selector(selectAssetAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_selectButton];
}

- (void)backButtonAction {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(previewNavBarDidSelectBackButton:)]) {
        [self.delegate previewNavBarDidSelectBackButton:self];
    }
}

- (void)selectAssetAction:(UdeskButton *)button {
    button.selected = !button.selected;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(previewNavBarDidSelectAsset:)]) {
        [self.delegate previewNavBarDidSelectAsset:self];
    }
}

- (void)setSelectionIndex:(NSInteger)selectionIndex {
    _selectionIndex = selectionIndex;
    
    if (selectionIndex == -1) {
        _selectButton.backgroundColor = [UIColor clearColor];
        [_selectButton setImage:[UIImage udDefaultImagePickerNotSelected] forState:UIControlStateNormal];
        [self.selectButton setTitle:nil forState:UIControlStateNormal];
        return;
    }
    
    [_selectButton setImage:nil forState:UIControlStateNormal];
    _selectButton.backgroundColor = [UIColor colorWithRed:0.165f  green:0.576f  blue:0.98f alpha:1];
    [self.selectButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)(selectionIndex + 1)] forState:UIControlStateNormal];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _backButton.frame = CGRectMake(10, 20 + (udIsIPhoneXSeries?24:0), 22, 22);
    _selectButton.frame = CGRectMake(CGRectGetWidth(self.frame) - 22 - 16, 20 + (udIsIPhoneXSeries?24:0), 22, 22);
}

@end
