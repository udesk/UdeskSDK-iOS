//
//  UdeskTextCell.m
//  UdeskSDK
//
//  Created by xuchen on 2017/5/17.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskTextCell.h"
#import "UdeskConfigurationHelper.h"
#import "UdeskTools.h"
#import "UdeskTextMessage.h"
#import "UdeskUtils.h"
#import "UdeskManager.h"
#import "UdeskSDKConfig.h"

@interface UdeskTextCell()<UDTTTAttributedLabelDelegate,UIAlertViewDelegate,UIActionSheetDelegate>

@end

@implementation UdeskTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self initTextLabel];
    }
    return self;
}

- (void)initTextLabel {
    
    _textContentLabel = [[UDTTTAttributedLabel alloc] initWithFrame:CGRectZero];
    _textContentLabel.numberOfLines = 0;
    _textContentLabel.delegate = self;
    _textContentLabel.textAlignment = NSTextAlignmentLeft;
    _textContentLabel.userInteractionEnabled = true;
    _textContentLabel.backgroundColor = [UIColor clearColor];
    [self.bubbleImageView addSubview:_textContentLabel];
    
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressContentLabelAction:)];
    [recognizer setMinimumPressDuration:0.4f];
    [_textContentLabel addGestureRecognizer:recognizer];
}

//长按复制
- (void)longPressContentLabelAction:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    
    @try {
        
        if (longPressGestureRecognizer.state != UIGestureRecognizerStateBegan || ![self becomeFirstResponder])
            return;
        
        NSArray *popMenuTitles = [[UdeskConfigurationHelper appearance] popMenuTitles];
        NSMutableArray *menuItems = [[NSMutableArray alloc] init];
        for (int i = 0; i < popMenuTitles.count; i ++) {
            NSString *title = popMenuTitles[i];
            SEL action = nil;
            switch (i) {
                case 0: {
                    if (self.baseMessage.message.messageType == UDMessageContentTypeText ||
                        self.baseMessage.message.messageType == UDMessageContentTypeRich) {
                        action = @selector(copyed:);
                    }
                    break;
                }
                    
                default:
                    break;
            }
            if (action) {
                UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:title action:action];
                if (item) {
                    [menuItems addObject:item];
                }
            }
        }
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:menuItems];
        
        CGRect targetRect = [self convertRect:self.baseMessage.bubbleFrame
                                     fromView:self];
        
        [menu setTargetRect:CGRectInset(targetRect, 0.0f, 4.0f) inView:self];
        [menu setMenuVisible:YES animated:YES];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

#pragma mark - 复制
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)becomeFirstResponder {
    return [super becomeFirstResponder];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return (action == @selector(copyed:));
}

- (void)copyed:(id)sender {
    
    [[UIPasteboard generalPasteboard] setString:self.textContentLabel.text];
    [self resignFirstResponder];
}

- (void)updateCellWithMessage:(UdeskBaseMessage *)baseMessage {

    [super updateCellWithMessage:baseMessage];
    
    UdeskTextMessage *textMessage = (UdeskTextMessage *)baseMessage;
    if (!textMessage || ![textMessage isKindOfClass:[UdeskTextMessage class]]) return;
    
    if ([UdeskTools isBlankString:textMessage.message.content]) {
        self.textContentLabel.text = @"";
    }
    else {
        self.textContentLabel.text = textMessage.cellText;
    }
    
    //设置frame
    self.textContentLabel.frame = textMessage.textFrame;
    
    @try {
        
        //获取文字中的可选中的元素
        if (textMessage.numberRangeDic.count > 0) {
            NSString *longestKey = @"";
            for (NSString *key in textMessage.numberRangeDic.allKeys) {
                //找到最长的key
                if (key.length > longestKey.length) {
                    longestKey = key;
                }
            }
            if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
                [self.textContentLabel addLinkToPhoneNumber:longestKey withRange:[textMessage.numberRangeDic[longestKey] rangeValue]];
            }
        }
        
        if (textMessage.message.messageType == UDMessageContentTypeText) {
            
            //设置高亮
            for (NSString *richContent in textMessage.matchArray) {
                
                if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
                    [self.textContentLabel addLinkToURL:[NSURL URLWithString:richContent] withRange:[textMessage.richURLDictionary[richContent] rangeValue]];
                }
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)attributedLabel:(UDTTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    
    if ([url.absoluteString rangeOfString:@"://"].location == NSNotFound) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", url.absoluteString]]];
    } else {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)attributedLabel:(UDTTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"%@\n可能是一个电话号码，你可以",phoneNumber] delegate:self cancelButtonTitle:getUDLocalizedString(@"udesk_cancel") destructiveButtonTitle:nil otherButtonTitles:getUDLocalizedString(@"udesk_call"), getUDLocalizedString(@"udesk_copy"), nil];
    [sheet showInView:[UIApplication sharedApplication].keyWindow];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    NSRange range = [actionSheet.title rangeOfString:@"\n"];
    NSString *number = actionSheet.title;
    if (actionSheet.title.length>range.location) {
        number = [actionSheet.title substringToIndex:range.location];
    }
    
    switch (buttonIndex) {
        case 0:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", actionSheet.title]]];
            break;
        case 1:
            [UIPasteboard generalPasteboard].string = number;
            break;
        default:
            break;
    }
}

@end
