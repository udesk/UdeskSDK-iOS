//
//  UdeskStructMessage.m
//  UdeskSDK
//
//  Created by xuchen on 2017/1/17.
//  Copyright © 2017年 xuchen. All rights reserved.
//

#import "UdeskStructMessage.h"
#import "UdeskImageUtil.h"
#import "UdeskStructCell.h"

@implementation UdeskStructButton

- (instancetype)initModelWithJSON:(id)json
{
    self = [super init];
    if (self) {
        
        @try {
            
            self.type = [NSString stringWithFormat:@"%@",json[@"type"]];
            self.text = [NSString stringWithFormat:@"%@",json[@"text"]];
            self.value = [NSString stringWithFormat:@"%@",json[@"value"]];
            self.callbackName = [NSString stringWithFormat:@"%@",json[@"callback_name"]];
            
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
    }
    return self;
}

@end

@interface UdeskStructMessage()

/** 结构消息Point */
@property (nonatomic, assign, readwrite) CGPoint    structPoint;

@end

@implementation UdeskStructMessage

- (instancetype)initWithMessage:(UdeskMessage *)message displayTimestamp:(BOOL)displayTimestamp
{
    self = [super initWithMessage:message displayTimestamp:displayTimestamp];
    if (self) {

        @try {
            
            if ([UdeskSDKUtil isBlankString:message.messageId]) {
                return nil;
            }
            if ([UdeskSDKUtil isBlankString:message.content]) {
                return nil;
            }
            
            NSDictionary *structMsg = [UdeskSDKUtil dictionaryWithJSON:message.content];
            if (!structMsg) {
                return nil;
            }
            
            NSString *title = [NSString stringWithFormat:@"%@",[structMsg objectForKey:@"title"]];
            NSString *description = [NSString stringWithFormat:@"%@",[structMsg objectForKey:@"description"]];
            NSString *img_url = [NSString stringWithFormat:@"%@",[structMsg objectForKey:@"img_url"]];
            NSArray *buttonArray = [structMsg objectForKey:@"buttons"];
            
            self.title = title;
            self.udDescription = description;
            self.imgURL = [img_url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            
            NSMutableArray *array = [NSMutableArray array];
            for (NSDictionary *buttonDic in buttonArray) {
                
                UdeskStructButton *structButton = [[UdeskStructButton alloc] initModelWithJSON:buttonDic];
                [array addObject:structButton];
            }
            self.buttons = array;
            
            if (img_url && img_url.length>0) {
                
                NSString *newURL = [img_url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:newURL]]];
                
                //限定图片的最大直径
                CGFloat maxBubbleDiameter = ceil(230 / 2);  //限定图片的最大直径
                CGSize contentImageSize = image.size;
                
                //先限定图片宽度来计算高度
                CGFloat imageWidth = contentImageSize.width < maxBubbleDiameter ? contentImageSize.width : maxBubbleDiameter;
                CGFloat imageHeight = ceil(contentImageSize.height / contentImageSize.width * imageWidth);
                //判断如果气泡高度计算结果超过图片的最大直径，则限制高度
                if (imageHeight > maxBubbleDiameter) {
                    imageHeight = maxBubbleDiameter;
                    imageWidth = ceil(contentImageSize.width / contentImageSize.height * imageHeight);
                }
                
                self.structImage = [UdeskImageUtil imageResize:image toSize:CGSizeMake(imageWidth, imageHeight)];
                
                //这种获取高度的方法不是很友好，之后需要优化
                NSMutableArray *actionArray = [NSMutableArray array];
                for (UdeskStructButton *button in array) {
                    UdeskStructAction *action = [UdeskStructAction actionWithTitle:button.text handler:^(UdeskStructAction * _Nonnull action) {
                    }];
                    [actionArray addObject:action];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.structContentView = [[UdeskStructView alloc] initWithImage:self.structImage title:self.title message:self.udDescription buttons:actionArray origin:CGPointMake(kUDBubbleToHorizontalEdgeSpacing, CGRectGetMaxY(self.avatarFrame)+kUDAvatarToBubbleSpacing)];

                    self.cellHeight = self.structContentView.frame.size.height+self.structContentView.frame.origin.y+kUDCellBottomMargin;
                });
            }
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }

    }
    return self;
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    
    return [[UdeskStructCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
