//
//  UdeskLocationCell.m
//  UdeskSDK
//
//  Created by xuchen on 2017/8/16.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskLocationCell.h"
#import "UDTTTAttributedLabel.h"
#import "UdeskLocationMessage.h"
#import "UIColor+UdeskSDK.h"
#import "Udesk_YYWebImageManager.h"

@implementation UdeskLocationCell {

    UIView *_locationView;
    UDTTTAttributedLabel *_textContentLabel;
    UIImageView *_locationSnapshot;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setupLocationView];
        [self setupLocationNameLabel];
        [self setupLocationSnapshotImageView];
    }
    return self;
}

- (void)setupLocationView {

    _locationView = [[UIView alloc] initWithFrame:CGRectZero];
    _locationView.backgroundColor = [UIColor colorWithHexString:@"#F0F1F5"];
    [self.contentView addSubview:_locationView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLocationView)];
    [_locationView addGestureRecognizer:tap];
}

- (void)tapLocationView {

    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectLocationCell:)]) {
        [self.delegate didSelectLocationCell:self.baseMessage.message];
    }
}

- (void)setupLocationNameLabel {

    _textContentLabel = [[UDTTTAttributedLabel alloc] initWithFrame:CGRectZero];
    _textContentLabel.numberOfLines = 1;
    _textContentLabel.textAlignment = NSTextAlignmentLeft;
    _textContentLabel.userInteractionEnabled = true;
    _textContentLabel.font = [UIFont systemFontOfSize:13];
    _textContentLabel.backgroundColor = [UIColor clearColor];
    [_locationView addSubview:_textContentLabel];
}

- (void)setupLocationSnapshotImageView {
    
    _locationSnapshot = [[UIImageView alloc] initWithFrame:CGRectZero];
    _locationSnapshot.userInteractionEnabled = YES;
    [_locationView addSubview:_locationSnapshot];
}

- (void)updateCellWithMessage:(UdeskBaseMessage *)baseMessage {

    [super updateCellWithMessage:baseMessage];
    
    @try {
     
        UdeskLocationMessage *locationMessage = (UdeskLocationMessage *)baseMessage;
        if (!locationMessage || ![locationMessage isKindOfClass:[UdeskLocationMessage class]]) return;
        
        _locationView.frame = locationMessage.locatioFrame;
        
        _textContentLabel.text = [locationMessage.message.content componentsSeparatedByString:@";"].lastObject;
        _textContentLabel.frame = locationMessage.locationNameFrame;
        
        if ([[Udesk_YYWebImageManager sharedManager].cache containsImageForKey:locationMessage.message.messageId]) {
            _locationSnapshot.image = [[Udesk_YYWebImageManager sharedManager].cache getImageForKey:locationMessage.message.messageId];
        }
        else {
            _locationSnapshot.image = locationMessage.message.image;
        }
        _locationSnapshot.frame = locationMessage.locationSnapshotFrame;
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
