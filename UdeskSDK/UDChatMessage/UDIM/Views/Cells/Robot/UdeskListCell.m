//
//  UdeskListCell.m
//  UdeskSDK
//
//  Created by xuchen on 2019/1/21.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UdeskListCell.h"
#import "UdeskListMessage.h"
#import "UdeskMessage+UdeskSDK.h"

static NSString *kUDListCellId = @"kUDListCellId";

@interface UdeskListCell()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UILabel *listTitleLabel;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UITableView *listTableView;

@end

@implementation UdeskListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    _listTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _listTitleLabel.font = [UIFont systemFontOfSize:15];
    _listTitleLabel.numberOfLines = 0;
    [self.bubbleImageView addSubview:_listTitleLabel];
    
    _lineView = [[UIView alloc] initWithFrame:CGRectZero];
    _lineView.backgroundColor = [UIColor colorWithRed:0.953f  green:0.961f  blue:0.965f alpha:1];
    [self.bubbleImageView addSubview:_lineView];
    
    _listTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _listTableView.delegate = self;
    _listTableView.dataSource = self;
    _listTableView.tableFooterView = [UIView new];
    _listTableView.backgroundColor = [UIColor clearColor];
    [self.bubbleImageView addSubview:_listTableView];
    
    [_listTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kUDListCellId];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.baseMessage.message.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kUDListCellId forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    if (self.baseMessage.message.list.count > indexPath.row) {
        
        UdeskMessageOption *option = self.baseMessage.message.list[indexPath.row];
        cell.textLabel.text = option.value;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor colorWithRed:0.18f  green:0.478f  blue:0.91f alpha:1];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row >= self.baseMessage.message.list.count) return;
    UdeskMessageOption *option = self.baseMessage.message.list[indexPath.row];
    
    UdeskMessage *message = [[UdeskMessage alloc] initWithText:option.value];
    message.sendType = UDMessageSendTypeRobot;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSendRobotMessage:)]) {
        [self.delegate didSendRobotMessage:message];
    }
}

- (void)updateCellWithMessage:(UdeskBaseMessage *)baseMessage {
    [super updateCellWithMessage:baseMessage];
    
    UdeskListMessage *listMessage = (UdeskListMessage *)baseMessage;
    if (!listMessage || ![listMessage isKindOfClass:[UdeskListMessage class]]) return;
    
    self.listTitleLabel.frame = listMessage.titleFrame;
    self.listTitleLabel.attributedText = listMessage.titleAttributedString;
    
    self.lineView.frame = listMessage.lineFrame;
    
    self.listTableView.frame = listMessage.listFrame;
    [self.listTableView reloadData];
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
