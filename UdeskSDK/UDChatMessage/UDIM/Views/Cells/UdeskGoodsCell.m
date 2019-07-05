//
//  UdeskGoodsCell.m
//  UdeskSDK
//
//  Created by xuchen on 2018/6/23.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskGoodsCell.h"
#import "UDTTTAttributedLabel.h"
#import "UdeskGoodsMessage.h"
#import "UdeskSDKUtil.h"
#import "Udesk_YYWebImage.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskSDKConfig.h"

@interface UdeskGoodsCell ()<UDTTTAttributedLabelDelegate>

@property (nonatomic, strong) UIImageView              *goodsImageView;
@property (nonatomic, strong) UDTTTAttributedLabel     *paramsLabel;
@property (nonatomic, strong) UDTTTAttributedLabel     *titleLabel;

@end

@implementation UdeskGoodsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    _goodsImageView = [[UIImageView alloc] init];
    _goodsImageView.userInteractionEnabled = true;
    [self.bubbleImageView addSubview:_goodsImageView];
    
    _titleLabel = [[UDTTTAttributedLabel alloc] initWithFrame:CGRectZero];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.userInteractionEnabled = true;
    _titleLabel.delegate = self;
    _titleLabel.backgroundColor = [UIColor clearColor];
    [self.bubbleImageView addSubview:_titleLabel];
    
    _paramsLabel = [[UDTTTAttributedLabel alloc] initWithFrame:CGRectZero];
    _paramsLabel.numberOfLines = 0;
    _paramsLabel.textAlignment = NSTextAlignmentLeft;
    _paramsLabel.userInteractionEnabled = true;
    _paramsLabel.delegate = self;
    _paramsLabel.backgroundColor = [UIColor clearColor];
    [self.bubbleImageView addSubview:_paramsLabel];
    
    //长按手势
    UITapGestureRecognizer *tapPressBubbleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGoodsMessage)];
    tapPressBubbleGesture.cancelsTouchesInView = false;
    [self.bubbleImageView addGestureRecognizer:tapPressBubbleGesture];
}

- (void)tapGoodsMessage {
    
    UdeskGoodsMessage *goodsMessage = (UdeskGoodsMessage *)self.baseMessage;
    if (!goodsMessage || ![goodsMessage isKindOfClass:[UdeskGoodsMessage class]]) return;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapGoodsMessageWithURL:goodsId:)]) {
        [self.delegate didTapGoodsMessageWithURL:goodsMessage.url goodsId:goodsMessage.goodsId];
    }
}

- (void)updateCellWithMessage:(UdeskBaseMessage *)baseMessage {
    [super updateCellWithMessage:baseMessage];
    
    UdeskGoodsMessage *goodsMessage = (UdeskGoodsMessage *)baseMessage;
    if (!goodsMessage || ![goodsMessage isKindOfClass:[UdeskGoodsMessage class]]) return;
    
    if (![UdeskSDKUtil isBlankString:goodsMessage.imgUrl]) {
        [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:[goodsMessage.imgUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholder:[UIImage udDefaultLoadingImage]];
    }
    
    self.titleLabel.numberOfLines = goodsMessage.numberOfLines;
    self.titleLabel.attributedText = goodsMessage.titleAttributedString;
    self.paramsLabel.attributedText = goodsMessage.paramsAttributedString;
    
    self.goodsImageView.frame = goodsMessage.imgFrame;
    self.titleLabel.frame = goodsMessage.titleFrame;
    self.paramsLabel.frame = goodsMessage.paramsFrame;
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
