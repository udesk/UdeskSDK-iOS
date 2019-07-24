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
#import "Udesk_YYWebImageManager.h"
#import "UdeskSDKUtil.h"

@implementation UdeskLocationCell {

    UIView *_locationView;
    UDTTTAttributedLabel *_nameLabel;
    UDTTTAttributedLabel *_thoroughfareLabel;
    UIImageView *_locationSnapshot;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setupLocationView];
        [self setupLocationLabel];
        [self setupLocationSnapshotImageView];
    }
    return self;
}

- (void)setupLocationView {

    _locationView = [[UIView alloc] initWithFrame:CGRectZero];
    _locationView.backgroundColor = [UIColor whiteColor];
    _locationView.layer.masksToBounds = YES;
    _locationView.layer.cornerRadius = 5;
    _locationView.layer.borderWidth = 0.7;
    _locationView.layer.borderColor = [UIColor colorWithRed:0.898f  green:0.898f  blue:0.898f alpha:1].CGColor;
    [self.contentView addSubview:_locationView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLocationView)];
    [_locationView addGestureRecognizer:tap];
}

- (void)tapLocationView {

    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapLocationMessage:)]) {
        [self.delegate didTapLocationMessage:self.baseMessage.message];
    }
}

- (void)setupLocationLabel {

    _nameLabel = [[UDTTTAttributedLabel alloc] initWithFrame:CGRectZero];
    _nameLabel.numberOfLines = 1;
    _nameLabel.textAlignment = NSTextAlignmentLeft;
    _nameLabel.userInteractionEnabled = true;
    _nameLabel.font = [UIFont systemFontOfSize:16];
    _nameLabel.textColor = [UIColor colorWithRed:0.165f  green:0.165f  blue:0.165f alpha:1];
    _nameLabel.backgroundColor = [UIColor clearColor];
    [_locationView addSubview:_nameLabel];
    
    _thoroughfareLabel = [[UDTTTAttributedLabel alloc] initWithFrame:CGRectZero];
    _thoroughfareLabel.numberOfLines = 1;
    _thoroughfareLabel.textAlignment = NSTextAlignmentLeft;
    _thoroughfareLabel.userInteractionEnabled = true;
    _thoroughfareLabel.font = [UIFont systemFontOfSize:12];
    _thoroughfareLabel.backgroundColor = [UIColor clearColor];
    _thoroughfareLabel.textColor = [UIColor colorWithRed:0.471f  green:0.471f  blue:0.471f alpha:1];
    [_locationView addSubview:_thoroughfareLabel];
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
        
        _locationView.frame = locationMessage.locationFrame;
        _nameLabel.frame = locationMessage.locationNameFrame;
        
        NSArray *array = [locationMessage.message.content componentsSeparatedByString:@";"];
        NSString *name = array.lastObject;
        if (array.count > 4) {
            NSString *thoroughfare = array[4];
            if (![UdeskSDKUtil isBlankString:thoroughfare]) {
                _thoroughfareLabel.text = [NSString stringWithFormat:@"%@",array[4]];
                _thoroughfareLabel.frame = locationMessage.locationThoroughfareFrame;
            }
            else {
                _thoroughfareLabel.text = @"";
                _thoroughfareLabel.frame = CGRectZero;
            }
            
            name = array[3];
        }
        
        if (![UdeskSDKUtil isBlankString:name]) {
            _nameLabel.text = [NSString stringWithFormat:@"%@",array[3]];
            _nameLabel.frame = locationMessage.locationNameFrame;
        }
        
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
