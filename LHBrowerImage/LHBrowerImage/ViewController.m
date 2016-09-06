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
#define imageWidth  72
@interface ViewController()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic,strong) NSMutableArray *imageArray;//存放处理完的图片
@property (nonatomic,strong) UIScrollView *scrolView;//滚动视图
@property (nonatomic,strong) NSMutableArray *scrollSubViews;//存放图片子视图
@property (nonatomic,strong) NSMutableArray *scrollSubFrame;//子视图的frame

@property (nonatomic,strong) NSMutableArray *needUploadArray;// 最终须要上传的图片

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from
    self.view.backgroundColor = [UIColor whiteColor];
    self.imageArray = [NSMutableArray new];
    self.scrollSubViews = [NSMutableArray new];
    self.scrollSubFrame = [NSMutableArray new];
    self.needUploadArray = [NSMutableArray new];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"添加照片" style:UIBarButtonItemStylePlain target:self action:@selector(toAdd)];
    [self setScrol];
}

#pragma mark --
-(void)setScrol{
    UIScrollView *scrol = [[UIScrollView alloc]init];
    scrol.frame = CGRectMake(0, 100, 320, 77);
    [self.view addSubview:scrol];
    self.scrolView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.scrolView = scrol;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

#pragma mark --
-(void)toAdd{
    UIAlertController *alert = [[UIAlertController alloc]init];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"本地" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self acquireLocal];
    }];
    UIAlertAction *archiveAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self acquireAlbum];
    }];
    [alert addAction:cancelAction];
    [alert addAction:deleteAction];
    [alert addAction:archiveAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -获取相机相册
-(void)acquireAlbum{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = sourceType;
        if ([[[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."].firstObject integerValue]  == 8) {
            self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }
        [self presentViewController:picker animated:YES completion:nil];
    }else
    {
        NSLog(@"模拟其中无法打开照相机,请在真机中使用");
    }
    
}

#pragma mark --
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *,id> *)info {
    __block UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    __weak ViewController *weakSelf = self;
    void(^imageBlock)() = ^(UIImage *image){
        __strong ViewController *strongSelf = weakSelf;
        if (!image) {
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        [strongSelf.imageArray addObject:image];
    };
    void(^dismissBlock)() = ^(){//声明
        __strong ViewController *strongSelf = weakSelf;
        [picker dismissViewControllerAnimated:YES completion:^{
            [strongSelf setSpread];
        }];
    };
    //写入本地
    [[LHPhotoList sharePhotoTool]saveImageToAblum:originalImage completion:^(BOOL suc, PHAsset *asset) {
        if (suc) {//存取成功
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                originalImage = [UIImage imageWithData:UIImageJPEGRepresentation(originalImage, 0.1) scale:originalImage.scale];
                imageBlock(originalImage);
                dispatch_sync(dispatch_get_main_queue(), ^{
                    dismissBlock();
                });
            });
        }else{//存取失败
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                originalImage = [UIImage imageWithData:UIImageJPEGRepresentation(originalImage, 0.1) scale:originalImage.scale];
                imageBlock(originalImage);
                dispatch_sync(dispatch_get_main_queue(), ^{
                    dismissBlock();
                });
            });
        }
    }];
}

#pragma mark --
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"您取消了选择图片");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark --
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -获取本地图片
-(void)acquireLocal{
    LHGroupViewController *group = [[LHGroupViewController alloc]init];
    group.maxChooseNumber = 15;
    group.backImageArray = ^(NSMutableArray<PHAsset *> *array){
        if (array) {
            for (int i = 0; i<array.count; i++) {
                PHAsset *asset = array[i];
                [[LHPhotoList sharePhotoTool]requestImageForAsset:asset size:CGSizeMake(1080, 1920) resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image, NSDictionary *info) {
                    [_imageArray addObject:image];
                    [self setSpread];
                }];
            }
        }
    };
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:group] animated:YES completion:nil];
}

#pragma mark -展示UI在界面
-(void)setSpread{
    
    self.scrolView.contentSize = CGSizeMake((imageWidth+10)*self.imageArray.count, 77);
    for (NSInteger i = self.scrollSubViews.count; i<self.imageArray.count; i++) {
        UIView *itemView = [[UIView alloc]init];
        itemView.frame = CGRectMake(imageWidth*i+10*i, 5, imageWidth, imageWidth);
        itemView.backgroundColor = [UIColor whiteColor];
        [self.scrolView addSubview:itemView];
        
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.frame = CGRectMake(0, 0, imageWidth, imageWidth);
        imageView.image = self.imageArray[i];
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.tag = 100 +i;
        [itemView addSubview:imageView];
        //手势
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteBtn.frame = CGRectMake(imageWidth - 17 , -5, 22, 22);
        deleteBtn.tag = 200+i;
        [deleteBtn setImage:[UIImage imageNamed:@"02"] forState:UIControlStateNormal];//正常显示
        [deleteBtn addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];//删除
        [itemView addSubview:deleteBtn];
        
        [self.scrollSubFrame addObject:[NSValue valueWithCGRect:itemView.frame]];
        [self.scrollSubViews addObject:itemView];
        [UIView animateWithDuration:0.2 animations:^{
            itemView.alpha = 1;
        } completion:nil];
    }
    
}

#pragma mark -删除图片
-(void)deleteImage:(UIButton *)btn{
    UIView *view  = btn.superview;
    NSInteger idx = [_scrollSubViews indexOfObject:view];
    [_scrollSubViews removeObject:view];
    [_imageArray removeObjectAtIndex:idx];
    [_scrollSubFrame removeLastObject];
    [UIView animateWithDuration:0.2 animations:^{
        view.alpha = 0;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
        self.scrolView.contentSize = CGSizeMake(imageWidth*self.scrollSubViews.count, imageWidth);
        [UIView animateWithDuration:0.2 animations:^{
            for (NSInteger i = idx; i < self.scrollSubViews.count; i++) {
                UIView *item = self.scrollSubViews[i];
                item.frame = [(NSValue*)(self.scrollSubFrame[i]) CGRectValue];
            }
        } completion:^(BOOL finished) {
            if (finished) {
                //完成之后处理的code
            }
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
