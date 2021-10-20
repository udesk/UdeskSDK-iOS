//
//  UdeskAlbumsViewController.m
//  UdeskImagePickerController
//
//  Created by xuchen on 2018/3/6.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskAlbumsViewController.h"
#import "UdeskAlbumCell.h"
#import "UdeskAlbumsViewManager.h"
#import "UdeskAssetsPickerController.h"
#import "UdeskImagePickerController.h"
#import "UdeskBundleUtils.h"
#import "UdeskSDKMacro.h"
#import "UdeskPushAnimation.h"
#import "UdeskSDKConfig.h"

static NSString *kUdeskAlbumCellIdentifier = @"kUdeskAlbumCellIdentifier";

@interface UdeskAlbumsViewController ()<UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate>

@property (nonatomic, strong) UdeskAlbumsViewManager *viewManager;
@property (nonatomic, strong) UITableView            *albumsTableView;
@property (nonatomic, strong) NSArray<UdeskAlbumModel *> *albumArray;

@end

@implementation UdeskAlbumsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
    [self fetchAlbumsData];
}

- (void)setupUI {
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
    
    self.navigationItem.hidesBackButton = YES;
    self.title = getUDLocalizedString(@"udesk_photo");
    NSDictionary *attr = @{NSForegroundColorAttributeName : [UdeskSDKConfig customConfig].sdkStyle.albumTitleColor};
    self.navigationController.navigationBar.titleTextAttributes = attr;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:getUDLocalizedString(@"udesk_cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelSelectImageAction)];
    self.navigationItem.rightBarButtonItem.tintColor = [UdeskSDKConfig customConfig].sdkStyle.albumCancelColor;
    
    _albumsTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _albumsTableView.delegate = self;
    _albumsTableView.dataSource = self;
    _albumsTableView.rowHeight = 60;
    _albumsTableView.tableFooterView = [UIView new];
    [_albumsTableView registerClass:[UdeskAlbumCell class] forCellReuseIdentifier:kUdeskAlbumCellIdentifier];
    [self.view addSubview:_albumsTableView];
}

- (void)cancelSelectImageAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)fetchAlbumsData {
    
    UdeskImagePickerController *imagePickerVC = (UdeskImagePickerController *)self.navigationController;
    @udWeakify(self);
    [UdeskAlbumsViewManager allAlbumsWithAllowPickingVideo:imagePickerVC.allowPickingVideo completion:^(NSArray<UdeskAlbumModel *> *albumArray) {
        @udStrongify(self);
        self.albumArray = albumArray;
        [self.albumsTableView reloadData];
    }];
}

#pragma mark - @protocol UITableViewDataSource && UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albumArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UdeskAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:kUdeskAlbumCellIdentifier forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (indexPath.row < self.albumArray.count) {
        cell.albumModel = self.albumArray[indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UdeskAssetsPickerController *photoPickerVC = [[UdeskAssetsPickerController alloc] init];
    photoPickerVC.albumIndex = indexPath.row;
    [self.navigationController pushViewController:photoPickerVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - lazy
- (UdeskAlbumsViewManager *)viewManager {
    if (!_viewManager) {
        _viewManager = [[UdeskAlbumsViewManager alloc] init];
    }
    return _viewManager;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.delegate = self;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
    if (operation == UINavigationControllerOperationPush) {
        return [[UdeskPushAnimation alloc] init];
    }
    
    return nil;
}

@end
