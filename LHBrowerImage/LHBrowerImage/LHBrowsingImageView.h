//
//  LHBrowsingImageView.h
//  LHBrowerImage
//
//  Created by lh on 16/9/7.
//  Copyright © 2016年 lh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LHPhotoList.h"
@interface LHBrowsingImageView : UIViewController
@property (nonatomic,strong) NSMutableArray<PHAsset *>*assetBigArray;//用于大图浏览
@property (nonatomic,strong) NSMutableArray *fuzzyArray;
@property (nonatomic,assign)NSInteger index;
@end
