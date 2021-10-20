//
//  UdeskFAQViewController.m
//  UdeskSDK
//
//  Created by Udesk on 16/6/20.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskFAQViewController.h"
#import "UdeskProblemModel.h"
#import "UdeskContentController.h"
#import "UdeskManager.h"
#import "UdeskTransitioningAnimation.h"
#import "UdeskSDKShow.h"
#import "UdeskThrottleUtil.h"

@interface UdeskFAQViewController ()<UISearchResultsUpdating,UISearchControllerDelegate>

/**  帮助中心表示图 */
@property (nonatomic, strong) UITableView *faqTableView;
/**  帮助中心数据数组 */
@property (nonatomic, strong) NSArray      *problemData;
/**  搜索 */
@property (nonatomic, strong) UISearchController *searchController;

@property (nonatomic, strong) UdeskSDKConfig   *sdkConfig;

@end

@implementation UdeskFAQViewController

- (instancetype)initWithSDKConfig:(UdeskSDKConfig *)config {
    
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        _sdkConfig = config;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UdeskSDKConfig customConfig].sdkStyle.tableViewBackGroundColor;
    //适配ios15
    if (@available(iOS 15.0, *)) {
        if(self.navigationController){
            UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
            // 背景色
            appearance.backgroundColor = [UIColor whiteColor];
            // 去掉半透明效果
            appearance.backgroundEffect = nil;
            // 去除导航栏阴影（如果不设置clear，导航栏底下会有一条阴影线）
            //        appearance.shadowColor = [UIColor clearColor];
            appearance.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
            self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
            self.navigationController.navigationBar.standardAppearance = appearance;
        }
    }
    
    //添加TableView&Search
    [self faqTableViewAndSearch];
    //请求数据
    [self requestFAQData];
    
    UIScreenEdgePanGestureRecognizer *popRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePopRecognizer:)];
    popRecognizer.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:popRecognizer];
}

//滑动返回
- (void)handlePopRecognizer:(UIScreenEdgePanGestureRecognizer*)recognizer {
    
    CGPoint translation = [recognizer translationInView:self.view];
    CGFloat xPercent = translation.x / CGRectGetWidth(self.view.bounds) * 0.9;
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            [UdeskTransitioningAnimation setInteractive:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case UIGestureRecognizerStateChanged:
            [UdeskTransitioningAnimation updateInteractiveTransition:xPercent];
            break;
        default:
            if (xPercent < .45) {
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
    
    if ([UdeskSDKConfig customConfig].presentingAnimation == UDTransiteAnimationTypePush) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.view.window.layer addAnimation:[UdeskTransitioningAnimation createDismissingTransiteAnimation:[UdeskSDKConfig customConfig].presentingAnimation] forKey:nil];
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - 添加帮助中心TableView和搜索
- (void)faqTableViewAndSearch {
    
    _faqTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, UD_SCREEN_WIDTH, UD_SCREEN_HEIGHT) style:UITableViewStylePlain];
    _faqTableView.backgroundColor = [UIColor colorWithRed:0.918f  green:0.922f  blue:0.925f alpha:1];
    _faqTableView.dataSource = self;
    _faqTableView.delegate = self;
    _faqTableView.tableFooterView = [UIView new];
    [self.view addSubview:_faqTableView];
    
    _faqTableView.tableHeaderView = self.searchController.searchBar;
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
    
    @try {
        
        if (self.searchController.active) {
            self.searchController.active = NO;
            [self.searchController.searchBar removeFromSuperview];
        }
        
        UdeskContentController *content = [[UdeskContentController alloc] init];
        UdeskProblemModel *model = _problemData[indexPath.row];
        content.articleId = model.articleId;
        content.articlesTitle = model.subject;
        
        UdeskSDKShow *show = [[UdeskSDKShow alloc] initWithConfig:_sdkConfig];
        [show presentOnViewController:self udeskViewController:content transiteAnimation:UDTransiteAnimationTypePush completion:nil];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

#pragma mark - 请求数据
- (void)requestFAQData {
    
    @udWeakify(self);
    [UdeskManager getFaqArticles:^(id responseObject, NSError *error) {
        
        @try {
            
            if (!error) {
                
                NSMutableArray *muArray = [NSMutableArray array];
                NSArray *contents = [responseObject objectForKey:@"contents"];
                for (NSDictionary *dic in contents) {
                    UdeskProblemModel *model = [[UdeskProblemModel alloc] initModelWithJSON:dic];
                    if (model) {
                        [muArray addObject:model];
                    }
                }
                
                @udStrongify(self);
                self.problemData = [muArray arrayByAddingObjectsFromArray:self.problemData];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.faqTableView reloadData];
                });
            }
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
    }];
}

- (UISearchController *)searchController {
    
    if (!_searchController) {
        
        _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        _searchController.searchResultsUpdater = self;
        _searchController.delegate = self;
        _searchController.dimsBackgroundDuringPresentation = NO;
        _searchController.searchBar.frame = CGRectMake(_searchController.searchBar.frame.origin.x, _searchController.searchBar.frame.origin.y, _searchController.searchBar.frame.size.width, 44.0);
        _searchController.searchBar.backgroundColor = [UIColor colorWithRed:0.953f  green:0.953f  blue:0.953f alpha:1];
        _searchController.searchBar.barTintColor = [UIColor colorWithRed:0.953f  green:0.953f  blue:0.953f alpha:1];
        _searchController.searchBar.backgroundImage = [UIImage new];
        _searchController.searchBar.placeholder = @"搜索";
    }
    return _searchController;
}

#pragma mark - @protocol UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    //设置时间阈值来限制方法调用频率
    ud_dispatch_throttle(0.35f, ^{
        if (searchController.searchBar.text.length == 0) {
            [self requestFAQData];
            return ;
        }
        
        [UdeskManager searchFaqArticles:searchController.searchBar.text completion:^(id responseObject, NSError *error) {
            
            if (!error) {
                
                NSMutableArray *array = [NSMutableArray array];
                NSArray *contents = [responseObject objectForKey:@"contents"];
                for (NSDictionary *dic in contents) {
                    UdeskProblemModel *model = [[UdeskProblemModel alloc] initModelWithJSON:dic];
                    [array addObject:model];
                }
                
                self.problemData = [array copy];
                [self.faqTableView reloadData];
            }
        }];
    });
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
