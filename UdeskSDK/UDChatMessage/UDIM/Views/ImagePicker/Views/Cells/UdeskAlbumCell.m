//
//  UdeskAlbumCell.m
//  UdeskImagePickerController
//
//  Created by xuchen on 2018/3/6.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskAlbumCell.h"
#import "UdeskAlbumModel.h"
#import "UdeskAlbumsViewManager.h"

@interface UdeskAlbumCell()

@property (nonatomic, strong) UIImageView *posterImageView;
@property (nonatomic, strong) UILabel     *titleLabel;

@end

@implementation UdeskAlbumCell

- (void)setAlbumModel:(UdeskAlbumModel *)albumModel {
    if (!albumModel || albumModel == (id)kCFNull) return ;
    _albumModel = albumModel;
    
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:albumModel.name attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor blackColor]}];
    NSAttributedString *countString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  (%zd)",albumModel.count] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    [nameString appendAttributedString:countString];
    self.titleLabel.attributedText = nameString;
    
    [UdeskAlbumsViewManager fetchAlbumPosterImageWithAsset:[albumModel.result lastObject] completion:^(UIImage *image) {
        self.posterImageView.image = image;
    }];
}

- (void)layoutSubviews {
    if (([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)) [super layoutSubviews];
    NSInteger titleHeight = ceil(self.titleLabel.font.lineHeight);
    self.titleLabel.frame = CGRectMake(70, (CGRectGetHeight(self.frame) - titleHeight) / 2, CGRectGetWidth(self.frame) - 60 - 50, titleHeight);
    self.posterImageView.frame = CGRectMake(0, 0, 60, 60);
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    if (([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)) [super layoutSublayersOfLayer:layer];
}

#pragma mark - Lazy load
- (UIImageView *)posterImageView {
    if (!_posterImageView) {
        _posterImageView = [[UIImageView alloc] init];
        _posterImageView.contentMode = UIViewContentModeScaleAspectFill;
        _posterImageView.clipsToBounds = YES;
        [self.contentView addSubview:_posterImageView];
    }
    return _posterImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:18];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
