//
//  UdeskQueueCell.m
//  UdeskSDK
//
//  Created by xuchen on 2018/11/12.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskQueueCell.h"
#import "UdeskQueueMessage.h"
#import "UdeskSDKUtil.h"

@interface UdeskQueueCell()

@property (nonatomic, strong) UdeskQueueMessage *queueMessage;
@property (nonatomic, strong) UIView *queueBackGroundView;
@property (nonatomic, strong) UILabel *queueTitleLabel;
@property (nonatomic, strong) UILabel *queueContentLabel;
@property (nonatomic, strong) UIButton *queueLeaveMsgButton;

@end

@implementation UdeskQueueCell

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
    
    @try {
        
        UdeskQueueMessage *queueMessage = (UdeskQueueMessage *)message;
        _queueMessage = queueMessage;
        
        if (![UdeskSDKUtil isBlankString:queueMessage.titleText]) {
            self.queueTitleLabel.text = queueMessage.titleText;
        }
        
        if (![UdeskSDKUtil isBlankString:queueMessage.contentText]) {
            self.queueContentLabel.text = queueMessage.contentText;
        }
        
        if (queueMessage.showLeaveMsgBtn) {
            [self.queueLeaveMsgButton setTitle:queueMessage.buttonText forState:UIControlStateNormal];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.queueBackGroundView.frame = self.queueMessage.backGroundFrame;
    self.queueTitleLabel.frame = self.queueMessage.titleFrame;
    self.queueContentLabel.frame = self.queueMessage.contentFrame;
    self.queueLeaveMsgButton.frame = self.queueMessage.buttonFrame;
}

- (UIView *)queueBackGroundView {
    if (!_queueBackGroundView) {
        _queueBackGroundView = [[UIView alloc] init];
        _queueBackGroundView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_queueBackGroundView];
    }
    return _queueBackGroundView;
}

- (UILabel *)queueTitleLabel {
    if (!_queueTitleLabel) {
        _queueTitleLabel = [[UILabel alloc] init];
        _queueTitleLabel.font = [UIFont boldSystemFontOfSize:17];
        [self.queueBackGroundView addSubview:_queueTitleLabel];
    }
    return _queueTitleLabel;
}

- (UILabel *)queueContentLabel {
    if (!_queueContentLabel) {
        _queueContentLabel = [[UILabel alloc] init];
        _queueContentLabel.numberOfLines = 0;
        _queueContentLabel.font = [UIFont systemFontOfSize:16];
        [self.queueBackGroundView addSubview:_queueContentLabel];
    }
    return _queueContentLabel;
}

- (UIButton *)queueLeaveMsgButton {
    if (!_queueLeaveMsgButton) {
        _queueLeaveMsgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _queueLeaveMsgButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_queueLeaveMsgButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_queueLeaveMsgButton addTarget:self action:@selector(leaveMessageAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.queueBackGroundView addSubview:_queueLeaveMsgButton];
    }
    return _queueLeaveMsgButton;
}

- (void)leaveMessageAction:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapLeaveMessageButton:)]) {
        [self.delegate didTapLeaveMessageButton:self.baseMessage.message];
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
