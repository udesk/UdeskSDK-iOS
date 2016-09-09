//
//  UdeskProductCell.m
//  UdeskSDK
//
//  Created by xuchen on 16/8/17.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskProductCell.h"
#import "UdeskProductMessage.h"
#import "UIColor+UdeskSDK.h"
#import "UdeskFoundationMacro.h"
#import "UdeskSDKConfig.h"

@interface UdeskProductCell()

@property (nonatomic, strong) UdeskProductMessage *productMessage;
@property (nonatomic, strong) UIView              *productBackGroundView;
@property (nonatomic, strong) UIImageView         *productImageView;
@property (nonatomic, strong) UILabel             *productTitleLabel;
@property (nonatomic, strong) UILabel             *productDetailLabel;
@property (nonatomic, strong) UIButton            *productSendButton;

@end

@implementation UdeskProductCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)updateCellWithMessage:(id)message {

    if ([message isKindOfClass:[UdeskProductMessage class]]) {
        
        UdeskProductMessage *productMessage = (UdeskProductMessage *)message;
        _productMessage = productMessage;
        self.productImageView.image = productMessage.productImage;
        self.productTitleLabel.text = productMessage.productTitle;
        self.productDetailLabel.text = productMessage.productDetail;
        [self.productSendButton setTitle:productMessage.productSendText forState:UIControlStateNormal];
    }
}

- (void)layoutSubviews {

    [super layoutSubviews];
    
    self.productBackGroundView.frame = self.productMessage.productFrame;
    self.productImageView.frame = self.productMessage.productImageFrame;
    self.productTitleLabel.frame = self.productMessage.productTitleFrame;
    self.productDetailLabel.frame = self.productMessage.productDetailFrame;
    self.productSendButton.frame = self.productMessage.productSendFrame;
}

- (UIView *)productBackGroundView {

    if (!_productBackGroundView) {
        _productBackGroundView = [[UIView alloc] initWithFrame:CGRectZero];
        _productBackGroundView.backgroundColor = [UdeskSDKConfig sharedConfig].sdkStyle.productBackGroundColor;
        [self.contentView addSubview:_productBackGroundView];
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
        _productTitleLabel.textColor = [UdeskSDKConfig sharedConfig].sdkStyle.productTitleColor;
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
        _productDetailLabel.textColor = [UdeskSDKConfig sharedConfig].sdkStyle.productDetailColor;
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
        _productSendButton.backgroundColor = [UdeskSDKConfig sharedConfig].sdkStyle.productSendBackGroundColor;
        [_productSendButton addTarget:self action:@selector(sendProductUrlAction:) forControlEvents:UIControlEventTouchUpInside];
        UDViewRadius(_productSendButton, 2);
        [self.productBackGroundView addSubview:_productSendButton];
    }
    
    return _productSendButton;
}

- (void)sendProductUrlAction:(UIButton *)button {

    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(sendProductURL:)]) {
            [self.delegate sendProductURL:self.productMessage.productURL];
        }
    }
}

@end
