//
//  UdeskGoodsMessage.m
//  UdeskSDK
//
//  Created by xuchen on 2018/6/23.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskGoodsMessage.h"
#import "UdeskGoodsCell.h"

/** 商品消息图片和气泡水平间距 */
static CGFloat const kUDGoodsImageHorizontalSpacing = 10.0;
/** 商品消息图片和气泡垂直间距 */
static CGFloat const kUDGoodsImageVerticalSpacing = 10.0;
/** 商品消息图片width */
static CGFloat const kUDGoodsImageWidth = 60.0;
/** 商品消息图片height */
static CGFloat const kUDGoodsImageHeight = 60.0;

/** 商品参数距离图片气泡水平间距 */
static CGFloat const kUDGoodsParamsHorizontalSpacing = 10.0;
/** 商品参数距离名称气泡垂直间距 */
static CGFloat const kUDGoodsParamsVerticalSpacing = 10.0;

@interface UdeskGoodsMessage()

/** model */
@property (nonatomic, strong, readwrite) UdeskGoodsModel *goodsModel;
/** 其他文本参数 */
@property (nonatomic, strong, readwrite) NSAttributedString  *titleAttributedString;
/** 其他文本参数 */
@property (nonatomic, strong, readwrite) NSAttributedString  *paramsAttributedString;

@property (nonatomic, assign, readwrite) CGRect imgFrame;
@property (nonatomic, assign, readwrite) CGRect titleFrame;
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
    
    CGFloat titleHeight = [UdeskSDKConfig customConfig].sdkStyle.goodsNameFont.lineHeight * [UdeskSDKConfig customConfig].sdkStyle.goodsNameNumberOfLines;
    CGSize titleSize = [UdeskStringSizeUtil sizeWithAttributedText:self.titleAttributedString size:CGSizeMake(labelWidth, CGFLOAT_MAX)];
    if (titleHeight == 0 || titleSize.height < titleHeight) {
        titleHeight = titleSize.height;
    }
    
    CGSize paramsSize = [UdeskStringSizeUtil sizeWithAttributedText:self.paramsAttributedString size:CGSizeMake(labelWidth, CGFLOAT_MAX)];
    
    //参数
    self.imgFrame = CGRectMake(kUDGoodsImageHorizontalSpacing, kUDGoodsImageVerticalSpacing, kUDGoodsImageWidth, kUDGoodsImageHeight);
    self.titleFrame = CGRectMake(CGRectGetMaxX(self.imgFrame) + kUDGoodsParamsHorizontalSpacing, kUDGoodsParamsVerticalSpacing, labelWidth, titleHeight);
    self.paramsFrame = CGRectMake(CGRectGetMaxX(self.imgFrame) + kUDGoodsParamsHorizontalSpacing, CGRectGetMaxY(self.titleFrame) + kUDGoodsParamsVerticalSpacing, paramsSize.width, paramsSize.height+5);
    CGFloat bubbleHeight = MAX(kUDGoodsImageHeight+kUDGoodsImageVerticalSpacing, CGRectGetMaxY(self.paramsFrame));
    
    if (self.message.messageFrom == UDMessageTypeSending) {
        
        CGFloat bubbleX = UD_SCREEN_WIDTH-kUDBubbleToHorizontalEdgeSpacing-bubbleWidth;
        self.bubbleFrame = CGRectMake(bubbleX, CGRectGetMaxY(self.avatarFrame)+kUDAvatarToBubbleSpacing, bubbleWidth, bubbleHeight+kUDGoodsParamsVerticalSpacing);
        
        //加载中frame
        self.loadingFrame = CGRectMake(self.bubbleFrame.origin.x-kUDBubbleToSendStatusSpacing-kUDSendStatusDiameter, self.bubbleFrame.origin.y+kUDCellBubbleToIndicatorSpacing, kUDSendStatusDiameter, kUDSendStatusDiameter);
        
        //加载失败frame
        self.failureFrame = self.loadingFrame;
    }
    else if (self.message.messageFrom == UDMessageTypeReceiving) {
        
        self.bubbleFrame = CGRectMake(kUDBubbleToHorizontalEdgeSpacing, CGRectGetMaxY(self.avatarFrame)+kUDAvatarToBubbleSpacing, bubbleWidth, bubbleHeight+kUDGoodsParamsVerticalSpacing);
    }
    
    //cell高度
    self.cellHeight = self.bubbleFrame.size.height+self.bubbleFrame.origin.y+kUDCellBottomMargin;
}

- (void)setupGoodsDataWithDictionary:(NSDictionary *)dictionary {
    
    if ([dictionary.allKeys containsObject:@"url"]) {
        self.goodsModel.url = dictionary[@"url"];
    }
    
    if ([dictionary.allKeys containsObject:@"imgUrl"]) {
        self.goodsModel.imgUrl = dictionary[@"imgUrl"];
    }
    
    if ([dictionary.allKeys containsObject:@"id"]) {
        self.goodsModel.goodsId = dictionary[@"id"];
    }
    
    if ([dictionary.allKeys containsObject:@"name"]) {
        self.goodsModel.name = dictionary[@"name"];
        [self setGoodsNameAttributedStringWithName:self.goodsModel.name];
    }
    
    if ([dictionary.allKeys containsObject:@"customParameters"]) {
        self.goodsModel.customParameters = dictionary[@"customParameters"];
    }
    
    if ([dictionary.allKeys containsObject:@"params"]) {
        NSArray *params = dictionary[@"params"];
        if (![params isKindOfClass:[NSArray class]]) return ;
        
        [self setupParamsWithArray:params];
    }
}

- (void)setGoodsNameAttributedStringWithName:(NSString *)name {
    
    //颜色
    UIColor *goodsNameTextColor = [UdeskSDKConfig customConfig].sdkStyle.customerGoodsNameTextColor;
    if (self.message.messageFrom == UDMessageTypeReceiving) {
        goodsNameTextColor = [UdeskSDKConfig customConfig].sdkStyle.agentGoodsNameTextColor;
    }
    
    //名称
    NSDictionary *dic = @{
                          NSForegroundColorAttributeName:goodsNameTextColor,
                          NSFontAttributeName:[UdeskSDKConfig customConfig].sdkStyle.goodsNameFont,
                          };
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:name attributes:dic];
    self.titleAttributedString = attributedString;
}

- (void)setupParamsWithArray:(NSArray *)array {
    
    NSMutableArray *paramArray = [NSMutableArray array];
        
    NSMutableAttributedString *mAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.paramsAttributedString];
    for (NSDictionary *param in array) {
        
        UdeskGoodsParamModel *paramModel = [[UdeskGoodsParamModel alloc] init];
        NSMutableDictionary *attributed = [NSMutableDictionary dictionary];
        //字体颜色
        UIColor *defaultColor = [UIColor whiteColor];
        if (self.message.messageFrom == UDMessageTypeReceiving) {
            defaultColor = [UIColor blackColor];
        }
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
            paramModel.color = colorString;
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
            paramModel.size = size;
        }
        
        UIFont *textFont = [UIFont systemFontOfSize:textSize];
        if ([param.allKeys containsObject:@"fold"]) {
            NSNumber *fold = param[@"fold"];
            if (![fold isKindOfClass:[NSNumber class]]) break;
            if (fold.boolValue) {
                textFont = [UIFont boldSystemFontOfSize:textSize];
            }
            paramModel.fold = fold;
        }
        
        [attributed setObject:textFont forKey:NSFontAttributeName];
        
        NSString *content = @"";
        //文本
        if ([param.allKeys containsObject:@"text"]) {
            NSString *text = param[@"text"];
            if (![text isKindOfClass:[NSString class]]) break;
            content = text;
            paramModel.text = text;
        }
        
        //换行
        if ([param.allKeys containsObject:@"break"]) {
            NSNumber *udBreak = param[@"break"];
            if (![udBreak isKindOfClass:[NSNumber class]]) break;
            if (udBreak.boolValue) {
                content = [content stringByAppendingString:@"\n"];
            }
            paramModel.udBreak = udBreak;
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
        
        [paramArray addObject:paramModel];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content attributes:attributed];
        [mAttributedString appendAttributedString:attributedString];
    }
    
    self.goodsModel.params = paramArray;
    self.paramsAttributedString = [mAttributedString copy];
}

- (UdeskGoodsModel *)goodsModel {
    if (!_goodsModel) {
        _goodsModel = [[UdeskGoodsModel alloc] init];
    }
    return _goodsModel;
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    
    return [[UdeskGoodsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
