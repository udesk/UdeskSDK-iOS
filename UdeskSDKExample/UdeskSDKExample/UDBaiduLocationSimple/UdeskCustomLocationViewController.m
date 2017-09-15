//
//  UdeskCustomLocationViewController.m
//  UdeskSDK
//
//  Created by xuchen on 2017/9/5.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UdeskCustomLocationViewController.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>

#import "UIImage+UdeskSDK.h"
#import "UdeskCustomLocationViewModel.h"
#import "UdeskCustomLocationDataSource.h"

@interface UdeskCustomLocationViewController ()<BMKMapViewDelegate, UdeskCustomLocationViewModelDelegate, UISearchBarDelegate, UITableViewDelegate> {

    BMKMapView *_mapView;
    BOOL _hasSend;
    UISearchBar *_searchBar;
    UIImageView *_locationPinImgView;
}

@property (nonatomic, strong) BMKMapView *mapView;
@property (nonatomic, strong) UITableView *searchResultTableView;
@property (nonatomic, strong) UITableView *locationTableView;
@property (nonatomic, strong) UIImageView *locationPinImgView;
@property (nonatomic, strong) UdeskCustomLocationDataSource *dataSource;

@property (nonatomic, strong) UdeskCustomLocationViewModel *viewModel;

@end

@implementation UdeskCustomLocationViewController

- (instancetype)initWithHasSend:(BOOL)hasSend
{
    self = [super init];
    if (self) {
        _hasSend = hasSend;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
}

- (void)setup {

    //适配ios7
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        self.navigationController.navigationBar.translucent = NO;
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(sendLocationAction)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
 
    //搜索
    if (!_hasSend) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        _searchBar.placeholder = @"搜索地点";
        _searchBar.delegate = self;
        [self.view addSubview:_searchBar];
    }
    
    //初始化地图
    _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, _hasSend?0:CGRectGetMaxY(_searchBar.frame), self.view.frame.size.width, _hasSend?self.view.frame.size.height:200)];
    _mapView.delegate = self;
    _mapView.zoomLevel = 16;
    _mapView.isSelectedAnnotationViewFront = YES;
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    [self.view addSubview:_mapView];
    
    _viewModel = [[UdeskCustomLocationViewModel alloc] initWithMapView:_mapView];
    _viewModel.delegate = self;
    
    _locationTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_mapView.frame), self.view.frame.size.width, self.view.frame.size.height-CGRectGetMaxY(_mapView.frame)-64) style:UITableViewStylePlain];
    _locationTableView.tag = 1024;
    _locationTableView.delegate = self;
    _locationTableView.dataSource = self.dataSource;
    _locationTableView.rowHeight = 50;
    [self.view addSubview:_locationTableView];
}

- (void)updateMapRegion {

    BMKCoordinateRegion region;
    region.center = CLLocationCoordinate2DMake(self.locationModel.latitude, self.locationModel.longitude);
    [_mapView setRegion:region animated:YES];
    self.locationPinImgView.center = self.mapView.center;
}

#pragma mark - BMKMapViewDelegate
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [self.viewModel beginReverseGeoCodeSearch:_mapView.centerCoordinate];
}

#pragma mark - BMKMapViewDelegate
/** * 当mapView完成加载的时候 * @param mapView 地图对象 */
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView
{
    //启动定位服务
    _mapView.showsUserLocation = NO;
    //先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeNone;
    //设置定位的状态
    _mapView.showsUserLocation = YES;
    
    //更新位置
    if (_hasSend) {
        [self updateMapRegion];
    }
}

#pragma mark - UdeskCustomLocationViewModelDelegate
- (void)updateBMKUserLocation {
    
    self.locationPinImgView.center = self.mapView.center;
    [self.viewModel stopUserLocationService];
}

- (void)reloadLocationTableView {

    self.dataSource.items = self.viewModel.locationArray;
    [self.locationTableView reloadData];
}

- (void)updateSearchResult {

    self.dataSource.items = self.viewModel.resultArray;
    [self.searchResultTableView reloadData];
}

#pragma mark - dataSource
- (UdeskCustomLocationDataSource *)dataSource {
    
    if (!_dataSource) {
        _dataSource = [[UdeskCustomLocationDataSource alloc] init];
    }
    return _dataSource;
}

#pragma mark - TableView
- (UITableView *)searchResultTableView {
    
    if (!_searchResultTableView) {
        _searchResultTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_searchBar.frame), self.view.frame.size.width, self.view.frame.size.height-CGRectGetMaxY(_searchBar.frame)-64) style:UITableViewStylePlain];
        _searchResultTableView.delegate = self;
        _searchResultTableView.dataSource = self.dataSource;
        _searchResultTableView.tag = 1025;
        [self.view addSubview:_searchResultTableView];
    }
    return _searchResultTableView;
}

//大头针
- (UIImageView *)locationPinImgView {
    
    if (!_locationPinImgView) {
        _locationPinImgView = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2, 100, 18, 38)];
        _locationPinImgView.image = [UIImage ud_defaultLocationPinImage];
        _locationPinImgView.center = _mapView.center;
        [self.view addSubview:_locationPinImgView];
    }
    return _locationPinImgView;
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [self.viewModel search:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [self cancelOrDoneSearch];
}

//取消／完成搜索
- (void)cancelOrDoneSearch {
    
    _searchBar.text = @"";
    [_searchBar setShowsCancelButton:NO animated:YES];
    [_searchBar resignFirstResponder];
    [_searchResultTableView removeFromSuperview];
}

#pragma mark - TableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (tableView.tag == 1024) {
     
        for (UITableViewCell *cell in tableView.visibleCells) {
            cell.accessoryView = nil;
        }
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage ud_defaultMarkImage]];
        
        [self.viewModel updateNearby:indexPath.row];
        return;
    }
    
    //点击搜索内容
    UdeskNearbyModel *model = self.viewModel.resultArray[indexPath.row];
    [self selectSearchResult:model];
}

- (void)selectSearchResult:(UdeskNearbyModel *)model {
    
    [self cancelOrDoneSearch];
    [self.viewModel selectSearchResult:model];
    
    self.locationPinImgView.center = self.mapView.center;
}

//发送位置
- (void)sendLocationAction {
    
    if (self.sendLocationBlock) {
        self.sendLocationBlock([self.viewModel getLocationModel]);
    }
    [self cancelAction];
}

- (void)cancelAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    if (_mapView) {
        _mapView = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}

- (void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
