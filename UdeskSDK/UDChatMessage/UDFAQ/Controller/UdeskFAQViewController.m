//
//  UdeskFAQViewController.m
//  UdeskSDK
//
//  Created by Udesk on 16/6/20.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UdeskFAQViewController.h"
#import "UdeskSDKMacro.h"
#import "UdeskBundleUtils.h"
#import "UdeskProblemModel.h"
#import "UdeskContentController.h"
#import "UdeskManager.h"
#import "UdeskSDKConfig.h"
#import "UdeskSearchController.h"
#import "UdeskTransitioningAnimation.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskSDKShow.h"

@interface UdeskFAQViewController ()<UISearchBarDelegate,UISearchDisplayDelegate>

/**  帮助中心表示图 */
@property (nonatomic, strong) UITableView *faqTableView;
/**  帮助中心数据数组 */
@property (nonatomic, strong) NSArray      *problemData;
/**  搜索vc */
@property (nonatomic, strong) UdeskSearchController *searchController;
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
    [self.view addSubview:_faqTableView];
    
    
    //删除多余的cell
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
    [_faqTableView setTableFooterView:footerView];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.f, 0.f,UD_SCREEN_WIDTH, 44)];
    searchBar.tintColor = [UIColor colorWithRed:33/255.0f green:40/255.0f blue:42/255.0f alpha:1];
    
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
    
    @try {
        
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
    [UdeskManager getFaqArticles:^(id responseObject, NSError *error) {
        
        @try {
            
            if (!error) {
                
                NSMutableArray *muArray = [NSMutableArray array];
                NSArray *contents = [responseObject objectForKey:@"contents"];
                for (NSDictionary *dic in contents) {
                    UdeskProblemModel *model = [[UdeskProblemModel alloc] initWithContentsOfDic:dic];
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
