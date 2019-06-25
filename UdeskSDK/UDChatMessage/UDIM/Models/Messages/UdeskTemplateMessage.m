//
//  UdeskTemplateMessage.m
//  UdeskSDK
//
//  Created by xuchen on 2019/6/5.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskTemplateMessage.h"
#import "UdeskTemplateCell.h"
#import "UdeskSDKUtil.h"
#import "UdeskStringSizeUtil.h"
#import "UdeskSDKMacro.h"

/** 聊天气泡和其中的文字水平间距 */
static CGFloat const kUDBubbleToTemplateHorizontalSpacing = 20.0;
/** 聊天气泡和其中的文字垂直间距 */
static CGFloat const kUDBubbleToTemplateVerticalSpacing = 9.0;
/** 模版消息按钮高度 */
static CGFloat const kUDBubbleToTemplateButtonHeight = 42.0;

@implementation UdeskTemplateButtonMessage


@end

@interface UdeskTemplateMessage()

@property (nonatomic, copy  , readwrite) NSAttributedString *titleAttributedString;
@property (nonatomic, copy  , readwrite) NSAttributedString *contentAttributedString;
@property (nonatomic, assign, readwrite) CGRect titleFrame;
@property (nonatomic, assign, readwrite) CGRect lineOneFrame;
@property (nonatomic, assign, readwrite) CGRect contentFrame;
@property (nonatomic, assign, readwrite) CGRect lineTwoFrame;
@property (nonatomic, assign, readwrite) CGRect buttonsFrame;
@property (nonatomic, strong, readwrite) NSArray *buttonsArray;

@end

@implementation UdeskTemplateMessage

- (instancetype)initWithMessage:(UdeskMessage *)message displayTimestamp:(BOOL)displayTimestamp
{
    self = [super initWithMessage:message displayTimestamp:displayTimestamp];
    if (self) {
        
        [self layoutTemplateMessage];
    }
    return self;
}

- (void)layoutTemplateMessage {
    
    if (!self.message.content || self.message.content == (id)kCFNull) return ;
    if (self.message.messageType == UDMessageContentTypeTemplate && self.message.messageFrom == UDMessageTypeReceiving) {
        
        @try {
            
            NSDictionary *templateDic = [UdeskSDKUtil dictionaryWithJSON:self.message.content];
            if (!templateDic || templateDic == (id)kCFNull) return ;
            if (![templateDic isKindOfClass:[NSDictionary class]]) return ;
            
            CGFloat textWidth = [self templateMaxWidth] - (kUDBubbleToTemplateHorizontalSpacing *2);
            
            if ([templateDic.allKeys containsObject:@"title"]) {
                
                NSString *title = templateDic[@"title"];
                self.titleAttributedString = [[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
                
                CGSize titleSize = [UdeskStringSizeUtil getSizeForAttributedText:self.titleAttributedString textWidth:textWidth];
                self.titleFrame = CGRectMake(kUDBubbleToTemplateHorizontalSpacing, kUDBubbleToTemplateVerticalSpacing, textWidth, titleSize.height);
            }
            
            if ([templateDic.allKeys containsObject:@"content"]) {
                
                NSString *content = templateDic[@"content"];
                self.contentAttributedString = [[NSAttributedString alloc] initWithString:content attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
                
                self.lineOneFrame = CGRectMake(0, CGRectGetMaxY(self.titleFrame)+kUDBubbleToTemplateVerticalSpacing, [self templateMaxWidth], 1);
                CGSize contentSize = [UdeskStringSizeUtil getSizeForAttributedText:self.contentAttributedString textWidth:textWidth];
                self.contentFrame = CGRectMake(kUDBubbleToTemplateHorizontalSpacing, CGRectGetMaxY(self.lineOneFrame) + kUDBubbleToTemplateVerticalSpacing, textWidth, contentSize.height);
            }
            
            if ([templateDic.allKeys containsObject:@"btns"]) {
                
                self.lineTwoFrame = CGRectMake(0, CGRectGetMaxY(self.contentFrame)+kUDBubbleToTemplateVerticalSpacing, [self templateMaxWidth], 1);
                self.buttonsFrame = CGRectMake(0, CGRectGetMaxY(self.lineTwoFrame), [self templateMaxWidth], kUDBubbleToTemplateButtonHeight);
                
                NSArray *btns = templateDic[@"btns"];
                if (btns && [btns isKindOfClass:[NSArray class]] && btns.count) {
                    
                    NSMutableArray *buttonArray = [NSMutableArray array];
                    for (int i = 0; i<btns.count; i++) {
                        
                        CGRect buttonRect = CGRectMake(i*([self templateMaxWidth]/btns.count), 0, [self templateMaxWidth]/btns.count, kUDBubbleToTemplateButtonHeight);
                        
                        NSDictionary *btn = btns[i];
                        UdeskTemplateButtonMessage *button = [[UdeskTemplateButtonMessage alloc] init];
                        button.name = btn[@"name"];
                        button.type = btn[@"type"];
                        button.url = btn[@"data"][@"url"];
                        button.frame = buttonRect;
                        
                        if (i != (btns.count-1)) {
                            
                            CGRect lineRect = CGRectMake(CGRectGetMaxX(buttonRect), 0, 1, kUDBubbleToTemplateButtonHeight);
                            button.lineFrame = lineRect;
                        }
                        
                        [buttonArray addObject:button];
                    }
                    
                    self.buttonsArray = [buttonArray copy];
                }
            }
            
            CGFloat bubbleHeight = CGRectGetMaxY(self.contentFrame);
            if (self.buttonsArray.count) {
                bubbleHeight = (CGRectGetMaxY(self.lineTwoFrame)+kUDBubbleToTemplateButtonHeight);
            }
            
            CGFloat bubbleY = [UdeskSDKUtil isBlankString:self.message.nickName] ? CGRectGetMinY(self.avatarFrame) : CGRectGetMaxY(self.nicknameFrame)+kUDCellBubbleToIndicatorSpacing;
            self.bubbleFrame = CGRectMake(self.avatarFrame.origin.x+kUDAvatarDiameter+kUDAvatarToBubbleSpacing, bubbleY, [self templateMaxWidth], bubbleHeight);
            
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
    }
    
    //cell高度
    self.cellHeight = self.bubbleFrame.size.height+self.bubbleFrame.origin.y+kUDCellBottomMargin;
}

- (CGFloat)templateMaxWidth {
    return (270.0/375.0) * UD_SCREEN_WIDTH;
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[UdeskTemplateCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
