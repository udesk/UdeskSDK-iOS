//
//  UdeskProductCell.m
//  UdeskSDK
//
//  Created by xuchen on 2019/1/21.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskProductCell.h"
#import "UdeskProductMessage.h"
#import "Udesk_YYWebImage.h"

@interface UdeskProductCell()

@property (nonatomic, strong) UIImageView *productImageView;
@property (nonatomic, strong) UILabel *productTitleLabel;
@property (nonatomic, strong) UILabel *firstInfoLabel;
@property (nonatomic, strong) UILabel *secondInfoLabel;
@property (nonatomic, strong) UILabel *thridInfoLabel;

@end

@implementation UdeskProductCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    _productImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.bubbleImageView addSubview:_productImageView];
    
    _productTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _productTitleLabel.textColor = [UIColor whiteColor];
    _productTitleLabel.font = [UIFont systemFontOfSize:14];
    _productTitleLabel.numberOfLines = 2;
    [self.bubbleImageView addSubview:_productTitleLabel];
    
    _firstInfoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _firstInfoLabel.font = [UIFont systemFontOfSize:12];
    [self.bubbleImageView addSubview:_firstInfoLabel];
    
    _secondInfoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _secondInfoLabel.font = [UIFont systemFontOfSize:12];
    _secondInfoLabel.textAlignment = NSTextAlignmentRight;
    [self.bubbleImageView addSubview:_secondInfoLabel];
    
    _thridInfoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _thridInfoLabel.font = [UIFont systemFontOfSize:12];
    [self.bubbleImageView addSubview:_thridInfoLabel];
}

- (void)updateCellWithMessage:(UdeskBaseMessage *)baseMessage {
    [super updateCellWithMessage:baseMessage];
    
    UdeskProductMessage *productMessage = (UdeskProductMessage *)baseMessage;
    if (!productMessage || ![productMessage isKindOfClass:[UdeskProductMessage class]]) return;
    
    self.productImageView.frame = productMessage.imageFrame;
    [self.productImageView yy_setImageWithURL:productMessage.imgURL placeholder:[UIImage udDefaultLoadingImage]];
    
    self.productTitleLabel.frame = productMessage.titleFrame;
    self.productTitleLabel.attributedText = productMessage.titleAttributedString;
    
    self.firstInfoLabel.frame = productMessage.firstInfoFrame;
    self.firstInfoLabel.attributedText = productMessage.firstAttributedString;
    
    self.secondInfoLabel.frame = productMessage.secondInfoFrame;
    self.secondInfoLabel.attributedText = productMessage.secondAttributedString;
    
    self.thridInfoLabel.frame = productMessage.thirdInfoFrame;
    self.thridInfoLabel.attributedText = productMessage.thirdAttributedString;
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
