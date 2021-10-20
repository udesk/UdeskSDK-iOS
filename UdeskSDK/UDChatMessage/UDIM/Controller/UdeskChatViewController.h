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
- (void)sendTextMessageWithContent:(NSString *)content completion:(void(^)(UdeskMessage *message))completion;
//发送图片
- (void)sendImageMessageWithImage:(UIImage *)image completion:(void(^)(UdeskMessage *message))completion;
//发送GIF图片
- (void)sendGIFMessageWithGIFData:(NSData *)gifData completion:(void(^)(UdeskMessage *message))completion;
//发送视频
- (void)sendVideoMessageWithVideoFile:(NSString *)videoFild completion:(void(^)(UdeskMessage *message))completion;
//发送语音
- (void)sendVoiceMessageWithVoicePath:(NSString *)voicePath voiceDuration:(NSString *)voiceDuration completion:(void(^)(UdeskMessage *message))completion;
//发送位置
- (void)sendLoactionMessageWithModel:(UdeskLocationModel *)locationModel completion:(void(^)(UdeskMessage *message))completion;
//发送商品
- (void)sendGoodsMessageWithModel:(UdeskGoodsModel *)goodsModel completion:(void(^)(UdeskMessage *message))completion;

@end
