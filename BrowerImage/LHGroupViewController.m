//
//  LHGroupViewController.m
//  testImage
//
//  Created by lh on 16/9/2.
//  Copyright © 2016年 lh. All rights reserved.
//

#import "LHGroupViewController.h"
#import "LHPhotoList.h"
#import "LHGroupTableViewCell.h"
#import "LHCollectionViewController.h"
@interface LHGroupViewController ()<UITableViewDelegate,UITableViewDataSource,PHPhotoLibraryChangeObserver>
@property (nonatomic,strong) NSMutableArray<LHPhotoAblumList *> *listArray;//all photos
@property (nonatomic,strong) NSMutableArray<PHAsset *> *contentArray;//all asset
@property (nonatomic,strong) UITableView *tableView;
@end

@implementation LHGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"照片";
    _listArray = [NSMutableArray new];
    _contentArray = [NSMutableArray new];
    //To determine whether can get photo album
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
        NSLog(@"暂无访问权限");
    }else{
        [_listArray removeAllObjects];
        [_listArray addObjectsFromArray:[[LHPhotoList sharePhotoTool]getPhotoAblumList]];
        [self.tableView reloadData];
    }
    [[PHPhotoLibrary sharedPhotoLibrary]registerChangeObserver:self];
    [self tableView];// tableview
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(backHome)];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
}
#pragma mark -delegate
-(void)photoLibraryDidChange:(PHChange *)changeInstance{
    __weak LHGroupViewController *weakSelf = self;
    dispatch_sync(dispatch_get_main_queue(), ^{
        __strong LHGroupViewController *strongSelf = weakSelf;
        [_listArray removeAllObjects];
        [_listArray addObjectsFromArray:[[LHPhotoList sharePhotoTool]getPhotoAblumList]];
        [strongSelf.tableView reloadData];
    });
    
}
#pragma mark -back
-(void)backHome{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -tableView
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellid = @"cellId";
    LHGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell) {
        cell = [[LHGroupTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    
    LHPhotoAblumList *album = _listArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell configUi:album];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _listArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 72*([UIScreen mainScreen].bounds.size.height/568);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    LHCollectionViewController *collect = [[LHCollectionViewController alloc]init];
    __weak LHGroupViewController *weakSelf = self;
    collect.imageBlockArray = ^(NSMutableArray<PHAsset *>*array){
        __strong LHGroupViewController *strongSelf = weakSelf;
        if (array) {
            strongSelf.backImageArray(array);
        }
    };
    collect.maxChooseNumber = self.maxChooseNumber;
    collect.album = _listArray[indexPath.row];
    [self.navigationController pushViewController:collect animated:YES];
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
