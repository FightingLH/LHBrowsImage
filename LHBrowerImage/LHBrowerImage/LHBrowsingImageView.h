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
@property (nonatomic,strong) NSMutableArray<PHAsset *>*assetBigArray;//
@property (nonatomic,assign)NSInteger index;
@end
