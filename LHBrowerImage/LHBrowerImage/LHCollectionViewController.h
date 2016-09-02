//
//  LHCollectionViewController.h
//  testImage
//
//  Created by lh on 16/9/2.
//  Copyright © 2016年 lh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LHPhotoList.h"

@interface VZTPhotoListCell : UICollectionViewCell
@property (strong,nonatomic) UIImageView *imageView;
@property (assign,nonatomic) BOOL isChoose;//是否选择
@property (nonatomic,strong)UIButton *selectBtn;//是否选择

@end

@protocol LHCollectionViewControllerDelegate <NSObject>
-(void)backImage:(NSArray *)image;//
@end

@interface LHCollectionViewController : UIViewController
@property (nonatomic,strong) LHPhotoAblumList *album;
@end
