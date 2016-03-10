//
//  UDSearchController.m
//  UdeskSDK
//
//  Created by xuchen on 15/11/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import "UDSearchController.h"
#import "UDProblemModel.h"
#import "UDContentController.h"
#import "UDChatViewController.h"
#import "UdeskUtils.h"
#import "UDFoundationMacro.h"
#import "UDManager.h"

@interface UDSearchController()<UISearchDisplayDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>


@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIViewController *searchContentsController;

@end

@implementation UDSearchController


- (instancetype)initWithSearchBar:(UISearchBar *)searchBar contentsController:(UIViewController *)viewController
{
    self = [super init];
    if (self) {
        
        [searchBar setPlaceholder:getUDLocalizedString(@"搜索")];
        
        searchBar.tintColor = Config.searchCancleButtonColor;
        
        UIButton *contactUs = [UIButton buttonWithType:UIButtonTypeCustom];
        contactUs.frame = CGRectMake((UD_SCREEN_WIDTH-250)/2, 50, 250, 40);
        [contactUs setTitleColor:Config.searchContactUsColor forState:0];
        [contactUs setTitle:getUDLocalizedString(@"联系我们") forState:0];
        [contactUs addTarget:self action:@selector(contactUsButton) forControlEvents:UIControlEventTouchUpInside];
        
        [contactUs.layer setMasksToBounds:YES];
        [contactUs.layer setCornerRadius:5.0]; //设置矩圆角半径
        [contactUs.layer setBorderWidth:1.5];   //边框宽度
        contactUs.titleLabel.font = [UIFont systemFontOfSize:19];
        [contactUs.layer setBorderColor:(Config.contactUsBorderColor).CGColor];//边框颜色
        
        
        UILabel *notFound = [[UILabel alloc] initWithFrame:CGRectMake((UD_SCREEN_WIDTH-230)/2, 0, 230, contactUs.frame.origin.y)];
        notFound.textAlignment = NSTextAlignmentCenter;
        notFound.font = [UIFont systemFontOfSize:17];
        notFound.textColor = Config.promptTextColor;
        notFound.text = getUDLocalizedString(@"无法找到你搜索的内容吗?");
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UD_SCREEN_WIDTH, UD_SCREEN_HEIGHT-69)];
        [view insertSubview:notFound aboveSubview:view];
        [view insertSubview:contactUs aboveSubview:view];
        
        _searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar
                                                                     contentsController:viewController];
        _searchDisplayController.delegate = self;
        _searchDisplayController.searchResultsDataSource = self;
        _searchDisplayController.searchResultsDelegate = self;
        _searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _searchDisplayController.searchResultsTableView.tableFooterView = view;
        _searchDisplayController.searchBar.delegate = self;
        
        viewController.navigationController.view.backgroundColor = UDRGBCOLOR(201, 201, 206);
        
    }
    return self;
}

- (void)contactUsButton {
    
    UDChatViewController *UdeskIM = [[UDChatViewController alloc] init];

    [self.searchContentsController.navigationController pushViewController:UdeskIM animated:YES];
    
}

//隐藏搜索无结果字样
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString

{
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.001);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        for (UIView * subview in self.searchDisplayController.searchResultsTableView.subviews) {
            if ([subview isKindOfClass: [UILabel class]])
            {
                subview.hidden = YES;
            }
        }
    });
    
    return YES;
    
}

- (UISearchBar *)searchBar
{
    return self.searchDisplayController.searchBar;
}

- (UIViewController *)searchContentsController
{
    return self.searchDisplayController.searchContentsController;
}


#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return _searchData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"searchID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    UDProblemModel *model = _searchData[indexPath.row];
    cell.textLabel.text = model.subject;
    return cell;
}

#pragma mark UITableViewDataDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //取消点击效果
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UDContentController *content = [[UDContentController alloc] init];
    UDProblemModel *model = _searchData[indexPath.row];
    content.Article_Id = model.Article_Id;
    content.ArticlesTitle = model.subject;
    
    [self.searchContentsController.navigationController pushViewController:content animated:YES];
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}

#pragma mark - UISearchBarDelegate


//搜索按钮
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    // TODO: 隐藏tabbar
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{

    [self initProblemLoad:searchText];
}

//加载数据
- (void)initProblemLoad:(NSString *)searchText {
    
    [UDManager searchFaqArticles:searchText completion:^(id responseObject, NSError *error) {
        
        if (!error) {
            
            NSMutableArray *muArray = [NSMutableArray array];
            NSArray *contents = [responseObject objectForKey:@"contents"];
            for (NSDictionary *dic in contents) {
                UDProblemModel *model = [[UDProblemModel alloc] initWithContentsOfDic:dic];
                
                [muArray addObject:model];
            }
            
            if (contents == nil) {
                self.searchData = nil;
            }else {
                self.searchData = [muArray arrayByAddingObjectsFromArray:self.searchData];
            }
            
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
    }];
   
}

@end
