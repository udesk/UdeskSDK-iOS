
//
//  UdeskChatMessage.m
//  UdeskSDK
//
//  Created by Udesk on 16/8/12.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskChatMessage.h"
#import "UdeskFoundationMacro.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskManager.h"
#import "UdeskStringSizeUtil.h"
#import "UdeskDateFormatter.h"
#import "UdeskUtils.h"
#import <AVFoundation/AVFoundation.h>
#import "UdeskSDKConfig.h"
#import "UdeskHpple.h"
#import "UdeskTools.h"
#import "UdeskImageUtil.h"
#import <CoreText/CoreText.h>
#import "UdeskSDKConfig.h"
#import "UdeskChatCell.h"

/** 头像距离屏幕水平边沿距离 */
static CGFloat const kUDAvatarToHorizontalEdgeSpacing = 15.0;
/** 头像距离屏幕垂直边沿距离 */
static CGFloat const kUDAvatarToVerticalEdgeSpacing = 15.0;
/** 头像与聊天气泡之间的距离 */
static CGFloat const kUDAvatarToBubbleSpacing = 8.0;
/** 聊天气泡和其中的文字水平间距 */
static CGFloat const kUDBubbleToTextHorizontalSpacing = 10.0;
/** 聊天气泡和其中的文字垂直间距 */
static CGFloat const kUDBubbleToTextVerticalSpacing = 12.0;
/** 聊天气泡和其中的图片水平间距 */
static CGFloat const kUDBubbleToImageHorizontalSpacing = 5.0;
/** 聊天头像大小 */
static CGFloat const kUDAvatarDiameter = 40.0;
/** 时间高度 */
static CGFloat const kUDChatMessageDateCellHeight = 14.0f;
/** 语音时长 height */
static CGFloat const kUDVoiceDurationLabelHeight = 15.0;
/** 发送状态与气泡的距离 */
static CGFloat const kUDBubbleToSendStatusSpacing = 10.0;
/**发送状态大小 */
static CGFloat const kUDSendStatusDiameter = 20.0;
/** 时间 Y */
static const CGFloat kUDChatMessageDateLabelY        = 10.0f;
/** 气泡箭头宽度 */
static const CGFloat kUDArrowMarginWidth        = 10.5f;
/** 聊天气泡和其中语音播放图片水平间距 */
static const CGFloat kUDBubbleToAnimationVoiceImageHorizontalSpacing     = 20.0f;
/** 聊天气泡和其中语音播放图片垂直间距 */
static const CGFloat kUDBubbleToAnimationVoiceImageVerticalSpacing     = 11.0f;
/** 语音播放图片 width */
static const CGFloat kUDAnimationVoiceImageViewWidth     = 12.0f;
/** 语音播放图片 height */
static const CGFloat kUDAnimationVoiceImageViewHeight    = 17.0f;

@interface UdeskChatMessage()

/** 消息气泡frame */
@property (nonatomic, assign, readwrite) CGRect    bubbleImageFrame;
/** 时间frame */
@property (nonatomic, assign, readwrite) CGRect    dateFrame;
/** 文本frame */
@property (nonatomic, assign, readwrite) CGRect    textFrame;
/** 图片frame */
@property (nonatomic, assign, readwrite) CGRect    imageFrame;
/** 语音frame */
@property (nonatomic, assign, readwrite) CGRect    voiceDurationFrame;
/** 语音播放图片frame */
@property (nonatomic, assign, readwrite) CGRect    animationVoiceFrame;
/** 头像frame */
@property (nonatomic, assign, readwrite) CGRect    avatarFrame;
/** 发送失败图片frame */
@property (nonatomic, assign, readwrite) CGRect    failureFrame;
/** 发送中frame */
@property (nonatomic, assign, readwrite) CGRect    activityIndicatorFrame;
/** 消息的文字 */
@property (nonatomic, copy, readwrite) NSAttributedString *cellText;
/** 消息的文字属性 */
@property (nonatomic, copy, readwrite) NSDictionary *cellTextAttributes;

@end

@implementation UdeskChatMessage

- (instancetype)initWithModel:(UdeskMessage *)message withDisplayTimestamp:(BOOL)displayTimestamp {
	
    if (self = [super init]) {
        
        @try {
         
            CGFloat dateHeight = 10;
            self.displayTimestamp = displayTimestamp;
            
            //根据是否显示时间创建
            if (displayTimestamp) {
                
                self.dateFrame = CGRectMake(0, kUDChatMessageDateLabelY, UD_SCREEN_WIDTH, kUDChatMessageDateCellHeight);
                dateHeight = kUDChatMessageDateCellHeight;
            }
            
            if ([UdeskTools isBlankString:message.messageId]) {
                return nil;
            }
            if ([UdeskTools isBlankString:message.content]) {
                return nil;
            }
            
            self.date = message.timestamp;
            self.messageId = message.messageId;
            self.nickName = message.nickName;
            self.avatar = message.avatar;
            self.messageType = message.messageType;
            self.messageFrom = message.messageFrom;
            self.messageStatus = message.messageStatus;
            self.mediaURL = message.content;
            self.image = [UIImage ud_defaultLoadingImage];
            
            //发送的消息
            if (message.messageFrom == UDMessageTypeSending) {
                
                //头像frame
                self.avatarFrame = CGRectMake(UD_SCREEN_WIDTH-kUDAvatarToHorizontalEdgeSpacing-kUDAvatarDiameter, self.dateFrame.origin.y+self.dateFrame.size.height+ kUDAvatarToVerticalEdgeSpacing, kUDAvatarDiameter, kUDAvatarDiameter);
                //用户头像
                self.avatarImage = [UdeskSDKConfig sharedConfig].customerImage;
                if ([UdeskSDKConfig sharedConfig].customerImageURL.length > 0) {
                    
                    [UdeskManager downloadMediaWithUrlString:[UdeskSDKConfig sharedConfig].customerImageURL done:^(NSString *key, id<NSCoding> object) {
                        
                        self.avatarImage = [UdeskImageUtil compressImage:(UIImage *)object toMaxFileSize:CGSizeMake(kUDAvatarDiameter*2, kUDAvatarDiameter*2)];
                        //通知更新
                        if (self.delegate) {
                            if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                                [self.delegate didUpdateCellDataWithMessageId:self.messageId];
                            }
                        }
                    }];
                    
                }
                
                //发送的气泡
                [self sendedMessageBubble];
                //文字消息
                if (message.messageType == UDMessageContentTypeText) {
                    
                    [self sendedMessageOfText:message.content withDateHeight:dateHeight];
                }
                //图片消息
                else if (message.messageType == UDMessageContentTypeImage) {
                    
                    CGSize imageSize = CGSizeMake(message.width, message.height);
                    if (message.width==0 || message.height==0) {
                        imageSize = CGSizeMake(150, 150);
                    }
                    [self sendedMessageOfImage:imageSize withDateHeight:dateHeight];
                    
                    [UdeskManager downloadMediaWithUrlString:message.content done:^(NSString *key, id<NSCoding> object) {
                        
                        UIImage *image = (UIImage *)object;
                        self.image = [UIImage compressImageWith:image];
                        //通知更新
                        if (self.delegate) {
                            if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                                [self.delegate didUpdateCellDataWithMessageId:self.messageId];
                            }
                        }
                        
                    }];
                    
                }
                //语音消息
                else if (message.messageType == UDMessageContentTypeVoice) {
                    
                    [self messageVoiceAnimationImageViewWithBubbleMessageType:UDMessageTypeSending];
                    
                    [UdeskManager downloadMediaWithUrlString:message.content done:^(NSString *key, id<NSCoding> object) {
                        
                        NSData *voiceData = (NSData *)object;
                        [self sendedMessageOfVoice:voiceData withDateHeight:dateHeight];
                        //通知更新
                        if (self.delegate) {
                            if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                                [self.delegate didUpdateCellDataWithMessageId:self.messageId];
                            }
                        }
                    }];
                }
                
            }
            //接收的消息
            else if (message.messageFrom == UDMessageTypeReceiving) {
                
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
                                [self.delegate didUpdateCellDataWithMessageId:self.messageId];
                            }
                        }
                    }];
                }
                
                //气泡
                UIImage *bubbleImage = [UdeskSDKConfig sharedConfig].sdkStyle.agentBubbleImage;
                
                if ([UdeskSDKConfig sharedConfig].sdkStyle.agentBubbleColor) {
                    bubbleImage = [bubbleImage convertImageColor:[UdeskSDKConfig sharedConfig].sdkStyle.agentBubbleColor];
                }
                
                self.bubbleImage = [bubbleImage stretchableImageWithLeftCapWidth:bubbleImage.size.width*0.5f topCapHeight:bubbleImage.size.height*0.8f];
                
                //文字消息
                if (message.messageType == UDMessageContentTypeText) {
                    
                    self.text = [UdeskManager convertToUnicodeWithEmojiAlias:message.content];
                    [self setAttributedCellText:self.text messageFrom:self.messageFrom];
                    
                    NSMutableDictionary *richURLDictionary = [NSMutableDictionary dictionary];
                    NSMutableArray *richContetnArray = [NSMutableArray array];
                    
                    for (NSString *linkRegex in [UdeskSDKConfig sharedConfig].linkRegexs) {
                        
                        NSRange range = [self.text rangeOfString:linkRegex options:NSRegularExpressionSearch];
                        if (range.location != NSNotFound) {
                            [richURLDictionary setValue:[NSValue valueWithRange:range] forKey:[self.text substringWithRange:range]];
                            [richContetnArray addObject:[self.text substringWithRange:range]];
                        }
                    }
                    self.matchArray = [NSArray arrayWithArray:richContetnArray];
                    self.richURLDictionary = [NSDictionary dictionaryWithDictionary:richURLDictionary];
                    
                    NSMutableDictionary *numberDictionary = [NSMutableDictionary dictionary];
                    for (NSString *linkRegex in [UdeskSDKConfig sharedConfig].numberRegexs) {
                        
                        NSRange range = [self.text rangeOfString:linkRegex options:NSRegularExpressionSearch];
                        if (range.location != NSNotFound) {
                            [numberDictionary setValue:[NSValue valueWithRange:range] forKey:[self.text substringWithRange:range]];
                        }
                    }
                    self.numberRangeDic = [NSDictionary dictionaryWithDictionary:numberDictionary];
                    
                    CGSize textSize = [self neededSizeForText:self.text];
                    //接收文字气泡frame
                    self.bubbleImageFrame = CGRectMake(self.avatarFrame.origin.x+kUDAvatarDiameter+kUDAvatarToBubbleSpacing, self.dateFrame.origin.y+self.dateFrame.size.height+kUDAvatarToVerticalEdgeSpacing, textSize.width+(kUDBubbleToTextHorizontalSpacing*3), textSize.height+(kUDBubbleToTextVerticalSpacing*2));
                    //接收文字frame
                    self.textFrame = CGRectMake(self.bubbleImageFrame.origin.x+kUDBubbleToTextHorizontalSpacing+kUDArrowMarginWidth, self.bubbleImageFrame.origin.y+kUDBubbleToTextVerticalSpacing, textSize.width, textSize.height);
                    //cell高度
                    self.cellHeight = self.bubbleImageFrame.size.height+self.bubbleImageFrame.origin.y+dateHeight;
                }
                //欢迎语超链接
                else if (message.messageType == UDMessageContentTypeRich) {

                    [self setRichAttributedCellText:message.content messageFrom:message.messageFrom];

                    CGSize textSize = [self neededSizeForText:message.content];
                    //接收文字气泡frame
                    self.bubbleImageFrame = CGRectMake(self.avatarFrame.origin.x+kUDAvatarDiameter+kUDAvatarToBubbleSpacing, self.dateFrame.origin.y+self.dateFrame.size.height+kUDAvatarToVerticalEdgeSpacing, textSize.width+(kUDBubbleToTextHorizontalSpacing*3), textSize.height+(kUDBubbleToTextVerticalSpacing*2));
                    //接收文字frame
                    self.textFrame = CGRectMake(self.bubbleImageFrame.origin.x+kUDBubbleToTextHorizontalSpacing+kUDArrowMarginWidth, self.bubbleImageFrame.origin.y+kUDBubbleToTextVerticalSpacing, textSize.width, textSize.height);
                    //cell高度
                    self.cellHeight = self.bubbleImageFrame.size.height+self.bubbleImageFrame.origin.y+dateHeight;
                }
                //图片消息
                else if (message.messageType == UDMessageContentTypeImage) {
                    
                    CGSize imageSize = CGSizeMake(message.width, message.height);
                    if (message.width==0 || message.height==0) {
                        imageSize = CGSizeMake(150, 150);
                    }
                    [self receiveMessageOfImage:imageSize withDateHeight:dateHeight];
                    
                    [UdeskManager downloadMediaWithUrlString:message.content done:^(NSString *key, id<NSCoding> object) {
                        
                        UIImage *image = (UIImage *)object;
                        self.image = [UIImage compressImageWith:image];
                        //通知更新
                        if (self.delegate) {
                            if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                                [self.delegate didUpdateCellDataWithMessageId:self.messageId];
                            }
                        }
                        
                    }];
                    
                }
                //语音消息
                else if (message.messageType == UDMessageContentTypeVoice) {
                    
                    [self messageVoiceAnimationImageViewWithBubbleMessageType:UDMessageTypeReceiving];
                    
                    if (message.voiceData) {
                        
                        [self receiveMessageOfVoice:message.voiceData withDateHeight:dateHeight];
                    }
                    else {
                        
                        [UdeskManager downloadMediaWithUrlString:message.content done:^(NSString *key, id<NSCoding> object) {
                            
                            NSData *voiceData = (NSData *)object;
                            [self receiveMessageOfVoice:voiceData withDateHeight:dateHeight];
                            //通知更新
                            if (self.delegate) {
                                if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                                    [self.delegate didUpdateCellDataWithMessageId:self.messageId];
                                }
                            }
                        }];
                    }
                    
                }
                
            }
            
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
    }
    return self;
}

// 计算文本实际的大小
- (CGSize)neededSizeForText:(NSString *)text {
    
    @try {
        
        if ([UdeskTools isBlankString:text]) {
            return CGSizeMake(50, 50);
        }
        
        CGSize textSize = [UdeskStringSizeUtil getSizeForAttributedText:self.cellText textWidth:UD_SCREEN_WIDTH>320?235:180];
        
        if ([UdeskTools stringContainsEmoji:[self.cellText string]]) {
            NSAttributedString *oneLineText = [[NSAttributedString alloc] initWithString:@"haha" attributes:self.cellTextAttributes];
            CGFloat oneLineTextHeight = [UdeskStringSizeUtil getHeightForAttributedText:oneLineText textWidth:UD_SCREEN_WIDTH>320?235:180];
            NSInteger textLines = ceil(textSize.height / oneLineTextHeight);
            textSize.height += 8 * textLines;
        }
        
        textSize.height += 2;
        return textSize;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

// 计算图片实际大小
- (CGSize)neededSizeForPhoto:(UIImage *)image {
    
    @try {
        
        CGSize imageSize = CGSizeMake(150, 150);
        
        if (image) {
            
            CGFloat fixedSize;
            if (UD_SCREEN_WIDTH>320) {
                fixedSize = 140;
            }
            else {
                fixedSize = 115;
            }
            
            if (image.size.height > image.size.width) {
                
                CGFloat scale = image.size.height/fixedSize;
                if (scale!=0) {
                    
                    CGFloat newWidth = (image.size.width)/scale;
                    
                    imageSize = CGSizeMake(newWidth<60.0f?60:newWidth, fixedSize);
                }
            }
            else if (image.size.height < image.size.width) {
                
                CGFloat scale = image.size.width/fixedSize;
                
                if (scale!=0) {
                    
                    CGFloat newHeight = (image.size.height)/scale;
                    imageSize = CGSizeMake(fixedSize, newHeight);
                }
                
            }
            else if (image.size.height == image.size.width) {
                
                imageSize = CGSizeMake(fixedSize, fixedSize);
            }
            
        }
        // 这里需要缩放后的size
        return imageSize;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

// 计算语音实际大小
- (CGSize)neededSizeForVoiceDuration:(NSString *)voiceDuration {
    
    @try {
        
        // 这里的100只是暂时固定，到时候会根据一个函数来计算
        CGSize voiceSize = CGSizeMake(50, 40.0);
        if (voiceDuration.length) {
            if ([voiceDuration floatValue]) {
                
                voiceSize = CGSizeMake(MIN(50 + [voiceDuration floatValue]*2.5f, 130), 40.0);
            }
            else {
                voiceSize = CGSizeMake(50, 40.0);
            }
        }
        
        return voiceSize;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

//初始化发送的文本消息
- (instancetype)initWithText:(NSString *)text withDisplayTimestamp:(BOOL)displayTimestamp {
	
    if (self = [super init]) {
        
        @try {
            
            if ([UdeskTools isBlankString:text]) {
                return nil;
            }
            
            self.displayTimestamp = displayTimestamp;
            CGFloat dateHeight = 10;
            //根据是否显示时间创建
            if (displayTimestamp) {
                
                self.dateFrame = CGRectMake(0, kUDChatMessageDateLabelY, UD_SCREEN_WIDTH, kUDChatMessageDateCellHeight);
                dateHeight = kUDChatMessageDateCellHeight;
            }
            self.date = [NSDate date];
            self.messageId = [[NSUUID UUID] UUIDString];
            self.messageType = UDMessageContentTypeText;
            self.messageFrom = UDMessageTypeSending;
            self.messageStatus = UDMessageSendStatusSending;
            
            //用户头像
            self.avatarImage = [UdeskSDKConfig sharedConfig].customerImage;
            if ([UdeskSDKConfig sharedConfig].customerImageURL.length > 0) {
                
                [UdeskManager downloadMediaWithUrlString:[UdeskSDKConfig sharedConfig].customerImageURL done:^(NSString *key, id<NSCoding> object) {
                    
                    self.avatarImage = [UdeskImageUtil compressImage:(UIImage *)object toMaxFileSize:CGSizeMake(kUDAvatarDiameter*2, kUDAvatarDiameter*2)];
                    //通知更新
                    if (self.delegate) {
                        if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                            [self.delegate didUpdateCellDataWithMessageId:self.messageId];
                        }
                    }
                }];
                
            }
            
            //头像frame
            self.avatarFrame = CGRectMake(UD_SCREEN_WIDTH-kUDAvatarToHorizontalEdgeSpacing-kUDAvatarDiameter, self.dateFrame.origin.y+self.dateFrame.size.height+ kUDAvatarToVerticalEdgeSpacing, kUDAvatarDiameter, kUDAvatarDiameter);
            //发送的气泡
            [self sendedMessageBubble];
            //文字
            [self sendedMessageOfText:text withDateHeight:dateHeight];
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
    }
    
    return self;
}

//初始化发送的图片消息
- (instancetype)initWithImage:(UIImage *)image withDisplayTimestamp:(BOOL)displayTimestamp {
    
    if (self = [super init]) {
        
        @try {
            
            self.displayTimestamp = displayTimestamp;
            CGFloat dateHeight = 10;
            //根据是否显示时间创建
            if (displayTimestamp) {
                
                self.dateFrame = CGRectMake(0, kUDChatMessageDateLabelY, UD_SCREEN_WIDTH, kUDChatMessageDateCellHeight);
                dateHeight = kUDChatMessageDateCellHeight;
            }
            self.date = [NSDate date];
            self.messageId = [[NSUUID UUID] UUIDString];
            self.messageType = UDMessageContentTypeImage;
            self.messageFrom = UDMessageTypeSending;
            self.messageStatus = UDMessageSendStatusSending;
            //用户头像
            self.avatarImage = [UdeskSDKConfig sharedConfig].customerImage;
            if ([UdeskSDKConfig sharedConfig].customerImageURL.length > 0) {
                
                [UdeskManager downloadMediaWithUrlString:[UdeskSDKConfig sharedConfig].customerImageURL done:^(NSString *key, id<NSCoding> object) {
                    
                    self.avatarImage = [UdeskImageUtil compressImage:(UIImage *)object toMaxFileSize:CGSizeMake(kUDAvatarDiameter*2, kUDAvatarDiameter*2)];
                    //通知更新
                    if (self.delegate) {
                        if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                            [self.delegate didUpdateCellDataWithMessageId:self.messageId];
                        }
                    }
                }];
                
            }
            
            //头像frame
            self.avatarFrame = CGRectMake(UD_SCREEN_WIDTH-kUDAvatarToHorizontalEdgeSpacing-kUDAvatarDiameter, self.dateFrame.origin.y+self.dateFrame.size.height+ kUDAvatarToVerticalEdgeSpacing, kUDAvatarDiameter, kUDAvatarDiameter);
            //发送的气泡
            [self sendedMessageBubble];
            //图片
            CGSize imageSize = [self neededSizeForPhoto:image];
            self.image = [UIImage imageWithData:UIImageJPEGRepresentation([UIImage compressImageWith:image], 0.5f)];
            
            [self sendedMessageOfImage:imageSize withDateHeight:dateHeight];
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
    }
    
    return self;
}

//初始化发送的语音消息
- (instancetype)initWithVoiceData:(NSData *)voiceData withDisplayTimestamp:(BOOL)displayTimestamp {

    if (self = [super init]) {
     
        @try {
            
            self.displayTimestamp = displayTimestamp;
            CGFloat dateHeight = 10;
            //根据是否显示时间创建
            if (displayTimestamp) {
                
                self.dateFrame = CGRectMake(0, kUDChatMessageDateLabelY, UD_SCREEN_WIDTH, kUDChatMessageDateCellHeight);
                dateHeight = kUDChatMessageDateCellHeight;
            }
            
            self.date = [NSDate date];
            self.messageId = [[NSUUID UUID] UUIDString];
            self.messageType = UDMessageContentTypeVoice;
            self.messageFrom = UDMessageTypeSending;
            self.messageStatus = UDMessageSendStatusSending;
            //用户头像
            self.avatarImage = [UdeskSDKConfig sharedConfig].customerImage;
            if ([UdeskSDKConfig sharedConfig].customerImageURL.length > 0) {
                
                [UdeskManager downloadMediaWithUrlString:[UdeskSDKConfig sharedConfig].customerImageURL done:^(NSString *key, id<NSCoding> object) {
                    
                    self.avatarImage = [UdeskImageUtil compressImage:(UIImage *)object toMaxFileSize:CGSizeMake(kUDAvatarDiameter*2, kUDAvatarDiameter*2)];
                    //通知更新
                    if (self.delegate) {
                        if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                            [self.delegate didUpdateCellDataWithMessageId:self.messageId];
                        }
                    }
                }];
            }
            
            //头像frame
            self.avatarFrame = CGRectMake(UD_SCREEN_WIDTH-kUDAvatarToHorizontalEdgeSpacing-kUDAvatarDiameter, self.dateFrame.origin.y+self.dateFrame.size.height+ kUDAvatarToVerticalEdgeSpacing, kUDAvatarDiameter, kUDAvatarDiameter);
            //发送的气泡
            [self sendedMessageBubble];
            //语音播放
            [self messageVoiceAnimationImageViewWithBubbleMessageType:UDMessageTypeSending];
            //语音
            [self sendedMessageOfVoice:voiceData withDateHeight:dateHeight];
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
    }
    
    return self;
}

//发送文本消息的组件
- (void)sendedMessageOfText:(NSString *)text withDateHeight:(CGFloat)dateHeight {

    @try {
        
        if ([UdeskTools isBlankString:text]) {
            return;
        }
        
        NSMutableDictionary *richURLDictionary = [NSMutableDictionary dictionary];
        NSMutableArray *richContetnArray = [NSMutableArray array];
        
        for (NSString *linkRegex in [UdeskSDKConfig sharedConfig].linkRegexs) {
            
            NSRange range = [text rangeOfString:linkRegex options:NSRegularExpressionSearch];
            if (range.location != NSNotFound) {
                [richURLDictionary setValue:[NSValue valueWithRange:range] forKey:[text substringWithRange:range]];
                [richContetnArray addObject:[text substringWithRange:range]];
            }
        }
        
        self.matchArray = [NSArray arrayWithArray:richContetnArray];
        self.richURLDictionary = [NSDictionary dictionaryWithDictionary:richURLDictionary];
        
        NSMutableDictionary *numberDictionary = [NSMutableDictionary dictionary];
        for (NSString *linkRegex in [UdeskSDKConfig sharedConfig].numberRegexs) {
            
            NSRange range = [text rangeOfString:linkRegex options:NSRegularExpressionSearch];
            if (range.location != NSNotFound) {
                [numberDictionary setValue:[NSValue valueWithRange:range] forKey:[text substringWithRange:range]];
            }
        }
        self.numberRangeDic = [NSDictionary dictionaryWithDictionary:numberDictionary];
        
        //文本
        self.text = text;
        
        [self setAttributedCellText:self.text messageFrom:self.messageFrom];
        
        CGSize textSize = [self neededSizeForText:text];
        //文本气泡frame
        self.bubbleImageFrame = CGRectMake(self.avatarFrame.origin.x-kUDArrowMarginWidth-kUDBubbleToTextHorizontalSpacing*2-kUDAvatarToBubbleSpacing-textSize.width, self.avatarFrame.origin.y, textSize.width+(kUDBubbleToTextHorizontalSpacing*3), textSize.height+(kUDBubbleToTextVerticalSpacing*2));
        //文本frame
        self.textFrame = CGRectMake(self.bubbleImageFrame.origin.x+kUDBubbleToTextHorizontalSpacing, self.bubbleImageFrame.origin.y+kUDBubbleToTextVerticalSpacing, textSize.width, textSize.height);
        //加载中frame
        self.activityIndicatorFrame = CGRectMake(self.bubbleImageFrame.origin.x-kUDBubbleToSendStatusSpacing-kUDSendStatusDiameter, self.textFrame.origin.y, kUDSendStatusDiameter, kUDSendStatusDiameter);
        //加载失败frame
        self.failureFrame = self.activityIndicatorFrame;
        //重发按钮图片
        self.failureImage = [UIImage ud_defaultRefreshImage];
        //cell高度
        self.cellHeight = self.bubbleImageFrame.size.height+self.bubbleImageFrame.origin.y+dateHeight;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

//发送图片消息的组件
- (void)sendedMessageOfImage:(CGSize)imageSize withDateHeight:(CGFloat)dateHeight {

    @try {
        
        //图片气泡位置
        self.bubbleImageFrame = CGRectMake(self.avatarFrame.origin.x-kUDArrowMarginWidth-kUDBubbleToImageHorizontalSpacing*2-kUDAvatarToBubbleSpacing-imageSize.width, self.avatarFrame.origin.y, imageSize.width+(kUDBubbleToImageHorizontalSpacing*4), imageSize.height+(kUDBubbleToImageHorizontalSpacing*2));
        //图片位置
        self.imageFrame = self.bubbleImageFrame;
        //发送中frame
        self.activityIndicatorFrame = CGRectMake(self.bubbleImageFrame.origin.x-kUDBubbleToSendStatusSpacing-kUDSendStatusDiameter, self.imageFrame.origin.y, kUDSendStatusDiameter, kUDSendStatusDiameter);
        //发送失败frame
        self.failureFrame = self.activityIndicatorFrame;
        //重发按钮图片
        self.failureImage = [UIImage ud_defaultRefreshImage];
        //cell高度
        self.cellHeight = self.bubbleImageFrame.size.height+self.bubbleImageFrame.origin.y+dateHeight;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

//发送语音消息的组件
- (void)sendedMessageOfVoice:(NSData *)voiceData withDateHeight:(CGFloat)dateHeight {
 
    @try {
        
        self.voiceData = voiceData;
        AVAudioPlayer *play = [[AVAudioPlayer alloc] initWithData:voiceData error:nil];
        //语音时长
        NSString *voiceDuration = [NSString stringWithFormat:@"%.f",play.duration];
        //语音文字大小
        CGSize voiceSize = [self neededSizeForVoiceDuration:voiceDuration];
        self.voiceDuration = voiceDuration;
        //语音气泡frame
        self.bubbleImageFrame = CGRectMake(self.avatarFrame.origin.x-kUDArrowMarginWidth-kUDBubbleToTextHorizontalSpacing*2-kUDAvatarToBubbleSpacing-voiceSize.width, self.avatarFrame.origin.y, voiceSize.width+(kUDBubbleToTextHorizontalSpacing*3), voiceSize.height);
        //语音时长frame
        self.voiceDurationFrame = CGRectMake(self.bubbleImageFrame.origin.x-kUDAvatarToBubbleSpacing-voiceSize.width, self.bubbleImageFrame.origin.y+kUDBubbleToTextVerticalSpacing, voiceSize.width, kUDVoiceDurationLabelHeight);
        //发送的语音播放动画图片
        self.animationVoiceFrame = CGRectMake(self.bubbleImageFrame.origin.x+self.bubbleImageFrame.size.width-kUDArrowMarginWidth-kUDBubbleToAnimationVoiceImageHorizontalSpacing, self.bubbleImageFrame.origin.y+ kUDBubbleToAnimationVoiceImageVerticalSpacing, kUDAnimationVoiceImageViewWidth, kUDAnimationVoiceImageViewHeight);
        //发送中
        self.activityIndicatorFrame = CGRectMake(self.bubbleImageFrame.origin.x-kUDBubbleToSendStatusSpacing-kUDSendStatusDiameter, self.voiceDurationFrame.origin.y, kUDSendStatusDiameter, kUDSendStatusDiameter);
        //发送失败
        self.failureFrame = self.activityIndicatorFrame;
        //重发按钮图片
        self.failureImage = [UIImage ud_defaultRefreshImage];
        //cell高度
        self.cellHeight = self.bubbleImageFrame.size.height+self.bubbleImageFrame.origin.y+dateHeight;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)messageVoiceAnimationImageViewWithBubbleMessageType:(UDMessageFromType)type {

    @try {
        
        NSString *imageSepatorName;
        switch (type) {
            case UDMessageTypeSending:
                imageSepatorName = @"udSender";
                break;
            case UDMessageTypeReceiving:
                imageSepatorName = @"udReceiver";
                break;
            default:
                break;
        }
        NSMutableArray *images = [NSMutableArray arrayWithCapacity:0];
        for (NSInteger i = 1; i < 4; i ++) {
            UIImage *image = [UIImage imageWithContentsOfFile:getUDBundlePath([imageSepatorName stringByAppendingFormat:@"VoiceNodePlaying00%ld@2x.png", (long)i])];
            if (image)
                [images addObject:image];
        }
        
        self.animationVoiceImage = [UIImage imageWithContentsOfFile:getUDBundlePath([imageSepatorName stringByAppendingString:@"VoiceNodePlaying003@2x.png"])];
        self.animationVoiceImages = images;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)receiveMessageOfImage:(CGSize)imageSize withDateHeight:(CGFloat)dateHeight {

    @try {
        
        //图片气泡frame
        self.bubbleImageFrame = CGRectMake(self.avatarFrame.origin.x+kUDAvatarDiameter+kUDAvatarToBubbleSpacing, self.dateFrame.origin.y+self.dateFrame.size.height+kUDAvatarToVerticalEdgeSpacing, imageSize.width+(kUDBubbleToImageHorizontalSpacing*4), imageSize.height+(kUDBubbleToImageHorizontalSpacing*2));
        //图片frame
        self.imageFrame = self.bubbleImageFrame;
        //cell高度
        self.cellHeight = self.bubbleImageFrame.size.height+self.bubbleImageFrame.origin.y+dateHeight;
        //通知更新
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                [self.delegate didUpdateCellDataWithMessageId:self.messageId];
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)receiveMessageOfVoice:(NSData *)voiceData withDateHeight:(CGFloat)dateHeight {

    @try {
        
        self.voiceData = voiceData;
        AVAudioPlayer *play = [[AVAudioPlayer alloc] initWithData:voiceData error:nil];
        //语音文字大小
        NSString *voiceDuration = [NSString stringWithFormat:@"%.f",play.duration];
        CGSize voiceSize = [self neededSizeForVoiceDuration:voiceDuration];
        self.voiceDuration = voiceDuration;
        //接收的语音气泡frame
        self.bubbleImageFrame = CGRectMake(self.avatarFrame.origin.x+kUDAvatarDiameter+kUDAvatarToBubbleSpacing, self.dateFrame.origin.y+self.dateFrame.size.height+kUDAvatarToVerticalEdgeSpacing, voiceSize.width+(kUDBubbleToTextHorizontalSpacing*3), voiceSize.height);
        //接收的语音时长frame
        self.voiceDurationFrame = CGRectMake(self.bubbleImageFrame.origin.x+kUDAvatarToBubbleSpacing+self.bubbleImageFrame.size.width, self.bubbleImageFrame.origin.y+kUDBubbleToTextVerticalSpacing, voiceSize.width, kUDVoiceDurationLabelHeight);
        //发送的语音播放动画图片
        self.animationVoiceFrame = CGRectMake(self.bubbleImageFrame.origin.x+kUDBubbleToAnimationVoiceImageHorizontalSpacing, self.bubbleImageFrame.origin.y+kUDBubbleToAnimationVoiceImageVerticalSpacing, kUDAnimationVoiceImageViewWidth, kUDAnimationVoiceImageViewHeight);
        //cell高度
        self.cellHeight = self.bubbleImageFrame.size.height+self.bubbleImageFrame.origin.y+dateHeight;
        //通知更新
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(didUpdateCellDataWithMessageId:)]) {
                [self.delegate didUpdateCellDataWithMessageId:self.messageId];
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)setRichAttributedCellText:(NSString *)text messageFrom:(UDMessageFromType)messageFrom {
    
    NSDictionary *dic = @{
                          NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,
                          NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)
                          };
    
    self.cellText = [[NSMutableAttributedString alloc] initWithData:[text dataUsingEncoding:NSUTF8StringEncoding] options:dic documentAttributes:nil error:nil];
    
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithAttributedString:self.cellText];
    NSRange range = NSMakeRange(0, self.cellText.string.length);
    // 设置字体大小
    [att addAttribute:NSFontAttributeName value:[UdeskSDKConfig sharedConfig].sdkStyle.messageContentFont range:range];
    // 设置颜色
    if (messageFrom == UDMessageTypeSending) {
        [att addAttribute:NSForegroundColorAttributeName value:[UdeskSDKConfig sharedConfig].sdkStyle.customerTextColor range:range];
    } else {
        [att addAttribute:NSForegroundColorAttributeName value:[UdeskSDKConfig sharedConfig].sdkStyle.agentTextColor range:range];
    }
    //字间距
    [att addAttribute:NSKernAttributeName value:@(2) range:range];
    
    self.cellText = att;
}

- (void)setAttributedCellText:(NSString *)text messageFrom:(UDMessageFromType)messageFrom {

    @try {
        
        if ([UdeskTools isBlankString:text]) {
            return;
        }
        
        self.cellTextAttributes = [[NSDictionary alloc] initWithDictionary:[self setParagraphStyle:messageFrom]];
        self.cellText = [[NSAttributedString alloc] initWithString:text attributes:self.cellTextAttributes];
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (NSMutableDictionary *)setParagraphStyle:(UDMessageFromType)messageFrom {

    NSMutableParagraphStyle *contentParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    contentParagraphStyle.lineSpacing = 6.0f;
    contentParagraphStyle.lineHeightMultiple = 1.0f;
    contentParagraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    contentParagraphStyle.alignment = NSTextAlignmentLeft;
    NSMutableDictionary *contentAttributes
    = [[NSMutableDictionary alloc]
       initWithDictionary:@{
                            NSParagraphStyleAttributeName : contentParagraphStyle,
                            NSFontAttributeName : [UdeskSDKConfig sharedConfig].sdkStyle.messageContentFont
                            }];
    if (messageFrom == UDMessageTypeSending) {
        [contentAttributes setObject:(__bridge id)[UdeskSDKConfig sharedConfig].sdkStyle.customerTextColor.CGColor forKey:(__bridge id)kCTForegroundColorAttributeName];
    } else {
        [contentAttributes setObject:(__bridge id)[UdeskSDKConfig sharedConfig].sdkStyle.agentTextColor.CGColor forKey:(__bridge id)kCTForegroundColorAttributeName];
    }

    return contentAttributes;
}

- (void)sendedMessageBubble {

    @try {
        
        //气泡
        UIImage *bubbleImage = [UdeskSDKConfig sharedConfig].sdkStyle.customerBubbleImage;
        if ([UdeskSDKConfig sharedConfig].sdkStyle.customerBubbleColor) {
            bubbleImage = [bubbleImage convertImageColor:[UdeskSDKConfig sharedConfig].sdkStyle.customerBubbleColor];
        }
        self.bubbleImage = [bubbleImage stretchableImageWithLeftCapWidth:bubbleImage.size.width*0.5f topCapHeight:bubbleImage.size.height*0.8f];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {

    return [[UdeskChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
