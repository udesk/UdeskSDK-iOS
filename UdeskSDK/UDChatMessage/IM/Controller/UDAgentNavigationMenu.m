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
#import "UdeskUtils.h"
#import "UDChatViewController.h"

@interface UDAgentNavigationMenu () <UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) UITableView    *agentMenuTableView;

@property (nonatomic, strong) UIScrollView   *agentMenuScrollView;

@property (nonatomic, strong) NSMutableArray *allAgentMenuData;

@property (nonatomic, assign) int      menuPage;

@end

@implementation UDAgentNavigationMenu

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        
        self.allAgentMenuData = [NSMutableArray array];
        
        self.menuPage = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:0.918f  green:0.922f  blue:0.925f alpha:1];
    
    [self setAgentMenuScrollView];
    
    [self setNavigationTitleName];
    
    [self setBackNavigationItem];
    
    [self requestAgentMenu];
}

#pragma mark - 设置标题
- (void)setNavigationTitleName {
    
    UILabel *menuLabel = [[UILabel alloc] initWithFrame:CGRectMake((UD_SCREEN_WIDTH-100)/2, 0, 100, 44)];
    menuLabel.text = getUDLocalizedString(@"请选择客服组");
    menuLabel.backgroundColor = [UIColor clearColor];
    menuLabel.textAlignment = NSTextAlignmentCenter;
    menuLabel.textColor = Config.faqTitleColor;
    self.navigationItem.titleView = menuLabel;
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

- (void)setAgentMenuScrollView {

    _agentMenuScrollView= [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _agentMenuScrollView.delegate = self;
    _agentMenuScrollView.showsHorizontalScrollIndicator = NO;
    _agentMenuScrollView.showsVerticalScrollIndicator = NO;
    _agentMenuScrollView.userInteractionEnabled = YES;
    _agentMenuScrollView.alwaysBounceHorizontal = NO;
    _agentMenuScrollView.pagingEnabled = YES;
    _agentMenuScrollView.scrollEnabled = NO;
    
    [self.view addSubview:_agentMenuScrollView];
}

- (void)closeButtonAction {
    
    self.menuPage --;
    
    if (self.agentMenuScrollView.contentOffset.x>0) {
        
        [UIView animateWithDuration:0.35f animations:^{
            
            _agentMenuScrollView.contentOffset = CGPointMake(self.agentMenuScrollView.contentOffset.x-UD_SCREEN_WIDTH, 0);
        } completion:^(BOOL finished) {
            
            NSMutableArray *array = [NSMutableArray array];
            
            UDAgentMenuModel *subMenuModel = self.agentMenuData.lastObject;
            
            NSString *parentId;
            
            for (UDAgentMenuModel *model in self.allAgentMenuData) {
                
                if ([model.menu_id isEqualToString:subMenuModel.parentId]) {
                    
                    parentId = model.parentId;
                    
                }
                
            }
            
            for (UDAgentMenuModel *model in self.allAgentMenuData) {
                
                if ([model.parentId isEqualToString:parentId]) {
                    
                    [array addObject:model];
                }
            }
            
            if (array.count > 0) {
                
                self.agentMenuData = array;
                
                UITableView *tableview = (UITableView *)[self.agentMenuScrollView viewWithTag:self.menuPage+100];
                
                [tableview reloadData];
            }
            else {
            
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
        
    }
    else {
    
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)requestAgentMenu {

    [UDManager getAgentNavigationMenu:^(id responseObject, NSError *error) {
        
        if ([[responseObject objectForKey:@"code"] integerValue] == 1000) {
            
            NSArray *result = [responseObject objectForKey:@"result"];
            
            for (NSDictionary *menuDict in result) {
 
                UDAgentMenuModel *agentMenuModel = [[UDAgentMenuModel alloc] initWithContentsOfDic:menuDict];
                
                [self.allAgentMenuData addObject:agentMenuModel];
                
            }
            
            NSMutableArray *rootMenuArray = [NSMutableArray array];
            
            int tableViewCount = 0;
            
            for (UDAgentMenuModel *agentMenuModel in self.allAgentMenuData) {
                
                if ([agentMenuModel.parentId isEqualToString:@"item_0"]) {
                    
                    [rootMenuArray addObject:agentMenuModel];
                }
                
                tableViewCount += [agentMenuModel.has_next intValue];
                
            }
            
            self.agentMenuScrollView.contentSize = CGSizeMake(tableViewCount*UD_SCREEN_WIDTH, UD_SCREEN_HEIGHT);
            
            for (int i = 0; i<tableViewCount;i++) {
                
                UITableView *agentMenuTableView = [[UITableView alloc] initWithFrame:CGRectMake(i*UD_SCREEN_WIDTH, 0, UD_SCREEN_WIDTH, UD_SCREEN_HEIGHT-64) style:UITableViewStyleGrouped];
                agentMenuTableView.delegate = self;
                agentMenuTableView.dataSource = self;
                agentMenuTableView.tag = 100+i;
                
                [self.agentMenuScrollView addSubview:agentMenuTableView];
                
            }
            
            self.agentMenuData = rootMenuArray;
            
            UITableView *tableview = (UITableView *)[self.agentMenuScrollView viewWithTag:100];
            
            [tableview reloadData];
        }
        
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (tableView.tag == self.menuPage+100) {
        
        return self.agentMenuData.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *agentMenuCellId = @"agentMenuCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:agentMenuCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:agentMenuCellId];
    }
    
    if (tableView.tag == self.menuPage+100) {
        
        UDAgentMenuModel *agentMenuModel = self.agentMenuData[indexPath.row];
        
        cell.textLabel.text = agentMenuModel.item_name;
        
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //取消点击效果
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.menuPage ++;
    
    NSMutableArray *menuArray = [NSMutableArray array];
    
    UDAgentMenuModel *didSelectModel = self.agentMenuData[indexPath.row];
    
    for (UDAgentMenuModel *allAgentMenuModel in self.allAgentMenuData) {
        
        if ([allAgentMenuModel.parentId isEqualToString:didSelectModel.menu_id]) {
            
            [menuArray addObject:allAgentMenuModel];
        }
        
    }
    
    if (menuArray.count > 0) {
        
        [UIView animateWithDuration:0.35f animations:^{
            
            self.agentMenuScrollView.contentOffset = CGPointMake(self.menuPage*UD_SCREEN_WIDTH, 0);
            
        } completion:^(BOOL finished) {
            
            self.agentMenuData = menuArray;
            
            UITableView *tableview = (UITableView *)[self.agentMenuScrollView viewWithTag:self.menuPage+100];
            
            [tableview reloadData];
            
        }];
        
    }
    else {
    
        UDChatViewController *chat = [[UDChatViewController alloc] init];
        
        chat.group_id = didSelectModel.group_id;
        
        chat.backBlock = ^(){
        
            self.menuPage --;
        };
        
        [self.navigationController pushViewController:chat animated:YES];
    }
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (ud_isIOS6) {
        self.navigationController.navigationBar.tintColor = Config.agentMenuNavigationColor;
    } else {
        self.navigationController.navigationBar.barTintColor = Config.agentMenuNavigationColor;
        self.navigationController.navigationBar.tintColor = Config.agentMenuBackButtonColor;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    
    if (ud_isIOS6) {
        self.navigationController.navigationBar.tintColor = Config.oneSelfNavcigtionColor;
    } else {
        self.navigationController.navigationBar.barTintColor = Config.oneSelfNavcigtionColor;
    }
    
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
