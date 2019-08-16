//
//  UdeskImageCell.m
//  UdeskSDK
//
//  Created by xuchen on 2017/5/17.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskImageCell.h"
#import "Udesk_YYWebImage.h"
#import "UdeskPhotoManeger.h"
#import "UdeskImageMessage.h"
#import "UdeskSDKUtil.h"
#import "UIImage+UdeskSDK.h"

@interface UdeskImageCell ()

@property (nonatomic, strong) UIImageView *chatImageView;
@property (nonatomic, strong) UIView *shadowView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

@end

@implementation UdeskImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self initChatImageView];
    }
    return self;
}

- (void)initChatImageView {

    _chatImageView = [Udesk_YYAnimatedImageView new];
    _chatImageView.userInteractionEnabled = YES;
    _chatImageView.layer.cornerRadius = 5;
    _chatImageView.layer.masksToBounds  = YES;
    _chatImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.bubbleImageView addSubview:_chatImageView];
    //添加图片点击手势
    UITapGestureRecognizer *tapContentImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapContentImageViewAction:)];
    [_chatImageView addGestureRecognizer:tapContentImage];
    
    _shadowView = [UIView new];
    _shadowView.backgroundColor = [UIColor colorWithWhite:0.6 alpha:0.7];
    _shadowView.userInteractionEnabled = YES;
    _shadowView.clipsToBounds = YES;
    [_chatImageView addSubview:_shadowView];
    
    _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [_chatImageView addSubview:_loadingView];
    
    _progressLabel = [UILabel new];
    _progressLabel.font = [UIFont systemFontOfSize:12];
    _progressLabel.textAlignment = NSTextAlignmentCenter;
    _progressLabel.textColor = [UIColor whiteColor];
    [_chatImageView addSubview:_progressLabel];
}

//点击图片
- (void)tapContentImageViewAction:(UIGestureRecognizer *)tap {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapChatImageView)]) {
        [self.delegate didTapChatImageView];
    }
    
    UdeskPhotoManeger *photoManeger = [UdeskPhotoManeger maneger];
    NSString *url = self.baseMessage.message.content?self.baseMessage.message.content:self.baseMessage.message.messageId;
    
    [photoManeger showLocalPhoto:self.chatImageView withMessageURL:url];
}

- (void)updateCellWithMessage:(UdeskBaseMessage *)baseMessage {

    [super updateCellWithMessage:baseMessage];
    
    UdeskImageMessage *imageMessage = (UdeskImageMessage *)baseMessage;
    if (!imageMessage || ![imageMessage isKindOfClass:[UdeskImageMessage class]]) return;
    
    NSString *imageUrl = imageMessage.message.content;
    if ([UdeskSDKUtil isBlankString:imageUrl]) {
        imageUrl = imageMessage.message.messageId;
    }
    
    if (imageMessage.message.image) {
        self.chatImageView.image = imageMessage.message.image;
    }
    else if ([[Udesk_YYWebImageManager sharedManager].cache containsImageForKey:imageUrl]) {
        self.chatImageView.image = [[Udesk_YYWebImageManager sharedManager].cache getImageForKey:imageUrl];
    }
    else {
        NSRange range = [UdeskSDKUtil linkRegexsMatch:imageUrl];
        if (range.location != NSNotFound) {
            [self.chatImageView udesk_yy_setImageWithURL:[NSURL URLWithString:[imageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholder:imageMessage.message.image];
        }
    }
    
    self.chatImageView.frame = imageMessage.imageFrame;
    self.shadowView.frame = imageMessage.shadowFrame;
    self.loadingView.frame = imageMessage.imageLoadingFrame;
    self.progressLabel.frame = imageMessage.imageProgressFrame;
    
    //设置图片全气泡展示
    UIImageView *ImageView = [[UIImageView alloc] init];
    [ImageView setFrame:self.chatImageView.frame];
    [ImageView setImage:self.bubbleImageView.image];

    CALayer *layer              = ImageView.layer;
    layer.frame                 = (CGRect){{0,0},ImageView.layer.frame.size};
    self.chatImageView.layer.mask = layer;
    [self.chatImageView setNeedsDisplay];
    
    if (imageMessage.message.messageFrom == UDMessageTypeSending) {
        
        if (imageMessage.message.messageStatus == UDMessageSendStatusSending) {
            [self imageUploading];
        }
        else {
            [self uploadImageSuccess];
        }
    }
    else {
        
        [self uploadImageSuccess];
    }
}

- (void)uploadImageSuccess {
    
    self.shadowView.hidden = YES;
    self.loadingView.hidden = YES;
    self.progressLabel.hidden = YES;
    [self.loadingView stopAnimating];
}

- (void)imageUploading {
    
    self.shadowView.hidden = NO;
    self.loadingView.hidden = NO;
    self.progressLabel.hidden = NO;
    [self.loadingView startAnimating];
}

@end
