//
//  LHBrowsingImageView.m
//  LHBrowerImage
//
//  Created by lh on 16/9/7.
//  Copyright © 2016年 lh. All rights reserved.
//
//浏览大图类似微信从小图访问大图效果
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
    //图片
    [self setTitle];
    [self createScrollView];
}

-(void)setTitle{
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.frame = CGRectMake((SCREEN_WIDTH -100)/2, SCREEN_HEIGHT - 54, 100, 44);
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.text = [NSString stringWithFormat:@"%ld of %ld",self.index+1,self.assetBigArray.count];
    [self.view addSubview:_titleLabel];
}

- (void)doneAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//滚动视图
- (void)createScrollView
{
    //创建滚动视图
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 84, SCREEN_WIDTH, SCREEN_HEIGHT - 84*2)];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    //设置代理
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    //显示图片
    for (int i=0; i<self.assetBigArray.count; i++) {
        //图片
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH*i, 0, SCREEN_WIDTH, scrollView.frame.size.height)];
        [[LHPhotoList sharePhotoTool]requestImageForAsset:self.assetBigArray[i] size:CGSizeMake(1080, 1920) resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image, NSDictionary *info) {
            imageView.image = image;
        }];
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

//状态栏的显示
- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - UIScrollView代理
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x/scrollView.bounds.size.width;
    //修改标题文字
    _titleLabel.text = [NSString stringWithFormat:@"%ld / %ld",index+1, self.assetBigArray.count];
}


@end
