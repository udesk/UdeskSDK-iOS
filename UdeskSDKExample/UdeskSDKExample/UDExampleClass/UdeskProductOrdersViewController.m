//
//  UdeskProductOrdersViewController.m
//  UdeskSDK
//
//  Created by xuchen on 2018/3/24.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskProductOrdersViewController.h"
#import "UdeskGoodsMessageTestViewController.h"

@interface UdeskProductOrdersViewController ()

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation UdeskProductOrdersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"API测试";
    self.dataSource = @[@"发送文本订单信息",@"发送图片订单信息",@"发送GIF订单信息",@"发送语音订单信息",@"发送视频订单信息",@"发送地理位置订单信息",@"发送商品信息"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(dismissViewController)];
}

- (void)dismissViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.dataSource[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row == self.dataSource.count - 1) {
        UdeskGoodsMessageTestViewController *goods = [[UdeskGoodsMessageTestViewController alloc] init];
        [self.navigationController pushViewController:goods animated:YES];
        goods.doneEditGoodsMessageBlock = ^(UdeskGoodsModel *model){
            if (self.didSendOrderBlock) {
                self.didSendOrderBlock(indexPath.row,model);
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        };
        return;
    }
    
    if (self.didSendOrderBlock) {
        self.didSendOrderBlock(indexPath.row,nil);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
