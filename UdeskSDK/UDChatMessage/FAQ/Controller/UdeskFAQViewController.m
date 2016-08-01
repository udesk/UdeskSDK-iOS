//
//  UdeskFAQViewController.m
//  UdeskSDK
//
//  Created by xuchen on 16/6/20.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "UdeskFAQViewController.h"
#import "UdeskFoundationMacro.h"
#import "UdeskUtils.h"
#import "UdeskProblemModel.h"
#import "UdeskContentController.h"
#import "UdeskManager.h"

@interface UdeskFAQViewController ()<UISearchBarDelegate,UISearchDisplayDelegate>

@property (nonatomic, weak) UISearchBar *searchBar;
@property (nonatomic, strong) NSArray   *recordFAQData;

@end

@implementation UdeskFAQViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.udNavView changeTitle:getUDLocalizedString(@"常见问题")];
 
    [self faqTableViewAndSearch];
    [self requestFAQData];
}

- (void)backButtonAction {

    [super backButtonAction];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 添加帮助中心TableView和搜索
- (void)faqTableViewAndSearch {
    
    CGFloat faqY = self.navigationController.navigationBarHidden?64:0;
    
    _faqTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, faqY, UD_SCREEN_WIDTH, UD_SCREEN_HEIGHT-44-kUDStatusBarHeight) style:UITableViewStylePlain];
    _faqTableView.backgroundColor = [UIColor colorWithRed:0.918f  green:0.922f  blue:0.925f alpha:1];
    _faqTableView.dataSource = self;
    _faqTableView.delegate = self;
    [self.view addSubview:_faqTableView];
    
    //删除多余的cell
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
    [_faqTableView setTableFooterView:footerView];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.f, 0.f,UD_SCREEN_WIDTH, 44)];
    searchBar.tintColor = UDRGBCOLOR(33, 40, 42);
    searchBar.placeholder = @"搜索";
    searchBar.delegate = self;
    searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    searchBar.returnKeyType = UIReturnKeySearch;
    _searchBar = searchBar;
    
    _faqTableView.tableHeaderView = searchBar;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _problemData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIden = @"HCCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIden];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIden];
    }
    
    UdeskProblemModel *model = _problemData[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld. %@",(long)indexPath.row+1,model.subject];
    
    return cell;
    
}

#pragma mark UITableViewDataDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //取消点击效果
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UdeskContentController *content = [[UdeskContentController alloc] init];
    UdeskProblemModel *model = _problemData[indexPath.row];
    content.Article_Id = model.Article_Id;
    content.ArticlesTitle = model.subject;
    
    [self.navigationController pushViewController:content animated:YES];
    
}

#pragma mark UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
 
    [self searchServerData:searchText];
}

#pragma mark - 请求数据
- (void)requestFAQData {
    
    @udWeakify(self);
    [UdeskManager getFaqArticles:^(id responseObject, NSError *error) {
        
        if (!error) {
            
            NSMutableArray *muArray = [NSMutableArray array];
            NSArray *contents = [responseObject objectForKey:@"contents"];
            for (NSDictionary *dic in contents) {
                UdeskProblemModel *model = [[UdeskProblemModel alloc] initWithContentsOfDic:dic];
                
                [muArray addObject:model];
            }
            
            @udStrongify(self);
            self.problemData = muArray;
            self.recordFAQData = self.problemData;
            [self.faqTableView reloadData];
        }
        
    }];
    
}

- (void)searchServerData:(NSString *)searchText {

    if (searchText.length) {
        
        [UdeskManager searchFaqArticles:searchText completion:^(id responseObject, NSError *error) {
            
            if (!error) {
                
                NSMutableArray *muArray = [NSMutableArray array];
                NSArray *contents = [responseObject objectForKey:@"contents"];
                for (NSDictionary *dic in contents) {
                    UdeskProblemModel *model = [[UdeskProblemModel alloc] initWithContentsOfDic:dic];
                    
                    [muArray addObject:model];
                }
                
                self.problemData = muArray;
                [self.faqTableView reloadData];
            }
        }];
    }
    else {
    
        self.problemData = self.recordFAQData;
        [self.faqTableView reloadData];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (ud_isIOS6) {
        self.navigationController.navigationBar.tintColor = UdeskUIConfig.oneSelfNavcigtionColor;
    } else {
        self.navigationController.navigationBar.barTintColor = UdeskUIConfig.oneSelfNavcigtionColor;
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (ud_isIOS6) {
        self.navigationController.navigationBar.tintColor = UdeskUIConfig.faqNavigationColor;
    } else {
        self.navigationController.navigationBar.barTintColor = UdeskUIConfig.faqNavigationColor;
        self.navigationController.navigationBar.tintColor = UdeskUIConfig.faqBackButtonColor;
    }
    
}

-(void)dealloc {
    
    _faqTableView = nil;
    
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
