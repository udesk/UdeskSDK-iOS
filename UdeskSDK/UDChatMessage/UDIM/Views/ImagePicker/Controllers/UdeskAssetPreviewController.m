//
//  UdeskAssetPreviewController.m
//  UdeskImagePickerController
//
//  Created by xuchen on 2018/3/6.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UdeskAssetPreviewController.h"
#import "UdeskPreviewNavBar.h"
#import "UdeskPhotoToolBar.h"
#import "UdeskAssetPreviewCell.h"
#import "UdeskSDKUtil.h"
#import "UdeskAssetModel.h"
#import "UdeskImagePickerController.h"
#import <Photos/Photos.h>
#import "UdeskBundleUtils.h"
#import "UdeskSDKMacro.h"

static NSString *kUdeskPhotoPreviewCellIdentifier = @"kUdeskPhotoPreviewCellIdentifier";
static NSString *kUdeskGIFPreviewCellIdentifier = @"kUdeskGIFPreviewCellIdentifier";
static NSString *kUdeskVideoPreviewCellIdentifier = @"kUdeskVideoPreviewCellIdentifier";

@interface UdeskAssetPreviewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UdeskPhotoToolBarDelegate,UdeskPreviewNavBarDelegate>

@property (nonatomic, strong) UdeskPreviewNavBar *navBar;
@property (nonatomic, strong) UdeskPhotoToolBar  *toolBar;

@property (nonatomic, assign) BOOL              isHideNaviBar;

@property (nonatomic, strong) UICollectionViewFlowLayout *previewFlowLayout;
@property (nonatomic, strong) UICollectionView *previewCollectionView;

@property (nonatomic, strong) NSArray          *dataSource;

@end

@implementation UdeskAssetPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataSource = self.assetArray ? :self.selectedAssetArray;
    [self setupUI];
}

- (void)setupUI {
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _previewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    _previewFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _previewCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_previewFlowLayout];
    _previewCollectionView.backgroundColor = [UIColor blackColor];
    _previewCollectionView.dataSource = self;
    _previewCollectionView.delegate = self;
    _previewCollectionView.pagingEnabled = YES;
    _previewCollectionView.scrollsToTop = NO;
    _previewCollectionView.showsHorizontalScrollIndicator = NO;
    _previewCollectionView.contentSize = CGSizeMake(self.dataSource.count * (CGRectGetWidth(self.view.frame) + 20), CGRectGetHeight(self.view.frame));
    [self.view addSubview:_previewCollectionView];
    
    [_previewCollectionView registerClass:[UdeskPhotoPreviewCell class] forCellWithReuseIdentifier:kUdeskPhotoPreviewCellIdentifier];
    [_previewCollectionView registerClass:[UdeskGIFPreviewCell class] forCellWithReuseIdentifier:kUdeskGIFPreviewCellIdentifier];
    [_previewCollectionView registerClass:[UdeskVideoPreviewCell class] forCellWithReuseIdentifier:kUdeskVideoPreviewCellIdentifier];
    
    _toolBar = [[UdeskPhotoToolBar alloc] initWithFrame:CGRectZero];
    _toolBar.backgroundColor = [UIColor colorWithRed:0.141f  green:0.145f  blue:0.149f alpha:1];
    _toolBar.delegate = self;
    _toolBar.previewButton.hidden = YES;
    _toolBar.selectedAssets = self.selectedAssetArray;
    if (self.currentIndex < self.assetArray.count) {
        _toolBar.currentAsset = self.assetArray[self.currentIndex];
    }
    if (_toolBar.selectedAssets.count == 1) {
        _toolBar.toolBarCollectionView.hidden = YES;
    }
    [self.view addSubview:_toolBar];
    
    _navBar = [[UdeskPreviewNavBar alloc] initWithFrame:CGRectZero];
    _navBar.backgroundColor = [UIColor colorWithRed:0.141f  green:0.145f  blue:0.149f alpha:0.95];
    _navBar.delegate = self;
    [self.view addSubview:_navBar];
    
    self.view.clipsToBounds = YES;
}

#pragma mark - @protocol UdeskPhotoToolBarDelegate
- (void)toolBarDidSelectOriginalPhoto:(UdeskPhotoToolBar *)toolBar {
    
    if (self.UpdateOriginalButtonBlock) {
        self.UpdateOriginalButtonBlock(self.toolBar.originalPhotoButton.selected);
    }
}

- (void)toolBarDidSelectDone:(UdeskPhotoToolBar *)toolBar {
    
    if (self.FinishSelectBlock) {
        self.FinishSelectBlock();
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)toolBarDidSelectPreviewItemAtAssetModel:(UdeskAssetModel *)asset {
    
    if ([self.dataSource containsObject:asset]) {
        _currentIndex = [self.dataSource indexOfObject:asset];
        [_previewCollectionView setContentOffset:CGPointMake((CGRectGetWidth(self.view.frame) + 20) * _currentIndex, 0) animated:NO];
        [self refreshNavBarAndBottomBarState];
    }
}

#pragma mark - @protocol UdeskPreviewNavBarDelegate
- (void)previewNavBarDidSelectBackButton:(UdeskPreviewNavBar *)navBar {
    
    if (self.BackButtonClickBlock) {
        self.BackButtonClickBlock();
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)previewNavBarDidSelectAsset:(UdeskPreviewNavBar *)navBar {
    
    UdeskImagePickerController *udImagePicker = (UdeskImagePickerController *)self.navigationController;
    if (_currentIndex >= self.dataSource.count) return;
    
    // 选择照片,检查是否超过了最大个数的限制
    if (udImagePicker.selectedModels.count == udImagePicker.maxImagesCount && navBar.selectButton.selected) {
        NSString *message = getUDLocalizedString(@"udesk_max_count_photo");
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[message stringByReplacingOccurrencesOfString:@"@" withString:[NSString stringWithFormat:@"%ld",udImagePicker.maxImagesCount]] preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:getUDLocalizedString(@"udesk_close") style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    @try {
        
        UdeskAssetModel *model = self.dataSource[_currentIndex];
        if (navBar.selectButton.selected) {
            [udImagePicker.selectedModels addObject:model];
        }
        else {
            NSArray *selectedModels = [NSArray arrayWithArray:udImagePicker.selectedModels];
            for (UdeskAssetModel *model_item in selectedModels) {
                if ([model.asset.localIdentifier isEqualToString:model_item.asset.localIdentifier]) {
                    
                    NSArray *selectedModelsTmp = [NSArray arrayWithArray:udImagePicker.selectedModels];
                    for (NSInteger i = 0; i < selectedModelsTmp.count; i++) {
                        UdeskAssetModel *model = selectedModelsTmp[i];
                        if ([model isEqual:model_item]) {
                            [udImagePicker.selectedModels removeObjectAtIndex:i];
                            break;
                        }
                    }
                    break;
                }
            }
            
            navBar.selectionIndex = -1;
        }
        
        model.isSelected = navBar.selectButton.selected;
        [self refreshNavBarAndBottomBarState];
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _navBar.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), udIsIPhoneXSeries?88:64);
    
    _previewFlowLayout.itemSize = CGSizeMake(CGRectGetWidth(self.view.frame) + 20, CGRectGetHeight(self.view.frame));
    _previewFlowLayout.minimumInteritemSpacing = 0;
    _previewFlowLayout.minimumLineSpacing = 0;
    _previewCollectionView.frame = CGRectMake(-10, 0, CGRectGetWidth(self.view.frame) + 20, CGRectGetHeight(self.view.frame));
    [_previewCollectionView setCollectionViewLayout:_previewFlowLayout];
    
    CGFloat toolBarHeight = (udIsIPhoneXSeries ? 50 + (83 - 49) : 50) + (self.selectedAssetArray.count > 1 ? 80 : 0);
    CGFloat toolBarTop = CGRectGetHeight(self.view.frame) - toolBarHeight;
    _toolBar.frame = CGRectMake(0, toolBarTop, CGRectGetWidth(self.view.frame), toolBarHeight);
}

//#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    @try {
        
        CGFloat offSetWidth = scrollView.contentOffset.x;
        offSetWidth = offSetWidth +  ((CGRectGetWidth(self.view.frame) + 20) * 0.5);
        
        NSInteger currentIndex = offSetWidth / (CGRectGetWidth(self.view.frame) + 20);
        
        if (currentIndex < self.dataSource.count && _currentIndex != currentIndex) {
            _currentIndex = currentIndex;
            [self refreshNavBarAndBottomBarState];
            self.toolBar.currentAsset = self.dataSource[currentIndex];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UdeskAssetPreviewCell *cell;
    if (indexPath.row >= self.dataSource.count) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kUdeskPhotoPreviewCellIdentifier forIndexPath:indexPath];
        return cell;
    }
    
    UdeskAssetModel *model = self.dataSource[indexPath.row];
    if (model.type == UdeskAssetModelMediaTypeVideo) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kUdeskVideoPreviewCellIdentifier forIndexPath:indexPath];
    } else if (model.type == UdeskAssetModelMediaTypePhotoGif) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kUdeskGIFPreviewCellIdentifier forIndexPath:indexPath];
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kUdeskPhotoPreviewCellIdentifier forIndexPath:indexPath];
    }
    
    cell.assetModel = model;
    __weak typeof(self) weakSelf = self;
    cell.SingleTapGestureBlock = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf didTapPreviewCell];
    };
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[UdeskPhotoPreviewCell class]]) {
        [(UdeskPhotoPreviewCell *)cell recoverSubviews];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[UdeskPhotoPreviewCell class]]) {
        [(UdeskPhotoPreviewCell *)cell recoverSubviews];
    } else if ([cell isKindOfClass:[UdeskVideoPreviewCell class]]) {
        [(UdeskVideoPreviewCell *)cell pausePlayerAndShowNavBar];
    }
}

#pragma mark - Private Method

- (void)refreshNavBarAndBottomBarState {
    
    if (!_dataSource || _dataSource == (id)kCFNull) return ;
    if (_dataSource.count == 0) return;
    if (_currentIndex >= _dataSource.count) return ;
    
    @try {
        
        UdeskImagePickerController *udImagePicker = (UdeskImagePickerController *)self.navigationController;
        
        UdeskAssetModel *model = _dataSource[_currentIndex];
        self.navBar.selectButton.selected = model.isSelected;
        
        if ([udImagePicker.selectedModels containsObject:model]) {
            self.navBar.selectionIndex = [udImagePicker.selectedModels indexOfObject:model];
        }
        else {
            self.navBar.selectionIndex = -1;
        }
        
        [self.toolBar updateSendNumber:udImagePicker.selectedModels.count];
        self.toolBar.selectedAssets = udImagePicker.selectedModels;
        if (self.selectedAssetArray.count > 1) {
            self.toolBar.toolBarCollectionView.hidden = NO;
        }
        [self.view setNeedsLayout];
        
        self.toolBar.originalPhotoButton.selected = self.isSelectOriginalPhoto;
        // 如果正在预览的是视频，隐藏原图按钮
        if (!_isHideNaviBar) {
            if (model.type == UdeskAssetModelMediaTypeVideo) {
                self.toolBar.originalPhotoButton.hidden = YES;
            } else {
                self.toolBar.originalPhotoButton.hidden = NO;
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [UIApplication sharedApplication].statusBarHidden = YES;
    if (_currentIndex) [_previewCollectionView setContentOffset:CGPointMake((CGRectGetWidth(self.view.frame) + 20) * _currentIndex, 0) animated:NO];
    [self refreshNavBarAndBottomBarState];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didTapPreviewCell {
    
    self.isHideNaviBar = !self.isHideNaviBar;
    _navBar.hidden = self.isHideNaviBar;
    _toolBar.hidden = self.isHideNaviBar;
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
