//
//  UdeskProductView.m
//  UdeskSDK
//
//  Created by xuchen on 16/3/29.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskProductView.h"
#import "UdeskViewExt.h"
#import "UdeskFoundationMacro.h"
#import "UdeskManager.h"

@interface UdeskProductView()

@property (nonatomic, weak) UIImageView *productImageView;
@property (nonatomic, weak) UILabel     *productTitle;
@property (nonatomic, weak) UILabel     *productDetail;

@property (nonatomic, strong) NSString  *productUrl;

@end

@implementation UdeskProductView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView *productImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:productImageView];
        _productImageView = productImageView;
        
        UILabel *productTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        productTitle.numberOfLines = 2;
        productTitle.font = [UIFont systemFontOfSize:15];
        
        [self addSubview:productTitle];
        _productTitle = productTitle;
        
        UILabel *productDetail = [[UILabel alloc] initWithFrame:CGRectZero];
        productDetail.font = [UIFont systemFontOfSize:15];
        [self addSubview:productDetail];
        _productDetail = productDetail;
        
        UIButton *productSendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        UDViewBorderRadius(productSendButton, 5, 0.5f, [UIColor blueColor]);
        
        [productSendButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        
        productSendButton.titleLabel.font = [UIFont systemFontOfSize:15];
        
        [productSendButton addTarget:self action:@selector(sendProductUrlAction) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:productSendButton];
        _productSendButton = productSendButton;
        
    }
    return self;
}

- (void)layoutSubviews {

    [super layoutSubviews];
    
    self.productImageView.frame = CGRectMake(10,10, 80, 80);
    
    self.productTitle.frame = CGRectMake(self.productImageView.ud_right+10, self.productImageView.ud_top, self.ud_width-self.productImageView.ud_right-10*2, self.productImageView.ud_height/2);
    
    self.productDetail.frame = CGRectMake(self.productTitle.ud_left, self.productTitle.ud_bottom+5, self.productTitle.ud_width/2, 30);
    
    CGFloat productSendButton_with = self.ud_width-self.productDetail.ud_right-10*3;
    
    self.productSendButton.frame = CGRectMake(self.productTitle.ud_right-productSendButton_with, self.productDetail.ud_top, productSendButton_with, 30);
    
}

- (void)sendProductUrlAction {

    [[NSNotificationCenter defaultCenter] postNotificationName:UdeskTouchProductUrlSendButton object:nil userInfo:@{@"productUrl":self.productUrl}];
}

- (void)shouldUpdateProductViewWithObject:(id)object {

    if ([object isKindOfClass:[UdeskMessage class]]) {
        
        UdeskMessage *message = (UdeskMessage *)object;
        
        [UdeskManager queryDiskCacheForKey:message.product_imageUrl done:^(UIImage *image) {
            
            if (image) {
                
                self.productImageView.image = image;
            }
            else {
                
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    
                    NSString *encodedString = (NSString *)
                    
                    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                              
                                                                              (CFStringRef)message.product_imageUrl,
                                                                              
                                                                              (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                                                              
                                                                              NULL,
                                                                              
                                                                              kCFStringEncodingUTF8));
                    
                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:encodedString]]];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.productImageView.image  = image;
                        //缓存图片
                        [UdeskManager storeImage:self.productImageView.image forKey:message.product_imageUrl];
                        
                    });
                });

            }
            
        }];

        self.productTitle.text = message.product_title;
        self.productDetail.text = message.product_detail;
        
        [self.productSendButton setTitle:@"发送链接" forState:UIControlStateNormal];
        
        self.productUrl = message.product_url;
        
    }
}

@end
