//
//  ViewController.m
//  LHBrowerImage
//
//  Created by lh on 16/9/2.
//  Copyright © 2016年 lh. All rights reserved.
//

#import "ViewController.h"
#import "LHGroupViewController.h"
#import "LHCollectionViewController.h"
@interface ViewController()
@property (nonatomic,strong) NSMutableArray *imageArray;
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from
    self.view.backgroundColor = [UIColor whiteColor];
    self.imageArray = [NSMutableArray new];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"添加照片" style:UIBarButtonItemStylePlain target:self action:@selector(toAdd)];
    
}

-(void)toAdd{
    UIAlertController *alert = [[UIAlertController alloc]init];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"本地" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self acquireLocal];
    }];
    UIAlertAction *archiveAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:cancelAction];
    [alert addAction:deleteAction];
    [alert addAction:archiveAction];
    [self presentViewController:alert animated:YES completion:nil];
}
//
#pragma mark -获取本地图片
-(void)acquireLocal{
    LHGroupViewController *group = [[LHGroupViewController alloc]init];
    group.maxChooseNumber = 4;
    __weak ViewController *weakSelf = self;
    group.backImageArray = ^(NSMutableArray<PHAsset *> *array){
        if (array) {
            //处理图片
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                __strong ViewController *strongSelf = weakSelf;
                for (int i = 0; i<array.count; i++) {
                    PHAsset *asset = array[i];
                    [[LHPhotoList sharePhotoTool]requestImageForAsset:asset scale:1 resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image) {
                        UIImage *compressImage = [strongSelf imageUserToCompressForSizeImage:CGSizeMake(1920, 1180) withImage:image];
                        [_imageArray addObject:compressImage];
                        NSLog(@"%ld",strongSelf.imageArray.count);
                    }];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [strongSelf setSpread];
                    });
                }
                
                });
        }
    };
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:group] animated:YES completion:nil];
}

#pragma mark -展示UI在界面
-(void)setSpread{
    NSLog(@"%ld",_imageArray.count);
    UIScrollView *scrol = [[UIScrollView alloc]init];
    scrol.frame = CGRectMake(0, 100, 320, 100);
    scrol.backgroundColor = [UIColor redColor];
    [self.view addSubview:scrol];
    
    for (int i = 0; i<self.imageArray.count; i++) {
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.frame = CGRectMake(0+50*i+10*i, 0, 50, 60);
        imageView.image = self.imageArray[i];
        [scrol addSubview:imageView];
    }
    scrol.contentSize = CGSizeMake(60*self.imageArray.count, 60);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -图片做一个稍微的处理
-(UIImage *)imageUserToCompressForSizeImage :(CGSize)size withImage:(UIImage *)changeImage{
    UIImage *newImage = nil;
    CGSize originalSize = changeImage.size;//获取原始图片size
    CGFloat originalWidth = originalSize.width;//宽
    CGFloat originalHeight = originalSize.height;//高
    if ((originalWidth <= size.width) && (originalHeight <= size.height)) {
        newImage = changeImage;//宽和高同时小于要压缩的尺寸时返回原尺寸
    }
    else{
        //新图片的宽和高
        CGFloat scale = (float)size.width/originalWidth < (float)size.height/originalHeight ? (float)size.width/originalWidth : (float)size.height/originalHeight;
        CGSize newImageSize = CGSizeMake(originalWidth*scale , originalHeight*scale );
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(newImageSize.width , newImageSize.height ), NO, changeImage.scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(context, 1, -1);
        CGContextTranslateCTM(context, 0, -newImageSize.height);
        CGContextSaveGState(context);
        CGContextDrawImage(context, CGRectMake(0, 0, newImageSize.width, newImageSize.height), changeImage.CGImage);
        CGContextRestoreGState(context);
        //        [self drawInRect:CGRectMake(0, 0, newImageSize.width, newImageSize.height) blendMode:kCGBlendModeNormal alpha:1.0];
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newImage;
}



@end
