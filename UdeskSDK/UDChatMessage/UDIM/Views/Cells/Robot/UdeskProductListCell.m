//
//  UdeskProductListCell.m
//  UdeskSDK
//
//  Created by xuchen on 2019/1/21.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskProductListCell.h"
#import "UdeskProductListMessage.h"
#import "Udesk_YYWebImage.h"
#import "NSAttributedString+UdeskHTML.h"
#import "UIColor+UdeskSDK.h"
#import "UdeskSDKShow.h"
#import "UdeskMessage+UdeskSDK.h"

static NSString *kUDProductListProductCellId = @"kUDProductListProductCellId";

@interface UdeskProductListProductCell : UITableViewCell

@property (nonatomic, strong) UIImageView *productImageView;
@property (nonatomic, strong) UILabel *productTitleLabel;
@property (nonatomic, strong) UILabel *firstInfoLabel;
@property (nonatomic, strong) UILabel *secondInfoLabel;
@property (nonatomic, strong) UILabel *thridInfoLabel;

@property (nonatomic, strong) UdeskMessageProduct *productModel;

@end

@implementation UdeskProductListProductCell

- (UIImageView *)productImageView {
    if (!_productImageView) {
        _productImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_productImageView];
    }
    return _productImageView;
}

- (UILabel *)productTitleLabel {
    if (!_productTitleLabel) {
        _productTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _productTitleLabel.font = [UIFont systemFontOfSize:14];
        _productTitleLabel.numberOfLines = 2;
        [self addSubview:_productTitleLabel];
    }
    return _productTitleLabel;
}

- (UILabel *)firstInfoLabel {
    if (!_firstInfoLabel) {
        _firstInfoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _firstInfoLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_firstInfoLabel];
    }
    return _firstInfoLabel;
}

- (UILabel *)secondInfoLabel {
    if (!_secondInfoLabel) {
        _secondInfoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _secondInfoLabel.font = [UIFont systemFontOfSize:12];
        _secondInfoLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_secondInfoLabel];
    }
    return _secondInfoLabel;
}

- (UILabel *)thridInfoLabel {
    if (!_thridInfoLabel) {
        _thridInfoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _thridInfoLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_thridInfoLabel];
    }
    return _thridInfoLabel;
}

- (void)setProductModel:(UdeskMessageProduct *)productModel {
    _productModel = productModel;
    
    [self resetProduct];
    
    self.productImageView.frame = CGRectMake(kUDBubbleToProductListHorizontalSpacing, kUDBubbleToProductListVerticalSpacing, kUDProductListImageWidth, kUDProductListImageHeight);
    [self.productImageView yy_setImageWithURL:[NSURL URLWithString:productModel.imageURL] placeholder:[UIImage udDefaultLoadingImage]];
    
    CGFloat textMaxWidth = [self productListMaxWidth]-kUDProductListImageWidth-kUDBubbleToProductListHorizontalSpacing;
    
    self.productTitleLabel.attributedText = [NSAttributedString attributedStringFromHTML:productModel.name customFont:[UIFont systemFontOfSize:15]];
    CGSize titleSize = [UdeskStringSizeUtil sizeWithAttributedText:self.productTitleLabel.attributedText size:CGSizeMake(textMaxWidth, kUDProductListTitleMaxHeight)];
    self.productTitleLabel.frame = CGRectMake(CGRectGetMaxX(self.productImageView.frame)+kUDBubbleToProductListHorizontalSpacing, kUDBubbleToProductListVerticalSpacing, textMaxWidth, titleSize.height);
    
    if (!productModel.infoList || productModel.infoList == (id)kCFNull) return ;
    
    if (productModel.infoList.count > 0) {
        
        self.firstInfoLabel.frame = CGRectMake(CGRectGetMinX(self.productTitleLabel.frame), CGRectGetMaxY(self.productTitleLabel.frame)+kUDProductListInfoToInfoVerticalSpacing, textMaxWidth/2, kUDProductListInfoToInfoHeight);
        
        UdeskMessageProductInfo *model = productModel.infoList[0];
        self.firstInfoLabel.attributedText = [[NSAttributedString alloc] initWithString:model.info attributes:[self productInfoAttributes:model]];
    }
    
    if (productModel.infoList.count > 1) {
        
        self.secondInfoLabel.frame = CGRectMake(CGRectGetMaxX(self.firstInfoLabel.frame), CGRectGetMaxY(self.productTitleLabel.frame)+kUDProductListInfoToInfoVerticalSpacing, textMaxWidth/2, kUDProductListInfoToInfoHeight);
        
        UdeskMessageProductInfo *model = productModel.infoList[1];
        self.secondInfoLabel.attributedText = [[NSAttributedString alloc] initWithString:model.info attributes:[self productInfoAttributes:model]];
    }
    
    if (productModel.infoList.count > 2) {
        
        self.thridInfoLabel.frame = CGRectMake(CGRectGetMinX(self.productTitleLabel.frame), CGRectGetMaxY(self.secondInfoLabel.frame)+ kUDProductListInfoToInfoVerticalSpacing, textMaxWidth, kUDProductListInfoToInfoHeight);
        
        UdeskMessageProductInfo *model = productModel.infoList[2];
        self.thridInfoLabel.attributedText = [[NSAttributedString alloc] initWithString:model.info attributes:[self productInfoAttributes:model]];
    }
}

- (void)resetProduct {
    
    self.productImageView.frame = CGRectZero;
    self.productImageView.image = nil;
    
    self.productTitleLabel.frame = CGRectZero;
    self.productTitleLabel.attributedText = nil;
    
    self.firstInfoLabel.frame = CGRectZero;
    self.firstInfoLabel.attributedText = nil;
    
    self.secondInfoLabel.frame = CGRectZero;
    self.secondInfoLabel.attributedText = nil;
    
    self.thridInfoLabel.frame = CGRectZero;
    self.thridInfoLabel.attributedText = nil;
}

- (NSDictionary *)productInfoAttributes:(UdeskMessageProductInfo *)model {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    if (model.boldFlag.boolValue) {
        [dic setObject:[UIFont boldSystemFontOfSize:12] forKey:NSFontAttributeName];
    }
    
    if (model.color) {
        [dic setObject:[UIColor udColorWithHexString:model.color] forKey:NSForegroundColorAttributeName];
    }
    
    return dic;
}

- (CGFloat)productListMaxWidth {
    return ((310.0/375.0) * UD_SCREEN_WIDTH)-(kUDBubbleToProductListHorizontalSpacing*2);
}

@end

@interface UdeskProductListCell()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UILabel *productTitleLabel;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *lineTwoView;
@property (nonatomic, strong) UITableView *productTableView;
@property (nonatomic, strong) UIButton *turnButton;

@end

@implementation UdeskProductListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    _productTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _productTitleLabel.font = [UIFont systemFontOfSize:15];
    _productTitleLabel.numberOfLines = 0;
    _productTitleLabel.backgroundColor = [UIColor clearColor];
    [self.bubbleImageView addSubview:_productTitleLabel];
    
    _lineView = [[UIView alloc] initWithFrame:CGRectZero];
    _lineView.backgroundColor = [UIColor colorWithRed:0.953f  green:0.961f  blue:0.965f alpha:1];
    [self.bubbleImageView addSubview:_lineView];
    
    _productTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _productTableView.delegate = self;
    _productTableView.dataSource = self;
    _productTableView.tableFooterView = [UIView new];
    _productTableView.backgroundColor = [UIColor clearColor];
    [self.bubbleImageView addSubview:_productTableView];
    
    [_productTableView registerClass:[UdeskProductListProductCell class] forCellReuseIdentifier:kUDProductListProductCellId];
    
    _lineTwoView = [[UIView alloc] initWithFrame:CGRectZero];
    _lineTwoView.backgroundColor = [UIColor colorWithRed:0.953f  green:0.961f  blue:0.965f alpha:1];
    [self.bubbleImageView addSubview:_lineTwoView];
    
    _turnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_turnButton addTarget:self action:@selector(turnButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_turnButton setTitleColor:[UIColor colorWithRed:0.18f  green:0.478f  blue:0.91f alpha:1] forState:UIControlStateNormal];
    _turnButton.titleLabel.font = [UIFont systemFontOfSize:15];
    _turnButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _turnButton.backgroundColor = [UIColor clearColor];
    [self.bubbleImageView addSubview:_turnButton];
}

- (void)turnButtonAction:(UIButton *)button {
    
    @try {
     
        UdeskProductListMessage *productListMessage = (UdeskProductListMessage *)self.baseMessage;
        if (!productListMessage || ![productListMessage isKindOfClass:[UdeskProductListMessage class]]) return ;
        
        NSMutableArray *array = [NSMutableArray arrayWithArray:productListMessage.message.productList];
        for (int i =0; i < productListMessage.message.productList.count; i++) {
            
            int n = (arc4random() % (productListMessage.message.productList.count - i)) + i;
            [array exchangeObjectAtIndex:i withObjectAtIndex:n];
        }
        productListMessage.message.productList = [array copy];
        [productListMessage layoutProductListMessage];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(reloadTableViewAtCell:)]) {
            [self.delegate reloadTableViewAtCell:self];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.baseMessage.message.showSize.integerValue;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UdeskProductListProductCell *cell = [tableView dequeueReusableCellWithIdentifier:kUDProductListProductCellId forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    UdeskProductListMessage *productListMessage = (UdeskProductListMessage *)self.baseMessage;
    
    if (productListMessage.displayProductArray.count > indexPath.row) {
        
        UdeskMessageProduct *product = productListMessage.displayProductArray[indexPath.row];
        cell.productModel = product;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UdeskProductListMessage *productListMessage = (UdeskProductListMessage *)self.baseMessage;
    if (!productListMessage || ![productListMessage isKindOfClass:[UdeskProductListMessage class]]) return ;
    
    if (indexPath.row >= productListMessage.displayProductArray.count) return;
    UdeskMessageProduct *product = productListMessage.displayProductArray[indexPath.row];
    
    if (self.baseMessage.message.messageType == UDMessageContentTypeShowProduct) {
        [UdeskSDKShow pushWebViewOnViewController:[UdeskSDKUtil currentViewController] URL:[NSURL URLWithString:product.url]];
    }
    else if (self.baseMessage.message.messageType == UDMessageContentTypeSelectiveProduct) {
        
        UdeskMessage *message = [[UdeskMessage alloc] initWithText:product.origin];
        message.sendType = UDMessageSendTypeRobot;
        message.messageType = UDMessageContentTypeReplyProduct;
        message.replyProduct = product;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSendRobotMessage:)]) {
            [self.delegate didSendRobotMessage:message];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UdeskProductListMessage *productListMessage = (UdeskProductListMessage *)self.baseMessage;
    if (!productListMessage || ![productListMessage isKindOfClass:[UdeskProductListMessage class]]) return 100;
    
    if (indexPath.row >= productListMessage.cellHeightArray.count) return 100;
    
    NSNumber *cellHeight = productListMessage.cellHeightArray[indexPath.row];
    
    return cellHeight.floatValue;
}

- (void)updateCellWithMessage:(UdeskBaseMessage *)baseMessage {
    [super updateCellWithMessage:baseMessage];
    
    UdeskProductListMessage *productListMessage = (UdeskProductListMessage *)baseMessage;
    if (!productListMessage || ![productListMessage isKindOfClass:[UdeskProductListMessage class]]) return;
    
    self.productTitleLabel.frame = productListMessage.titleFrame;
    self.productTitleLabel.attributedText = productListMessage.titleAttributedString;
    [self.turnButton setTitle:productListMessage.turnTitle forState:UIControlStateNormal];
    
    self.lineView.frame = productListMessage.lineFrame;
    self.productTableView.frame = productListMessage.listFrame;
    self.lineTwoView.frame = productListMessage.lineTwoFrame;
    self.turnButton.frame = productListMessage.turnFrame;
    
    [self.productTableView reloadData];
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
