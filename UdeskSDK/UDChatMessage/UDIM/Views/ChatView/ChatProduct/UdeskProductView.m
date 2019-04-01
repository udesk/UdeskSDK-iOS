//
//  UdeskProductView.m
//  UdeskSDK
//
//  Created by xuchen on 2019/3/14.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskProductView.h"
#import "UdeskSDKConfig.h"
#import "UdeskBundleUtils.h"
#import "UdeskSDKUtil.h"
#import "UIImage+UdeskSDK.h"
#import "Udesk_YYWebImage.h"

/** 咨询对象height */
const CGFloat kUDProductHeight = 85;
/** 咨询对象图片距离屏幕水平边沿距离 */
static CGFloat const kUDProductImageToHorizontalEdgeSpacing = 10.0;
/** 咨询对象图片距离屏幕垂直边沿距离 */
static CGFloat const kUDProductImageToVerticalEdgeSpacing = 10.0;
/** 咨询对象图片直径 */
static CGFloat const kUDProductImageDiameter = 65.0;
/** 咨询对象标题距离咨询对象图片水平边沿距离 */
static CGFloat const kUDProductTitleToProductImageHorizontalEdgeSpacing = 12.0;
/** 咨询对象标题距离屏幕垂直边沿距离 */
static CGFloat const kUDProductTitleToVerticalEdgeSpacing = 10.0;
/** 咨询对象标题高度 */
static CGFloat const kUDProductTitleHeight = 40.0;
/** 咨询对象副标题距离标题垂直距离 */
static CGFloat const kUDProductDetailToTitleVerticalEdgeSpacing = 5.0;
/** 咨询对象副标题高度 */
static CGFloat const kUDProductDetailHeight = 20;
/** 咨询对象发送按钮右侧距离 */
static CGFloat const kUDProductSendButtonToRightHorizontalEdgeSpacing = 19.0;
/** 咨询对象发送按钮距离标题垂直距离 */
static CGFloat const kUDProductSendButtonToTitleVerticalEdgeSpacing = 5.0;
/** 咨询对象发送按钮距width */
static CGFloat const kUDProductSendButtonWidth = 65.0;
/** 咨询对象发送按钮距height */
static CGFloat const kUDProductSendButtonHeight = 25.0;

@interface UdeskProductView()

@property (nonatomic, strong) UIView       *productBackGroundView;
@property (nonatomic, strong) UIImageView  *productImageView;
@property (nonatomic, strong) UILabel      *productTitleLabel;
@property (nonatomic, strong) UILabel      *productDetailLabel;
@property (nonatomic, strong) UIButton     *productSendButton;
@property (nonatomic, copy  ) NSString     *productURL;

@end

@implementation UdeskProductView

- (void)setProductData:(NSDictionary *)productData {
    _productData = productData;
    
    self.productURL = [NSString stringWithFormat:@"%@",productData[@"productURL"]];

    //咨询对象图片
    NSString *productImageURL = productData[@"productImageUrl"];
    if (![UdeskSDKUtil isBlankString:productImageURL]) {
        
        self.productImageView.frame = CGRectMake(kUDProductImageToHorizontalEdgeSpacing, kUDProductImageToVerticalEdgeSpacing, kUDProductImageDiameter, kUDProductImageDiameter);
        [self.productImageView yy_setImageWithURL:[NSURL URLWithString:productImageURL] placeholder:[UIImage udDefaultLoadingImage]];
    }
    
    //咨询对象标题
    NSString *productTitle = productData[@"productTitle"];
    if (![UdeskSDKUtil isBlankString:productTitle]) {
        self.productTitleLabel.text = self.productTitleLabel.text = productTitle;;
        CGFloat productTitleX = CGRectGetMaxX(self.productImageView.frame)+kUDProductTitleToProductImageHorizontalEdgeSpacing;
        self.productTitleLabel.frame = CGRectMake(productTitleX, kUDProductTitleToVerticalEdgeSpacing, UD_SCREEN_WIDTH-productTitleX-kUDProductTitleToProductImageHorizontalEdgeSpacing, kUDProductTitleHeight);
    }
    
    //咨询对象副标题
    NSString *productDetail = productData[@"productDetail"];
    if (![UdeskSDKUtil isBlankString:productDetail]) {
        self.productDetailLabel.text = productDetail;
        self.productDetailLabel.frame = CGRectMake(CGRectGetMinX(self.productTitleLabel.frame), CGRectGetMaxY(self.productTitleLabel.frame)+ kUDProductDetailToTitleVerticalEdgeSpacing, CGRectGetWidth(self.productTitleLabel.frame)/2, kUDProductDetailHeight);
    }
    
    //咨询对象发送按钮
    NSString *productSendText = getUDLocalizedString(@"udesk_send_link");
    if (![UdeskSDKUtil isBlankString:[UdeskSDKConfig customConfig].productSendText]) {
        productSendText = [UdeskSDKConfig customConfig].productSendText;
    }
    
    [self.productSendButton setTitle:productSendText forState:UIControlStateNormal];
    self.productSendButton.frame = CGRectMake(UD_SCREEN_WIDTH-kUDProductSendButtonWidth-kUDProductSendButtonToRightHorizontalEdgeSpacing, CGRectGetMaxY(self.productTitleLabel.frame)+kUDProductSendButtonToTitleVerticalEdgeSpacing, kUDProductSendButtonWidth, kUDProductSendButtonHeight);
    
    self.productBackGroundView.frame = CGRectMake(0, 0, UD_SCREEN_WIDTH, kUDProductHeight);
}

- (UIView *)productBackGroundView {
    
    if (!_productBackGroundView) {
        _productBackGroundView = [[UIView alloc] initWithFrame:CGRectZero];
        _productBackGroundView.backgroundColor = [UdeskSDKConfig customConfig].sdkStyle.productBackGroundColor;
        [self addSubview:_productBackGroundView];
    }
    return _productBackGroundView;
}

- (UIImageView *)productImageView {
    
    if (!_productImageView) {
        _productImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _productImageView.backgroundColor = [UIColor clearColor];
        [self.productBackGroundView addSubview:_productImageView];
    }
    
    return _productImageView;
}

- (UILabel *)productTitleLabel {
    
    if (!_productTitleLabel) {
        _productTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _productTitleLabel.backgroundColor = [UIColor clearColor];
        _productTitleLabel.textColor = [UdeskSDKConfig customConfig].sdkStyle.productTitleColor;
        _productTitleLabel.font = [UIFont systemFontOfSize:15];
        _productTitleLabel.numberOfLines = 0;
        [self.productBackGroundView addSubview:_productTitleLabel];
    }
    
    return _productTitleLabel;
}

- (UILabel *)productDetailLabel {
    
    if (!_productDetailLabel) {
        _productDetailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _productDetailLabel.backgroundColor = [UIColor clearColor];
        _productDetailLabel.textColor = [UdeskSDKConfig customConfig].sdkStyle.productDetailColor;
        _productDetailLabel.font = [UIFont systemFontOfSize:15];
        _productDetailLabel.numberOfLines = 0;
        [_productDetailLabel sizeToFit];
        [self.productBackGroundView addSubview:_productDetailLabel];
    }
    
    return _productDetailLabel;
}

- (UIButton *)productSendButton {
    
    if (!_productSendButton) {
        _productSendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _productSendButton.frame = CGRectZero;
        _productSendButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_productSendButton setTitleColor:[UdeskSDKConfig customConfig].sdkStyle.productSendTitleColor forState:UIControlStateNormal];
        _productSendButton.backgroundColor = [UdeskSDKConfig customConfig].sdkStyle.productSendBackGroundColor;
        [_productSendButton addTarget:self action:@selector(sendProductUrlAction:) forControlEvents:UIControlEventTouchUpInside];
        UDViewRadius(_productSendButton, 2);
        [self.productBackGroundView addSubview:_productSendButton];
    }
    
    return _productSendButton;
}

- (void)sendProductUrlAction:(UIButton *)button {
    
    if (self.didTapProductSendBlock) {
        self.didTapProductSendBlock(self.productURL);
    }
}
@end
