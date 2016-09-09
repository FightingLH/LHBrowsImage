//
//  LHCollectionViewController.m
//  testImage
//
//  Created by lh on 16/9/2.
//  Copyright © 2016年 lh. All rights reserved.
//

#import "LHCollectionViewController.h"
#import "LHPhotoList.h"
#import "ViewController.h"
#import "LHConst.h"

#import "LHBrowsingImageView.h"
const CGFloat imageSpacing = 2.0f;//图片间距
const NSInteger maxCountInLine = 4;//每行显示图片的张数
@interface VZTPhotoListCell()
@property (nonatomic,assign) BOOL isChoose;
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UIButton *selectBtn;
@end
@implementation VZTPhotoListCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc]initWithFrame:self.bounds];
        [self.contentView addSubview:_imageView];
        _selectBtn = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width - 28, frame.size.height - 28, 18+5, 18+5)];
        _selectBtn.clipsToBounds = YES;
        [_selectBtn setImage:[UIImage imageNamed:@"gallery_chs_normal"] forState:UIControlStateNormal];
        [_selectBtn setImage:[UIImage imageNamed:@"gallery_chs_seleceted"] forState:UIControlStateSelected];
        [_selectBtn addTarget:self action:@selector(btnChoose) forControlEvents:UIControlEventTouchUpInside];
        _selectBtn.userInteractionEnabled = YES;
        [self.contentView addSubview:_selectBtn];
    }
    return self;
}

-(void)btnChoose{
    self.btnChooseBlock();
}

-(void)setIsChoose:(BOOL)isChoose{
    _isChoose = isChoose;
    _selectBtn.selected = isChoose;
}
@end

@interface LHCollectionViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic,strong) NSArray<PHAsset *>*assetArray;//相册集里面的所有图片
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *selectedFalgList;//是否选中标记
@property (nonatomic,strong) NSMutableArray <PHAsset *>*assArray;//选中的图片
@property (nonatomic,strong) UIToolbar *toolBar;//底部的toolBar
@property (nonatomic,strong) UIButton *layBtn;//添加的layer
@property (nonatomic,strong) UILabel  *label;
@property (nonatomic,strong) UILabel  *remainLabel;
@property (nonatomic,strong) UILabel  *leReadLabel;

//
@property (nonatomic,strong) NSMutableArray *fuzzyImageArray;//模糊图片
@end

@implementation LHCollectionViewController
#pragma mark -lazy loading
-(UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        //每张图片的宽度
        CGFloat width = (self.view.frame.size.width - imageSpacing*(maxCountInLine - 1))/maxCountInLine;
        layout.itemSize = CGSizeMake(width, width);
        layout.minimumLineSpacing = imageSpacing;
        layout.minimumInteritemSpacing = imageSpacing;
        _collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[VZTPhotoListCell class] forCellWithReuseIdentifier:@"cell"];
        _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
    }
    return _collectionView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.album.title;
    self.view.backgroundColor = [UIColor whiteColor];
    self.selectedFalgList = [NSMutableArray new];
    self.fuzzyImageArray = [NSMutableArray new];
    [self.fuzzyImageArray removeAllObjects];
    self.assArray = [NSMutableArray new];
    self.assetArray =  [[LHPhotoList sharePhotoTool]getAssetsInAssetCollection:self.album.assetCollection ascending:NO];
    for (int i = 0;i<self.assetArray.count;i++) {
        [self.selectedFalgList addObject:@(0)];//首先默认是没有被选中的
    }
    [self.view addSubview:self.collectionView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(toHome)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(toGroup)];
    [self setToBar];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
}
#pragma mark --toolBar
-(void)setToBar{
    _toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 44, [UIScreen mainScreen].bounds.size.width, 44)];
    _toolBar.backgroundColor = [UIColor colorWithRed:0.98f green:0.98f blue:0.98f alpha:1.00f];
    //layerbtn
    UIButton *layerBtn = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 80, 7, 70, 30)];
    layerBtn.layer.cornerRadius = 5.0f;
    layerBtn.clipsToBounds = YES;
    layerBtn.backgroundColor = [UIColor colorWithRed:0.92f green:0.92f blue:0.93f alpha:1.00f];
    [layerBtn setTitle:@"确定" forState:UIControlStateNormal];
    layerBtn.hidden = YES;//图片隐藏
    _layBtn = layerBtn;
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 80, 7, 70, 30)];
    [btn addTarget:self action:@selector(clickFinish) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 5.5f;
    btn.clipsToBounds = YES;
    btn.backgroundColor = [UIColor colorWithRed:0.17f green:0.73f blue:0.96f alpha:1.00f];
    _label = [[UILabel alloc]initWithFrame:CGRectMake(30, 2.5, 30, 25)];
    _label.textColor = [UIColor whiteColor];
    _label.font = [UIFont systemFontOfSize:15.0f];
    _label.textAlignment = NSTextAlignmentRight;
    _remainLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 2.5, 30, 25)];
    [btn addSubview:_label];
    _remainLabel.text = @"确定";
    _remainLabel.textAlignment = NSTextAlignmentRight;
    _remainLabel.font = [UIFont systemFontOfSize:15.0f];
    _remainLabel.textColor = [UIColor whiteColor];
    [btn addSubview:_remainLabel];
    //只能选择图片个数
    _leReadLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 125, 25)];
    _leReadLabel.font = [UIFont systemFontOfSize:15.0f];
    _leReadLabel.text = [NSString stringWithFormat:@"还能选择%ld张图片",self.maxChooseNumber - self.assArray.count];
    _leReadLabel.textColor = [UIColor grayColor];
    [_toolBar addSubview:_leReadLabel];
    if (self.assArray.count == 0) {
        layerBtn.hidden = NO;
        _label.hidden = YES;
        _remainLabel.hidden = YES;
    }else{
        layerBtn.hidden = YES;
        _label.hidden = NO;
        _label.hidden = NO;
    }
    [_toolBar addSubview:btn];
    [_toolBar addSubview:layerBtn];
    [self.view addSubview:_toolBar];
}
#pragma mark -back choose imageArray
-(void)clickFinish{
    self.imageBlockArray(self.assArray);
    [self toHome];
}
#pragma mark -back group
-(void)toGroup{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -back first page
-(void)toHome{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -delegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _assetArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    VZTPhotoListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (!cell) {
        cell = [VZTPhotoListCell new];
    }
    [[LHPhotoList sharePhotoTool] requestImageForAsset:self.assetArray[indexPath.row] size:CGSizeMake(65*3, 65*3) resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image, NSDictionary *info) {
        cell.imageView.image = image;
        [self.fuzzyImageArray addObject:image];
    }];
    cell.isChoose = [_selectedFalgList[indexPath.row]boolValue];
    cell.btnChooseBlock = ^{
        [self isChooseOrNot:indexPath];
    };
    return cell;
}

#pragma mark -choose or not
-(void)isChooseOrNot:(NSIndexPath *)indexPath{
    _selectedFalgList[indexPath.row] = [NSNumber numberWithBool:![_selectedFalgList[indexPath.row]boolValue]];
    VZTPhotoListCell *cell = (id)[_collectionView cellForItemAtIndexPath:indexPath];
    cell.isChoose = [_selectedFalgList[indexPath.row]boolValue];
    PHAsset *asset = self.assetArray[indexPath.row];
    if (cell.isChoose) {
        [self.assArray addObject:asset];
    }else{
        [self.assArray removeObject:asset];
    }
    if(self.assArray.count > self.maxChooseNumber&&[_selectedFalgList[indexPath.row]boolValue]){
        cell.isChoose = NO;
        if ([self.assArray containsObject:asset]) {
            [self.assArray removeObject:asset];
        }
        _selectedFalgList[indexPath.row] = @(0);
        return;
    }
    if (self.assArray.count == 0) {
        _layBtn.hidden = NO;
        _label.hidden = YES;
        _remainLabel.hidden = YES;
    }else{
        _layBtn.hidden = YES;
        _label.hidden = NO;
        _remainLabel.hidden = NO;
    }
    _label.text = [NSString stringWithFormat:@"(%ld)",self.assArray.count];
    _leReadLabel.text = [NSString stringWithFormat:@"还能选择%ld张照片",self.maxChooseNumber - self.assArray.count];
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    LHBrowsingImageView *browsing = [[LHBrowsingImageView alloc]init];
    browsing.assetBigArray = [NSMutableArray arrayWithArray:self.assetArray];
    browsing.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    browsing.index = indexPath.row;
    [self.navigationController presentViewController:browsing animated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
