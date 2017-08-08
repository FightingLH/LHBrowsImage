//
//  BeeHiveViewController.m
//  LHBrowerImage
//
//  Created by lh on 2017/7/10.
//  Copyright © 2017年 lh. All rights reserved.
//

#import "BeeHiveViewController.h"
#import "BeeHiveTableViewCell.h"

@interface BeeHiveViewController ()<UITableViewDelegate,UITableViewDataSource>
@property  (nonatomic, strong)  UITableView  *tableView;
@end

@implementation BeeHiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    cell = [tableView  dequeueReusableCellWithIdentifier:@"test"];
    if (!cell)
    {
        
    }
    return cell;
}

- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
        [_tableView registerNib:[UINib nibWithNibName:@"BeeHiveTableViewCell" bundle:nil] forCellReuseIdentifier:@"test"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
    }
    return _tableView;
    
}

@end
