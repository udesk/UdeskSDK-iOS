//
//  UdeskChatViewController.h
//  UdeskSDK
//
//  Created by Udesk on 15/11/26.
//  Copyright (c) 2015年 Udesk. All rights reserved.
//

#import "UdeskBaseViewController.h"
#import "UdeskChatViewModel.h"

@interface UdeskChatViewController : UdeskBaseViewController

@property (nonatomic, strong, readonly) UdeskChatViewModel  *chatViewModel;//viewModel

//发送文字
- (void)sendTextMessageWithContent:(NSString *)content;
//发送图片
- (void)sendImageMessageWithImage:(UIImage *)image;
//发送GIF图片
- (void)sendGIFMessageWithGIFData:(NSData *)gifData;
//发送视频
- (void)sendVideoMessageWithVideoFile:(NSString *)videoFild;
//发送语音
- (void)sendVoiceMessageWithVoicePath:(NSString *)voicePath voiceDuration:(NSString *)voiceDuration;
//发送位置
- (void)sendLoactionMessageWithModel:(UdeskLocationModel *)locationModel;
//发送商品
- (void)sendGoodsMessageWithModel:(UdeskGoodsModel *)goodsModel;

//更新发送消息的状态
- (void)updateMessageStatus:(UdeskMessage *)message;

@end
