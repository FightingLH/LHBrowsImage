//
//  TestViewController.m
//  LHBrowerImage
//
//  Created by lh on 2017/7/1.
//  Copyright © 2017年 lh. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()
@property (nonatomic, strong) UIView *bgView;
@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    
    UIView *tes = [[UIView alloc]initWithFrame:CGRectMake(15, 80, [UIScreen mainScreen].bounds.size.width - 30, [UIScreen mainScreen].bounds.size.height -160 )];
    tes.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:tes];
    
    [self.view addSubview:self.bgView];
    [UIView animateWithDuration:3 animations:^{
        self.bgView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 100);
    } completion:^(BOOL finished) {
        self.bgView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 100, [UIScreen mainScreen].bounds.size.width, 100);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (UIView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIView alloc]init];
        _bgView.backgroundColor = [UIColor whiteColor];
    }
    return _bgView;
}

@end
