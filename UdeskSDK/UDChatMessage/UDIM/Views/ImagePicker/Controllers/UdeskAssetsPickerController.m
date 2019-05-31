//
//  UdeskAssetsPickerController.m
//  UdeskImagePickerController
//
//  Created by xuchen on 2018/3/6.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskAssetsPickerController.h"
#import "UdeskAssetsPickerManager.h"
#import "UdeskAlbumModel.h"
#import "UdeskAssetCell.h"
#import "UdeskPhotoToolBar.h"
#import "UdeskAssetPreviewController.h"
#import "UdeskImagePickerController.h"
#import "UdeskSDKUtil.h"
#import "UdeskBundleUtils.h"
#import "UdeskSDKMacro.h"
#import "UdeskAlbumsViewManager.h"
#import "UIBarButtonItem+UdeskSDK.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskPopAnimation.h"
#import "UdeskAlbumsViewController.h"

static CGFloat udItemMargin = 5;
static CGFloat udColumnNumber = 4;
static NSString *kUdeskAssetCellIdentifier  = @"kUdeskAssetCellIdentifier";

@interface UdeskAssetsPickerController ()<UICollectionViewDelegate,UICollectionViewDataSource,UdeskPhotoToolBarDelegate,UdeskAssetCellDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UdeskAssetsPickerManager *viewManager;
@property (nonatomic, strong) UICollectionViewFlowLayout *assetFlowLayout;
@property (nonatomic, strong) UICollectionView *assetCollectionView;
@property (nonatomic, strong) UdeskPhotoToolBar *toolBar;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

@end

@implementation UdeskAssetsPickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
    [self fetchAssetsData];
}

- (void)setupUI {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *leftBarButtonItem = [UIBarButtonItem udItemWithTitle:getUDLocalizedString(@"udesk_back") image:[UIImage udDefaultWhiteBackImage] target:self action:@selector(backSelectImageAction)];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    if((FUDSystemVersion>=7.0)){
        negativeSpacer.width = -13;
        self.navigationItem.leftBarButtonItems = @[negativeSpacer,leftBarButtonItem];
    }
    else {
        self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:getUDLocalizedString(@"udesk_cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelSelectImageAction)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    _assetFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    _assetCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_assetFlowLayout];
    _assetCollectionView.backgroundColor = [UIColor whiteColor];
    _assetCollectionView.dataSource = self;
    _assetCollectionView.delegate = self;
    _assetCollectionView.alwaysBounceHorizontal = NO;
    _assetCollectionView.contentInset = UIEdgeInsetsMake(udItemMargin, udItemMargin, udItemMargin, udItemMargin);
    [_assetCollectionView registerClass:[UdeskAssetCell class] forCellWithReuseIdentifier:kUdeskAssetCellIdentifier];
    [self.view addSubview:_assetCollectionView];
    
    _toolBar = [[UdeskPhotoToolBar alloc] initWithFrame:CGRectZero];
    _toolBar.delegate = self;
    _toolBar.toolBarCollectionView.hidden = YES;
    [self.view addSubview:_toolBar];
}

- (void)backSelectImageAction {
    
    UdeskAlbumsViewController *albums = [[UdeskAlbumsViewController alloc] init];
    [self.navigationController pushViewController:albums animated:YES];
}

- (void)cancelSelectImageAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)fetchAssetsData {
    
    UdeskImagePickerController *imagePicker = (UdeskImagePickerController *)self.navigationController;
    @udWeakify(self);
    [UdeskAlbumsViewManager allAlbumsWithAllowPickingVideo:imagePicker.allowPickingVideo completion:^(NSArray<UdeskAlbumModel *> *albumArray) {
        @udStrongify(self);
        if (self.albumIndex >= albumArray.count || self.albumIndex<0) {
            self.albumIndex = 0;
        }
        UdeskAlbumModel *alumModel = albumArray[self.albumIndex];
        [self updateWithAlbumModel:alumModel];
        
        [self.viewManager assetsFromFetchResult:alumModel.result allowPickingVideo:imagePicker.allowPickingVideo completion:^(NSArray<UdeskAssetModel *> *assetArray) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.assetCollectionView reloadData];
            });
            [self.assetCollectionView setContentOffset:CGPointMake(0, self.assetCollectionView.contentSize.height - self.assetCollectionView.frame.size.height) animated:NO];
        }];
    }];
}

- (void)updateWithAlbumModel:(UdeskAlbumModel *)alumModel {
    
    self.title = alumModel.name;
    self.assetCollectionView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), ((alumModel.count + udColumnNumber - 1) / udColumnNumber) * CGRectGetWidth(self.view.frame));
}

#pragma mark - @protocol UICollectionViewDataSource && UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.viewManager.assetArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UdeskAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kUdeskAssetCellIdentifier forIndexPath:indexPath];
    
    UdeskImagePickerController *udImagePicker = (UdeskImagePickerController *)self.navigationController;
    if (indexPath.row < self.viewManager.assetArray.count) {
     
        UdeskAssetModel *model = self.viewManager.assetArray[indexPath.row];
        cell.assetModel = model;
        cell.udDelegate = self;

        if ([udImagePicker.selectedModels containsObject:model]) {
            cell.selectionIndex = [udImagePicker.selectedModels indexOfObject:model];
        }
        else {
            cell.selectionIndex = -1;
        }
    }
    
    return cell;
}

#define mark - @protocol UdeskAssetCellDelegate
- (void)assetCell:(UdeskAssetCell *)assetCell didSelectAsset:(BOOL)isSelected {
    
    UdeskImagePickerController *udImagePicker = (UdeskImagePickerController *)self.navigationController;
    NSIndexPath *indexPath = [self.assetCollectionView indexPathForCell:assetCell];
    UdeskAssetModel *model = self.viewManager.assetArray[indexPath.row];
    
    if (isSelected) {
        if ([self checkImagesCount]) {
            model.isSelected = isSelected;
            [udImagePicker.selectedModels addObject:model];
            [self.assetCollectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        }
        else {
            assetCell.selectAssetButton.selected = NO;
        }
    }
    else {
        [udImagePicker.selectedModels removeObject:model];
        [self.assetCollectionView deselectItemAtIndexPath:indexPath animated:NO];
        assetCell.selectionIndex = -1;
    }
    
    for (UdeskAssetModel *selectedModel in udImagePicker.selectedModels) {
        NSInteger index = [self.viewManager.assetArray indexOfObject:selectedModel];
        UdeskAssetCell *cell = (UdeskAssetCell *)[self.assetCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        cell.selectionIndex = [udImagePicker.selectedModels indexOfObject:selectedModel];
    }
    
    //更新发送个数
    [self.toolBar updateSendNumber:udImagePicker.selectedModels.count];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // 预览照片或视频
    if (indexPath.row > self.viewManager.assetArray.count) return;
    UdeskAssetModel *model = self.viewManager.assetArray[indexPath.row];
    if (!model || model == (id)kCFNull) return ;
    
    [self pushAssetPreviewViewControllerAtIndex:indexPath.row isSwitchAllAsset:YES];
}

- (void)pushAssetPreviewViewControllerAtIndex:(NSInteger)index isSwitchAllAsset:(BOOL)isSwitchAllAsset {
    
    UdeskImagePickerController *udImagePicker = (UdeskImagePickerController *)self.navigationController;
    
    UdeskAssetPreviewController *photoPreviewVC = [[UdeskAssetPreviewController alloc] init];
    photoPreviewVC.currentIndex = index;
    photoPreviewVC.selectedAssetArray = udImagePicker.selectedModels.count ? [udImagePicker.selectedModels copy] : @[self.viewManager.assetArray[index]];
    photoPreviewVC.assetArray = isSwitchAllAsset ? self.viewManager.assetArray : nil;
    photoPreviewVC.isSelectOriginalPhoto = self.toolBar.originalPhotoButton.selected;
    [self.navigationController pushViewController:photoPreviewVC animated:YES];
    
    __weak typeof(self) weakSelf = self;
    photoPreviewVC.BackButtonClickBlock = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.assetCollectionView reloadData];
        [strongSelf.toolBar updateSendNumber:udImagePicker.selectedModels.count];
    };
    
    photoPreviewVC.UpdateOriginalButtonBlock = ^(BOOL isSelect) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.toolBar.originalPhotoButton.selected = isSelect;
    };
    
    photoPreviewVC.FinishSelectBlock = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf toolBarDidSelectDone:nil];
    };
}

#pragma mark - @protocol UdeskPhotoToolBarDelegate
- (void)toolBarDidSelectPreview:(UdeskPhotoToolBar *)toolBar {
    
    UdeskImagePickerController *udImagePicker = (UdeskImagePickerController *)self.navigationController;
    UdeskAssetModel *model = (UdeskAssetModel *)udImagePicker.selectedModels.firstObject;
    if (!model || model == (id)kCFNull) return ;
    if (![model isKindOfClass:[UdeskAssetModel class]]) return ;
    
    if ([self.viewManager.assetArray containsObject:model]) {
        NSInteger index = [self.viewManager.assetArray indexOfObject:model];
        [self pushAssetPreviewViewControllerAtIndex:index isSwitchAllAsset:NO];
    }
}

- (void)toolBarDidSelectDone:(UdeskPhotoToolBar *)toolBar {
    
    UdeskImagePickerController *udImagePicker = (UdeskImagePickerController *)self.navigationController;
    NSMutableArray *photoArray = [NSMutableArray array];
    NSMutableArray *videoArray = [NSMutableArray array];
    NSMutableArray *gifArray = [NSMutableArray array];
    
    for (UdeskAssetModel *model in udImagePicker.selectedModels) {
        if (![model isKindOfClass:[UdeskAssetModel class]]) return ;
        switch (model.type) {
            case UdeskAssetModelMediaTypePhoto:
                [photoArray addObject:model];
                break;
            case UdeskAssetModelMediaTypeVideo:
                [videoArray addObject:model];
                break;
            case UdeskAssetModelMediaTypePhotoGif:
                [gifArray addObject:model];
                break;
                
            default:
                break;
        }
    }
    
    dispatch_group_t group = dispatch_group_create();
    
    [self.loadingView startAnimating];
    //原图
    if (self.toolBar.originalPhotoButton.selected) {

        [self fetchOriginalPhotoDataWithSelectedModels:photoArray imagePicker:udImagePicker group:group];
        [self fetchGifDataWithSelectedModels:gifArray imagePicker:udImagePicker group:group];
        [self fetchVideoDataWithSelectedModels:videoArray imagePicker:udImagePicker group:group];
    }
    else {

        [self fetchCompressPhotoDataWithSelectedModels:photoArray quality:udImagePicker.quality imagePicker:udImagePicker group:group];
        [self fetchGifDataWithSelectedModels:gifArray imagePicker:udImagePicker group:group];
        [self fetchVideoDataWithSelectedModels:videoArray imagePicker:udImagePicker group:group];
    }

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self.loadingView stopAnimating];
        [self.loadingView setHidesWhenStopped:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

//原图
- (void)fetchOriginalPhotoDataWithSelectedModels:(NSArray *)selectedModels imagePicker:(UdeskImagePickerController *)imagePicker group:(dispatch_group_t)group {
    
    if (!selectedModels || selectedModels == (id)kCFNull) return ;
    if (selectedModels.count == 0) return;
    
    dispatch_group_enter(group);
    [self.viewManager fetchOriginalPhotoWithAssets:[selectedModels valueForKey:@"asset"] completion:^(NSArray<UIImage *> *images) {
    
        if (imagePicker.pickerDelegate && [imagePicker.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingPhotos:)]) {
            [imagePicker.pickerDelegate imagePickerController:imagePicker didFinishPickingPhotos:images];
        }
        dispatch_group_leave(group);
    }];
}

//压缩
- (void)fetchCompressPhotoDataWithSelectedModels:(NSArray *)selectedModels quality:(CGFloat)quality imagePicker:(UdeskImagePickerController *)imagePicker group:(dispatch_group_t)group {
    
    if (!selectedModels || selectedModels == (id)kCFNull) return ;
    if (selectedModels.count == 0) return;
    
    dispatch_group_enter(group);
    [self.viewManager fetchCompressPhotoWithAssets:[selectedModels valueForKey:@"asset"] quality:quality completion:^(NSArray<UIImage *> *images) {
        
        if (imagePicker.pickerDelegate && [imagePicker.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingPhotos:)]) {
            [imagePicker.pickerDelegate imagePickerController:imagePicker didFinishPickingPhotos:images];
        }
        dispatch_group_leave(group);
    }];
}

//GIF
- (void)fetchGifDataWithSelectedModels:(NSArray *)selectedModels imagePicker:(UdeskImagePickerController *)imagePicker group:(dispatch_group_t)group {
    
    if (!selectedModels || selectedModels == (id)kCFNull) return ;
    if (selectedModels.count == 0) return;
    
    dispatch_group_enter(group);
    [self.viewManager fetchOriginalGifPhotoWithAssets:[selectedModels valueForKey:@"asset"] completion:^(NSArray<NSData *> *gifs) {
        
        if (imagePicker.pickerDelegate && [imagePicker.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingGIFImages:)]) {
            [imagePicker.pickerDelegate imagePickerController:imagePicker didFinishPickingGIFImages:gifs];
        }
        dispatch_group_leave(group);
    }];
}

//视频
- (void)fetchVideoDataWithSelectedModels:(NSArray *)selectedModels imagePicker:(UdeskImagePickerController *)imagePicker group:(dispatch_group_t)group {
    
    if (!selectedModels || selectedModels == (id)kCFNull) return ;
    if (selectedModels.count == 0) return;
    
    dispatch_group_enter(group);
    [self.viewManager fetchCompressVideoWithAssets:[selectedModels valueForKey:@"asset"] completion:^(NSArray<NSString *> *paths) {
        
        if (!paths) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:getUDLocalizedString(@"udesk_video_export_failed") preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:getUDLocalizedString(@"udesk_close") style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
            return ;
        }
        
        if (imagePicker.pickerDelegate && [imagePicker.pickerDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingVideos:)]) {
            [imagePicker.pickerDelegate imagePickerController:imagePicker didFinishPickingVideos:paths];
        }
        dispatch_group_leave(group);
    }];
}

//检查张数
- (BOOL)checkImagesCount {
    
    UdeskImagePickerController *imagePicker = (UdeskImagePickerController *)self.navigationController;
    if (imagePicker.selectedModels.count == imagePicker.maxImagesCount) {
        NSString *message = getUDLocalizedString(@"udesk_max_count_photo");
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[message stringByReplacingOccurrencesOfString:@"@" withString:[NSString stringWithFormat:@"%ld",imagePicker.maxImagesCount]] preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:getUDLocalizedString(@"udesk_close") style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat top = 0;
    CGFloat toolBarTop = 0;
    CGFloat toolBarHeight = udIsIPhoneXSeries ? (50 + 34) : 50;
    CGFloat collectionViewHeight = CGRectGetHeight(self.view.frame) - toolBarHeight;;
    
    _assetCollectionView.frame = CGRectMake(0, top, CGRectGetWidth(self.view.frame), collectionViewHeight);
    CGFloat itemWH = (CGRectGetWidth(self.view.frame) - (udColumnNumber + 1) * udItemMargin) / udColumnNumber;
    _assetFlowLayout.itemSize = CGSizeMake(itemWH, itemWH);
    _assetFlowLayout.minimumInteritemSpacing = udItemMargin;
    _assetFlowLayout.minimumLineSpacing = udItemMargin;
    [_assetCollectionView setCollectionViewLayout:_assetFlowLayout];
    
    if (!self.navigationController.navigationBar.isHidden) {
        toolBarTop = CGRectGetHeight(self.view.frame) - toolBarHeight;
    } else {
        toolBarTop = CGRectGetHeight(self.view.frame) - toolBarHeight - CGRectGetMaxY(self.navigationController.navigationBar.frame);
    }
    _toolBar.frame = CGRectMake(0, toolBarTop, CGRectGetWidth(self.view.frame), toolBarHeight);
    [self.assetCollectionView reloadData];
}

#pragma mark - lazy
- (UdeskAssetsPickerManager *)viewManager {
    if (!_viewManager) {
        _viewManager = [[UdeskAssetsPickerManager alloc] init];
    }
    return _viewManager;
}

- (UIActivityIndicatorView *)loadingView {
    if (!_loadingView) {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
        view.center = self.view.center;
        view.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.8];
        view.layer.masksToBounds = YES;
        view.layer.cornerRadius = 5;
        [self.view addSubview:view];
        
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _loadingView.frame = CGRectMake(60, 60, 0, 0);
        [view addSubview:_loadingView];
    }
    return _loadingView;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        
        UdeskImagePickerController *udImagePicker = (UdeskImagePickerController *)self.navigationController;
        [udImagePicker.selectedModels removeAllObjects];
        udImagePicker.selectedModels = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.delegate = self;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
    
    //预览图
    if ([toVC isKindOfClass:[UdeskAssetPreviewController class]]) {
        return nil;
    }
    
    if (operation == UINavigationControllerOperationPush) {
        return [[UdeskPopAnimation alloc] init];
    }
    
    return nil;
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
