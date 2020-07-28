//
//  LHCollectionViewController.h
//  testImage
//
//  Created by lh on 16/9/2.
//  Copyright © 2016年 lh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LHPhotoList.h"
typedef void(^cellChooseBlock)(void);//是否选中
@interface VZTPhotoListCell : UICollectionViewCell
@property (nonatomic,copy) cellChooseBlock btnChooseBlock;//选中按钮
@end

@protocol LHCollectionViewControllerDelegate <NSObject>
-(void)backImage:(NSArray *)image;//
@end

typedef void(^imageBlock)(id x);
@interface LHCollectionViewController : UIViewController
@property (nonatomic,strong) LHPhotoAblumList *album;
@property (nonatomic,copy) imageBlock imageBlockArray;
@property (nonatomic,assign) NSInteger maxChooseNumber;//最多选择的数量
@end
