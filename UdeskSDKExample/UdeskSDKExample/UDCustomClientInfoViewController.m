//
//  UDCustomClientInfoViewController.m
//  UdeskSDK
//
//  Created by xuchen on 16/8/29.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UDCustomClientInfoViewController.h"
#import "UdeskTransitioningAnimation.h"
#import "UIColor+UdeskSDK.h"
#import "UdeskManager.h"

@interface UDCustomClientInfoViewController() <UITextFieldDelegate>

@property (nonatomic, strong)NSArray *titleArray;
@property (nonatomic, strong)NSArray *contentArray;
@property (nonatomic, strong)NSMutableArray *textFieldArray;

@end

@implementation UDCustomClientInfoViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    self.title = @"自定义客户信息";
    
    _textFieldArray = [NSMutableArray array];
    
    _titleArray = @[@"姓名",@"邮箱",@"电话",@"描述"];
    _contentArray = @[@"请输入客户姓名",@"请输入客户邮箱",@"请输入客户电话",@"请输入客户描述"];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, 10.f)];
    footerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footerView;
    self.tableView.rowHeight = 60;
    UIScreenEdgePanGestureRecognizer *popRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePopRecognizer:)];
    popRecognizer.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:popRecognizer];
    
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    saveButton.frame = CGRectMake((self.view.frame.size.width-280)/2, self.view.frame.size.height-150, 280, 48);
    saveButton.backgroundColor = [UIColor colorWithHexString:@"#0093FF"];
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveClientInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveButton];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTableView)];
    [self.tableView addGestureRecognizer:tap];
}

- (void)tapTableView {

    [self.view endEditing:YES];
}

- (void)saveClientInfo {

    UdeskCustomer *customer = [UdeskCustomer new];
    
    for (UITextField *textField in self.textFieldArray) {
        
        switch (textField.tag) {
            case 0:
                if (textField.text.length > 0) {
                    customer.nickName = textField.text;
                }
                break;
            case 1:
                if (textField.text.length > 0) {
                    customer.email = textField.text;
                }
                break;
            case 2:
                if (textField.text.length > 0) {
                    customer.cellphone = textField.text;
                }
                break;
            case 3:
                if (textField.text.length > 0) {
                    customer.customerDescription = textField.text;
                }
                break;
                
            default:
                break;
        }
        
    }
    
    [UdeskManager updateCustomer:customer completion:nil];
    
    [self dismissChatViewController];

}

//滑动返回
- (void)handlePopRecognizer:(UIScreenEdgePanGestureRecognizer*)recognizer {
    
    CGPoint translation = [recognizer translationInView:self.view];
    CGFloat xPercent = translation.x / CGRectGetWidth(self.view.bounds) * 0.7;
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            [UdeskTransitioningAnimation setInteractive:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case UIGestureRecognizerStateChanged:
            [UdeskTransitioningAnimation updateInteractiveTransition:xPercent];
            break;
        default:
            if (xPercent < .25) {
                [UdeskTransitioningAnimation cancelInteractiveTransition];
            } else {
                [UdeskTransitioningAnimation finishInteractiveTransition];
            }
            [UdeskTransitioningAnimation setInteractive:NO];
            break;
    }
    
}
//点击返回
- (void)dismissChatViewController {
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.view.window.layer addAnimation:[UdeskTransitioningAnimation createDismissingTransiteAnimation:UDTransiteAnimationTypePush] forKey:nil];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *developerCellId = @"customCellId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:developerCellId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:developerCellId];
    }
    
    cell.textLabel.text = self.titleArray[indexPath.row];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(80, 0, self.view.frame.size.width-80, 60)];
    textField.placeholder = self.contentArray[indexPath.row];
    textField.clearButtonMode = UITextFieldViewModeAlways;
    textField.tag = indexPath.row;
    textField.delegate = self;
    [cell.contentView addSubview:textField];
    
    [self.textFieldArray addObject:textField];
    
    return cell;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldClear:(UITextField *)textField {
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

@end
