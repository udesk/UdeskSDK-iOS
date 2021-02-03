//
//  UdeskTopAskCell.m
//  UdeskSDK
//
//  Created by xuchen on 2019/1/21.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskTopAskCell.h"
#import "UIView+UdeskSDK.h"
#import "UdeskTopAskMessage.h"

static NSString *kUDTopAskQuestionCellId = @"topAskQuestionCellId";

@interface UdeskTopAskOptionsCell : UITableViewCell

@property (nonatomic, strong) UIImageView *optionTagImageView;
@property (nonatomic, strong) UILabel *optionTitleLabel;

@end

@implementation UdeskTopAskOptionsCell

- (UIImageView *)optionTagImageView {
    if (!_optionTagImageView) {
        _optionTagImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _optionTagImageView.image = [UIImage udDefaultListTag];
        _optionTagImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_optionTagImageView];
    }
    return _optionTagImageView;
}

- (UILabel *)optionTitleLabel {
    if (!_optionTitleLabel) {
        _optionTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _optionTitleLabel.font = [UIFont systemFontOfSize:15];
        _optionTitleLabel.numberOfLines = 0;
        _optionTitleLabel.textColor = [UIColor colorWithRed:0.255f  green:0.557f  blue:0.949f alpha:1];
        _optionTitleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_optionTitleLabel];
    }
    return _optionTitleLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.optionTagImageView.frame = CGRectMake(kUDCellToTopAskQuestionTagHorizontalSpacing, kUDCellToTopAskQuestionTagVerticalSpacing, kUDTopAskOptionTagWidth, kUDTopAskOptionTagHeight);
    
    CGFloat titleX = self.optionTagImageView.udRight+kUDOptionToTagHorizontalSpacing;
    self.optionTitleLabel.frame = CGRectMake(titleX, kUDCellToTopAskQuestionVerticalSpacing, self.udWidth-titleX-kUDBubbleToTopAskHorizontalSpacing, self.udHeight-kUDBubbleToTopAskVerticalSpacing);
}

@end

@interface UdeskTopAskCell()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>

@property (nonatomic, strong) UITextView *leadWordTextView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UITableView *topAskTableView;
@property (nonatomic, strong) UITextView *recommendLeadingWordTextView;

@end

@implementation UdeskTopAskCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    _leadWordTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    _leadWordTextView.delegate = self;
    _leadWordTextView.editable = NO;
    _leadWordTextView.dataDetectorTypes = UIDataDetectorTypeAll;
    _leadWordTextView.showsVerticalScrollIndicator = NO;
    _leadWordTextView.showsHorizontalScrollIndicator = NO;
    _leadWordTextView.textContainer.lineFragmentPadding = 0;
    _leadWordTextView.textContainerInset = UIEdgeInsetsMake(5, 0, 0, 0);
    _leadWordTextView.backgroundColor = [UIColor clearColor];
    [self.bubbleImageView addSubview:_leadWordTextView];
    
    
    _recommendLeadingWordTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    _recommendLeadingWordTextView.editable = NO;
    _recommendLeadingWordTextView.dataDetectorTypes = UIDataDetectorTypeAll;
    _recommendLeadingWordTextView.showsVerticalScrollIndicator = NO;
    _recommendLeadingWordTextView.showsHorizontalScrollIndicator = NO;
    _recommendLeadingWordTextView.textContainer.lineFragmentPadding = 0;
    _recommendLeadingWordTextView.textContainerInset = UIEdgeInsetsMake(5, 0, 0, 0);
    _recommendLeadingWordTextView.backgroundColor = [UIColor clearColor];
    _recommendLeadingWordTextView.scrollEnabled = NO;
    [self.bubbleImageView addSubview:_recommendLeadingWordTextView];
    
    _lineView = [[UIView alloc] initWithFrame:CGRectZero];
    _lineView.backgroundColor = [UIColor colorWithRed:0.953f  green:0.961f  blue:0.965f alpha:1];
    [self.bubbleImageView addSubview:_lineView];
    
    _topAskTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _topAskTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _topAskTableView.delegate = self;
    _topAskTableView.dataSource = self;
    _topAskTableView.sectionFooterHeight = 0;
    _topAskTableView.tableFooterView = [UIView new];
    _topAskTableView.backgroundColor = [UIColor clearColor];
    [self.bubbleImageView addSubview:_topAskTableView];
    
    [_topAskTableView registerClass:[UdeskTopAskOptionsCell class] forCellReuseIdentifier:kUDTopAskQuestionCellId];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    
    return [self udRichTextView:textView shouldInteractWithURL:URL inRange:characterRange];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.baseMessage.message.topAsk.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    UdeskMessageTopAsk *topAsk = self.baseMessage.message.topAsk[section];
    if (self.baseMessage.message.topAsk.count == 1) {
        return topAsk.optionsList.count;
    }
    return topAsk.isUnfold ? topAsk.optionsList.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UdeskTopAskOptionsCell *cell = [tableView dequeueReusableCellWithIdentifier:kUDTopAskQuestionCellId forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (self.baseMessage.message.topAsk.count > indexPath.section) {
        
        if (self.baseMessage.message.topAsk.count > indexPath.section) {
            UdeskMessageTopAsk *topAsk = self.baseMessage.message.topAsk[indexPath.section];
            if (topAsk.optionsList.count > indexPath.row) {
                UdeskMessageOption *option = topAsk.optionsList[indexPath.row];
                cell.optionTitleLabel.text = option.value;
            }
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UdeskTopAskMessage *topAskMessage = (UdeskTopAskMessage *)self.baseMessage;
    if (!topAskMessage || ![topAskMessage isKindOfClass:[UdeskTopAskMessage class]]) return 0;
    if (indexPath.row >= topAskMessage.questionHeightArray.count) return 0;
    
    NSNumber *height = topAskMessage.questionHeightArray[indexPath.row];
    
    return height.floatValue;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    //一个分类不需要折叠
    if (self.baseMessage.message.topAsk.count == 1) {
        return 0;
    }
    
    UdeskTopAskMessage *topAskMessage = (UdeskTopAskMessage *)self.baseMessage;
    if (!topAskMessage || ![topAskMessage isKindOfClass:[UdeskTopAskMessage class]]) return 0;
    if (section >= topAskMessage.topAskTitleHeightArray.count) return 0;
    
    NSNumber *height = topAskMessage.topAskTitleHeightArray[section];
    
    return height.floatValue;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    //一个分类不需要折叠
    if (self.baseMessage.message.topAsk.count == 1) {
        return nil;
    }
    
    UdeskTopAskMessage *topAskMessage = (UdeskTopAskMessage *)self.baseMessage;
    if (!topAskMessage || ![topAskMessage isKindOfClass:[UdeskTopAskMessage class]]) return nil;
    
    if (section >= topAskMessage.topAskTitleHeightArray.count || section >= self.baseMessage.message.topAsk.count) return nil;
    
    NSNumber *height = topAskMessage.topAskTitleHeightArray[section];
    
    UdeskMessageTopAsk *topAsk = self.baseMessage.message.topAsk[section];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bubbleImageView.frame), height.floatValue)];
    view.backgroundColor = [UIColor whiteColor];
    view.tag = 8890 + section;
    
    CGFloat titleLabelX = kUDBubbleToTopAskHorizontalSpacing - 4;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX, 1, CGRectGetWidth(self.bubbleImageView.frame)-(titleLabelX*2)-25, height.floatValue-1)];
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.text = topAsk.questionType;
    titleLabel.backgroundColor = [UIColor whiteColor];
    titleLabel.textColor = [UIColor colorWithRed:0.333f  green:0.333f  blue:0.333f alpha:1];
    [view addSubview:titleLabel];
    
    if (self.baseMessage.message.topAsk.count != (section + 1)) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(view.frame)-1, CGRectGetWidth(self.bubbleImageView.frame), 1)];
        lineView.backgroundColor = [UIColor colorWithRed:0.953f  green:0.961f  blue:0.965f alpha:1];
        [view addSubview:lineView];
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:topAsk.isUnfold?[UIImage udDefaultUpArrow]:[UIImage udDefaultDownArrow]];
    imageView.frame = CGRectMake(titleLabel.udRight, 10, 20, 20);
    imageView.udRight = view.udRight-15;
    imageView.udCenterY = titleLabel.udCenterY;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topAskTapFoldAction:)];
    [view addGestureRecognizer:tap];
    
    [view addSubview:imageView];
    
    return view;
}

- (void)topAskTapFoldAction:(UIGestureRecognizer *)gesture {
    
    UIView *view = gesture.view;
    NSInteger section = view.tag - 8890;
    
    UdeskMessageTopAsk *currentTopAsk = self.baseMessage.message.topAsk[section];
    
    for (UdeskMessageTopAsk *topAsk in self.baseMessage.message.topAsk) {
        
        if ([topAsk.questionTypeId isKindOfClass:[NSString class]] && [currentTopAsk.questionTypeId isKindOfClass:[NSString class]]) {
            if (![topAsk.questionTypeId isEqualToString:currentTopAsk.questionTypeId]) {
                topAsk.isUnfold = NO;
            }
        }
    }
    
    currentTopAsk.isUnfold = !currentTopAsk.isUnfold;
    
    UdeskTopAskMessage *topAskMessage = (UdeskTopAskMessage *)self.baseMessage;
    if (!topAskMessage || ![topAskMessage isKindOfClass:[UdeskTopAskMessage class]]) return;
    
    [topAskMessage layoutTopAskMessage];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(reloadTableViewAtCell:)]) {
        [self.delegate reloadTableViewAtCell:self];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self didSelectRobotHitMessageAtIndexPath:indexPath];
}

- (void)updateCellWithMessage:(UdeskBaseMessage *)baseMessage {
    [super updateCellWithMessage:baseMessage];
    
    UdeskTopAskMessage *topAskMessage = (UdeskTopAskMessage *)baseMessage;
    if (!topAskMessage || ![topAskMessage isKindOfClass:[UdeskTopAskMessage class]]) return;
    
    self.leadWordTextView.frame = topAskMessage.leadingWordFrame;
    self.leadWordTextView.attributedText = topAskMessage.leadingAttributedString;
    
    self.recommendLeadingWordTextView.attributedText = topAskMessage.recommendLeadingAttributedString;
    self.recommendLeadingWordTextView.frame = topAskMessage.recommendLeadingWordFrame;
    
    self.lineView.frame = topAskMessage.lineFrame;
    
    self.topAskTableView.frame = topAskMessage.topAskFrame;
    [self.topAskTableView reloadData];
    
    
    //self.recommendLeadingWordTextView.backgroundColor = [UIColor yellowColor];
    //self.leadWordTextView.backgroundColor = [UIColor lightGrayColor];
    //self.topAskTableView.backgroundColor = [UIColor purpleColor];
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
