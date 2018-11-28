//
//  UdeskStructCell.m
//  UdeskSDK
//
//  Created by xuchen on 2017/1/17.
//  Copyright © 2017年 xuchen. All rights reserved.
//

#import "UdeskStructCell.h"
#import "UdeskSDKMacro.h"
#import "UdeskStructMessage.h"

@implementation UdeskStructCell{
    
    UdeskStructView *structContentView;
    UILabel *dateLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)updateCellWithMessage:(id)message {

    [super updateCellWithMessage:message];
    
    @try {
        
        if (![message isKindOfClass:[UdeskStructMessage class]]) {
            return;
        }
        
        UdeskStructMessage *structMsg = (UdeskStructMessage *)message;
        
        //结构化消息
        NSMutableArray *array = [NSMutableArray array];
        @udWeakify(self);
        for (UdeskStructButton *button in structMsg.buttons) {
            UdeskStructAction *action = [UdeskStructAction actionWithTitle:button.text handler:^(UdeskStructAction * _Nonnull action) {
                
                [__weak_self__ tapButtonAction:button];
            }];
            [array addObject:action];
        }
        
        UIView *view = (UIView *)[self.contentView.subviews lastObject];
        if ([view isKindOfClass:[UdeskStructView class]]) {
            [view removeFromSuperview];
        }

        UdeskStructView *structView = structMsg.structContentView;
        structView.mutableActions = array;
        [self.contentView addSubview:structView];
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)tapButtonAction:(UdeskStructButton *)button {

    @try {
        
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
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(didTapStructMessageButtonWithValue:callbackName:)]) {
                [self.delegate didTapStructMessageButtonWithValue:button.value callbackName:button.callback_name];
            }
            return;
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

@end
