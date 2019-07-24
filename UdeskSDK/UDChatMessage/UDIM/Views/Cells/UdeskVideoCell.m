//
//  UdeskVideoCell.m
//  UdeskSDK
//
//  Created by xuchen on 2017/5/15.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskVideoCell.h"
#import "UdeskVideoMessage.h"
#import "UdeskSDKUtil.h"
#import "UdeskBundleUtils.h"
#import "UdeskCacheUtil.h"
#import "Udesk_WHC_HttpManager.h"
#import "Udesk_WHC_DownloadObject.h"
#import "UdeskToast.h"
#import "UdeskSDKMacro.h"
#import "UIImage+UdeskSDK.h"
#import "UIView+UdeskSDK.h"
#import "UdeskSDKAlert.h"
#import <AVKit/AVKit.h>

@interface UdeskVideoCell ()

@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) UIButton *downloadButton;
@property (nonatomic, strong) UILabel  *videoDuration;

@end

@implementation UdeskVideoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self initVideoFileView];
    }
    return self;
}

- (void)initVideoFileView {

    _previewImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _previewImageView.userInteractionEnabled = YES;
    _previewImageView.layer.cornerRadius = 5;
    _previewImageView.layer.masksToBounds  = YES;
    _previewImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_previewImageView];
    
    _downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_downloadButton setImage:[UIImage udDefaultVideoDownload] forState:UIControlStateNormal];
    [_downloadButton addTarget:self action:@selector(downloadAction) forControlEvents:UIControlEventTouchUpInside];
    [_previewImageView addSubview:_downloadButton];
    
    _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playButton setImage:[UIImage udDefaultVideoPlay] forState:UIControlStateNormal];
    [_playButton addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
    [_previewImageView addSubview:_playButton];
    
    _videoDuration = [[UILabel alloc] initWithFrame:CGRectZero];
    _videoDuration.textColor = [UIColor whiteColor];
    _videoDuration.font = [UIFont systemFontOfSize:12];
    _videoDuration.textAlignment = NSTextAlignmentCenter;
    [_previewImageView addSubview:_videoDuration];
    
    _uploadProgressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _uploadProgressLabel.textColor = [UIColor whiteColor];
    _uploadProgressLabel.layer.masksToBounds = YES;
    _uploadProgressLabel.layer.cornerRadius = 24;
    _uploadProgressLabel.layer.borderWidth = 1;
    _uploadProgressLabel.font = [UIFont systemFontOfSize:12];
    _uploadProgressLabel.textAlignment = NSTextAlignmentCenter;
    _uploadProgressLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    [_previewImageView addSubview:_uploadProgressLabel];
}

- (void)downloadAction {
    
    if (![[UdeskSDKUtil internetStatus] isEqualToString:@"wifi"]) {
        
        [UdeskSDKAlert showWithTitle:getUDLocalizedString(@"udesk_wwan_tips") message:getUDLocalizedString(@"udesk_video_send_tips") handler:^{
            [self readyDownloadVideo];
        }];
        return;
    }
    
    [self readyDownloadVideo];
}

- (void)playAction {
    
    UdeskVideoMessage *videoMessage = (UdeskVideoMessage *)self.baseMessage;
    if (!videoMessage || ![videoMessage isKindOfClass:[UdeskVideoMessage class]]) return;
    
    [self openVideoWithMessageId:videoMessage.message.messageId contentURL:videoMessage.message.content];
}

- (void)readyDownloadVideo {

    UdeskVideoMessage *videoMessage = (UdeskVideoMessage *)self.baseMessage;
    if (!videoMessage || ![videoMessage isKindOfClass:[UdeskVideoMessage class]]) return;
    
    self.uploadProgressLabel.hidden = NO;
    self.downloadButton.hidden = YES;
    
    @udWeakify(self);
    [[Udesk_WHC_HttpManager shared] download:videoMessage.message.content
                                    savePath:[[UdeskCacheUtil sharedManager] filePath]
                                saveFileName:videoMessage.message.messageId
                                    response:^(Udesk_WHC_BaseOperation *operation, NSError *error, BOOL isOK) {
                                  
                                  @try {
                                      
                                      @udStrongify(self);
                                      if (isOK) {
                                          Udesk_WHC_DownloadOperation * downloadOperation = (Udesk_WHC_DownloadOperation*)operation;
                                          Udesk_WHC_DownloadObject * downloadObject = [Udesk_WHC_DownloadObject readDiskCache:operation.strUrl];
                                          if (downloadObject == nil) {
                                              downloadObject = [Udesk_WHC_DownloadObject new];
                                          }
                                          downloadObject.fileName = downloadOperation.saveFileName;
                                          downloadObject.downloadPath = downloadOperation.strUrl;
                                          downloadObject.downloadState = Udesk_WHCDownloading;
                                          downloadObject.currentDownloadLenght = downloadOperation.recvDataLenght;
                                          downloadObject.totalLenght = downloadOperation.fileTotalLenght;
                                          
                                          [downloadObject writeDiskCache];
                                      }else {
                                          [self errorHandle:(Udesk_WHC_DownloadOperation *)operation error:error];
                                      }
                                  } @catch (NSException *exception) {
                                      NSLog(@"%@",exception);
                                  } @finally {
                                  }
                              } process:^(Udesk_WHC_BaseOperation *operation, uint64_t recvLength, uint64_t totalLength, NSString *speed) {
                                  
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      @udStrongify(self);
                                      self.uploadProgressLabel.hidden = NO;
                                      self.playButton.hidden = YES;
                                      double progress = (double)recvLength / ((double)totalLength == 0 ? 1 : totalLength);
                                      self.uploadProgressLabel.text = [NSString stringWithFormat:@"%.f%%",progress*100];
                                  });
                                  
                              } didFinished:^(Udesk_WHC_BaseOperation *operation, NSData *data, NSError *error, BOOL isSuccess) {
                                  
                                  @udStrongify(self);
                                  if (isSuccess) {
                                      NSLog(@"UdeskSDK：视频下载成功");
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          self.uploadProgressLabel.hidden = YES;
                                          self.playButton.hidden = NO;
                                      });
                                      [self saveDownloadStateOperation:(Udesk_WHC_DownloadOperation *)operation];
                                  }
                                  else {
                                      [self errorHandle:(Udesk_WHC_DownloadOperation *)operation error:error];
                                  }
                              }];
}

- (void)errorHandle:(Udesk_WHC_DownloadOperation *)operation error:(NSError *)error {
    NSString * errInfo = error.userInfo[NSLocalizedDescriptionKey];
    if (!errInfo || errInfo == (id)kCFNull) return ;
    if (![errInfo isKindOfClass:[NSString class]]) return ;
    
    if ([errInfo containsString:@"404"]) {
        [UdeskToast showToast:getUDLocalizedString(@"udesk_file_not_exist") duration:1.0f window:[UIApplication sharedApplication].keyWindow];
    }
    else if([errInfo isEqualToString:@"下载失败"]){
        [UdeskToast showToast:getUDLocalizedString(@"udesk_download_failed") duration:1.0f window:[UIApplication sharedApplication].keyWindow];
    }
    else {
        [UdeskToast showToast:errInfo duration:1.0f window:[UIApplication sharedApplication].keyWindow];
    }
    
    _uploadProgressLabel.hidden = YES;
    _downloadButton.hidden = NO;
    _playButton.hidden = YES;
    
    [[UdeskCacheUtil sharedManager] udRemoveObjectForKey:self.baseMessage.messageId];
    [self removeDownloadStateOperation:operation];
}

- (void)saveDownloadStateOperation:(Udesk_WHC_DownloadOperation *)operation {
    Udesk_WHC_DownloadObject * downloadObject = [Udesk_WHC_DownloadObject readDiskCache:operation.saveFileName];
    if (downloadObject != nil) {
        downloadObject.currentDownloadLenght = operation.recvDataLenght;
        downloadObject.totalLenght = operation.fileTotalLenght;
        [downloadObject writeDiskCache];
    }
}

- (void)removeDownloadStateOperation:(Udesk_WHC_DownloadOperation *)operation {
    Udesk_WHC_DownloadObject * downloadObject = [Udesk_WHC_DownloadObject readDiskCache:operation.saveFileName];
    if (downloadObject != nil) {
        [downloadObject removeFromDisk];
    }
}

- (void)openVideoWithMessageId:(NSString *)messageId contentURL:(NSString *)contentURL {
    
    NSURL *url = [NSURL URLWithString:@"https://www.udesk.cn"];
    if ([[UdeskCacheUtil sharedManager] containsObjectForKey:messageId]) {
        NSString *path = [[UdeskCacheUtil sharedManager] filePathForkey:messageId];
        url = [NSURL fileURLWithPath:path];
    }
    else {
        url = [NSURL URLWithString:[contentURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
     
    AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
    playerVC.player = [AVPlayer playerWithURL:url];
    playerVC.showsPlaybackControls = YES;
    playerVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    if (@available(iOS 11.0, *)) {
        playerVC.entersFullScreenWhenPlaybackBegins = YES;
    }
    //开启这个播放的时候支持（全屏）横竖屏哦
    if (@available(iOS 11.0, *)) {
        playerVC.exitsFullScreenWhenPlaybackEnds = YES;
    }
    
    [[UdeskSDKUtil currentViewController] presentViewController:playerVC animated:YES completion:^{
        if (playerVC.readyForDisplay) {
            [playerVC.player play];
        }
    }];
}

- (void)dealloc
{
    [[Udesk_WHC_HttpManager shared] cancelAllDownloadTaskAndDelFile:YES];
}

- (void)updateCellWithMessage:(UdeskBaseMessage *)baseMessage {

    [super updateCellWithMessage:baseMessage];
    
    UdeskVideoMessage *videoMessage = (UdeskVideoMessage *)baseMessage;
    if (!videoMessage || ![videoMessage isKindOfClass:[UdeskVideoMessage class]]) return;
    
    self.bubbleImageView.hidden = YES;
    
    _previewImageView.image = videoMessage.previewImage;
    _previewImageView.frame = videoMessage.previewFrame;
    
    _playButton.frame = videoMessage.playFrame;
    _downloadButton.frame = videoMessage.downloadFrame;
    _videoDuration.frame = videoMessage.videoDurationFrame;
    _uploadProgressLabel.frame = videoMessage.uploadProgressFrame;
    
    _videoDuration.text = videoMessage.videoDuration;
    
    if (videoMessage.message.messageFrom == UDMessageTypeSending) {
        _downloadButton.hidden = YES;
        if (videoMessage.message.messageStatus == UDMessageSendStatusSending) {
            _uploadProgressLabel.hidden = NO;
            _playButton.hidden = YES;
        }
        else {
            _uploadProgressLabel.hidden = YES;
            _playButton.hidden = NO;
        }
        
        //检查是否有缓存
        if (![[UdeskCacheUtil sharedManager] containsObjectForKey:videoMessage.message.messageId]) {
            _downloadButton.hidden = NO;
            _playButton.hidden = YES;
        }
    }
    else {
        
        _uploadProgressLabel.hidden = YES;
        if ([[UdeskCacheUtil sharedManager] containsObjectForKey:videoMessage.message.messageId]) {
            _downloadButton.hidden = YES;
            _playButton.hidden = NO;
        }
        else {
            _downloadButton.hidden = NO;
            _playButton.hidden = YES;
        }
    }
}

@end
