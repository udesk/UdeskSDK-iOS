//
//  UdeskLocationViewController.m
//  UdeskSDK
//
//  Created by xuchen on 2017/8/16.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskLocationViewController.h"
#import "UdeskSDKMacro.h"
#import "UIView+UdeskSDK.h"
#import "UIImage+UdeskSDK.h"
#import "UdeskSDKConfig.h"
#import "UdeskCustomNavigation.h"
#import "UdeskBundleUtils.h"
#import "UdeskLocationViewModel.h"
#import "UdeskLocationResultDataSource.h"

#define UdeskLocationCellIdntifier @"UdeskLocationCellIdntifier"

@interface UdeskLocationViewController ()<MKMapViewDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>

@property (nonatomic, strong) UdeskSDKConfig *sdkConfig;
@property (nonatomic, strong) UdeskCustomNavigation *customNav;
@property (nonatomic, assign) BOOL haveGetUserLocation;   //是否获取到用户位置
@property (nonatomic, assign) BOOL spanBool;//是否是滑动
@property (nonatomic, assign) BOOL pinchBool;//是否缩放
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIImageView *locationPinImgView; //大头针
@property (nonatomic, strong) UITableView *nearbyTableView;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) UdeskLocationViewModel *viewModel;

@property (nonatomic, strong) UdeskLocationResultDataSource *resultViewModel;
@property (nonatomic, strong) UITableView *searchResultTableView;

@property (nonatomic, assign) BOOL hasSend;

@end

@implementation UdeskLocationViewController

- (instancetype)initWithSDKConfig:(UdeskSDKConfig *)config hasSend:(BOOL)hasSend
{
    self = [super init];
    if (self) {
        _sdkConfig = config;
        _hasSend = hasSend;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.viewModel startPositioning];
    [self setupCustomNav];
    [self setupSearchBar];
    [self setupMapView];
    if (!_hasSend) {
        [self setupNearbayTableView];
    }
    else {
        _mapView.udHeight = UD_SCREEN_HEIGHT-_customNav.udBottom;
        [self updateMapRegion];
    }
}

- (void)updateMapRegion {

    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(self.locationModel.latitude, self.locationModel.longitude), 800, 800);
    [_mapView setRegion:region animated:YES];
}

- (UdeskLocationViewModel *)viewModel {

    if (!_viewModel) {
        _viewModel = [[UdeskLocationViewModel alloc] init];
    }
    return _viewModel;
}

- (void)setupCustomNav {

    self.view.backgroundColor = _sdkConfig.sdkStyle.tableViewBackGroundColor;
    
    _customNav = [[UdeskCustomNavigation alloc] init];
    
    if (_sdkConfig.sdkStyle.navigationColor) {
        _customNav.backgroundColor = _sdkConfig.sdkStyle.navigationColor;
    }
    if (_sdkConfig.sdkStyle.titleColor) {
        _customNav.titleLabel.textColor = _sdkConfig.sdkStyle.titleColor;
    }
    if (_sdkConfig.sdkStyle.navBackButtonColor) {
        [_customNav.closeButton setTitleColor:_sdkConfig.sdkStyle.navBackButtonColor forState:UIControlStateNormal];
    }
    
    _customNav.titleLabel.text = getUDLocalizedString(@"udesk_location");
    [self.view addSubview:_customNav];
    
    if (!_hasSend) {
        
        if (_sdkConfig.sdkStyle.navRightButtonColor) {
            [_customNav.rightButton setTitleColor:_sdkConfig.sdkStyle.navRightButtonColor forState:UIControlStateNormal];
        }
        _customNav.rightButton.hidden = NO;
        [_customNav.rightButton setTitle:getUDLocalizedString(@"udesk_send") forState:UIControlStateNormal];
    }
    
    @udWeakify(self)
    _customNav.closeButtonActionBlock = ^(){
        @udStrongify(self)
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    
    _customNav.rightButtonActionBlock = ^{
        @udStrongify(self)
        [self.viewModel getMapSnapshotWithRegion:self.mapView.region mapViewSize:self.mapView.udSize completion:^(UIImage *snapshot) {
            if (self.sendLocationBlock) {
                self.sendLocationBlock([self.viewModel getLocationModel:self.mapView.region.center image:snapshot]);
            }
        }];
        [self dismissViewControllerAnimated:YES completion:nil];
    };
}

//搜索
- (void)setupSearchBar {

    if (!_hasSend) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, _customNav.udBottom, UD_SCREEN_WIDTH, 44)];
        _searchBar.placeholder = getUDLocalizedString(@"udesk_search");;
        _searchBar.delegate = self;
        [self.view addSubview:_searchBar];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {

    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

    [self.resultViewModel searchPlace:searchBar.text completion:^{
        [self.searchResultTableView reloadData];
    }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {

    [self cancelOrDoneSearch];
}

- (void)cancelOrDoneSearch {

    self.searchBar.text = @"";
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
    [self.searchResultTableView removeFromSuperview];
}

//地图
- (void)setupMapView {

    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, self.hasSend?_customNav.udBottom:_searchBar.udBottom, UD_SCREEN_WIDTH, 200)];
    _mapView.userTrackingMode = MKUserTrackingModeFollow;
    _mapView.mapType = MKMapTypeStandard;
    _mapView.showsUserLocation = YES;
    _mapView.showsBuildings = YES;
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    
    //打印完后我们发现有个View带有手势数组其类型为_MKMapContentView获取Span和Pinch手势
    for (UIView *view in self.mapView.subviews) {
        NSString *viewName = NSStringFromClass([view class]);
        if ([viewName isEqualToString:@"_MKMapContentView"]) {
            UIView *contentView = view;//[self.mapView valueForKey:@"_contentView"];
            for (UIGestureRecognizer *gestureRecognizer in contentView.gestureRecognizers) {
                if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
                    [gestureRecognizer addTarget:self action:@selector(mapViewSpanGesture:)];
                }
                if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
                    [gestureRecognizer addTarget:self action:@selector(mapViewPinchGesture:)];
                }
            }
        }
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    if (!_haveGetUserLocation) {
        if (_mapView.userLocationVisible) {
            _haveGetUserLocation = YES;
            [self getAddressByLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude];
            [self addCenterLocationViewWithCenterPoint:_mapView.center];
        }
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    if (_locationPinImgView && (_spanBool||_pinchBool)) {
        [self.viewModel removeAllObjects];
        [self.nearbyTableView reloadData];
        [self resetTableHeadView];
        
        CGPoint mapCenter = _mapView.center;
        CLLocationCoordinate2D coordinate = [_mapView convertPoint:mapCenter toCoordinateFromView:_mapView];
        [self getAddressByLatitude:coordinate.latitude longitude:coordinate.longitude];
        //更新大头针
        [self updatePinImageCenter:mapCenter];
    }
}

//附近地点
- (void)setupNearbayTableView {

    _nearbyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _mapView.udBottom, UD_SCREEN_WIDTH, UD_SCREEN_HEIGHT-_mapView.udBottom) style:UITableViewStylePlain];
    _nearbyTableView.delegate = self;
    _nearbyTableView.dataSource = self;
    _nearbyTableView.rowHeight = 50;
    [self.view addSubview:_nearbyTableView];
}

#pragma mark - Private Methods
- (void)resetTableHeadView {
    if (self.viewModel.nearbyArray.count > 0) {
        _nearbyTableView.tableHeaderView = nil;
    }
    else{
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30.0)];
        view.backgroundColor = _nearbyTableView.backgroundColor;
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicatorView.center = view.center;
        [indicatorView startAnimating];
        [view addSubview:indicatorView];
        _nearbyTableView.tableHeaderView = view;
    }
}

- (void)addCenterLocationViewWithCenterPoint:(CGPoint)point {
    
    if (!_locationPinImgView) {
        _locationPinImgView = [[UIImageView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2, 100, 18, 38)];
        _locationPinImgView.center = point;
        _locationPinImgView.image = [UIImage udDefaultLocationPinImage];
        _locationPinImgView.center = _mapView.center;
        [self.view addSubview:_locationPinImgView];
    }
}

#pragma mark 根据坐标取得地名
- (void)getAddressByLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude{
    
    //反地理编码
    [self.viewModel getAddressByLatitude:latitude longitude:longitude completion:^(NSError *error) {
        
        if (!error) {
            [self.nearbyTableView reloadData];
            [self resetTableHeadView];
        }else{
            _haveGetUserLocation = NO;
        }
    }];
}

//地名取坐标
- (void)getAddressString:(NSString *)addressString {
    
    [self.viewModel getAddressString:addressString completionHandler:^(CLPlacemark *placemark, NSError *error) {
        
        if (!error) {
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(placemark.location.coordinate, 800, 800);
            [self.mapView setRegion:region animated:YES];
            
            //更新大头针
            CGPoint mapCenter = _mapView.center;
            [self updatePinImageCenter:mapCenter];
            
        }else{
            _haveGetUserLocation = NO;
        }
    }];
}

//更新大头针
- (void)updatePinImageCenter:(CGPoint)mapCenter {

    _locationPinImgView.center = CGPointMake(mapCenter.x, mapCenter.y-15);
    [UIView animateWithDuration:0.2 animations:^{
        _locationPinImgView.center = mapCenter;
    }completion:^(BOOL finished){
        if (finished) {
            [UIView animateWithDuration:0.05 animations:^{
                _locationPinImgView.transform = CGAffineTransformMakeScale(1.0, 0.8);
                
            }completion:^(BOOL finished){
                if (finished) {
                    [UIView animateWithDuration:0.1 animations:^{
                        _locationPinImgView.transform = CGAffineTransformIdentity;
                    }completion:^(BOOL finished){
                        if (finished) {
                            _spanBool = NO;
                        }
                    }];
                }
            }];
        }
    }];
}

#pragma mark － TableView datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.nearbyArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UdeskLocationCellIdntifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:UdeskLocationCellIdntifier];
    }
    
    if (indexPath.row < self.viewModel.nearbyArray.count) {
        UdeskNearbyModel *model = self.viewModel.nearbyArray[indexPath.row];
        cell.textLabel.text = model.name;
        cell.detailTextLabel.text = model.thoroughfare;
        if (model.isSelect) {
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage udDefaultMarkImage]];
        }
        else {
            cell.accessoryView = nil;
        }
    }
    
    return cell;
}

#pragma mark - TableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    for (UITableViewCell *cell in tableView.visibleCells) {
        cell.accessoryView = nil;
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage udDefaultMarkImage]];
    
    NSString *name = [self.viewModel updateNearby:indexPath.row];
    [self getAddressString:name];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _spanBool = YES;
}

#pragma mark - MapView Gesture
- (void)mapViewSpanGesture:(UIPanGestureRecognizer *)gesture {
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        _spanBool = YES;
    }
}

- (void)mapViewPinchGesture:(UIGestureRecognizer *)gesture {
    
    switch (gesture.state) {
        case UIGestureRecognizerStateChanged:{
            _pinchBool = YES;
        }
            break;
        case UIGestureRecognizerStateEnded:{
            _pinchBool = NO;
        }
            break;
            
        default:
            break;
    }
}

- (UdeskLocationResultDataSource *)resultViewModel {

    if (!_resultViewModel) {
        @udWeakify(self);
        _resultViewModel = [[UdeskLocationResultDataSource alloc] init];
        _resultViewModel.didSeledctSearchResultBlock = ^(UdeskNearbyModel *model) {
            
            @udStrongify(self);
            [self selecetSearchResult:model];
        };
        
        _resultViewModel.scrollViewWillBeginDraggingBlock = ^(UIScrollView *scrollView) {
            
            @udStrongify(self);
            [self.searchBar resignFirstResponder];
        };
    }
    return _resultViewModel;
}

- (UITableView *)searchResultTableView {

    if (!_searchResultTableView) {
        _searchResultTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _searchBar.udBottom, UD_SCREEN_WIDTH, UD_SCREEN_HEIGHT-_searchBar.udBottom) style:UITableViewStylePlain];
        _searchResultTableView.delegate = self.resultViewModel;
        _searchResultTableView.dataSource = self.resultViewModel;
        [self.view addSubview:_searchResultTableView];
    }
    return _searchResultTableView;
}

- (void)selecetSearchResult:(UdeskNearbyModel *)model {

    [self cancelOrDoneSearch];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(model.coordinate, 800, 800);
    [self.mapView setRegion:region animated:YES];
    [self getAddressByLatitude:model.coordinate.latitude longitude:model.coordinate.longitude];
    [self addCenterLocationViewWithCenterPoint:self.mapView.center];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [UdeskSDKConfig customConfig].orientationMask;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
