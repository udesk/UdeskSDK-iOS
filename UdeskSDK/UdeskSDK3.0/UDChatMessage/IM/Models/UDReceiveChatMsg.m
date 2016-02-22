//
//  UDReceiveChatMsg.m
//  UdeskSDK
//
//  Created by xuchen on 15/11/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import "UDReceiveChatMsg.h"

@implementation UDReceiveChatMsg

+ (instancetype)store {

    return [[self alloc] init];

}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)resolveChatMsg:(NSDictionary *)messageDic callbackMsg:(void(^)(UDMessage *message))block {

    UDMessage *message = [[UDMessage alloc] init];
    NSString *content_id = [UDTools soleString];
    if ([UDTools isBlankString:message.contentId]) {
        message.contentId = content_id;
    }
    
    message.messageStatus = UDMessageSuccess;
    
    NSString *receiveType = [messageDic objectForKey:@"type"];
    NSString *receiveContent = [[messageDic objectForKey:@"data"] objectForKey:@"content"];
    
    //消息类型
    NSString *type = receiveType;
    //消息内容
    NSString *content = receiveContent;
    
    //消息时间
    NSString *created_at = [UDTools nowDate];
    NSString *subString = [created_at substringWithRange:NSMakeRange(0, 19)];
    
    NSDate *lastDate = [UDTools dateFromString:subString];
    
    message.timestamp = lastDate;
    message.messageFrom = UDMessageTypeReceiving;
    
    //这里文件类型是个地址 所以归类到message了
    if ([type isEqualToString:@"message"]||[type isEqualToString:@"file"]) {
        message.text = [UDTools receiveTextEmoji:content];
        message.messageType = UDMessageMediaTypeText;
        
        NSArray *textDBArray = @[content,subString,content_id,[NSString stringWithFormat:@"%ld",(long)UDMessageSuccess],[NSString stringWithFormat:@"%ld",(long)UDMessageTypeReceiving],[NSString stringWithFormat:@"0"]];
        [UDManager insertTableWithSqlString:InsertTextMsg params:textDBArray];
        
        if (block) {
            block(message);
        }
    }
    else if ([type isEqualToString:@"image"]) {
        
        //缓存image
        NSString *newURL = [content stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:newURL]];
        
        NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            UIImage *image = [UIImage imageWithData:data];
            message.photo  = image;

            //缓存图片
            [[YYCache sharedCache] setObject:image forKey:message.contentId withBlock:nil];
            
            message.messageType = UDMessageMediaTypePhoto;
            message.photoUrl = content;
            
            CGSize imageSize = [UDTools setImageSize:image];
            NSString *newWidth = [NSString stringWithFormat:@"%f",imageSize.width];
            NSString *newHeight = [NSString stringWithFormat:@"%f",imageSize.height];
            message.width = newWidth;
            message.height = newHeight;
            //缓存图片
            NSArray *photoDBArray = @[content,subString,content_id,[NSString stringWithFormat:@"%ld",(long)UDMessageSuccess],[NSString stringWithFormat:@"%ld",(long)UDMessageTypeReceiving],[NSString stringWithFormat:@"1"],newWidth,newHeight];
            [UDManager insertTableWithSqlString:InsertPhotoMsg params:photoDBArray];
            
            if (block) {
                block(message);
            }
            
        }];
        
        [dataTask resume];
        
    }
    else if ([type isEqualToString:@"audio"]) {
        
        NSString *newURL = [content stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [[NSURL alloc]initWithString:newURL];
        NSData *audioData = [NSData dataWithContentsOfURL:url];
        
        AVAudioPlayer *pl = [[AVAudioPlayer alloc] initWithData:audioData error:nil];
        
        message.voiceDuration = [NSString stringWithFormat:@"%.f",pl.duration];
        
        message.messageType = UDMessageMediaTypeVoice;
        //Udesk SDK 使用的第三方缓存框架
        [[YYCache sharedCache] setObject:audioData forKey:message.contentId];
        
        NSArray *audioDBArray = @[content,subString,content_id,[NSString stringWithFormat:@"%ld",(long)UDMessageSuccess],[NSString stringWithFormat:@"%ld",(long)UDMessageTypeReceiving],[NSString stringWithFormat:@"2"],[NSString stringWithFormat:@"%.f",pl.duration]];
        
        [UDManager insertTableWithSqlString:InsertAudioMsg params:audioDBArray];
        
        if (block) {
            block(message);
        }
    }
    else if ([type isEqualToString:@"redirect"]) {
    
        message.messageType = UDMessageMediaTypeRedirect;
        message.messageFrom = UDMessageTypeCenter;
        
        [UDManager getRedirectAgentInformation:messageDic completion:^(id responseObject, NSError *error) {

            
            if ([[responseObject objectForKey:@"code"] integerValue] == 1000) {
                
                NSString *nick = [[[responseObject objectForKey:@"result"] objectForKey:@"agent"] objectForKey:@"nick"];
                
                message.text = [NSString stringWithFormat:@"客服转接成功，%@ 为你服务",nick];
            }
            
            NSArray *textDBArray = @[message.text,subString,content_id,[NSString stringWithFormat:@"%ld",(long)UDMessageSuccess],[NSString stringWithFormat:@"%ld",(long)UDMessageTypeCenter],[NSString stringWithFormat:@"4"]];
            
            [UDManager insertTableWithSqlString:InsertTextMsg params:textDBArray];
            
            if (block) {
                block(message);
            }
            
        }];
    }

    
}

@end
