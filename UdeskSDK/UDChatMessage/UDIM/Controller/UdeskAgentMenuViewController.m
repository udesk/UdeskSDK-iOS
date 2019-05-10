//
//  UdeskAgentMenuViewController.m
//  UdeskSDK
//
//  Created by Udesk on 16/3/16.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskAgentMenuViewController.h"
#import "UdeskAgentMenuModel.h"
#import "UIView+UdeskSDK.h"
#import "UdeskSDKMacro.h"
#import "UdeskBundleUtils.h"
#import "UdeskChatViewController.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskStringSizeUtil.h"
#import "UdeskSDKUtil.h"
#import "UdeskSDKShow.h"

@interface UdeskAgentMenuViewController () <UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

/** 客服组菜单Tableview */
@property (nonatomic, strong) UITableView    *agentMenuTableView;
/** 客服组菜单ScrollView */
@property (nonatomic, strong) UIScrollView   *agentMenuScrollView;
/** agentMenuModel数组 */
@property (nonatomic, strong) NSMutableArray *allAgentMenuData;
/** 一级菜单数据 */
@property (nonatomic, strong) NSArray        *agentMenuData;
/** 客服组分页 */
@property (nonatomic, assign) int            menuPage;
/** 客服组路径名字 */
@property (nonatomic, strong) NSString       *pathString;

@end

@implementation UdeskAgentMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = self.sdkConfig.sdkStyle.tableViewBackGroundColor;
    
    if (self.sdkConfig.agentMenuTitle) {
        self.title = self.sdkConfig.agentMenuTitle;
    }
    else {
        self.title = getUDLocalizedString(@"udesk_choose_group");
    }
    
    [self setAgentMenuScrollView];
}

#pragma mark - 设置MenuScrollView
- (void)setAgentMenuScrollView {
    
    _agentMenuScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _agentMenuScrollView.udHeight -= [self getSpacing];
    _agentMenuScrollView.delegate = self;
    _agentMenuScrollView.showsHorizontalScrollIndicator = NO;
    _agentMenuScrollView.showsVerticalScrollIndicator = NO;
    _agentMenuScrollView.userInteractionEnabled = YES;
    _agentMenuScrollView.alwaysBounceHorizontal = NO;
    _agentMenuScrollView.pagingEnabled = YES;
    _agentMenuScrollView.scrollEnabled = NO;
    
    [self.view addSubview:_agentMenuScrollView];
}

- (CGFloat)getSpacing {
    
    CGFloat spacing = 0;
    if (udIsIPhoneXSeries) {
        spacing = 34;
    }
    
    return spacing;
}

#pragma mark - 请求客服组选择菜单
- (void)requestAgentMenu:(NSArray *)result {
    
    @try {
        
        for (NSDictionary *menuDict in result) {
            
            UdeskAgentMenuModel *agentMenuModel = [[UdeskAgentMenuModel alloc] initWithContentsOfDic:menuDict];
            [self.allAgentMenuData addObject:agentMenuModel];
        }
        
        NSMutableArray *rootMenuArray = [NSMutableArray array];
        
        int tableViewCount = 1;
        //寻找树状的根
        for (UdeskAgentMenuModel *agentMenuModel in self.allAgentMenuData) {
            
            if ([agentMenuModel.parentId isEqualToString:@"item_0"]) {
                [rootMenuArray addObject:agentMenuModel];
            }
            
            tableViewCount += [agentMenuModel.has_next intValue];
        }
        //根据最大的级数设置ScrollView.contentSize
        self.agentMenuScrollView.contentSize = CGSizeMake(tableViewCount*UD_SCREEN_WIDTH, UD_SCREEN_HEIGHT);
        
        //根据最大的级数循环添加tableView
        for (int i = 0; i<tableViewCount;i++) {
            
            UITableView *agentMenuTableView = [[UITableView alloc] initWithFrame:CGRectMake(i*UD_SCREEN_WIDTH, 0, UD_SCREEN_WIDTH, UD_SCREEN_HEIGHT-(udIsIPhoneXSeries ? 88 :64)) style:UITableViewStylePlain];
            agentMenuTableView.udHeight -= [self getSpacing];
            agentMenuTableView.delegate = self;
            agentMenuTableView.dataSource = self;
            agentMenuTableView.tag = 100+i;
            agentMenuTableView.backgroundColor = self.view.backgroundColor;
            agentMenuTableView.estimatedRowHeight = 44;
            [self.agentMenuScrollView addSubview:agentMenuTableView];
            
            //删除多余的cell
            UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
            [agentMenuTableView setTableFooterView:footerView];
        }
        //装载数据 刷新第一个tableView
        self.agentMenuData = rootMenuArray;
        
        UITableView *tableview = (UITableView *)[self.agentMenuScrollView viewWithTag:100];
        [tableview reloadData];
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }

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
        UdeskAgentMenuModel *agentMenuModel = self.agentMenuData[indexPath.row];
        cell.textLabel.text = agentMenuModel.item_name;
        cell.textLabel.numberOfLines = 0;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //取消点击效果
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    @try {
        
        if (indexPath.row>(self.agentMenuData.count-1)) {
            return;
        }
        
        NSMutableArray *menuArray = [NSMutableArray array];
        
        //获取点击菜单选项的子集
        UdeskAgentMenuModel *didSelectModel = self.agentMenuData[indexPath.row];
        
        if ([didSelectModel.group_id isKindOfClass:[NSNumber class]]) {
            didSelectModel.group_id = [NSString stringWithFormat:@"%@",didSelectModel.group_id];
        }
        
        if (didSelectModel.group_id.length > 0 && didSelectModel.group_id) {
            
            self.sdkConfig.groupId = didSelectModel.group_id;
            //存储
            [UdeskSDKUtil storeGroupId:didSelectModel.group_id];
            UdeskSDKShow *show = [[UdeskSDKShow alloc] initWithConfig:self.sdkConfig];
            UdeskChatViewController *chat = [[UdeskChatViewController alloc] initWithSDKConfig:self.sdkConfig setting:self.sdkSetting];
            [show presentOnViewController:self udeskViewController:chat transiteAnimation:UDTransiteAnimationTypePush completion:nil];
        }
        else {
            
            self.menuPage ++;
            for (UdeskAgentMenuModel *allAgentMenuModel in self.allAgentMenuData) {
                
                if ([allAgentMenuModel.parentId isEqualToString:didSelectModel.menu_id]) {
                    [menuArray addObject:allAgentMenuModel];
                }
            }
            //根据是否还有子集选择push还是执行动画
            if (menuArray.count > 0) {
                
                [UIView animateWithDuration:0.35f animations:^{
                    
                    self.agentMenuScrollView.contentOffset = CGPointMake(self.menuPage*UD_SCREEN_WIDTH, 0);
                    
                } completion:^(BOOL finished) {
                    
                    if ([UdeskSDKUtil isBlankString:self.pathString]) {
                        self.pathString = [NSString stringWithFormat:@"   %@",didSelectModel.item_name];
                    }
                    else {
                        self.pathString = [NSString stringWithFormat:@"%@ > ",self.pathString];
                        self.pathString = [self.pathString stringByAppendingString:didSelectModel.item_name];
                    }
                    
                    self.agentMenuData = menuArray;
                    
                    UITableView *tableview = (UITableView *)[self.agentMenuScrollView viewWithTag:self.menuPage+100];
                    [tableview reloadData];
                }];
            }
            else {
                
                //这里--是因为之前的++并没有执行给ScrollView.contentOffset
                self.menuPage -- ;
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    @try {
        
        if (self.menuPage) {
            
            UIButton *pathButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [pathButton setTitle:self.pathString forState:UIControlStateNormal];
            pathButton.frame = CGRectMake(0, 0, tableView.udWidth-0, 30);
            pathButton.titleLabel.numberOfLines = 0;
            pathButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [pathButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [pathButton addTarget:self action:@selector(pathBackButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            
            return pathButton;
        }
        else {
            
            return nil;
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    @try {
        
        if (self.menuPage) {
            
            CGSize pathSize = [UdeskStringSizeUtil textSize:self.pathString withFont:[UIFont systemFontOfSize:17] withSize:CGSizeMake(tableView.udWidth, CGFLOAT_MAX)];
            
            CGFloat otherH;
            if (pathSize.height==0) {
                otherH = 45;
            }
            else {
                otherH = 25;
            }
            
            return pathSize.height+otherH;
        }
        else {
            
            return 0;
        }
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)pathBackButtonAction:(UIButton *)button {
    
    @try {
        
        self.menuPage --;
        
        //判断ScrollView.contentOffset.x是否到头
        if (self.agentMenuScrollView.contentOffset.x>0) {
            
            [UIView animateWithDuration:0.35f animations:^{
                //执行返回
                self.agentMenuScrollView.contentOffset = CGPointMake(self.agentMenuScrollView.contentOffset.x-UD_SCREEN_WIDTH, 0);
            } completion:^(BOOL finished) {
                //装载这个页面的数据
                NSMutableArray *array = [NSMutableArray array];
                
                UdeskAgentMenuModel *subMenuModel = self.agentMenuData.lastObject;
                
                NSString *parentId;
                NSString *upString;
                //查找属于上级菜单的父级
                for (UdeskAgentMenuModel *model in self.allAgentMenuData) {
                    
                    if ([model.menu_id isEqualToString:subMenuModel.parentId]) {
                        
                        parentId = model.parentId;
                        
                        if ([model.parentId isEqualToString:@"item_0"]) {
                            upString = model.item_name;
                        }
                        else {
                            upString = [NSString stringWithFormat:@" > %@",model.item_name];
                        }
                    }
                }
                
                if (parentId) {
                    
                    //查找与上级菜单的父级同级的菜单选项
                    for (UdeskAgentMenuModel *model in self.allAgentMenuData) {
                        
                        if ([model.parentId isEqualToString:parentId]) {
                            [array addObject:model];
                        }
                    }
                }
                
                if (array.count > 0) {
                    
                    NSMutableString *mString = [NSMutableString stringWithString:self.pathString];
                    if (upString) {
                        [mString deleteCharactersInRange:[mString rangeOfString:upString]];
                    }
                    
                    self.pathString = mString;
                    //装载数据刷新指定tableview
                    self.agentMenuData = array;
                    
                    UITableView *tableview = (UITableView *)[self.agentMenuScrollView viewWithTag:self.menuPage+100];
                    [tableview reloadData];
                }
            }];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (NSMutableArray *)allAgentMenuData {

    if (!_allAgentMenuData) {
        _allAgentMenuData = [NSMutableArray array];
    }
    return _allAgentMenuData;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _agentMenuScrollView.frame = self.view.bounds;
    if (self.menuDataSource) {
        while (self.agentMenuScrollView.subviews.count) {
            [self.agentMenuScrollView.subviews.lastObject removeFromSuperview];
        }
        [self requestAgentMenu:self.menuDataSource];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
