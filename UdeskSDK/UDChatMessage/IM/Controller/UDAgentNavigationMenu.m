//
//  UDAgentNavigationMenu.m
//  UdeskSDKExample
//
//  Created by xuchen on 16/3/16.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UDAgentNavigationMenu.h"
#import "UDAgentMenuModel.h"
#import "UDViewExt.h"
#import "UDFoundationMacro.h"

@interface UDAgentNavigationMenu () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *agentMenuTableView;

@end

@implementation UDAgentNavigationMenu

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"请选择客服组";
    
    self.view.backgroundColor = [UIColor colorWithRed:0.918f  green:0.922f  blue:0.925f alpha:1];
    
    [self setBackNavigationItem];
    
    [self setAgentMentTableView];
    
    [self requestAgentMenu];
}


- (void)setBackNavigationItem {
    //取消按钮
    UIButton * closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(0, 0, 40, 40);
    [closeButton setTitle:@"返回" forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *closeNavigationItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    
    // 调整 leftBarButtonItem 在 iOS7 下面的位置
    if((FUDSystemVersion>=7.0)){
        
        negativeSpacer.width = -10;
        self.navigationItem.leftBarButtonItems = @[negativeSpacer,closeNavigationItem];
    }else
        self.navigationItem.leftBarButtonItem = closeNavigationItem;
    
}

- (void)closeButtonAction {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setAgentMentTableView {

    _agentMenuTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _agentMenuTableView.delegate = self;
    _agentMenuTableView.dataSource = self;

    [self.view addSubview:_agentMenuTableView];
}

- (void)requestAgentMenu {

    [UDManager getAgentNavigationMenu:^(id responseObject, NSError *error) {
        
        NSMutableArray *menuMutableArray = [NSMutableArray array];
        
        if ([[responseObject objectForKey:@"code"] integerValue] == 1000) {
            
            NSArray *result = [responseObject objectForKey:@"result"];
            
            for (NSDictionary *menuDict in result) {

                UDAgentMenuModel *agentMenuModel = [[UDAgentMenuModel alloc] initWithContentsOfDic:menuDict];
                
                [menuMutableArray addObject:agentMenuModel];
                
            }
            
            self.agentMenuData = menuMutableArray;
            
            [self.agentMenuTableView reloadData];
        }
        
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.agentMenuData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *agentMenuCellId = @"agentMenuCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:agentMenuCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:agentMenuCellId];
    }
    
    UDAgentMenuModel *agentMenuModel = self.agentMenuData[indexPath.row];
    
    if ([agentMenuModel.parentId isEqualToString:@"item_0"]) {
        
        cell.textLabel.text = agentMenuModel.item_name;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //取消点击效果
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    [UIView animateWithDuration:0.35f animations:^{
        
        self.agentMenuTableView.ud_right = 0;
        
    }];
    
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
