//
//  UdeskRichCell.m
//  UdeskSDK
//
//  Created by xuchen on 2019/1/16.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskRichCell.h"
#import "UdeskRichMessage.h"
#import "UdeskBundleUtils.h"
#import "UdeskPhotoManeger.h"
#import "UdeskAlertController.h"
#import "UdeskMessage+UdeskSDK.h"

@interface UdeskRichCell()<UITextViewDelegate>

@property (nonatomic, strong) UITextView *richTextView;

@end

@implementation UdeskRichCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    _richTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    _richTextView.delegate = self;
    _richTextView.editable = NO;
    _richTextView.dataDetectorTypes = UIDataDetectorTypeAll;
    _richTextView.showsVerticalScrollIndicator = NO;
    _richTextView.showsHorizontalScrollIndicator = NO;
    _richTextView.textContainer.lineFragmentPadding = 0;
    _richTextView.textContainerInset = UIEdgeInsetsMake(5, 0, 0, 0);
    _richTextView.backgroundColor = [UIColor clearColor];
    [self.bubbleImageView addSubview:_richTextView];
    
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRichTextViewAction:)];
    [recognizer setMinimumPressDuration:0.4f];
    [_richTextView addGestureRecognizer:recognizer];
}

//长按复制
- (void)longPressRichTextViewAction:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    
    @try {
        
        if (longPressGestureRecognizer.state != UIGestureRecognizerStateBegan || ![self becomeFirstResponder])
            return;
        
        NSMutableArray *menuItems = [[NSMutableArray alloc] init];
        
        if (self.baseMessage.message.messageType == UDMessageContentTypeText ||
            self.baseMessage.message.messageType == UDMessageContentTypeRich) {
            
            UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:getUDLocalizedString(@"udesk_copy") action:@selector(copyed:)];
            if (item) {
                [menuItems addObject:item];
            }
            
            UIMenuController *menu = [UIMenuController sharedMenuController];
            [menu setMenuItems:menuItems];
            
            CGRect targetRect = [self convertRect:self.baseMessage.bubbleFrame
                                         fromView:self];
            
            [menu setTargetRect:CGRectInset(targetRect, 0.0f, 4.0f) inView:self];
            [menu setMenuVisible:YES animated:YES];
        }
        
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
    
    [[UIPasteboard generalPasteboard] setString:self.richTextView.text];
    [self resignFirstResponder];
}

- (void)updateCellWithMessage:(UdeskBaseMessage *)baseMessage {
    [super updateCellWithMessage:baseMessage];
    
    UdeskRichMessage *richMessage = (UdeskRichMessage *)baseMessage;
    if (!richMessage || ![richMessage isKindOfClass:[UdeskRichMessage class]]) return;
    
    if ([UdeskSDKUtil isBlankString:richMessage.message.content]) {
        self.richTextView.text = @"";
    }
    else {
        self.richTextView.attributedText = richMessage.attributedString;
    }
    
    //设置frame
    self.richTextView.frame = richMessage.richTextFrame;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    
    if ([URL.absoluteString hasPrefix:@"sms:"] || [URL.absoluteString hasPrefix:@"tel:"]) {
        
        NSString *phoneNumber = [URL.absoluteString componentsSeparatedByString:@":"].lastObject;
        [self callPhoneNumber:phoneNumber];
        return NO;
    }
    else if ([URL.absoluteString hasPrefix:@"img:"]) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTapChatImageView)]) {
            [self.delegate didTapChatImageView];
        }
        
        NSString *url = [URL.absoluteString componentsSeparatedByString:@"img:"].lastObject;
        url = [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        UdeskPhotoManeger *photoManeger = [UdeskPhotoManeger maneger];
        [photoManeger showLocalPhoto:(UIImageView *)self.bubbleImageView withMessageURL:url];
        return NO;
    }
    else if ([URL.absoluteString hasPrefix:@"data-type:"]) {
        
        NSString *content = [textView.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];;
        [self flowMessageWithText:content flowContent:URL.absoluteString];
    }
    else {
        
        if (textView.text.length >= (characterRange.location+characterRange.length)) {
            NSURL *url = [NSURL URLWithString:[textView.text substringWithRange:characterRange]];
            if (!url) {
                url = URL;
            }
            
            [self openURL:url];
        }
        else {
            [self openURL:URL];
        }
        
        return NO;
    }
    
    return YES;
}

- (void)callPhoneNumber:(NSString *)phoneNumber {
    
    UdeskAlertController *alert = [UdeskAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@\n%@",phoneNumber,getUDLocalizedString(@"udesk_phone_number_tip")] message:nil preferredStyle:UdeskAlertControllerStyleActionSheet];
    [alert addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_cancel") style:UdeskAlertActionStyleCancel handler:nil]];
    [alert addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_call") style:UdeskAlertActionStyleDefault handler:^(UdeskAlertAction *action) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", phoneNumber]]];
    }]];
    
    [alert addAction:[UdeskAlertAction actionWithTitle:getUDLocalizedString(@"udesk_copy") style:UdeskAlertActionStyleDefault handler:^(UdeskAlertAction *action) {
        
        [UIPasteboard generalPasteboard].string = phoneNumber;
    }]];
    
    [[UdeskSDKUtil currentViewController] presentViewController:alert animated:YES completion:nil];
}

- (void)flowMessageWithText:(NSString *)text flowContent:(NSString *)flowContent {
    if (!flowContent || flowContent == (id)kCFNull) return ;
    
    @try {
     
        NSArray *array = [flowContent componentsSeparatedByString:@";"];
        NSString *dataType = [array.firstObject componentsSeparatedByString:@":"].lastObject;
        NSString *dataId = [array.lastObject componentsSeparatedByString:@":"].lastObject;
        
        UdeskMessage *flowMessage = [[UdeskMessage alloc] initWithText:text];
        flowMessage.logId = self.baseMessage.message.logId;
        flowMessage.sendType = UDMessageSendTypeHit;
        
        if ([dataType isEqualToString:@"1"]) {
            flowMessage.robotType = @"1";
            flowMessage.robotQuestionId = dataId;
            flowMessage.robotQueryType = @"8";
        }
        else if ([dataType isEqualToString:@"2"]) {
            flowMessage.robotType = @"2";
            flowMessage.flowId = dataId;
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSendRobotMessage:)]) {
            [self.delegate didSendRobotMessage:flowMessage];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)openURL:(NSURL *)URL {
    
    //用户设置了点击链接回调
    if ([UdeskSDKConfig customConfig].actionConfig.linkClickBlock) {
        [UdeskSDKConfig customConfig].actionConfig.linkClickBlock([UdeskSDKUtil currentViewController],URL);
        return ;
    }
    
    if ([URL.absoluteString rangeOfString:@"://"].location == NSNotFound) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", URL.absoluteString]]];
    } else {
        [[UIApplication sharedApplication] openURL:URL];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
