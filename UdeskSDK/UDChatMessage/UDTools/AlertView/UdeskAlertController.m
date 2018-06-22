//
//  UdeskAlertController.m
//  UdeskSDK
//
//  Created by 许晨 on 17/1/18.
//  Copyright © 2017年 bestdew. All rights reserved.
//

#import "UdeskAlertController.h"
#import "UDTTTAttributedLabel.h"
#import "UdeskOverlayTransitioningDelegate.h"

#define ActionDefaultColor [UIColor colorWithRed:0.08 green:0.49 blue:0.98 alpha:1.00]
#define ActionDestructiveColor [UIColor colorWithRed:0.99 green:0.26 blue:0.24 alpha:1.00]
#define ButtonDisableColor [UIColor colorWithRed:0.58 green:0.58 blue:0.58 alpha:1.00]
#define AlertControllerHeight CGRectGetHeight([[UIScreen mainScreen] bounds])

@interface ActionButton : UIButton

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;

@end

@implementation ActionButton

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    if (enabled == NO) [self setTitleColor:ButtonDisableColor forState:UIControlStateNormal];
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

@interface ActionScrollView : UIScrollView

@end

@implementation ActionScrollView

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    if ([view isKindOfClass:[UIButton class]]) return YES;
    return [super touchesShouldCancelInContentView:view];
}

@end

@interface UdeskAlertAction ()

@property (nonatomic, copy) void(^alertActionHandler)(UdeskAlertAction *action);

@end

@implementation UdeskAlertAction

+ (instancetype)actionWithTitle:(nullable NSString *)title style:(UDAlertActionStyle)style handler:(void (^ __nullable)(UdeskAlertAction *))handler
{
    UdeskAlertAction *instance = [[UdeskAlertAction alloc] init];
    instance -> _title = title;
    instance -> _udStyle = style;
    instance.alertActionHandler = handler;
    instance.enabled = YES; // 默认可用
    
    return instance;
}

@end

static CGRect contentViewRect;
static CGRect textScrollViewRect;
static CGRect menuScrollViewRect;

@interface UdeskAlertController ()<UDTTTAttributedLabelDelegate>
{
    UIView *_contentView;
    
    UIEdgeInsets _contentMargin; // 默认边距
    CGFloat _contentViewWidth; // 默认alertView宽度
    CGFloat _maxHeight; // alertView的最大高度
    CGFloat _buttonHeight; // 默认按钮高度
    CGFloat _maxMenuHeight; // 按钮选项的最大高度
    CGFloat _textFieldHeight; // 默认输入框高度
    CGFloat _textFieldMargin; // 输入框之间的间距
    
    BOOL _firstDisplay;
    NSUInteger _count; // style == ZKAlertActionStyleCancel的action的数量
    
    UdeskOverlayTransitioningDelegate *_transitioningDelegate;
}

@property (nonatomic, strong) UIScrollView *textScrollView;
@property (nonatomic, strong) ActionScrollView *menuScrollView;
@property (nonatomic, strong) UILabel *titleLabel;
//@property (nonatomic, strong) UILabel *messageLbel;
@property (nonatomic, strong) UDTTTAttributedLabel *messageLbel;
@property (nonatomic, strong) NSMutableArray *mutableActions;
@property (nonatomic, strong) NSMutableArray *mutableTextFields;

@end

@implementation UdeskAlertController

#pragma mark -- 初始化
+ (instancetype)alertControllerWithTitle:(nullable NSString *)title attributedMessage:(nullable NSAttributedString *)attributedMessage preferredStyle:(UDAlertControllerStyle)preferredStyle
{
    UdeskAlertController *instance = [[UdeskAlertController alloc] init];
    
    instance.title = title;
    instance.attributedMessage = attributedMessage;
    instance -> _preferredStyle = preferredStyle;
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self defaultConfig]; // 默认配置
    }
    return self;
}

#pragma mark -- life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    
    NSAssert(self.title.length || self.attributedMessage.length || self.actions.count || self.textFields.count, @"ZKAlertController must have a title, a message or an action to display");
    
    /** 调整actions元素顺序 */
    [self adjustIndexesforActions];
    
    /** 创建基础视图 */
    [self creatContentView];
    
    /** 创建按钮 */
    [self creatAllButtons];
    
    /** 设置textScrollView的frame */
    [self configTextScrollViewFrame];
    
    /** 设置menuScrollView的frame */
    [self configMenuScrollViewFrame];
    
    /** 设置弹出框的frame */
    [self configContentViewFrame];
    
    /** 添加通知 */
    [self addNotification];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    /** 显示弹出动画 */
    [self showAppearAnimation];
}

#pragma mark -- 默认配置
- (void)defaultConfig
{
    _contentMargin = UIEdgeInsetsMake(20, 15, 15, 15);
    _maxHeight = AlertControllerHeight * 0.7;
    _contentViewWidth = 285;
    
    _buttonHeight = 45;
    _maxMenuHeight = _buttonHeight * 1.5;
    
    _textFieldHeight = 30;
    _textFieldMargin = 5;
    
    _messageAlignment = NSTextAlignmentCenter;
    _firstDisplay = YES;
    _count = 0;
    
    CGFloat systemVersion = [[[UIDevice currentDevice]systemVersion] floatValue];
    if (systemVersion >= 7.0 && systemVersion < 8.0) {
        _transitioningDelegate = [[UdeskOverlayTransitioningDelegate alloc] init];
        self.transitioningDelegate = _transitioningDelegate;
    }
}

- (void)adjustIndexesforActions
{
    // 当只有两个action时，style == ZKAlertActionStyleCancel的action始终居左显示
    if (self.mutableActions.count == 2) {
        [self.mutableActions enumerateObjectsUsingBlock:^(UdeskAlertAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.udStyle == UDAlertActionStyleCancel) {
                [self.mutableActions exchangeObjectAtIndex:idx withObjectAtIndex:0];
            }
        }];
    }
    
    // 当多于两个action时，style == ZKAlertActionStyleCancel的action始终居下显示
    if (self.mutableActions.count > 2) {
        [self.mutableActions enumerateObjectsUsingBlock:^(UdeskAlertAction *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.udStyle == UDAlertActionStyleCancel) {
                [self.mutableActions removeObject:obj];
                [self.mutableActions addObject:obj];
            }
        }];
    }
}

#pragma mark -- 创建内部视图
- (void)creatContentView
{
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [UIColor whiteColor];
    _contentView.layer.cornerRadius = 13;
    _contentView.clipsToBounds = YES;
    [self.view addSubview:_contentView];
}

- (void)creatAllButtons
{
    for (int i = 0; i < self.actions.count; i++) {
        ActionButton *button = [ActionButton buttonWithType:UIButtonTypeCustom];
        button.tag = 10 + i;
        [button setBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1] forState:UIControlStateHighlighted];
        switch (self.actions[i].udStyle) {
            case UDAlertActionStyleDefault:
                
                button.titleLabel.font = [UIFont systemFontOfSize:17];
                [button setTitleColor:ActionDefaultColor forState:UIControlStateNormal];
                
                break;
                
            case UDAlertActionStyleCancel:
                
                button.titleLabel.font = [UIFont boldSystemFontOfSize:17];
                [button setTitleColor:ActionDefaultColor forState:UIControlStateNormal];
                
                break;
                
            case UDAlertActionStyleDestructive:
                
                button.titleLabel.font = [UIFont systemFontOfSize:17];
                [button setTitleColor:ActionDestructiveColor forState:UIControlStateNormal];
                
                break;
                
            default:
                break;
        }
        button.enabled = self.actions[i].enabled;
        [button setTitle:self.actions[i].title forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.menuScrollView addSubview:button];
        
        // 绘制横向分割线
        CGFloat lineWidth = self.actions.count > 2 ? _contentViewWidth : _contentViewWidth / self.actions.count;
        CALayer *border_hor = [CALayer layer];
        border_hor.frame = CGRectMake(0, 0, lineWidth, 0.6);
        border_hor.backgroundColor = [UIColor colorWithWhite:0.90 alpha:1].CGColor;
        [button.layer addSublayer:border_hor];
        
        // 当有两个按钮时，绘制竖向分割线
        if (self.actions.count == 2 && i == 1) {
            CALayer *border_ver = [CALayer layer];
            border_ver.frame = CGRectMake(0, 0, 0.6, _buttonHeight - 0.6);
            border_ver.backgroundColor = [UIColor colorWithWhite:0.90 alpha:1].CGColor;
            [button.layer addSublayer:border_ver];
        }
    }
}

#pragma mark -- 设置内部控件frame
- (void)configTextScrollViewFrame
{
    
    CGFloat messageY = _contentMargin.top;
    CGFloat menuHeight = [self getMenuHeight];
    CGFloat labelWidth = _contentViewWidth - _contentMargin.left - _contentMargin.right;
    CGFloat textHeight = (!self.title.length && !self.attributedMessage.length && !self.textFields.count) ? 0.0 : _contentMargin.top;
    
    if (self.title.length) {
        CGSize size = [self.titleLabel sizeThatFits:CGSizeMake(labelWidth, CGFLOAT_MAX)];
        self.titleLabel.frame = CGRectMake(_contentMargin.left, _contentMargin.top, labelWidth, size.height);
        messageY =  CGRectGetMaxY(self.titleLabel.frame) + _contentMargin.bottom;
        textHeight = CGRectGetMaxY(self.titleLabel.frame) + _contentMargin.bottom;
    }
    
    if (self.attributedMessage.length) {
        CGSize size = [self.messageLbel sizeThatFits:CGSizeMake(labelWidth, CGFLOAT_MAX)];
        self.messageLbel.frame = CGRectMake(_contentMargin.left, messageY, labelWidth, size.height);
        textHeight = CGRectGetMaxY(self.messageLbel.frame) + _contentMargin.bottom;
    }
    
    for (int i = 0; i < self.textFields.count; i++) {
        UITextField *textField = (UITextField *)self.textFields[i];
        textField.frame = CGRectMake(_contentMargin.left, textHeight + (_textFieldHeight + 5) * i, labelWidth, _textFieldHeight);
        [self.textScrollView addSubview:textField];
        if (i == self.textFields.count - 1) textHeight = CGRectGetMaxY(textField.frame) + _contentMargin.bottom;
    }
    
    if (textHeight + menuHeight <= _maxHeight) {
        
        self.textScrollView.frame = CGRectMake(0, 0, _contentViewWidth, textHeight);
    }else{
        
        self.textScrollView.frame = CGRectMake(0, 0, _contentViewWidth, _maxHeight - menuHeight);
    }
    
    self.textScrollView.contentSize = CGSizeMake(_contentViewWidth, textHeight);
    
    textScrollViewRect = self.textScrollView.frame;
    
    
    
}

- (void)configMenuScrollViewFrame
{
    if (!self.actions.count) return;
    
    CGFloat firstButtonY = CGRectGetMaxY(self.textScrollView.frame);
    CGFloat buttonWidth = self.actions.count > 2 ? _contentViewWidth : _contentViewWidth / self.actions.count;
    
    for (int i = 0; i < self.actions.count; i++) {
        UIButton *button = (UIButton *)[self.menuScrollView viewWithTag:10 + i];
        CGFloat buttonX = self.actions.count > 2 ? 0 : buttonWidth * i;
        CGFloat buttonY = self.actions.count > 2 ? _buttonHeight * i : 0;
        button.frame = CGRectMake(buttonX, buttonY, buttonWidth, _buttonHeight);
    }
    
    CGFloat buttonTotalHeight = self.actions.count == 2 ? _buttonHeight : _buttonHeight * self.actions.count;
    CGFloat menuHeight = buttonTotalHeight > (_maxHeight - firstButtonY) ? (_maxHeight - firstButtonY) : buttonTotalHeight;
    
    self.menuScrollView.frame = CGRectMake(0, firstButtonY, _contentViewWidth, menuHeight);
    self.menuScrollView.contentSize = CGSizeMake(_contentViewWidth, buttonTotalHeight);
    
    menuScrollViewRect = self.menuScrollView.frame;
}

- (void)configContentViewFrame
{
    CGFloat firstButtonY = CGRectGetMaxY(self.textScrollView.frame);
    
    CGRect rect = _contentView.frame;
    rect.size.width = _contentViewWidth;
    rect.size.height = firstButtonY + CGRectGetHeight(self.menuScrollView.frame);
    _contentView.frame = rect;
    _contentView.center = self.view.center;
    
    contentViewRect = _contentView.frame;
}

- (CGFloat)getMenuHeight
{
    CGFloat menuHeight;
    
    if (!self.actions.count) {
        menuHeight = 0;
    }else if (self.actions.count < 3) {
        menuHeight = _buttonHeight;
    }else{
        menuHeight = _maxMenuHeight;
    }
    
    return menuHeight;
}

#pragma mark -- 事件响应
- (void)buttonDidClick:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    if (self.actions.count > (sender.tag - 10)) {
        
        UdeskAlertAction *action = self.actions[sender.tag - 10];
        if (action) {
            [self showDisappearAnimation:^{
                if (action.alertActionHandler) action.alertActionHandler(action);
            }];
        }
    }
}

- (void)showAppearAnimation
{
    if (!_firstDisplay) return;
    
    _firstDisplay = NO;
    _contentView.transform = CGAffineTransformMakeScale(1.1, 1.1);
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.55 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _contentView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)showDisappearAnimation:(void(^)(void))completion
{
    [self dismissViewControllerAnimated:YES completion:completion];
}

#pragma mark -- 方法实现
- (void)addAction:(UdeskAlertAction *)action
{
    if (action.udStyle == UDAlertActionStyleCancel) _count ++;
    
    NSAssert(_count < 2, @"ZKAlertController can only have one action with a style of ZKAlertActionStyleCancel");
    
    [self.mutableActions addObject:action];
}

- (void)addTextFieldWithConfigurationHandler:(void (^ __nullable)(UITextField *))configurationHandler
{
    UITextField *textField = [[UITextField alloc] init];
    textField.font = [UIFont systemFontOfSize:15];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    
    [self.mutableTextFields addObject:textField];
    
    if (configurationHandler) {
        configurationHandler(textField);
    }
}

#pragma mark -- 添加键盘通知
- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardNotify:) name:UIKeyboardWillShowNotification object:nil];
}

#pragma mark -- 键盘通知接收处理
- (void)keyboardNotify:(NSNotification *)notify
{
    NSValue *frameNum = [notify.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect rect = frameNum.CGRectValue;
    CGFloat keyboardHeight = rect.size.height + 5; // 键盘高度 + 5
    CGFloat keyboardMinY = rect.origin.y - 5; // 键盘y坐标 - 5
    
    CGFloat duration = [[notify.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]; // 获取键盘动画持续时间
    NSInteger curve = [[notify.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue]; // 获取动画曲线
    
    CGFloat marginBottom = AlertControllerHeight - CGRectGetMaxY(_contentView.frame);
    if (marginBottom >= keyboardHeight) return;
    
    CGFloat availableHeight = AlertControllerHeight * 0.95 - keyboardHeight;
    CGFloat alertViewMinX = CGRectGetMinX(contentViewRect);
    CGFloat alertViewWidth = CGRectGetWidth(contentViewRect);
    CGFloat alertViewHeight = CGRectGetHeight(contentViewRect);
    
    if (alertViewHeight <= availableHeight) {
        
        CGFloat alertViewMinY = keyboardMinY - alertViewHeight;
        
        [UIView animateWithDuration:duration delay:0 options:curve animations:^{
            
            _contentView.frame = CGRectMake(alertViewMinX, alertViewMinY, alertViewWidth, alertViewHeight);
            
        } completion:nil];
        
    }else{
        
        CGFloat difference = keyboardHeight - (AlertControllerHeight * 0.95 - alertViewHeight);
        
        alertViewHeight -= difference;
        CGFloat alertViewMinY = AlertControllerHeight * 0.05;
        
        CGFloat textScrollViewMinX = CGRectGetMinX(textScrollViewRect);
        CGFloat textScrollViewMinY = CGRectGetMinY(textScrollViewRect);
        CGFloat textScrollViewWidth = CGRectGetWidth(textScrollViewRect);
        
        CGFloat menuScrollViewMinX = CGRectGetMinX(menuScrollViewRect);
        CGFloat menuScrollViewWidth = CGRectGetWidth(menuScrollViewRect);
        CGFloat menuMinHeight = CGRectGetHeight(menuScrollViewRect) < _maxMenuHeight ? CGRectGetHeight(menuScrollViewRect) : _maxMenuHeight;
        
        CGFloat menuMaxOffset = CGRectGetHeight(menuScrollViewRect) - menuMinHeight;
        CGFloat textScrollViewOffset = difference > menuMaxOffset ? difference - menuMaxOffset : 0;
        CGFloat textScrollViewHeight = CGRectGetHeight(textScrollViewRect) - textScrollViewOffset;
        CGFloat menuScrollViewMinY = CGRectGetMinY(menuScrollViewRect) - textScrollViewOffset;
        CGFloat menuScrollViewHeight = difference > menuMaxOffset ? menuMinHeight : CGRectGetHeight(menuScrollViewRect) - difference;
        
        [UIView animateWithDuration:duration delay:0 options:curve animations:^{
            
            _textScrollView.frame = CGRectMake(textScrollViewMinX, textScrollViewMinY, textScrollViewWidth, textScrollViewHeight);
            _menuScrollView.frame = CGRectMake(menuScrollViewMinX, menuScrollViewMinY, menuScrollViewWidth, menuScrollViewHeight);
            _contentView.frame = CGRectMake(alertViewMinX, alertViewMinY, alertViewWidth, alertViewHeight);
            
        } completion:nil];
    }
}

#pragma mark -- setter & getter
- (NSString *)title
{
    return [super title];
}

- (NSArray<UdeskAlertAction *> *)actions
{
    return [NSArray arrayWithArray:self.mutableActions];
}

- (NSArray<UITextField *> *)textFields
{
    return [NSArray arrayWithArray:self.mutableTextFields];
}

- (NSMutableArray *)mutableActions
{
    if (!_mutableActions) {
        _mutableActions = [NSMutableArray array];
    }
    return _mutableActions;
}

- (NSMutableArray *)mutableTextFields
{
    if (!_mutableTextFields) {
        _mutableTextFields = [NSMutableArray array];
    }
    return _mutableTextFields;
}

- (UIScrollView *)textScrollView
{
    if (!_textScrollView) {
        _textScrollView = [[UIScrollView alloc] init];
        _textScrollView.showsHorizontalScrollIndicator = NO;
        [_contentView addSubview:_textScrollView];
    }
    return _textScrollView;
}

- (ActionScrollView *)menuScrollView
{
    if (!_menuScrollView) {
        _menuScrollView = [[ActionScrollView alloc] init];
        _menuScrollView.showsHorizontalScrollIndicator = NO;
        _menuScrollView.delaysContentTouches = NO;
        [_contentView addSubview:_menuScrollView];
    }
    return _menuScrollView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont boldSystemFontOfSize:17];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.text = self.title;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.textScrollView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UDTTTAttributedLabel *)messageLbel
{
    if (!_messageLbel) {
        _messageLbel = [[UDTTTAttributedLabel alloc] initWithFrame:CGRectZero];
        _messageLbel.numberOfLines = 0;
        _messageLbel.delegate = self;
        _messageLbel.font = [UIFont boldSystemFontOfSize:16];
        _messageLbel.textAlignment = self.messageAlignment;
        _messageLbel.userInteractionEnabled = true;
        _messageLbel.backgroundColor = [UIColor clearColor];
        NSMutableAttributedString *mAttributedMsg = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedMessage];
        @try {
            [mAttributedMsg addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:NSMakeRange(0, self.attributedMessage.length)];
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
        _messageLbel.text = mAttributedMsg;
        [self.textScrollView addSubview:_messageLbel];
    }
    return _messageLbel;
}

- (void)attributedLabel:(UDTTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    
    if ([url.absoluteString rangeOfString:@"://"].location == NSNotFound) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", url.absoluteString]]];
    } else {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    
    _titleLabel.text = title;
}

- (void)setAttributedMessage:(NSAttributedString *)attributedMessage {
    _attributedMessage = attributedMessage;
    _messageLbel.text = attributedMessage;
}

- (void)setMessageAlignment:(NSTextAlignment)messageAlignment
{
    _messageAlignment = messageAlignment;
    
    _messageLbel.textAlignment = messageAlignment;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
