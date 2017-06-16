//
//  UdeskSearchController.m
//  UdeskSDK
//
//  Created by Udesk on 15/11/26.
//  Copyright (c) 2015年 Udesk. All rights reserved.
//

#import "UdeskSearchController.h"
#import "UdeskProblemModel.h"
#import "UdeskContentController.h"
#import "UdeskChatViewController.h"
#import "UdeskUtils.h"
#import "UdeskFoundationMacro.h"
#import "UdeskManager.h"
#import "UdeskViewExt.h"
#import "UdeskSDKConfig.h"
#import "UdeskSDKShow.h"

@interface UdeskSearchController()<UISearchDisplayDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>


@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIViewController *searchContentsController;

@end

@implementation UdeskSearchController


- (instancetype)initWithSearchBar:(UISearchBar *)searchBar contentsController:(UIViewController *)viewController
{
    self = [super init];
    if (self) {

        @try {
            
            self.searchContentsController = viewController;
            
            [searchBar setPlaceholder:getUDLocalizedString(@"udesk_faq_search")];
            
            searchBar.tintColor = [UdeskSDKConfig sharedConfig].sdkStyle.searchCancleButtonColor;
            
            UIButton *contactUs = [UIButton buttonWithType:UIButtonTypeCustom];
            contactUs.frame = CGRectMake((UD_SCREEN_WIDTH-250)/2, 50, 250, 40);
            [contactUs setTitleColor:[UdeskSDKConfig sharedConfig].sdkStyle.searchContactUsColor forState:0];
            [contactUs setTitle:getUDLocalizedString(@"udesk_faq_Contactus") forState:0];
            [contactUs addTarget:self action:@selector(contactUsButton) forControlEvents:UIControlEventTouchUpInside];
            
            [contactUs.layer setMasksToBounds:YES];
            [contactUs.layer setCornerRadius:5.0]; //设置矩圆角半径
            [contactUs.layer setBorderWidth:1.5];   //边框宽度
            contactUs.titleLabel.font = [UIFont systemFontOfSize:19];
            [contactUs.layer setBorderColor:([UdeskSDKConfig sharedConfig].sdkStyle.contactUsBorderColor).CGColor];//边框颜色
            
            
            UILabel *notFound = [[UILabel alloc] initWithFrame:CGRectMake((UD_SCREEN_WIDTH-230)/2, 0, 230, contactUs.frame.origin.y)];
            notFound.textAlignment = NSTextAlignmentCenter;
            notFound.font = [UIFont systemFontOfSize:17];
            notFound.textColor = [UdeskSDKConfig sharedConfig].sdkStyle.promptTextColor;
            notFound.text = getUDLocalizedString(@"udesk_faq_tips");
            
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
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
        
    }
    return self;
}

- (void)contactUsButton {
    
#warning 如果你设置了UI 记得在这里也设置下
    UdeskSDKConfig *config = [UdeskSDKConfig sharedConfig];
    config.sdkStyle = [UdeskSDKStyle defaultStyle];
    UdeskChatViewController *chat = [[UdeskChatViewController alloc] initWithSDKConfig:config withSettings:nil];
    
    UdeskSDKShow *show = [[UdeskSDKShow alloc] initWithConfig:[UdeskSDKConfig sharedConfig]];
    [show presentOnViewController:self.searchContentsController.navigationController udeskViewController:chat transiteAnimation:UDTransiteAnimationTypePush completion:nil];
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {

}

//隐藏搜索无结果字样
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.001);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        for (UIView * subview in self.searchDisplayController.searchResultsTableView.subviews) {
            if ([subview isKindOfClass:[UILabel class]])
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
    UdeskProblemModel *model = _searchData[indexPath.row];
    cell.textLabel.text = model.subject;
    return cell;
}

#pragma mark UITableViewDataDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //取消点击效果
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UdeskContentController *content = [[UdeskContentController alloc] init];
    UdeskProblemModel *model = _searchData[indexPath.row];
    content.articleId = model.articleId;
    content.articlesTitle = model.subject;
    
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
    
    [UdeskManager searchFaqArticles:searchText completion:^(id responseObject, NSError *error) {
        
        @try {
            
            if (!error) {
                
                NSMutableArray *muArray = [NSMutableArray array];
                NSArray *contents = [responseObject objectForKey:@"contents"];
                for (NSDictionary *dic in contents) {
                    UdeskProblemModel *model = [[UdeskProblemModel alloc] initWithContentsOfDic:dic];
                    
                    [muArray addObject:model];
                }
                
                if (contents == nil) {
                    self.searchData = nil;
                }else {
                    self.searchData = [muArray arrayByAddingObjectsFromArray:self.searchData];
                }
                
                [self.searchDisplayController.searchResultsTableView reloadData];
            }
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
    }];
   
}

@end
