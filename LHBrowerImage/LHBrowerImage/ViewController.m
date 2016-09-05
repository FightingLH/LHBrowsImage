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
@property (nonatomic,strong) UIImageView *testImage;
@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"添加照片" style:UIBarButtonItemStylePlain target:self action:@selector(toAdd)];
   
    self.testImage = [[UIImageView alloc]init];
    self.testImage.frame = CGRectMake(10, 100, 300, 300);
    [self.view addSubview:self.testImage];
    
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

#pragma mark -获取本地图片
-(void)acquireLocal{
    LHGroupViewController *group = [[LHGroupViewController alloc]init];
    group.backImageArray = ^(id x){
        PHAsset *asset = x;
        [[LHPhotoList sharePhotoTool] requestImageForAsset:asset size:CGSizeMake(65*3, 65*3) resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image, NSDictionary *info) {
            self.testImage.image = image;
        }];
    };
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:group] animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
