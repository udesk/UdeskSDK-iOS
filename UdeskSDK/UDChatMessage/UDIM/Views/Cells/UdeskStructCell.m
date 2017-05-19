//
//  UdeskStructCell.m
//  UdeskSDK
//
//  Created by xuchen on 2017/1/17.
//  Copyright © 2017年 xuchen. All rights reserved.
//

#import "UdeskStructCell.h"
#import "UdeskStructView.h"
#import "UdeskSDKConfig.h"
#import "UdeskDateFormatter.h"
#import "UdeskStructMessage.h"
#import "UdeskViewExt.h"

@implementation UdeskStructCell{
    
    UdeskStructView *structContentView;
    UILabel *dateLabel;
    UIImageView *avatarImageView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //时间
        dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        dateLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        dateLabel.textColor = [UdeskSDKConfig sharedConfig].sdkStyle.chatTimeColor;
        dateLabel.font = [UdeskSDKConfig sharedConfig].sdkStyle.messageTimeFont;
        dateLabel.textAlignment = NSTextAlignmentCenter;
        dateLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:dateLabel];
        
        //头像
        avatarImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        UDViewRadius(avatarImageView, 20);
        [self.contentView addSubview:avatarImageView];
    }
    return self;
}

- (void)updateCellWithMessage:(id)message {

    if (![message isKindOfClass:[UdeskStructMessage class]]) {
        return;
    }
    
    UdeskStructMessage *structMsg = (UdeskStructMessage *)message;
    dateLabel.frame = structMsg.dateFrame;
    dateLabel.text = [[UdeskDateFormatter sharedFormatter] ud_styleDateForDate:structMsg.date];
    
    avatarImageView.frame = structMsg.avatarFrame;
    avatarImageView.image = structMsg.avatarImage;
    
    //结构化消息
    NSMutableArray *array = [NSMutableArray array];
    @udWeakify(self);
    for (UdeskStructButton *button in structMsg.buttons) {
        UdeskStructAction *action = [UdeskStructAction actionWithTitle:button.text handler:^(UdeskStructAction * _Nonnull action) {
            
            [__weak_self__ tapButtonAction:button];
        }];
        [array addObject:action];
    }
    
    structContentView = [[UdeskStructView alloc] initWithImage:structMsg.structImage title:structMsg.title message:structMsg.udDescription buttons:array origin:CGPointMake(avatarImageView.ud_right+kUDStructPadding, dateLabel.ud_bottom+kUDStructPadding)];
    
    structContentView.layer.borderWidth = 1;
    structContentView.layer.borderColor = [UIColor colorWithWhite:0.90 alpha:1].CGColor;
    
    [self.contentView addSubview:structContentView];
}

- (void)tapButtonAction:(UdeskStructButton *)button {

    //点击链接
    if ([button.type isEqualToString:@"link"]) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:button.value]];
        return;
    }
    
    //点击电话
    if ([button.type isEqualToString:@"phone"]) {
        
        NSMutableString *str = [[NSMutableString alloc] initWithFormat:@"telprompt://%@",button.value];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        return;
    }
    
    //点击自定义回调
    if ([button.type isEqualToString:@"sdk_callback"]) {
     
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectStructButton)]) {
            [self.delegate didSelectStructButton];
        }
        return;
    }
}

@end
