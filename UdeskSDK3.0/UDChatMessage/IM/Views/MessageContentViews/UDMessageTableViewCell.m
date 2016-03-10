//
//  UDMessageTableViewCell.m
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UDMessageTableViewCell.h"
#import "UDFoundationMacro.h"
#import "UIImage+UDMessage.h"

//时间 Y
static const CGFloat kUDLabelPadding         = 5.0f;
//时间 height
static const CGFloat kUDTimeStampLabelHeight = 14.0f;
//头像 X
static const CGFloat kUDHeadShowX       = 8.0;
//头像 Y
static const CGFloat kUDHeadShowY       = 11;
// 头像大小
static CGFloat const kUDHeadImageSize = 40.0f;

@interface UDMessageTableViewCell ()<UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL displayTimestamp;//是否显示时间轴Label


@end

@implementation UDMessageTableViewCell

#pragma mark - 复制
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)becomeFirstResponder {
    return [super becomeFirstResponder];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return (action == @selector(copyed:));
}

- (void)copyed:(id)sender {
    [[UIPasteboard generalPasteboard] setString:self.messageContentView.textLabel.text];
    [self resignFirstResponder];
}

#pragma mark - Setters

- (void)configureCellWithMessage:(UDMessage *)message
               displaysTimestamp:(BOOL)displayTimestamp {
    // 1、是否显示Time Line的label
    [self configureTimestamp:displayTimestamp atMessage:message];
    
    // 2、配置头像
    [self configHeadWithMessage:message];
    
    // 3、配置需要显示什么消息内容，比如语音、文字、图片，并添加点击事件
    [self configureMessageBubbleViewWithMessage:message];
}
#pragma mark - 是否显示Time的label
- (void)configureTimestamp:(BOOL)displayTimestamp atMessage:(UDMessage *)message {

    self.displayTimestamp = displayTimestamp;
    self.timestampLabel.hidden = !self.displayTimestamp;
    if (displayTimestamp) {
        
        NSString *dateText = nil;
        NSString *timeText = nil;
        
        NSDate *today = [NSDate date];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setDay:-1];
        NSDate *yesterday = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:today options:0];
        
        NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:message.timestamp];
        NSDateComponents *todayComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:today];
        NSDateComponents *yesterdayComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:yesterday];
        
        if (dateComponents.year == todayComponents.year && dateComponents.month == todayComponents.month && dateComponents.day == todayComponents.day) {
            dateText = @"今天";
        } else if (dateComponents.year == yesterdayComponents.year && dateComponents.month == yesterdayComponents.month && dateComponents.day == yesterdayComponents.day) {
            dateText = @"昨天";
        } else {
            dateText = [NSDateFormatter localizedStringFromDate:message.timestamp dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
        }
        
        timeText = [NSDateFormatter localizedStringFromDate:message.timestamp dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
        
        self.timestampLabel.text = [NSString stringWithFormat:@"%@ %@",dateText,timeText];
        
    }
}

#pragma 配置头像
- (void)configHeadWithMessage:(UDMessage *)message {
    
    switch (message.messageFrom) {
        case UDMessageTypeSending:
            
            if (Config.headImage != nil) {
                _headImageView.image = Config.headImage;
            } else {
                _headImageView.image = [UIImage ud_defaultCustomerImage];
            }

            break;
        case UDMessageTypeReceiving:
            
            _headImageView.image = [UIImage ud_defaultAgentImage];
            break;
            
        default:
            break;
    }
    
}

#pragma mark - 配置需要显示什么消息内容，比如语音、文字、图片，并添加点击事件
- (void)configureMessageBubbleViewWithMessage:(UDMessage *)message {
    UDMessageMediaType currentMediaType = message.messageType;

    for (UIGestureRecognizer *gesTureRecognizer in self.messageContentView.bubbleImageView.gestureRecognizers) {
        gesTureRecognizer.delegate = self;
        [self.messageContentView.bubbleImageView removeGestureRecognizer:gesTureRecognizer];
    }
    for (UIGestureRecognizer *gesTureRecognizer in self.messageContentView.photoImageView.gestureRecognizers) {
        gesTureRecognizer.delegate = self;
        [self.messageContentView.photoImageView removeGestureRecognizer:gesTureRecognizer];
    }
    switch (currentMediaType) {
        case UDMessageMediaTypePhoto:{
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sigleTapGestureRecognizerHandle:)];
            tapGestureRecognizer.delegate = self;
            [self.messageContentView.photoImageView addGestureRecognizer:tapGestureRecognizer];
            break;
        }
        case UDMessageMediaTypeText:
        case UDMessageMediaTypeVoice: {
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sigleTapGestureRecognizerHandle:)];
            tapGestureRecognizer.delegate = self;
            [self.messageContentView.bubbleImageView addGestureRecognizer:tapGestureRecognizer];
            
            break;
        }

        default:
            break;
    }
    //展示消息
    [self.messageContentView configureCellWithMessage:message];
}

#pragma mark - Gestures
//隐藏Menu
- (void)setupNormalMenuController {
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if (menu.isMenuVisible) {
        [menu setMenuVisible:NO animated:YES];
    }
}
//长按复制
- (void)longPressGestureRecognizerHandle:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    
    if (longPressGestureRecognizer.state != UIGestureRecognizerStateBegan || ![self becomeFirstResponder])
        return;
    
    NSArray *popMenuTitles = [[UDConfigurationHelper appearance] popMenuTitles];
    NSMutableArray *menuItems = [[NSMutableArray alloc] init];
    for (int i = 0; i < popMenuTitles.count; i ++) {
        NSString *title = popMenuTitles[i];
        SEL action = nil;
        switch (i) {
            case 0: {
                if ([self.messageContentView.message messageType] == UDMessageMediaTypeText) {
                    action = @selector(copyed:);
                }
                break;
            }

            default:
                break;
        }
        if (action) {
            UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:title action:action];
            if (item) {
                [menuItems addObject:item];
            }
        }
    }
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuItems:menuItems];
    
    CGRect targetRect = [self convertRect:[self.messageContentView bubbleFrame]
                                 fromView:self.messageContentView];
    
    [menu setTargetRect:CGRectInset(targetRect, 0.0f, 4.0f) inView:self];
    
    [menu setMenuVisible:YES animated:YES];
    
}
#pragma mark - 点击消息
- (void)sigleTapGestureRecognizerHandle:(UITapGestureRecognizer *)tapGestureRecognizer {

    if (tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self setupNormalMenuController];
        //代理传出点击事件
        if ([self.delegate respondsToSelector:@selector(didSelectedOnMessage:indexPath:messageTableViewCell:)]) {
            [self.delegate didSelectedOnMessage:self.messageContentView.message indexPath:self.indexPath messageTableViewCell:self];
        }
    }
}

#pragma mark - 消息类型
- (UDMessageFromType)bubbleMessageType {
    return self.messageContentView.message.messageFrom;
}
#pragma mark - 消息Cell高度
+ (CGFloat)calculateCellHeightWithMessage:(UDMessage *)message
                        displaysTimestamp:(BOOL)displayTimestamp {
    
    // 第一，是否有时间戳的显示
    CGFloat timestampHeight = displayTimestamp ? (kUDTimeStampLabelHeight + kUDLabelPadding * 2) : 0;
    
    CGFloat bubbleMessageHeight = [UDMessageContentView calculateCellHeightWithMessage:message] + timestampHeight + kUDHeadShowY*2;
    
    return bubbleMessageHeight;
}

- (void)setup {
    
    self.imageView.image = nil;
    self.imageView.hidden = YES;
    self.textLabel.text = nil;
    self.textLabel.hidden = YES;
    self.detailTextLabel.text = nil;
    self.detailTextLabel.hidden = YES;

    
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.accessoryView = nil;
    
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizerHandle:)];
    [recognizer setMinimumPressDuration:0.4f];
    recognizer.delegate = self;
    [self addGestureRecognizer:recognizer];
    
}

- (instancetype)initWithMessage:(UDMessage *)message
              displaysTimestamp:(BOOL)displayTimestamp
                reuseIdentifier:(NSString *)cellIdentifier {
    self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    if (self) {
        
        // 1、是否显示Time Line的label
        if (!_timestampLabel) {
            
            UILabel *timestampLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kUDLabelPadding, UD_SCREEN_WIDTH, kUDTimeStampLabelHeight)];
            timestampLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
            timestampLabel.textColor = Config.chatTimeColor;
            timestampLabel.font = [UIFont systemFontOfSize:Config.timeFontSize];
            timestampLabel.center = CGPointMake(CGRectGetWidth([[UIScreen mainScreen] bounds]) / 2.0, timestampLabel.center.y);
            timestampLabel.textAlignment = NSTextAlignmentCenter;
            timestampLabel.backgroundColor = [UIColor clearColor];
            [self.contentView addSubview:timestampLabel];
            [self.contentView bringSubviewToFront:timestampLabel];
            
            _timestampLabel = timestampLabel;

        }
        
        // 2、配置头像
        
        CGRect headButtonFrame;
        switch (message.messageFrom) {
            case UDMessageTypeSending:
                
                headButtonFrame = CGRectMake(kUDHeadShowX,
                                             kUDHeadShowY + (displayTimestamp ? (kUDTimeStampLabelHeight + kUDLabelPadding * 2) : 0),
                                             kUDHeadImageSize,
                                             kUDHeadImageSize);
                
                break;
            case UDMessageTypeReceiving:
                headButtonFrame = CGRectMake(UD_SCREEN_WIDTH - kUDHeadImageSize - kUDHeadShowX,
                                             kUDHeadShowY + (displayTimestamp ? (kUDTimeStampLabelHeight + kUDLabelPadding * 2) : 0),
                                             kUDHeadImageSize,
                                             kUDHeadImageSize);
                break;
            default:
                break;
  
        }
                        
        // 初始化头像
        UIImageView *headImage = [[UIImageView alloc] initWithFrame:headButtonFrame];
        [self.contentView addSubview:headImage];
        self.headImageView = headImage;
        
        // 3、配置需要显示什么消息内容，比如语音、文字、图片
        if (!self.messageContentView) {

            // 初始化消息内容view
            UDMessageContentView *messageBubbleView = [[UDMessageContentView alloc] initWithFrame:CGRectZero message:message];
            [self.contentView addSubview:messageBubbleView];
            [self.contentView sendSubviewToBack:messageBubbleView];
            self.messageContentView = messageBubbleView;
        }
    
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // 初始化
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    // 初始化
    [self setup];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 布局头像
    CGFloat layoutOriginY = kUDHeadShowY + (self.displayTimestamp ? 19 : 0);
    CGRect headImageViewFrame = self.headImageView.frame;
    headImageViewFrame.origin.y = layoutOriginY;
    
    if ([self bubbleMessageType] == UDMessageTypeReceiving) {
        headImageViewFrame.origin.x = kUDHeadShowX;
    }
    else if ([self bubbleMessageType] == UDMessageTypeSending) {
    
        headImageViewFrame.origin.x = (CGRectGetWidth(self.bounds) - kUDHeadShowX - kUDHeadImageSize);
    }

    self.headImageView.frame = headImageViewFrame;
    
    // 布局消息内容的View
    CGFloat bubbleX = 0.0f;
    CGFloat offsetX = 0.0f;
    if ([self bubbleMessageType] == UDMessageTypeReceiving) {
        bubbleX = kUDHeadImageSize + kUDHeadShowX * 2;
    } else if ([self bubbleMessageType] == UDMessageTypeSending) {
        offsetX = kUDHeadImageSize + kUDHeadShowX * 2;
    }
    
    CGFloat timeStampLabelNeedHeight = (self.displayTimestamp ? (kUDTimeStampLabelHeight + kUDLabelPadding) : 0);
    
    CGRect bubbleMessageViewFrame = CGRectMake(bubbleX,
                              timeStampLabelNeedHeight,
                              CGRectGetWidth(self.contentView.bounds) - bubbleX - offsetX,
                              CGRectGetHeight(self.contentView.bounds) - timeStampLabelNeedHeight);
    self.messageContentView.frame = bubbleMessageViewFrame;
    
}


- (void)dealloc {
    _headImageView = nil;
    _timestampLabel = nil;
    _messageContentView = nil;
    _indexPath = nil;
}

#pragma mark - TableViewCell

- (void)prepareForReuse {
    // 这里做清除工作
    [super prepareForReuse];
    self.messageContentView.textLabel.text = nil;
    self.messageContentView.textLabel.attributedText = nil;
    self.messageContentView.bubbleImageView.image = nil;
    self.messageContentView.animationVoiceImageView.image = nil;
    self.messageContentView.voiceDurationLabel.text = nil;
    self.messageContentView.photoImageView.image = nil;
    self.headImageView.image = nil;
    self.timestampLabel.text = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
