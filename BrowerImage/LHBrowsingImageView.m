//
//  LHBrowsingImageView.m
//  LHBrowerImage
//
//  Created by lh on 16/9/7.
//  Copyright © 2016年 lh. All rights reserved.
//
//use to brower big image
#import "LHBrowsingImageView.h"
#import "LHPhotoList.h"
#import "LHConst.h"
@interface LHBrowsingImageView ()<UIScrollViewDelegate>
@property (nonatomic,strong) UILabel *titleLabel;
@end

@implementation LHBrowsingImageView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    [self setTitle];
    [self createScrollView];
}

#pragma mark --set Title
-(void)setTitle{
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.frame = CGRectMake((SCREEN_WIDTH -100)/2, SCREEN_HEIGHT - 54, 100, 44);
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.text = [NSString stringWithFormat:@"%ld of %ld",self.index+1,self.assetBigArray.count];
    [self.view addSubview:_titleLabel];
}

#pragma mark --add Action
- (void)doneAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark --create scrollView
- (void)createScrollView
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 84, SCREEN_WIDTH, SCREEN_HEIGHT - 84*2)];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    //存在bug
    for (int i=0; i<self.assetBigArray.count; i++) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH*i, 0, SCREEN_WIDTH, scrollView.frame.size.height)];
        [[LHPhotoList sharePhotoTool]requestImageForAsset:self.assetBigArray[i] size:CGSizeMake(1080, 1920) resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image, NSDictionary *info) {
            imageView.image = image;
        }];
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doneAction:)];
        [imageView addGestureRecognizer:gesture];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [scrollView addSubview:imageView];
    }
    scrollView.contentSize = CGSizeMake(self.assetBigArray.count*SCREEN_WIDTH, scrollView.frame.size.height);
    scrollView.contentOffset = CGPointMake(SCREEN_WIDTH*self.index, 0);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --statues view
- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - UIScrollView delegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x/scrollView.bounds.size.width;
    _titleLabel.text = [NSString stringWithFormat:@"%ld / %ld",index+1, self.assetBigArray.count];
}


@end
