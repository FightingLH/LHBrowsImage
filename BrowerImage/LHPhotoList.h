//
//  LHPhotoList.h
//  testImage
//
//  Created by lh on 16/9/2.
//  Copyright © 2016年 lh. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface LHPhotoAblumList : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) PHAsset *headImageAsset;
@property (nonatomic, strong) PHAssetCollection *assetCollection;
@end
@interface LHPhotoList : NSObject
+ (instancetype)sharePhotoTool;
/**
 * @brief Save the photo albums to the system
 */
- (void)saveImageToAblum:(UIImage *)image completion:(void (^)(BOOL suc, PHAsset *asset))completion;
/**
 * @brief Get the user list all albums
 */
- (NSArray<LHPhotoAblumList *> *)getPhotoAblumList;
/**
 * @brief For all images resources in the album
 * @param ascending Whether the positive sequence arrangement created time YES, creation time is (l) sequence arrangement;NO, creation time fell (fall) sequence alignment
 */
- (NSArray<PHAsset *> *)getAllAssetInPhotoAblumWithAscending:(BOOL)ascending;
/**
 * @brief For all images within a specified album
 */
- (NSArray<PHAsset *> *)getAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending;
/**
 * @brief Each Asset obtained the corresponding pictures
 */
- (void)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *image, NSDictionary *info))completion;
/**
 * @brief Click ok, to get each Asset corresponding pictures (imageData)
 */
- (void)requestImageForAsset:(PHAsset *)asset scale:(CGFloat)scale resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *image))completion;
/**
 * @brief Get the size, in bytes array images
 */
//- (void)getPhotosBytesWithArray:(NSArray *)photos completion:(void (^)(NSString *photosBytes))completion;

/**
 * @brief Access to an array of image size for an array of bytes in a byte size
 */
- (BOOL)judgeAssetisInLocalAblum:(PHAsset *)asset ;
@end
