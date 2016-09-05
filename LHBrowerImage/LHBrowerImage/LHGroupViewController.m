//
//  LHGroupViewController.m
//  testImage
//
//  Created by lh on 16/9/2.
//  Copyright © 2016年 lh. All rights reserved.
//

#import "LHGroupViewController.h"
#import "LHPhotoList.h"

#import "LHCollectionViewController.h"
@interface LHGroupViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) NSMutableArray<LHPhotoAblumList *> *listArray;//所有的相册列表
@property (nonatomic,strong) NSMutableArray<PHAsset *> *contentArray;//里面所有的相册
@property (nonatomic,strong) UITableView *tableView;
@end

@implementation LHGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _listArray = [NSMutableArray new];
    _contentArray = [NSMutableArray new];
    [_listArray addObjectsFromArray:[[LHPhotoList sharePhotoTool]getPhotoAblumList]];
    [self tableView];//创建tableview
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(backHome)];
}

#pragma mark -返回
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    LHPhotoAblumList *album = _listArray[indexPath.row];
    [[LHPhotoList sharePhotoTool] requestImageForAsset:album.headImageAsset size:CGSizeMake(65*3, 65*3) resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image, NSDictionary *info) {
        cell.imageView.image = image;
    }];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = album.title;
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _listArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%@",_listArray[indexPath.row].title);
    LHCollectionViewController *collect = [[LHCollectionViewController alloc]init];
    collect.imageBlockArray = ^(id x){
        if (x) {
            self.backImageArray(x);
        }
    };
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
