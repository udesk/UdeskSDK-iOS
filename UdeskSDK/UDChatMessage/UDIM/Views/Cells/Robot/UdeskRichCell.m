//
//  UdeskRichCell.m
//  UdeskSDK
//
//  Created by xuchen on 2019/1/16.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskRichCell.h"
#import "UdeskRichMessage.h"

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
    return [self udRichTextView:textView shouldInteractWithURL:URL inRange:characterRange];
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
