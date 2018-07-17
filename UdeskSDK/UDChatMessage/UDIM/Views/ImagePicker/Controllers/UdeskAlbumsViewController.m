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

static NSString *kUdeskAlbumCellIdentifier = @"kUdeskAlbumCellIdentifier";

@interface UdeskAlbumsViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UdeskAlbumsViewManager *viewManager;
@property (nonatomic, strong) UITableView            *albumsTableView;

@end

@implementation UdeskAlbumsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
    [self fetchAlbumsData];
}

- (void)setupUI {
    
    self.title = getUDLocalizedString(@"udesk_photo");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:getUDLocalizedString(@"udesk_cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelSelectImageAction)];
    
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
    [self.viewManager allAlbumsWithAllowPickingVideo:imagePickerVC.allowPickingVideo completion:^(NSArray<UdeskAlbumModel *> *albumArray) {
        @udStrongify(self);
        [self.albumsTableView reloadData];
        [self pushAssetsPickerWithAlumModel:self.viewManager.albumArray.firstObject animated:NO];
    }];
}

#pragma mark - @protocol UITableViewDataSource && UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewManager.albumArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UdeskAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:kUdeskAlbumCellIdentifier forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (indexPath.row < self.viewManager.albumArray.count) {
        cell.albumModel = self.viewManager.albumArray[indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row >= self.viewManager.albumArray.count) {
        return;
    }
    
    UdeskAlbumModel *albumModel = self.viewManager.albumArray[indexPath.row];
    
    [self pushAssetsPickerWithAlumModel:albumModel animated:YES];
}

- (void)pushAssetsPickerWithAlumModel:(UdeskAlbumModel *)albumModel animated:(BOOL)animated {
    
    if (!albumModel || albumModel == (id)kCFNull) return ;
    if (![albumModel isKindOfClass:[UdeskAlbumModel class]]) return;
    
    UdeskAssetsPickerController *photoPickerVC = [[UdeskAssetsPickerController alloc] init];
    photoPickerVC.alumModel = albumModel;
    [self.navigationController pushViewController:photoPickerVC animated:animated];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
