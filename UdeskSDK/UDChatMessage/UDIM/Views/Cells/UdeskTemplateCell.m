//
//  UdeskTemplateCell.m
//  UdeskSDK
//
//  Created by xuchen on 2019/6/5.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskTemplateCell.h"
#import "UdeskTemplateMessage.h"
#import "UdeskSDKUtil.h"
#import "UdeskSDKShow.h"
#import "UdeskManager.h"

@interface UdeskTemplateCell()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *lineOneView;

@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIView *lineTwoView;

@property (nonatomic, strong) UIView *buttonsView;

@end

@implementation UdeskTemplateCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.font = [UIFont systemFontOfSize:15];
    _titleLabel.numberOfLines = 0;
    _titleLabel.backgroundColor = [UIColor clearColor];
    [self.bubbleImageView addSubview:_titleLabel];
    
    _lineOneView = [[UIView alloc] initWithFrame:CGRectZero];
    _lineOneView.backgroundColor = [UIColor colorWithRed:0.953f  green:0.961f  blue:0.965f alpha:1];
    [self.bubbleImageView addSubview:_lineOneView];
    
    _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _contentLabel.font = [UIFont systemFontOfSize:15];
    _contentLabel.numberOfLines = 0;
    _contentLabel.backgroundColor = [UIColor clearColor];
    [self.bubbleImageView addSubview:_contentLabel];
    
    _lineTwoView = [[UIView alloc] initWithFrame:CGRectZero];
    _lineTwoView.backgroundColor = [UIColor colorWithRed:0.953f  green:0.961f  blue:0.965f alpha:1];
    [self.bubbleImageView addSubview:_lineTwoView];
    
    _buttonsView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.bubbleImageView addSubview:_buttonsView];
}

- (void)updateCellWithMessage:(UdeskBaseMessage *)baseMessage {
    [super updateCellWithMessage:baseMessage];
    
    UdeskTemplateMessage *templateMessage = (UdeskTemplateMessage *)baseMessage;
    if (!templateMessage || ![templateMessage isKindOfClass:[UdeskTemplateMessage class]]) return;
    
    self.titleLabel.attributedText = templateMessage.titleAttributedString;
    self.titleLabel.frame = templateMessage.titleFrame;
    self.lineOneView.frame = templateMessage.lineOneFrame;
    
    self.contentLabel.attributedText = templateMessage.contentAttributedString;
    self.contentLabel.frame = templateMessage.contentFrame;
    self.lineTwoView.frame = templateMessage.lineTwoFrame;
    
    self.buttonsView.frame = templateMessage.buttonsFrame;
    
    if (templateMessage.buttonsArray.count) {
        [[self.buttonsView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    for (int i = 0; i<templateMessage.buttonsArray.count; i++) {
        
        UdeskTemplateButtonMessage *btnMsg = templateMessage.buttonsArray[i];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:btnMsg.name forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:48/255.0 green:122/255.0 blue:232/255.0 alpha:1.0] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        button.frame = btnMsg.frame;
        button.tag = 1899+i;
        [button addTarget:self action:@selector(tapTemplateButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonsView addSubview:button];
        
        UIView *lineView = [[UIView alloc] initWithFrame:btnMsg.lineFrame];
        lineView.backgroundColor = [UIColor colorWithRed:0.953f  green:0.961f  blue:0.965f alpha:1];
        [self.buttonsView addSubview:lineView];
    }
}

- (void)tapTemplateButtonAction:(UIButton *)button {
    
    UdeskTemplateMessage *templateMessage = (UdeskTemplateMessage *)self.baseMessage;
    if (!templateMessage || ![templateMessage isKindOfClass:[UdeskTemplateMessage class]]) return;
    
    NSInteger index = button.tag - 1899;
    if (index < templateMessage.buttonsArray.count) {
        
        UdeskTemplateButtonMessage *btnMsg = templateMessage.buttonsArray[index];
        [UdeskSDKShow pushWebViewOnViewController:[UdeskSDKUtil currentViewController] URL:[UdeskManager udeskURLSignature:btnMsg.url]];
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
