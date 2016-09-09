//
//  UdeskProductMessage.m
//  UdeskSDK
//
//  Created by xuchen on 16/8/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskProductMessage.h"
#import "UdeskManager.h"
#import "UdeskFoundationMacro.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskSDKConfig.h"
#import "UdeskUtils.h"

/** 咨询对象cell高度 */
static CGFloat const kUDProductCellHeight = 105;
/** 咨询对象height */
static CGFloat const kUDProductHeight = 85;
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
/** 咨询对象副标题距离屏幕水平边沿距离 */
static CGFloat const kUDProductDetailToHorizontalEdgeSpacing = 89.0;
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

@interface UdeskProductMessage()

/** 咨询对象标题Frame */
@property (nonatomic, assign, readwrite) CGRect   productTitleFrame;
/** 咨询对象副标题Frame */
@property (nonatomic, assign, readwrite) CGRect   productDetailFrame;
/** 咨询对象发送文字Frame */
@property (nonatomic, assign, readwrite) CGRect   productSendFrame;
/** 咨询对象图片Frame */
@property (nonatomic, assign, readwrite) CGRect   productImageFrame;
/** 咨询对象Frame */
@property (nonatomic, assign, readwrite) CGRect   productFrame;

@end

@implementation UdeskProductMessage

- (instancetype)initWithProductMessage:(NSDictionary *)message {
    
    self = [super init];
    if (self) {
        
        self.date = [NSDate date];
        self.messageId = [NSUUID UUID].UUIDString;
        self.productURL = [message objectForKey:@"productURL"];
        NSString *productImageUrl = [message objectForKey:@"productImageUrl"];
        self.productImage = [UIImage ud_defaultLoadingImage];
        
        [UdeskManager downloadMediaWithUrlString:productImageUrl done:^(NSString *key, id<NSCoding> object) {
            
            self.productImage = (UIImage *)object;
            //通知更新
            if (self.delegate) {
                if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                    [self.delegate didUpdateCellDataWithMessageId:self.messageId];
                }
            }

        }];
        
        self.productTitle = [message objectForKey:@"productTitle"];
        self.productDetail = [message objectForKey:@"productDetail"];
        if ([UdeskSDKConfig sharedConfig].productSendText) {
            self.productSendText = [UdeskSDKConfig sharedConfig].productSendText;
        }
        else {
            self.productSendText = getUDLocalizedString(@"udesk_send_link");
        }
        
        self.cellHeight = kUDProductCellHeight;
        self.productImageFrame = CGRectMake(kUDProductImageToHorizontalEdgeSpacing, kUDProductImageToVerticalEdgeSpacing, kUDProductImageDiameter, kUDProductImageDiameter);
        CGFloat productTitleX = self.productImageFrame.origin.x+self.productImageFrame.size.width+kUDProductTitleToProductImageHorizontalEdgeSpacing;
        self.productTitleFrame = CGRectMake(productTitleX, kUDProductTitleToVerticalEdgeSpacing, UD_SCREEN_WIDTH-productTitleX-kUDProductTitleToProductImageHorizontalEdgeSpacing, kUDProductTitleHeight);
        self.productDetailFrame = CGRectMake(kUDProductDetailToHorizontalEdgeSpacing, self.productTitleFrame.origin.y+self.productTitleFrame.size.height+ kUDProductDetailToTitleVerticalEdgeSpacing, self.productTitleFrame.size.width/2, kUDProductDetailHeight);
        self.productSendFrame = CGRectMake(UD_SCREEN_WIDTH-kUDProductSendButtonWidth-kUDProductSendButtonToRightHorizontalEdgeSpacing, self.productTitleFrame.origin.y+self.productTitleFrame.size.height+kUDProductSendButtonToTitleVerticalEdgeSpacing, kUDProductSendButtonWidth, kUDProductSendButtonHeight);
        
        self.productFrame = CGRectMake(0, 10, UD_SCREEN_WIDTH, kUDProductHeight);
    }
    return self;
}
@end
