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

const CGFloat imageSpacing = 2.0f;//图片间距
const NSInteger maxCountInLine = 4;//每行显示图片的张数
#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height

@implementation VZTPhotoListCell

-(instancetype)initWithFrame:(CGRect)frame{ //初始化cell的大小
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc]initWithFrame:self.bounds];
        //显示的时候做一个处理
        [self.contentView addSubview:_imageView];
        _selectBtn = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width - 23, frame.size.height - 23, 18, 18)];
        _selectBtn.clipsToBounds = YES;
        [_selectBtn setImage:[UIImage imageNamed:@"gallery_chs_normal"] forState:UIControlStateNormal];
        [_selectBtn setImage:[UIImage imageNamed:@"gallery_chs_seleceted"] forState:UIControlStateSelected];
        _selectBtn.userInteractionEnabled = NO;
        [self.contentView addSubview:_selectBtn];
    }
    return self;
}

@end

@interface LHCollectionViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic,strong) NSArray<PHAsset *>*assetArray;//相册集里面的所有图片
@property (nonatomic,strong) UICollectionView *collectionView;
@end

@implementation LHCollectionViewController
#pragma mark -懒加载
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
    self.view.backgroundColor = [UIColor whiteColor];
    self.assetArray =  [[LHPhotoList sharePhotoTool]getAssetsInAssetCollection:self.album.assetCollection ascending:NO];
    [self.view addSubview:self.collectionView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(toHome)];
}
-(void)toHome{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -代理
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
 
    [[LHPhotoList sharePhotoTool] requestImageForAsset:self.assetArray[indexPath.row] size:CGSizeMake((self.view.frame.size.width - imageSpacing*(maxCountInLine - 1))/maxCountInLine*3, (self.view.frame.size.width - imageSpacing*(maxCountInLine - 1))/maxCountInLine*3) resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image, NSDictionary *info) {

        cell.imageView.image = [self cutSquareImage:image];
    }];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    PHAsset *asset = _assetArray[indexPath.row];
    self.imageBlockArray(asset);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark 裁减正方形图片
- (UIImage *)cutSquareImage:(UIImage *)images {
    float min =
    images.size.height > images.size.width ? images.size.width : images.size.height;
    CGRect rect = CGRectMake((images.size.width - min) / 2,
                             (images.size.height - min) / 2, min, min);
    UIGraphicsBeginImageContextWithOptions(images.size, NO, images.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -rect.size.height);
    CGContextSaveGState(context);
    CGContextDrawImage(context, CGRectMake(-rect.origin.x, -rect.origin.y, images.size.width,
                                           images.size.height), images.CGImage);
    CGContextRestoreGState(context);
    //  [self drawInRect:CGRectMake(-rect.origin.x, -rect.origin.y, self.size.width,
    //                              self.size.height)];
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newimg;
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
