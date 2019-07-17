//
//  UdeskLinkCell.m
//  UdeskSDK
//
//  Created by xuchen on 2019/1/21.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskLinkCell.h"
#import "UdeskLinkMessage.h"
#import "UdeskSDKUtil.h"
#import "UdeskSDKShow.h"

@interface UdeskLinkCell()

@property (nonatomic, strong) UILabel *linkLabel;

@end

@implementation UdeskLinkCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    _linkLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _linkLabel.numberOfLines = 0;
    [self.bubbleImageView addSubview:_linkLabel];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLinkTextViewAction:)];
    [self.bubbleImageView addGestureRecognizer:recognizer];
}

- (void)tapLinkTextViewAction:(UITapGestureRecognizer *)gesture {
    
    if (!self.baseMessage.message.linkAnswerUrl || self.baseMessage.message.linkAnswerUrl == (id)kCFNull) return ;
    
    NSRange range = [UdeskSDKUtil linkRegexsMatch:self.baseMessage.message.linkAnswerUrl];
    if (range.location != NSNotFound) {
        
        NSURL *url = [NSURL URLWithString: self.baseMessage.message.linkAnswerUrl];
        [self udOpenURL:url];
    }
}

- (void)updateCellWithMessage:(UdeskBaseMessage *)baseMessage {
    [super updateCellWithMessage:baseMessage];
    
    UdeskLinkMessage *linkMessage = (UdeskLinkMessage *)baseMessage;
    if (!linkMessage || ![linkMessage isKindOfClass:[UdeskLinkMessage class]]) return;
    
    self.linkLabel.frame = linkMessage.textFrame;
    self.linkLabel.attributedText = linkMessage.attributedString;
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
