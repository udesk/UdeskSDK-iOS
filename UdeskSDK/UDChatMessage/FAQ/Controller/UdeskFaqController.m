//
//  UdeskFaqController.m
//  UdeskSDK
//
//  Created by xuchen on 15/11/26.
//  Copyright (c) 2015年 xuchen. All rights reserved.
//

#import "UdeskFaqController.h"
#import "UdeskProblemModel.h"
#import "UdeskSearchController.h"
#import "UdeskFoundationMacro.h"
#import "UdeskUtils.h"
#import "UDManager.h"

@interface UdeskFaqController ()<UISearchDisplayDelegate,UISearchBarDelegate>

@property (nonatomic, strong) UdeskSearchController *searchController;//搜索VC

@end

@implementation UdeskFaqController


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
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    //设置标题
    [self setNavigationTitleName];
    //添加TableView&Search
    [self faqTableViewAndSearch];
    //请求数据
    [self requestFAQData];

}
#pragma mark - 设置标题
- (void)setNavigationTitleName {

    UILabel *faqLabel = [[UILabel alloc] initWithFrame:CGRectMake((UD_SCREEN_WIDTH-100)/2, 0, 100, 44)];
    faqLabel.text = getUDLocalizedString(@"常见问题");
    faqLabel.backgroundColor = [UIColor clearColor];
    faqLabel.textAlignment = NSTextAlignmentCenter;
    faqLabel.textColor = Config.faqTitleColor;
    self.navigationItem.titleView = faqLabel;
}
#pragma mark - 添加帮助中心TableView和搜索
- (void)faqTableViewAndSearch {
    
    _faqTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, UD_SCREEN_WIDTH, UD_SCREEN_HEIGHT-44-kUDStatusBarHeight) style:UITableViewStylePlain];
    _faqTableView.backgroundColor = [UIColor colorWithRed:0.918f  green:0.922f  blue:0.925f alpha:1];
    _faqTableView.dataSource = self;
    _faqTableView.delegate = self;
    [self.view addSubview:_faqTableView];
    
    
    //删除多余的cell
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
    [_faqTableView setTableFooterView:footerView];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.f, 0.f,UD_SCREEN_WIDTH, 44)];
    searchBar.tintColor = UDRGBCOLOR(33, 40, 42);
    
    _faqTableView.tableHeaderView = searchBar;
    
    UdeskSearchController *searchDisplayController = [[UdeskSearchController alloc] initWithSearchBar:searchBar
                                                                             contentsController:self];
    
    
    self.searchController = searchDisplayController;
    
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
#pragma mark - 请求数据
- (void)requestFAQData {
    
    @udWeakify(self);
    [UDManager getFaqArticles:^(id responseObject, NSError *error) {
        
        if (!error) {
            
            NSMutableArray *muArray = [NSMutableArray array];
            NSArray *contents = [responseObject objectForKey:@"contents"];
            for (NSDictionary *dic in contents) {
                UdeskProblemModel *model = [[UdeskProblemModel alloc] initWithContentsOfDic:dic];
                
                [muArray addObject:model];
            }
            
            @udStrongify(self);
            self.problemData = [muArray arrayByAddingObjectsFromArray:self.problemData];
            
            [self.faqTableView reloadData];
        }
        
    }];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (ud_isIOS6) {
        self.navigationController.navigationBar.tintColor = Config.oneSelfNavcigtionColor;
    } else {
        self.navigationController.navigationBar.barTintColor = Config.oneSelfNavcigtionColor;
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (ud_isIOS6) {
        self.navigationController.navigationBar.tintColor = Config.faqNavigationColor;
    } else {
        self.navigationController.navigationBar.barTintColor = Config.faqNavigationColor;
        self.navigationController.navigationBar.tintColor = Config.faqBackButtonColor;
    }

}

-(void)dealloc {

    _faqTableView = nil;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
