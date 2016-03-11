//
//  UDEmotionManagerView.m
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UDEmotionManagerView.h"
#import "UDFoundationMacro.h"
#import "UdeskUtils.h"
#import "UIImage+UDMessage.h"

static CGFloat EmojiWidth;
static CGFloat EmojiHeight;
static CGFloat EmojiFontSize;


@interface UDEmotionManagerView ()

@property (nonatomic, strong) NSArray      *emojis;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation UDEmotionManagerView

#pragma mark - Life cycle

- (void)setup {
    if (UD_SCREEN_WIDTH<375) {
        
        EmojiWidth = 45;
        EmojiHeight = 45;
        EmojiFontSize = 30;
        
    }
    else {
        
        EmojiWidth = 53;
        EmojiHeight = 50;
        EmojiFontSize = 32;
    }
    
    // init emojis
    self.emojis = [NSArray arrayWithContentsOfFile:getUDBundlePath(@"UDEmojiList.plist")];

    //
    NSInteger rowNum = (CGRectGetHeight(self.bounds) / EmojiHeight);
    NSInteger colNum = (CGRectGetWidth(self.bounds) / EmojiWidth);
    NSInteger numOfPage = ceil((float)[self.emojis count] / (float)(rowNum * colNum));
    
    // init scrollview
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) * numOfPage,
                                             CGRectGetHeight(self.bounds));
    [self addSubview:self.scrollView];
    
    // add emojis
    
    NSInteger row = 0;
    NSInteger column = 0;
    NSInteger page = 0;
    
    NSInteger emojiPointer = 0;
    for (int i = 0; i < [self.emojis count] + numOfPage - 1; i++) {
        
        // Pagination
        if (i % (rowNum * colNum) == 0) {
            page ++;    // Increase the number of pages
            row = 0;    // the number of lines is 0
            column = 0; // the number of columns is 0
        }else if (i % colNum == 0) {
            // NewLine
            row += 1;   // Increase the number of lines
            column = 0; // The number of columns is 0
        }
        
        CGRect currentRect = CGRectMake(((page-1) * self.bounds.size.width) + (column * EmojiWidth),
                                        row * EmojiHeight+10,
                                        EmojiWidth,
                                        EmojiHeight);
        
        if (row == (rowNum - 1) && column == (colNum - 1)) {
            // last position of page, add delete button
            
        }else{
            NSString *emoji = self.emojis[emojiPointer++];
            
            // init Emoji Button
            UIButton *emojiButton = [UIButton buttonWithType:UIButtonTypeCustom];
            emojiButton.titleLabel.font = [UIFont fontWithName:@"Apple color emoji" size:EmojiFontSize];
            [emojiButton setTitle:emoji forState:UIControlStateNormal];
            [emojiButton addTarget:self action:@selector(emojiButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            emojiButton.frame = currentRect;
            [self.scrollView addSubview:emojiButton];
        }
        
        column++;
    }
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendBtn setTitle:getUDLocalizedString(@"发送") forState:UIControlStateNormal];
    sendBtn.frame = CGRectMake(UD_SCREEN_WIDTH-90, UD_SCREEN_WIDTH<375?150:166, 75, 38);;
    sendBtn.backgroundColor = UDRGBACOLOR(8, 125, 253, 1);
    UDViewRadius(sendBtn, 4);
    [sendBtn addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sendBtn];
    
    
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    deleteButton.frame = CGRectMake(sendBtn.frame.origin.x-50, UD_SCREEN_WIDTH<375?153:169, 36, 33);
    deleteButton.titleLabel.font = [UIFont systemFontOfSize:12];
    UIImage *deleteImage = [UIImage ud_defaultDeleteImage];
    UIImage *deleteImageh = [UIImage ud_defaultDeleteHighlightedImage];
    [deleteButton setBackgroundImage:deleteImage forState:UIControlStateNormal];
    [deleteButton setBackgroundImage:deleteImageh forState:UIControlStateHighlighted];
    deleteButton.tintColor = [UIColor blackColor];
    [self.scrollView addSubview:deleteButton];}

- (void)awakeFromNib {
    [self setup];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];

    }
    return self;
}
//点击表情
- (void)emojiButtonPressed:(UIButton *)button {
    
    // Add a simple scale animation
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.byValue = @0.3;
    animation.duration = 0.1;
    animation.autoreverses = YES;
    [button.layer addAnimation:animation forKey:nil];
    
    // Callback
    if ([self.delegate respondsToSelector:@selector(emojiViewDidSelectEmoji:)]) {
        [self.delegate emojiViewDidSelectEmoji:button.titleLabel.text];
    }
}

//删除按钮
- (void)deleteButtonPressed:(UIButton *)button{
    // Add a simple scale animation
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.toValue = @0.9;
    animation.duration = 0.1;
    animation.autoreverses = YES;
    [button.layer addAnimation:animation forKey:nil];
    
    // Callback
    if ([self.delegate respondsToSelector:@selector(emojiViewDidPressDeleteButton:)]) {
        [self.delegate emojiViewDidPressDeleteButton:button];
    }
}

//发送按钮
- (void)sendAction:(UIButton *)button {
    
    [self.delegate didEmotionViewSendAction];
    
}

@end
