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
#import "UdeskTools.h"
#import "UIImage+UdeskSDK.h"

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
}

//点击图片
- (void)tapContentImageViewAction:(UIGestureRecognizer *)tap {
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(didSelectImageCell)]) {
            [self.delegate didSelectImageCell];
        }
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
    if ([UdeskTools isBlankString:imageUrl]) {
        imageUrl = imageMessage.message.messageId;
    }
    
    if ([[Udesk_YYWebImageManager sharedManager].cache containsImageForKey:imageMessage.message.messageId]) {
        self.chatImageView.image = [[Udesk_YYWebImageManager sharedManager].cache getImageForKey:imageMessage.message.messageId];
    }
    else {
        [self.chatImageView yy_setImageWithURL:[NSURL URLWithString:imageUrl] placeholder:imageMessage.message.image];
    }
    
    self.chatImageView.frame = imageMessage.imageFrame;
    
    //设置图片全气泡展示
    UIImageView *ImageView = [[UIImageView alloc] init];
    [ImageView setFrame:self.chatImageView.frame];
    [ImageView setImage:self.bubbleImageView.image];
    
    CALayer *layer              = ImageView.layer;
    layer.frame                 = (CGRect){{0,0},ImageView.layer.frame.size};
    self.chatImageView.layer.mask = layer;
    [self.chatImageView setNeedsDisplay];
}

@end
