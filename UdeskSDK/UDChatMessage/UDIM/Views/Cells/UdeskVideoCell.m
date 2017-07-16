//
//  UdeskVideoCell.m
//  UdeskSDK
//
//  Created by xuchen on 2017/5/15.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskVideoCell.h"
#import "UdeskVideoMessage.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import "UdeskTools.h"
#import "UdeskUtils.h"
#import "UdeskManager.h"
#import "UdeskCaheHelper.h"
#import "Udesk_WHC_HttpManager.h"
#import "Udesk_WHC_DownloadObject.h"
#import "UdeskToast.h"
#import "UdeskFoundationMacro.h"
#import "UdeskAlertController.h"

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

    _videoFileView = [[UIView alloc] initWithFrame:CGRectZero];
    _videoFileView.backgroundColor = [UIColor colorWithRed:0.949f  green:0.949f  blue:0.949f alpha:1];
    _videoFileView.userInteractionEnabled = YES;
    [self.contentView addSubview:_videoFileView];
    
    _videoNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _videoNameLabel.textColor = [UIColor blackColor];
    _videoNameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _videoNameLabel.font = [UIFont systemFontOfSize:16];
    [_videoFileView addSubview:_videoNameLabel];
    
    _videoProgressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
    _videoProgressView.progress = 0.0;
    [_videoFileView addSubview:_videoProgressView];
    
    _videoSizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _videoSizeLabel.textColor = [UIColor colorWithRed:0.6f  green:0.6f  blue:0.6f alpha:1];
    _videoSizeLabel.font = [UIFont systemFontOfSize:13];
    [_videoFileView addSubview:_videoSizeLabel];
    
    _videoPercentButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_videoPercentButton setTitleColor:[UIColor colorWithRed:0.6f  green:0.6f  blue:0.6f alpha:1] forState:UIControlStateNormal];
    _videoPercentButton.titleLabel.font = [UIFont systemFontOfSize:13];
    _videoPercentButton.titleLabel.textAlignment = NSTextAlignmentRight;
    [_videoPercentButton addTarget:self action:@selector(downloadVideo:) forControlEvents:UIControlEventTouchUpInside];
    [_videoFileView addSubview:_videoPercentButton];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapVideoMessage:)];
    [_videoFileView addGestureRecognizer:tap];
}

- (void)downloadVideo:(UIButton *)button {

    if ([button.titleLabel.text isEqualToString:getUDLocalizedString(@"udesk_video_download")]) {
        
        if (![[UdeskTools internetStatus] isEqualToString:@"wifi"]) {
            
            UdeskAlertController *alert = [UdeskAlertController alertControllerWithTitle:getUDLocalizedString(@"udesk_wwan_tips") message:getUDLocalizedString(@"udesk_video_send_tips") preferredStyle:UDAlertControllerStyleAlert];
            [alert addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_cancel") style:UDAlertActionStyleDefault handler:nil]];
            [alert addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_sure") style:UDAlertActionStyleDefault handler:^(UdeskAlertAction * _Nonnull action) {
                
                [self readyDownloadVideo];
            }]];
            
            [[UdeskTools currentViewController] presentViewController:alert animated:YES completion:nil];
            
            return;
        }
        
        [self readyDownloadVideo];
    }
}

- (void)readyDownloadVideo {

    UdeskVideoMessage *videoMessage = (UdeskVideoMessage *)self.baseMessage;
    if (!videoMessage || ![videoMessage isKindOfClass:[UdeskVideoMessage class]]) return;
    
    @udWeakify(self);
    [[Udesk_WHC_HttpManager shared] download:videoMessage.message.content
                              savePath:[[UdeskCaheHelper sharedManager] filePath]
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
                                          downloadObject.downloadState = WHCDownloading;
                                          downloadObject.currentDownloadLenght = downloadOperation.recvDataLenght;
                                          downloadObject.totalLenght = downloadOperation.fileTotalLenght;
                                          
                                          CGFloat size = downloadOperation.fileTotalLenght/1024.f/1024.f;
                                          self.videoSizeLabel.hidden = NO;
                                          self.videoSizeLabel.text = [NSString stringWithFormat:@"%.1fMB",size];
                                          
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
                                      self.videoProgressView.progress = (double)recvLength / ((double)totalLength == 0 ? 1 : totalLength);
                                      [self.videoPercentButton setTitle:[NSString stringWithFormat:@"%.f%%",_videoProgressView.progress*100] forState:UIControlStateNormal];
                                  });
                                  
                              } didFinished:^(Udesk_WHC_BaseOperation *operation, NSData *data, NSError *error, BOOL isSuccess) {
                                  
                                  @udStrongify(self);
                                  if (isSuccess) {
                                      NSLog(@"下载成功视频");
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [self.videoPercentButton setTitle:getUDLocalizedString(@"udesk_has_downed") forState:UIControlStateNormal];
                                      });
                                      //  下载成功后保存装载
                                      [self saveDownloadStateOperation:(Udesk_WHC_DownloadOperation *)operation];
                                  }else {
                                      [self errorHandle:(Udesk_WHC_DownloadOperation *)operation error:error];
                                      if (error != nil &&error.code == WHCCancelDownloadError) {
                                          [self saveDownloadStateOperation:(Udesk_WHC_DownloadOperation *)operation];
                                      }
                                  }
                              }];
}

- (void)errorHandle:(Udesk_WHC_DownloadOperation *)operation error:(NSError *)error {
    NSString * errInfo = error.userInfo[NSLocalizedDescriptionKey];
    
    if ([errInfo containsString:@"404"]) {
        
        [UdeskToast showToast:@"该文件不存在,链接错误" duration:1.0f window:[UIApplication sharedApplication].keyWindow];
        Udesk_WHC_DownloadObject * downloadObject = [Udesk_WHC_DownloadObject readDiskCache:operation.strUrl];
        if (downloadObject != nil) {
            [downloadObject removeFromDisk];
        }
    }else if([errInfo isEqualToString:@"下载失败"]){
        
        [UdeskToast showToast:@"下载失败" duration:1.0f window:[UIApplication sharedApplication].keyWindow];
    }
}

- (void)saveDownloadStateOperation:(Udesk_WHC_DownloadOperation *)operation {
    Udesk_WHC_DownloadObject * downloadObject = [Udesk_WHC_DownloadObject readDiskCache:operation.strUrl];
    if (downloadObject != nil) {
        downloadObject.currentDownloadLenght = operation.recvDataLenght;
        downloadObject.totalLenght = operation.fileTotalLenght;
        [downloadObject writeDiskCache];
    }
}

- (void)tapVideoMessage:(UITapGestureRecognizer *)tap {

    UdeskVideoMessage *videoMessage = (UdeskVideoMessage *)self.baseMessage;
    if (!videoMessage || ![videoMessage isKindOfClass:[UdeskVideoMessage class]]) return;

    if (videoMessage.message.messageFrom == UDMessageTypeReceiving) {
        
        if (![self.videoPercentButton.titleLabel.text isEqualToString:getUDLocalizedString(@"udesk_has_downed")]) {
            
            [UdeskToast showToast:getUDLocalizedString(@"udesk_has_uncomplete_tip") duration:1.0f window:[UIApplication sharedApplication].keyWindow];
            return;
        }
    }
    
    [self openVideo:videoMessage.message.messageId];
}

- (void)openVideo:(NSString *)messageId {
    
    NSString *path = [[UdeskCaheHelper sharedManager] filePathForkey:messageId];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    MPMoviePlayerViewController *playerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    playerViewController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    [playerViewController.moviePlayer prepareToPlay];
    
    [[UdeskTools currentViewController] presentMoviePlayerViewControllerAnimated:playerViewController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

- (void)moviePlayerPlaybackDidFinish:(NSNotification *)notif {
    
    NSDictionary *userInfo = notif.userInfo;
    
    if ([[userInfo allKeys] containsObject:@"error"]) {
        
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0/*延迟执行时间*/ * NSEC_PER_SEC));
        
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [[[UIAlertView alloc] initWithTitle:nil
                                        message:getUDLocalizedString(@"udesk_failed_video")
                                       delegate:nil
                              cancelButtonTitle:getUDLocalizedString(@"udesk_close")
                              otherButtonTitles:nil] show];
#pragma clang diagnostic pop
        });
    }
}

- (void)dealloc
{
    NSLog(@"%@销毁了",[self class]);
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:nil];
}

- (void)updateCellWithMessage:(UdeskBaseMessage *)baseMessage {

    [super updateCellWithMessage:baseMessage];
    
    UdeskVideoMessage *videoMessage = (UdeskVideoMessage *)baseMessage;
    if (!videoMessage || ![videoMessage isKindOfClass:[UdeskVideoMessage class]]) return;
    
    self.bubbleImageView.hidden = YES;
    self.videoFileView.frame = videoMessage.videoFrame;
    self.videoNameLabel.frame = videoMessage.videoNameFrame;
    self.videoProgressView.frame = videoMessage.videoProgressFrame;
    self.videoSizeLabel.frame = videoMessage.videoSizeLaeblFrame;
    self.videoPercentButton.frame = videoMessage.videoProgressPercentFrame;
    
    //设置文件大小
    [self setVideoSizeLabel];
    
    switch (videoMessage.message.messageStatus) {
        case UDMessageSendStatusFailed:{
            
            _videoProgressView.progress = 0;
            _videoPercentButton.titleLabel.text = @"0%";
            
            _videoNameLabel.text = videoMessage.message.content;
            
            break;
        }
        case UDMessageSendStatusSuccess:{
            
            if (videoMessage.message.messageFrom == UDMessageTypeSending) {
             
                _videoProgressView.progress = 1.0f;
                [_videoPercentButton setTitle:getUDLocalizedString(@"udesk_has_send") forState:UIControlStateNormal];
                
                NSArray *array = [videoMessage.message.content componentsSeparatedByString:@"UdeskiOSVideo"];
                _videoNameLabel.text = array.lastObject;
            }
            else if (videoMessage.message.messageFrom == UDMessageTypeReceiving) {
            
                if ([[UdeskCaheHelper sharedManager] containsObjectForKey:videoMessage.message.messageId]) {
                    
                    _videoProgressView.progress = 1.0f;
                    [_videoPercentButton setTitle:getUDLocalizedString(@"udesk_has_downed") forState:UIControlStateNormal];
                    NSArray *array = [videoMessage.message.content componentsSeparatedByString:@"/"];
                    _videoNameLabel.text = array.lastObject;
                }
                else {
                
                    _videoProgressView.progress = 0.0f;
                    [_videoPercentButton setTitle:getUDLocalizedString(@"udesk_video_download") forState:UIControlStateNormal];
                    NSArray *array = [videoMessage.message.content componentsSeparatedByString:@"/"];
                    _videoNameLabel.text = array.lastObject;
                    _videoSizeLabel.hidden = YES;
                }
            }
            
            return;
            
            break;
        }
        case UDMessageSendStatusSending:{
        
            _videoNameLabel.text = videoMessage.message.content;
            
            break;
        }

        default:
            break;
    }
}

- (void)setVideoSizeLabel {

    @try {
        
        UdeskVideoMessage *videoMessage = (UdeskVideoMessage *)self.baseMessage;
        if (!videoMessage || ![videoMessage isKindOfClass:[UdeskVideoMessage class]]) return;
        
        _videoSizeLabel.hidden = NO;
        if ([[UdeskCaheHelper sharedManager] containsObjectForKey:videoMessage.message.messageId]) {
            NSString *path = [[UdeskCaheHelper sharedManager] filePathForkey:videoMessage.message.messageId];
            NSData *data = [NSData dataWithContentsOfFile:path];
            CGFloat size = data.length/1024.f/1024.f;
            _videoSizeLabel.text = [NSString stringWithFormat:@"%.1fMB",size];
        }
        else {
            _videoSizeLabel.text = @"0MB";
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

@end
