//
//  UdeskGoodsMessage.m
//  UdeskSDK
//
//  Created by xuchen on 2018/6/23.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskGoodsMessage.h"
#import "UdeskGoodsCell.h"
#import "UdeskSDKUtil.h"
#import "UdeskStringSizeUtil.h"
#import "UIColor+UdeskSDK.h"
#import "UdeskSDKMacro.h"
#import "UdeskSDKConfig.h"

/** 商品消息图片和气泡水平间距 */
const CGFloat kUDGoodsImageHorizontalSpacing = 10.0;
/** 商品消息图片和气泡垂直间距 */
const CGFloat kUDGoodsImageVerticalSpacing = 10.0;
/** 商品消息图片width */
const CGFloat kUDGoodsImageWidth = 60.0;
/** 商品消息图片height */
const CGFloat kUDGoodsImageHeight = 60.0;

/** 商品参数距离图片气泡水平间距 */
const CGFloat kUDGoodsParamsHorizontalSpacing = 10.0;
/** 商品参数距离名称气泡垂直间距 */
const CGFloat kUDGoodsParamsVerticalSpacing = 10.0;

@interface UdeskGoodsMessage()

/** id */
@property (nonatomic, copy, readwrite) NSString *goodsId;
/** 名称 */
@property (nonatomic, copy, readwrite) NSString *name;
/** 链接 */
@property (nonatomic, copy, readwrite) NSString *url;
/** 图片 */
@property (nonatomic, copy, readwrite) NSString *imgUrl;
/** 其他文本参数 */
@property (nonatomic, strong, readwrite) NSAttributedString  *paramsAttributedString;

@property (nonatomic, assign, readwrite) CGRect imgFrame;
@property (nonatomic, assign, readwrite) CGRect paramsFrame;

@end

@implementation UdeskGoodsMessage

- (instancetype)initWithMessage:(UdeskMessage *)message displayTimestamp:(BOOL)displayTimestamp
{
    self = [super initWithMessage:message displayTimestamp:displayTimestamp];
    if (self) {
        [self layoutGoodsMessage];
    }
    return self;
}

- (void)layoutGoodsMessage {
    
    if (!self.message.content || [NSNull isEqual:self.message.content]) return;
    if ([UdeskSDKUtil isBlankString:self.message.content]) return;
    
    NSDictionary *goodsDic = [UdeskSDKUtil dictionaryWithJSON:self.message.content];
    if (!goodsDic || goodsDic == (id)kCFNull) return ;
    if (![goodsDic isKindOfClass:[NSDictionary class]]) return ;
    
    //商品信息
    [self setupGoodsDataWithDictionary:goodsDic];
    
    CGFloat labelWidth = UD_SCREEN_WIDTH>320?170:140;
    CGFloat bubbleWidth = UD_SCREEN_WIDTH>320?280:230;
    
    if (self.message.messageFrom == UDMessageTypeSending) {
        
        //图片
        self.imgFrame = CGRectMake(kUDGoodsImageHorizontalSpacing, kUDGoodsImageVerticalSpacing, kUDGoodsImageWidth, kUDGoodsImageHeight);
        //名称+参数
        CGSize paramsSize = [UdeskStringSizeUtil getSizeForAttributedText:self.paramsAttributedString textWidth:labelWidth];
        self.paramsFrame = CGRectMake(CGRectGetMaxX(self.imgFrame) + kUDGoodsParamsHorizontalSpacing, kUDGoodsParamsVerticalSpacing, paramsSize.width, paramsSize.height+5);
        
        CGFloat bubbleHeight = MAX(kUDGoodsImageHeight+kUDGoodsImageVerticalSpacing, CGRectGetMaxY(self.paramsFrame));
        self.bubbleFrame = CGRectMake(self.avatarFrame.origin.x-kUDArrowMarginWidth-bubbleWidth, self.avatarFrame.origin.y, bubbleWidth, bubbleHeight+kUDGoodsParamsVerticalSpacing);
        
        //加载中frame
        self.loadingFrame = CGRectMake(self.bubbleFrame.origin.x-kUDBubbleToSendStatusSpacing-kUDSendStatusDiameter, self.bubbleFrame.origin.y+kUDCellBubbleToIndicatorSpacing, kUDSendStatusDiameter, kUDSendStatusDiameter);
        
        //加载失败frame
        self.failureFrame = self.loadingFrame;
        
        //cell高度
        self.cellHeight = self.bubbleFrame.size.height+self.bubbleFrame.origin.y+kUDCellBottomMargin;
    }
}

- (void)setupGoodsDataWithDictionary:(NSDictionary *)dictionary {
    
    if ([dictionary.allKeys containsObject:@"url"]) {
        self.url = dictionary[@"url"];
    }
    
    if ([dictionary.allKeys containsObject:@"imgUrl"]) {
        self.imgUrl = dictionary[@"imgUrl"];
    }
    
    if ([dictionary.allKeys containsObject:@"id"]) {
        self.goodsId = dictionary[@"id"];
    }
    
    if ([dictionary.allKeys containsObject:@"name"]) {
        self.name = dictionary[@"name"];
        [self setGoodsNameAttributedStringWithName:self.name];
    }
    
    if ([dictionary.allKeys containsObject:@"params"]) {
        NSArray *params = dictionary[@"params"];
        if (![params isKindOfClass:[NSArray class]]) return ;
        
        [self setupParamsWithArray:params];
    }
}

- (void)setGoodsNameAttributedStringWithName:(NSString *)name {
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.paragraphSpacing = 5;
    
    //名称
    UIColor *color = [UdeskSDKConfig customConfig].sdkStyle.goodsNameTextColor;
    if (![UdeskSDKUtil isBlankString:self.url]) {
        color = [UdeskSDKConfig customConfig].sdkStyle.linkColor;
    }
    
    //名称
    NSDictionary *dic = @{
                          NSForegroundColorAttributeName:color,
                          NSFontAttributeName:[UdeskSDKConfig customConfig].sdkStyle.goodsNameFont,
                          NSParagraphStyleAttributeName:paragraphStyle
                          };
    
    NSMutableAttributedString *mAttributedString = [[NSMutableAttributedString alloc] init];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:[name stringByAppendingString:@"\n"] attributes:dic];
    [mAttributedString appendAttributedString:attributedString];
    self.paramsAttributedString = attributedString;
}

- (void)setupParamsWithArray:(NSArray *)array {
        
    NSMutableAttributedString *mAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.paramsAttributedString];
    for (NSDictionary *param in array) {
        
        NSMutableDictionary *attributed = [NSMutableDictionary dictionary];
        //字体颜色
        UIColor *defaultColor = [UIColor udColorWithHexString:@"#ffffff"];
        if ([param.allKeys containsObject:@"color"]) {
            NSString *colorString = param[@"color"];
            if (![colorString isKindOfClass:[NSString class]]) break;
            UIColor *color = [UIColor udColorWithHexString:colorString];
            if (color) {
                [attributed setObject:color forKey:NSForegroundColorAttributeName];
            }
            else {
                if (defaultColor) {
                    [attributed setObject:defaultColor forKey:NSForegroundColorAttributeName];
                }
            }
        }
        else {
            if (defaultColor) {
                [attributed setObject:defaultColor forKey:NSForegroundColorAttributeName];
            }
        }
        
        //字体
        CGFloat textSize = 12;
        if ([param.allKeys containsObject:@"size"]) {
            NSNumber *size = param[@"size"];
            if (![size isKindOfClass:[NSNumber class]]) break;
            textSize = size.floatValue;
        }
        
        UIFont *textFont = [UIFont systemFontOfSize:textSize];
        if ([param.allKeys containsObject:@"fold"]) {
            NSNumber *fold = param[@"fold"];
            if (![fold isKindOfClass:[NSNumber class]]) break;
            if (fold.boolValue) {
                textFont = [UIFont boldSystemFontOfSize:textSize];
            }
        }
        
        [attributed setObject:textFont forKey:NSFontAttributeName];
        
        NSString *content = @"";
        //文本
        if ([param.allKeys containsObject:@"text"]) {
            NSString *text = param[@"text"];
            if (![text isKindOfClass:[NSString class]]) break;
            content = text;
        }
        
        //换行
        if ([param.allKeys containsObject:@"break"]) {
            NSNumber *udBreak = param[@"break"];
            if (![udBreak isKindOfClass:[NSNumber class]]) break;
            if (udBreak.boolValue) {
                content = [content stringByAppendingString:@"\n"];
            }
        }
        
        //处理间隙
        NSUInteger index = [array indexOfObject:param];
        if (index != 0) {
            NSDictionary *previousParam = [array objectAtIndex:index-1];
            NSNumber *previousBreak = @0;
            if ([previousParam.allKeys containsObject:@"break"]) {
                previousBreak = previousParam[@"break"];
                if (![previousBreak isKindOfClass:[NSNumber class]]) {
                    previousBreak = @0;
                }
            }
            if (!previousBreak.boolValue) {
                content = [NSString stringWithFormat:@"    %@",content];
            }
        }
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content attributes:attributed];
        [mAttributedString appendAttributedString:attributedString];
    }
    
    self.paramsAttributedString = [mAttributedString copy];
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    
    return [[UdeskGoodsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
