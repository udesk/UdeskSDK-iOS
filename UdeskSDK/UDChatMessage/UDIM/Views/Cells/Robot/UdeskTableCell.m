//
//  UdeskTableCell.m
//  UdeskSDK
//
//  Created by xuchen on 2019/1/21.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskTableCell.h"
#import "UdeskTableMessage.h"
#import "UdeskMessage+UdeskSDK.h"

@interface UdeskTableCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation UdeskTableCollectionViewCell

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.font = [UIFont systemFontOfSize:15];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.backgroundColor = [UIColor whiteColor];
        _textLabel.textColor = [UIColor colorWithRed:0.18f  green:0.478f  blue:0.91f alpha:1];
        UDViewBorderRadius(_textLabel, 1, 1, [UIColor colorWithRed:0.91f  green:0.925f  blue:0.929f alpha:1]);
        [self addSubview:_textLabel];
    }
    return _textLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.frame = self.bounds;
}

@end

static NSString *kUdeskTableCellIdentifier = @"kUdeskTableCellIdentifier";

@interface UdeskTableCell()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UILabel *tableTitleLabel;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UICollectionViewFlowLayout *tableFlowLayout;
@property (nonatomic, strong) UICollectionView *tableCollectionView;

@end

@implementation UdeskTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    _tableTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _tableTitleLabel.font = [UIFont systemFontOfSize:15];
    _tableTitleLabel.numberOfLines = 0;
    [self.bubbleImageView addSubview:_tableTitleLabel];
    
    _lineView = [[UIView alloc] initWithFrame:CGRectZero];
    _lineView.backgroundColor = [UIColor colorWithRed:0.953f  green:0.961f  blue:0.965f alpha:1];
    [self.bubbleImageView addSubview:_lineView];
    
    _tableFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    _tableCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_tableFlowLayout];
    _tableCollectionView.backgroundColor = [UIColor clearColor];
    _tableCollectionView.dataSource = self;
    _tableCollectionView.delegate = self;
    _tableCollectionView.pagingEnabled = YES;
    _tableCollectionView.scrollsToTop = NO;
    _tableCollectionView.showsHorizontalScrollIndicator = NO;
    [self.bubbleImageView addSubview:_tableCollectionView];
    
    [_tableCollectionView registerClass:[UdeskTableCollectionViewCell class] forCellWithReuseIdentifier:kUdeskTableCellIdentifier];
}

#pragma mark - UICollectionViewDataSource && Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.baseMessage.message.table.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UdeskTableCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kUdeskTableCellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    UdeskMessageOption *model = self.baseMessage.message.table[indexPath.row];
    cell.textLabel.text = model.value;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row > self.baseMessage.message.table.count) return;
    UdeskMessageOption *model = self.baseMessage.message.table[indexPath.row];
    
    UdeskMessage *message = [[UdeskMessage alloc] initWithText:model.value];
    message.sendType = UDMessageSendTypeRobot;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSendRobotMessage:)]) {
        [self.delegate didSendRobotMessage:message];
    }
}

- (void)updateCellWithMessage:(UdeskBaseMessage *)baseMessage {
    [super updateCellWithMessage:baseMessage];
    
    UdeskTableMessage *tableMessage = (UdeskTableMessage *)baseMessage;
    if (!tableMessage || ![tableMessage isKindOfClass:[UdeskTableMessage class]]) return;
    
    self.tableTitleLabel.frame = tableMessage.titleFrame;
    self.tableTitleLabel.attributedText = tableMessage.titleAttributedString;
    
    self.lineView.frame = tableMessage.lineFrame;
    
    self.tableFlowLayout.itemSize = CGSizeMake(tableMessage.singleTableWidth, kUDSingleTableHeight);
    self.tableFlowLayout.minimumInteritemSpacing = kUDBubbleToTableHorizontalSpacing;
    self.tableFlowLayout.minimumLineSpacing = kUDBubbleToTableVerticalSpacing;
    self.tableCollectionView.frame = tableMessage.tableFrame;
    [self.tableCollectionView setCollectionViewLayout:self.tableFlowLayout];
    [self.tableCollectionView reloadData];
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
