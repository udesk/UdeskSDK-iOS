//
//  UdeskChatMessage.m
//  UdeskSDK
//
//  Created by xuchen on 16/8/12.
//  Copyright © 2016年 xuchen. All rights reserved.
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
#import "UDTTTAttributedLabel.h"

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
        
        CGFloat dateHeight = 10;
        self.displayTimestamp = displayTimestamp;
        
        //根据是否显示时间创建
        if (displayTimestamp) {
            
            self.dateFrame = CGRectMake(0, kUDChatMessageDateLabelY, UD_SCREEN_WIDTH, kUDChatMessageDateCellHeight);
            dateHeight = kUDChatMessageDateCellHeight;
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
            
                NSData *htmlData = [message.content dataUsingEncoding:NSUTF8StringEncoding];
                UdeskHpple *xpathParser = [[UdeskHpple alloc] initWithHTMLData:htmlData];
                
                NSArray *dataPArray = [xpathParser searchWithXPathQuery:@"//p"];
                NSArray *dataAArray = [xpathParser searchWithXPathQuery:@"//a"];
                
                NSString *newText;
                for (UdeskHppleElement *happleElement in dataPArray) {
                    
                    if ([UdeskTools isBlankString:newText]) {
                        newText = happleElement.content;
                    }
                    else {
                        
                        newText = [newText stringByAppendingString:[NSString stringWithFormat:@"\n%@",happleElement.content]];
                    }
                    
                }
                
                self.text = newText;
                [self setAttributedCellText:self.text messageFrom:message.messageFrom];
                
                NSMutableDictionary *richURLDictionary = [NSMutableDictionary dictionary];
                NSMutableArray *richContetnArray = [NSMutableArray array];
                
                for (UdeskHppleElement *happleElement in dataAArray) {
                    
                    [richURLDictionary setObject:[NSString stringWithFormat:@"%@",happleElement.attributes[@"href"]] forKey:[NSValue valueWithRange:[self.text rangeOfString:happleElement.content]]];
                    [richContetnArray addObject:happleElement.content];
                }
                
                self.matchArray = [NSArray arrayWithArray:richContetnArray];
                self.richURLDictionary = [NSDictionary dictionaryWithDictionary:richURLDictionary];

                CGSize textSize = [self neededSizeForText:newText];
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
        
    }
    return self;
}

// 计算文本实际的大小
- (CGSize)neededSizeForText:(NSString *)text {
    
    //文字最大宽度
    CGFloat maxLabelWidth = UD_SCREEN_WIDTH>320?235:180;
    
    //文字高度
    CGFloat messageTextHeight = [UdeskStringSizeUtil getHeightForAttributedText:self.cellText textWidth:maxLabelWidth];
    //判断文字中是否有emoji
    if ([self stringContainsEmoji:[self.cellText string]]) {
        NSAttributedString *oneLineText = [[NSAttributedString alloc] initWithString:@"haha" attributes:self.cellTextAttributes];
        CGFloat oneLineTextHeight = [UdeskStringSizeUtil getHeightForAttributedText:oneLineText textWidth:maxLabelWidth];
        NSInteger textLines = ceil(messageTextHeight / oneLineTextHeight);
        messageTextHeight += 8 * textLines;
    }
    //文字宽度
    CGFloat messageTextWidth = [UdeskStringSizeUtil getWidthForAttributedText:self.cellText textHeight:messageTextHeight];
    //#warning 注：这里textLabel的宽度之所以要增加，是因为TTTAttributedLabel的bug，在文字有"."的情况下，有可能显示不出来，开发者可以帮忙定位TTTAttributedLabel的这个bug^.^
    NSRange periodRange = [self.cellText.string rangeOfString:@"."];
    if (periodRange.location != NSNotFound) {
        messageTextWidth += 8;
    }
    if (messageTextWidth > maxLabelWidth) {
        messageTextWidth = maxLabelWidth;
    }
    
    return CGSizeMake(messageTextWidth, messageTextHeight);
}

- (BOOL)stringContainsEmoji:(NSString *)string
{
    __block BOOL returnValue = NO;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue = YES;
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue = YES;
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue = YES;
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue = YES;
                                    }
                                }
                            }];
    
    return returnValue;
}

// 计算图片实际大小
- (CGSize)neededSizeForPhoto:(UIImage *)image {
    
    CGSize imageSize;
    
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
    
    // 这里需要缩放后的size
    return imageSize;
}

// 计算语音实际大小
- (CGSize)neededSizeForVoiceDuration:(NSString *)voiceDuration {
    // 这里的100只是暂时固定，到时候会根据一个函数来计算
    CGSize voiceSize;
    if ([voiceDuration floatValue]) {
        voiceSize = CGSizeMake(40 + [voiceDuration floatValue]*5, 40.0);
        if (UD_SCREEN_WIDTH>320) {
            if (voiceSize.width>325.0f) {
                voiceSize = CGSizeMake(325.0f, 40.0);
            }
        }
        else {
            if (voiceSize.width>180.0f) {
                voiceSize = CGSizeMake(180.0f, 40.0);
            }
        }
    }
    else {
        voiceSize = CGSizeMake(50, 40.0);
    }
    return voiceSize;
}

//初始化发送的文本消息
- (instancetype)initWithText:(NSString *)text withDisplayTimestamp:(BOOL)displayTimestamp {
	
    if (self = [super init]) {
        
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
    }
    
    return self;
}

//初始化发送的图片消息
- (instancetype)initWithImage:(UIImage *)image withDisplayTimestamp:(BOOL)displayTimestamp {
    
    if (self = [super init]) {
        
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
        self.image = [UIImage compressImageWith:image];
        
        [self sendedMessageOfImage:imageSize withDateHeight:dateHeight];
    }
    
    return self;
}

//初始化发送的语音消息
- (instancetype)initWithVoiceData:(NSData *)voiceData withDisplayTimestamp:(BOOL)displayTimestamp {

    if (self = [super init]) {
     
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
    }
    
    return self;
}

//发送文本消息的组件
- (void)sendedMessageOfText:(NSString *)text withDateHeight:(CGFloat)dateHeight {

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
}

//发送图片消息的组件
- (void)sendedMessageOfImage:(CGSize)imageSize withDateHeight:(CGFloat)dateHeight {

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
}

//发送语音消息的组件
- (void)sendedMessageOfVoice:(NSData *)voiceData withDateHeight:(CGFloat)dateHeight {
 
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
}

- (void)messageVoiceAnimationImageViewWithBubbleMessageType:(UDMessageFromType)type {

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
}

- (void)receiveMessageOfImage:(CGSize)imageSize withDateHeight:(CGFloat)dateHeight {

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

}

- (void)receiveMessageOfVoice:(NSData *)voiceData withDateHeight:(CGFloat)dateHeight {

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

}

- (void)setAttributedCellText:(NSString *)text messageFrom:(UDMessageFromType)messageFrom {

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
    self.cellTextAttributes = [[NSDictionary alloc] initWithDictionary:contentAttributes];
    self.cellText = [[NSAttributedString alloc] initWithString:text attributes:self.cellTextAttributes];
}

- (void)sendedMessageBubble {

    //气泡
    UIImage *bubbleImage = [UdeskSDKConfig sharedConfig].sdkStyle.customerBubbleImage;
    if ([UdeskSDKConfig sharedConfig].sdkStyle.customerBubbleColor) {
        bubbleImage = [bubbleImage convertImageColor:[UdeskSDKConfig sharedConfig].sdkStyle.customerBubbleColor];
    }
    self.bubbleImage = [bubbleImage stretchableImageWithLeftCapWidth:bubbleImage.size.width*0.5f topCapHeight:bubbleImage.size.height*0.8f];
}

@end
