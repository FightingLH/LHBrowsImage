//
//  LHConst.h
//  LHBrowerImage
//
//  Created by lh on 16/9/6.
//  Copyright © 2016年 lh. All rights reserved.
//

#ifndef LHConst_h
#define LHConst_h
#define imageWidth  72
/////// 不建议设置太大，太大的话会导致图片加载过慢
#define kMaxImageWidth 500
#define kViewWidth      [[UIScreen mainScreen] bounds].size.width
//如果项目中设置了导航条为不透明，即[UINavigationBar appearance].translucent=NO，那么这里的kViewHeight需要-64
#define kViewHeight     [[UIScreen mainScreen] bounds].size.height
#define CollectionName [[NSBundle mainBundle].infoDictionary valueForKey:(__bridge NSString *)kCFBundleNameKey]
#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height

#endif /* LHConst_h */
