//
//  UdeskStructMessage.m
//  UdeskSDK
//
//  Created by xuchen on 2017/1/17.
//  Copyright © 2017年 xuchen. All rights reserved.
//

#import "UdeskStructMessage.h"
#import "UdeskStringSizeUtil.h"
#import "UdeskFoundationMacro.h"
#import "UdeskTools.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskManager.h"
#import "UdeskImageUtil.h"
#import "UdeskStructView.h"
#import "UdeskViewExt.h"
#import "UdeskStructCell.h"

/** 时间 Y */
static const CGFloat kUDChatMessageDateLabelY   = 10.0f;
/** 聊天头像大小 */
static CGFloat const kUDAvatarDiameter = 40.0;
/** 时间高度 */
static CGFloat const kUDChatMessageDateCellHeight = 14.0f;
/** 头像距离屏幕水平边沿距离 */
static CGFloat const kUDAvatarToHorizontalEdgeSpacing = 15.0;
/** 头像距离屏幕垂直边沿距离 */
static CGFloat const kUDAvatarToVerticalEdgeSpacing = 15.0;

@implementation UdeskStructButton

@end

@interface UdeskStructMessage()

/** 时间frame */
@property (nonatomic, assign, readwrite) CGRect     dateFrame;
/** 头像frame */
@property (nonatomic, assign, readwrite) CGRect     avatarFrame;
/** 结构消息Point */
@property (nonatomic, assign, readwrite) CGPoint    structPoint;

@end

@implementation UdeskStructMessage

- (instancetype)initWithUdeskMessage:(UdeskMessage *)message
{
    self = [super init];
    if (self) {
        
        if ([UdeskTools isBlankString:message.messageId]) {
            return nil;
        }
        if ([UdeskTools isBlankString:message.content]) {
            return nil;
        }

        self.date = message.timestamp;
        self.messageId = message.messageId;
        
        //时间frame
        self.dateFrame = CGRectMake(0, kUDChatMessageDateLabelY, UD_SCREEN_WIDTH, kUDChatMessageDateCellHeight);
        //用户头像frame
        self.avatarFrame = CGRectMake(kUDAvatarToHorizontalEdgeSpacing, self.dateFrame.origin.y+self.dateFrame.size.height+kUDAvatarToVerticalEdgeSpacing, kUDAvatarDiameter, kUDAvatarDiameter);
        
        //客服头像
        self.avatarImage = [UIImage ud_defaultAgentImage];
        if (message.avatar.length > 0) {
            
            [UdeskManager downloadMediaWithUrlString:message.avatar done:^(NSString *key, id<NSCoding> object) {
                
                self.avatarImage = [UdeskImageUtil compressImage:(UIImage *)object toMaxFileSize:CGSizeMake(kUDAvatarDiameter*2, kUDAvatarDiameter*2)];
                //通知更新
                if (self.delegate) {
                    if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                        [self.delegate didUpdateCellDataWithMessageId:message.messageId];
                    }
                }
            }];
        }
        

        NSDictionary *structMsg = [UdeskTools dictionaryWithJSON:message.content];
        
        NSString *title = [NSString stringWithFormat:@"%@",[structMsg objectForKey:@"title"]];
        NSString *description = [NSString stringWithFormat:@"%@",[structMsg objectForKey:@"description"]];
        NSString *img_url = [NSString stringWithFormat:@"%@",[structMsg objectForKey:@"img_url"]];
        NSArray *buttonArray = [structMsg objectForKey:@"buttons"];
        
        self.title = title;
        self.udDescription = description;
        self.imgURL = img_url;
        
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *buttonDic in buttonArray) {
            
            UdeskStructButton *structButton = [[UdeskStructButton alloc] initWithContentsOfDic:buttonDic];
            [array addObject:structButton];
        }
        self.buttons = array;
        
        if (img_url && img_url.length>0) {
        
            NSString *newURL = [img_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            [UdeskManager downloadMediaWithUrlString:newURL done:^(NSString *key, id<NSCoding> object) {
                
                //限定图片的最大直径
                UIImage *image = (UIImage *)object;
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
                
                self.structImage = [UdeskImageUtil compressImage:(UIImage *)object toMaxFileSize:CGSizeMake(imageWidth, imageHeight)];
                
                
                //这种获取高度的方法不是很友好，之后需要优化
                NSMutableArray *actionArray = [NSMutableArray array];
                for (UdeskStructButton *button in array) {
                    UdeskStructAction *action = [UdeskStructAction actionWithTitle:button.text handler:^(UdeskStructAction * _Nonnull action) {
                    }];
                    [actionArray addObject:action];
                }
                
                UdeskStructView *structContentView = [[UdeskStructView alloc] initWithImage:self.structImage title:self.title message:self.udDescription buttons:actionArray origin:CGPointMake(CGRectGetMaxX(self.avatarFrame)+kUDStructPadding, CGRectGetMaxY(self.dateFrame)+kUDStructPadding)];
                self.cellHeight = structContentView.ud_height+CGRectGetHeight(self.dateFrame)+(kUDStructPadding*3);
                
                //通知更新
                if (self.delegate) {
                    if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                        [self.delegate didUpdateCellDataWithMessageId:message.messageId];
                    }
                }
            }];
        }
    }
    
    return self;
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    
    return [[UdeskStructCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
