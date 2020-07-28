//
//  LHGroupViewController.h
//  testImage
//
//  Created by lh on 16/9/2.
//  Copyright © 2016年 lh. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^backArrayBlock)(NSMutableArray *array);
@interface LHGroupViewController : UIViewController
@property (nonatomic,copy)backArrayBlock backImageArray;
@property (nonatomic,assign) NSInteger maxChooseNumber;
@end
