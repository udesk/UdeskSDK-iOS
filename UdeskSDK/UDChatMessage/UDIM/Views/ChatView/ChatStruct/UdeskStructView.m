//
//  UdeskStructView.m
//  UdeskSDK
//
//  Created by 许晨 on 17/1/18.
//  Copyright © 2017年 xushichen. All rights reserved.
//

#import "UdeskStructView.h"

@interface UdeskActionButton : UIButton

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;

@end

@implementation UdeskActionButton

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    if (enabled == NO) [self setTitleColor:[UIColor colorWithRed:0.58 green:0.58 blue:0.58 alpha:1.00] forState:UIControlStateNormal];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state
{
    [self setBackgroundImage:[self imageWithColor:backgroundColor] forState:state];
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end

@interface UdeskStructScrollView : UIScrollView

@end

@implementation UdeskStructScrollView

- (void)drawRect:(CGRect)rect {

    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 1.0);
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:0.90 alpha:1].CGColor);
    CGContextMoveToPoint(ctx, 0, CGRectGetHeight(self.frame));
    CGContextAddLineToPoint(ctx, rect.size.width, CGRectGetHeight(self.frame));
    
    CGContextClosePath(ctx);
    CGContextStrokePath(ctx);
}

@end


@interface UdeskActionScrollView : UIScrollView

@end

@implementation UdeskActionScrollView

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    if ([view isKindOfClass:[UIButton class]]) return YES;
    return [super touchesShouldCancelInContentView:view];
}

@end

@interface UdeskStructAction ()

@property (nonatomic, copy) void(^structActionHandler)(UdeskStructAction *action);

@end

@implementation UdeskStructAction

+ (instancetype)actionWithTitle:(nullable NSString *)title handler:(void (^ __nullable)(UdeskStructAction *))handler
{
    UdeskStructAction *instance = [UdeskStructAction new];
    instance -> _title = title;
    instance.structActionHandler = handler;
    instance.enabled = YES; // 默认可用
    
    return instance;
}

@end

static CGRect contentViewRect;
static CGRect imageScrollViewRect;
static CGRect textScrollViewRect;
static CGRect menuScrollViewRect;

@interface UdeskStructView ()
{
    UIEdgeInsets _contentMargin; // 默认边距
    CGFloat _contentViewWidth; // 默认alertView宽度
    CGFloat _maxHeight; // alertView的最大高度
    CGFloat _buttonHeight; // 默认按钮高度
    CGFloat _maxMenuHeight; // 按钮选项的最大高度
    NSUInteger _count; //button数量
}

@property (nonatomic, strong) UdeskStructScrollView *imageScrollView;
@property (nonatomic, strong) UIScrollView *textScrollView;
@property (nonatomic, strong) UdeskActionScrollView *menuScrollView;
@property (nonatomic, strong) UIImageView *structImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLbel;

@end

@implementation UdeskStructView

- (instancetype)initWithImage:(nullable UIImage *)image
                        title:(nullable NSString *)title
                      message:(nullable NSString *)message
                      buttons:(nullable NSArray<UdeskStructAction *> *)buttons
                       origin:(CGPoint)origin
{
    self = [super init];
    if (self) {
        
        self.title = title;
        self.message = message;
        self.image = image;
        [self.mutableActions addObjectsFromArray:buttons];
        
        [self defaultConfig]; // 默认配置
        /** 创建按钮 */
        [self creatAllButtons];
        
        /** 设置imageScrollView的frame */
        [self configImageScrollViewFrame];
        
        /** 设置textScrollView的frame */
        [self configTextScrollViewFrame];
        
        /** 设置menuScrollView的frame */
        [self configMenuScrollViewFrame];
        
        /** 设置弹出框的frame */
        [self configContentViewFrame:origin];
    }
    return self;
}

#pragma mark -- 默认配置
- (void)defaultConfig
{
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 13;
    self.clipsToBounds = YES;
    
    _contentMargin = UIEdgeInsetsMake(15, 15, 15, 15);
    _maxHeight = CGRectGetHeight([[UIScreen mainScreen] bounds]) * 0.7;
    _contentViewWidth = 230;
    
    _buttonHeight = 45;
    _maxMenuHeight = _buttonHeight * 1.5;
    
    _count = 0;
}

#pragma mark -- 创建内部视图

- (void)creatAllButtons
{
    for (int i = 0; i < self.actions.count; i++) {
        UdeskActionButton *button = [UdeskActionButton buttonWithType:UIButtonTypeCustom];
        button.tag = 10 + i;
        [button setBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1] forState:UIControlStateHighlighted];
        button.titleLabel.font = [UIFont systemFontOfSize:17];
        [button setTitleColor:[UIColor colorWithRed:0.08 green:0.49 blue:0.98 alpha:1.00] forState:UIControlStateNormal];

        button.enabled = self.actions[i].enabled;
        [button setTitle:self.actions[i].title forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.menuScrollView addSubview:button];
        
        // 绘制横向分割线
        CALayer *border_hor = [CALayer layer];
        border_hor.frame = CGRectMake(0, 0, _contentViewWidth, 0.6);
        border_hor.backgroundColor = [UIColor colorWithWhite:0.90 alpha:1].CGColor;
        [button.layer addSublayer:border_hor];
    }
}

#pragma mark -- 设置内部控件frame

- (void)configImageScrollViewFrame
{
 
    @try {
        
        if (!self.image) {
            return;
        }
        
        //限定图片的最大直径
        CGFloat maxBubbleDiameter = ceil(_contentViewWidth / 2);  //限定图片的最大直径
        CGSize contentImageSize = self.image.size;
        
        //先限定图片宽度来计算高度
        CGFloat imageWidth = contentImageSize.width < maxBubbleDiameter ? contentImageSize.width : maxBubbleDiameter;
        CGFloat imageHeight = ceil(contentImageSize.height / contentImageSize.width * imageWidth);
        //判断如果气泡高度计算结果超过图片的最大直径，则限制高度
        if (imageHeight > maxBubbleDiameter) {
            imageHeight = maxBubbleDiameter;
            imageWidth = ceil(contentImageSize.width / contentImageSize.height * imageHeight);
        }
        
        self.structImageView.frame = CGRectMake((_contentViewWidth-imageWidth)/2, _contentMargin.top, imageWidth, imageHeight);
        self.imageScrollView.frame = CGRectMake(0, 0, _contentViewWidth, imageHeight+_contentMargin.top+_contentMargin.bottom);
        
        self.imageScrollView.contentSize = CGSizeMake(_contentViewWidth, imageHeight);
        
        // 绘制横向分割线
        CALayer *border_hor = [CALayer layer];
        CGFloat bottom = CGRectGetMaxY(self.structImageView.frame)+CGRectGetHeight(self.structImageView.frame);
        border_hor.frame = CGRectMake(0, bottom, _contentViewWidth, 0.6);
        border_hor.backgroundColor = [UIColor colorWithWhite:0.90 alpha:1].CGColor;
        [self.structImageView.layer addSublayer:border_hor];
        
        imageScrollViewRect = self.imageScrollView.frame;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)configTextScrollViewFrame
{
    
    @try {
        
        CGFloat textScrollY = CGRectGetMaxY(self.imageScrollView.frame);
        CGFloat messageY = _contentMargin.top;
        CGFloat menuHeight = [self getMenuHeight];
        CGFloat labelWidth = _contentViewWidth - _contentMargin.left - _contentMargin.right;
        CGFloat textHeight = (!self.title.length && !self.message.length) ? 0.0 : _contentMargin.top;
        
        if (self.title.length) {
            CGSize size = [self.titleLabel sizeThatFits:CGSizeMake(labelWidth, CGFLOAT_MAX)];
            self.titleLabel.frame = CGRectMake(_contentMargin.left, _contentMargin.top, labelWidth, size.height);
            messageY =  CGRectGetMaxY(self.titleLabel.frame) + _contentMargin.bottom;
            textHeight = CGRectGetMaxY(self.titleLabel.frame) + _contentMargin.bottom;
        }
        
        if (self.message.length) {
            CGSize size = [self.messageLbel sizeThatFits:CGSizeMake(labelWidth, CGFLOAT_MAX)];
            self.messageLbel.frame = CGRectMake(_contentMargin.left, messageY, labelWidth, size.height);
            textHeight = CGRectGetMaxY(self.messageLbel.frame) + _contentMargin.bottom;
        }
        
        if (textHeight + menuHeight + CGRectGetHeight(self.imageScrollView.frame) <= _maxHeight) {
            
            self.textScrollView.frame = CGRectMake(0, textScrollY, _contentViewWidth, textHeight);
        }else{
            self.textScrollView.frame = CGRectMake(0, textScrollY, _contentViewWidth, _maxHeight - menuHeight - CGRectGetHeight(self.imageScrollView.frame));
        }
        
        self.textScrollView.contentSize = CGSizeMake(_contentViewWidth, textHeight);
        
        textScrollViewRect = self.textScrollView.frame;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)configMenuScrollViewFrame
{
    @try {
        
        if (!self.actions.count) return;
        
        CGFloat firstButtonY = CGRectGetMaxY(self.textScrollView.frame);
        
        for (int i = 0; i < self.actions.count; i++) {
            UIButton *button = (UIButton *)[self.menuScrollView viewWithTag:10 + i];
            button.frame = CGRectMake(0, _buttonHeight * i, _contentViewWidth, _buttonHeight);
        }
        
        CGFloat buttonTotalHeight = _buttonHeight * self.actions.count;
        CGFloat menuHeight = buttonTotalHeight > (_maxHeight - firstButtonY) ? (_maxHeight - firstButtonY) : buttonTotalHeight;
        
        self.menuScrollView.frame = CGRectMake(0, firstButtonY, _contentViewWidth, menuHeight);
        self.menuScrollView.contentSize = CGSizeMake(_contentViewWidth, buttonTotalHeight);
        
        menuScrollViewRect = self.menuScrollView.frame;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)configContentViewFrame:(CGPoint)origin
{
    @try {
        
        CGFloat firstButtonY = CGRectGetMaxY(self.textScrollView.frame);
        
        CGRect rect = self.frame;
        rect.origin = origin;
        rect.size.width = _contentViewWidth;
        rect.size.height = firstButtonY + CGRectGetHeight(self.menuScrollView.frame);
        self.frame = rect;
        
        contentViewRect = self.frame;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (CGFloat)getMenuHeight
{
    CGFloat menuHeight;
    
    if (!self.actions.count) {
        menuHeight = 0;
    }else{
        menuHeight = _buttonHeight*self.actions.count;
    }
    
    return menuHeight;
}

#pragma mark -- 事件响应
- (void)buttonDidClick:(UIButton *)sender
{
    [self endEditing:YES];
    
    UdeskStructAction *action = self.actions[sender.tag - 10];
    if (action.structActionHandler) action.structActionHandler(action);
}

#pragma mark -- 方法实现
- (void)addAction:(UdeskStructAction *)action
{
    [self.mutableActions addObject:action];
}

- (NSArray<UdeskStructAction *> *)actions
{
    return [NSArray arrayWithArray:self.mutableActions];
}

- (NSMutableArray *)mutableActions
{
    if (!_mutableActions) {
        _mutableActions = [NSMutableArray array];
    }
    return _mutableActions;
}

- (UdeskStructScrollView *)imageScrollView {

    if (!_imageScrollView) {
        _imageScrollView = [UdeskStructScrollView new];
        _imageScrollView.backgroundColor = [UIColor clearColor];
        _imageScrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_imageScrollView];
    }
    return _imageScrollView;
}

- (UIScrollView *)textScrollView
{
    if (!_textScrollView) {
        _textScrollView = [UIScrollView new];
        _textScrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_textScrollView];
    }
    return _textScrollView;
}

- (UdeskActionScrollView *)menuScrollView
{
    if (!_menuScrollView) {
        _menuScrollView = [UdeskActionScrollView new];
        _menuScrollView.showsHorizontalScrollIndicator = NO;
        _menuScrollView.delaysContentTouches = NO;
        [self addSubview:_menuScrollView];
    }
    return _menuScrollView;
}

- (UIImageView *)structImageView {

    if (!_structImageView) {
        _structImageView = [UIImageView new];
        _structImageView.userInteractionEnabled = YES;
        _structImageView.image = self.image;
        [self.imageScrollView addSubview:_structImageView];
    }
    return _structImageView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.text = self.title;
        [self.textScrollView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)messageLbel
{
    if (!_messageLbel) {
        _messageLbel = [UILabel new];
        _messageLbel.numberOfLines = 0;
        _messageLbel.font = [UIFont systemFontOfSize:16];
        _messageLbel.textColor = [UIColor lightGrayColor];
        _messageLbel.text = self.message;
        [self.textScrollView addSubview:_messageLbel];
    }
    return _messageLbel;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    _titleLabel.text = title;
}

- (void)setMessage:(NSString *)message
{
    _message = message;
    
    _messageLbel.text = message;
}

- (void)setImage:(UIImage *)image {

    _image = image;
    
    _structImageView.image = image;
}

@end
