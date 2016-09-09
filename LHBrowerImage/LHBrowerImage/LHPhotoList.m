//
//  LHPhotoList.m
//  testImage
//
//  Created by lh on 16/9/2.
//  Copyright © 2016年 lh. All rights reserved.
//

#import "LHPhotoList.h"
#import "LHConst.h"
@implementation LHPhotoAblumList

@end

@implementation LHPhotoList
static LHPhotoList *sharePhotoTool = nil;
+ (instancetype)sharePhotoTool
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharePhotoTool = [[self alloc] init];
    });
    return sharePhotoTool;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharePhotoTool = [super allocWithZone:zone];
    });
    return sharePhotoTool;
}

#pragma mark - save image to photos
- (void)saveImageToAblum:(UIImage *)image completion:(void (^)(BOOL, PHAsset *))completion
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusDenied) {
        if (completion) completion(NO, nil);
    } else if (status == PHAuthorizationStatusRestricted) {
        if (completion) completion(NO, nil);
    } else {
        __block NSString *assetId = nil;
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            assetId = [PHAssetCreationRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (!success) {
                if (completion) completion(NO, nil);
                return;
            }
            if(assetId == nil){
                if (completion) completion(NO,nil);
                return;
            }
            PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].lastObject;
            
            PHAssetCollection *desCollection = [self getDestinationCollection];
            if (!desCollection) completion(NO, nil);
            
            //save image
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [[PHAssetCollectionChangeRequest changeRequestForAssetCollection:desCollection] addAssets:@[asset]];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (completion) completion(success, asset);
            }];
        }];
    }
}

//To get custom photo album
- (PHAssetCollection *)getDestinationCollection
{
    //To find whether have created a custom photo album
    PHFetchResult<PHAssetCollection *> *collectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collectionResult) {
        if ([collection.localizedTitle isEqualToString:CollectionName]) {
            return collection;
        }
    }
    //The new custom photo album
    __block NSString *collectionId = nil;
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        collectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:CollectionName].placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    if (error) {
        NSLog(@"create album：%@failed", CollectionName);
        return nil;
    }
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[collectionId] options:nil].lastObject;
}

#pragma mark - list albums
- (NSArray<LHPhotoAblumList *> *)getPhotoAblumList
{
    NSMutableArray<LHPhotoAblumList *> *photoAblumList = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    //Get all the smart albums
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL *stop) {
        //The filtered video and recently removed
        if(collection.assetCollectionSubtype != 202 && collection.assetCollectionSubtype < 212){
            __strong typeof(weakSelf) strongSelf = weakSelf;
            NSArray<PHAsset *> *assets = [strongSelf getAssetsInAssetCollection:collection ascending:NO];
            if (assets.count > 0) {
                LHPhotoAblumList *ablum = [[LHPhotoAblumList alloc] init];
                ablum.title = [strongSelf transFormPhotoTitle:collection.localizedTitle];
                ablum.count = assets.count;
                ablum.headImageAsset = assets.firstObject;
                ablum.assetCollection = collection;
                [photoAblumList addObject:ablum];
            }
        }
    }];
    
    //For users to create photo albums
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSArray<PHAsset *> *assets = [strongSelf getAssetsInAssetCollection:collection ascending:NO];
        if (assets.count > 0) {
            LHPhotoAblumList *ablum = [[LHPhotoAblumList alloc] init];
            ablum.title = [strongSelf transFormPhotoTitle:collection.localizedTitle];
            ablum.count = assets.count;
            ablum.headImageAsset = assets.firstObject;
            ablum.assetCollection = collection;
            [photoAblumList addObject:ablum];
        }
    }];
    
    return photoAblumList;
}

- (PHFetchResult *)fetchAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending
{
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:option];
    return result;
}

#pragma mark - all photos
- (NSArray<PHAsset *> *)getAllAssetInPhotoAblumWithAscending:(BOOL)ascending
{
    NSMutableArray<PHAsset *> *assets = [NSMutableArray array];
    
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    //ascending To YES, according to the pictures the creation time of ascending;To NO, the descending order
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:option];
    
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAsset *asset = (PHAsset *)obj;
        [assets addObject:asset];
    }];
    
    return assets;
}

#pragma mark - For all images within a specified album
- (NSArray<PHAsset *> *)getAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending
{
    NSMutableArray<PHAsset *> *arr = [NSMutableArray array];
    
    PHFetchResult *result = [self fetchAssetsInAssetCollection:assetCollection ascending:ascending];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (((PHAsset *)obj).mediaType == PHAssetMediaTypeImage) {
            [arr addObject:obj];
        }
    }];
    return arr;
}

#pragma mark - To obtain the asset corresponding pictures
- (void)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *, NSDictionary *))completion
{
    //Request a larger screen, when switching images, cancel a picture on request, for up to the pictures, can save the traffic
    static PHImageRequestID requestID = -1;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat width = MIN(kViewWidth, kMaxImageWidth);
    if (requestID >= 1 && size.width/width==scale) {
        [[PHCachingImageManager defaultManager] cancelImageRequest:requestID];
    }
    
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    /**
     resizeMode：For the request of image zooming.There are three options: None, the default load;Fast, as soon as possible to provide close to or slightly greater than the required size;Exact and accurate to provide the size of the requirements.
     deliveryMode：Image quality.There are three values: Opportunistic, balanced in speed and quality;HighQualityFormat, no matter how long it takes, provides the high quality images;FastFormat, with the fastest speed to provide good quality.
     This attribute is only valid at the time of synchronous to true.
     */
    
    option.resizeMode = resizeMode;//Control the photo size
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;//Control the quality
    option.networkAccessAllowed = YES;
    
    /*
     info Dictionaries provide request status information:
     PHImageResultIsInCloudKey：Whether the image must be from up to the request
     PHImageResultIsDegradedKey：The current UIImage is low quality, this can be achieved to the user to display a preview first
     PHImageResultRequestIDKey和PHImageCancelledKey：Request ID and whether the request has been cancelled
     PHImageErrorKey：If there is no image, in the dictionary of error information
     */
    
    requestID = [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey];
        //Don't the judgment, that is, if the picture on the up, will first show a vague preview and after being loaded Gao Qingtu will be shown
        // && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]
        if (downloadFinined && completion) {
            completion(image, info);
        }
    }];
}

- (void)requestImageForAsset:(PHAsset *)asset scale:(CGFloat)scale resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *image))completion
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = resizeMode;//Control the photo size
    option.networkAccessAllowed = YES;
    
    [[PHCachingImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
        if (downloadFinined && completion) {
            CGFloat sca = imageData.length/(CGFloat)UIImageJPEGRepresentation([UIImage imageWithData:imageData], 1).length;
            NSData *data = UIImageJPEGRepresentation([UIImage imageWithData:imageData], scale==1?sca:sca/2);
            completion([UIImage imageWithData:data]);
        }
    }];
}

- (NSString *)transformDataLength:(NSInteger)dataLength {
    NSString *bytes = @"";
    if (dataLength >= 0.1 * (1024 * 1024)) {
        bytes = [NSString stringWithFormat:@"%.1fM",dataLength/1024/1024.0];
    } else if (dataLength >= 1024) {
        bytes = [NSString stringWithFormat:@"%.0fK",dataLength/1024.0];
    } else {
        bytes = [NSString stringWithFormat:@"%zdB",dataLength];
    }
    return bytes;
}

- (BOOL)judgeAssetisInLocalAblum:(PHAsset *)asset
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.networkAccessAllowed = NO;
    option.synchronous = YES;
    
    __block BOOL isInLocalAblum = YES;
    
    [[PHCachingImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        isInLocalAblum = imageData ? YES : NO;
    }];
    return isInLocalAblum;
}
//Temporarily do not need to
//- (void)getPhotosBytesWithArray:(NSArray *)photos completion:(void (^)(NSString *photosBytes))completion
//{
//    __block NSInteger dataLength = 0;
//    
//    __block NSInteger count = photos.count;
//    
//    __weak typeof(self) weakSelf = self;
//    for (int i = 0; i < photos.count; i++) {
//        LHSelectPhotoModel *model = photos[i];
//        [[PHCachingImageManager defaultManager] requestImageDataForAsset:model.asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
//            __strong typeof(weakSelf) strongSelf = weakSelf;
//            dataLength += imageData.length;
//            count--;
//            if (count <= 0) {
//                if (completion) {
//                    completion([strongSelf transformDataLength:dataLength]);
//                }
//            }
//        }];
//    }
//}
-(NSString *)transFormPhotoTitle:(NSString *)englishName{
    NSString *photoName;
    if ([englishName isEqualToString:@"Bursts"]) {
        photoName = @"连拍快照";
    }else if([englishName isEqualToString:@"Recently Added"]){
        photoName = @"最近添加";
    }else if([englishName isEqualToString:@"Screenshots"]){
        photoName = @"屏幕快照";
    }else if([englishName isEqualToString:@"Camera Roll"]){
        photoName = @"相机胶卷";
    }else if([englishName isEqualToString:@"Selfies"]){
        photoName = @"自拍";
    }else if([englishName isEqualToString:@"QQ"]){
        photoName = @"QQ";
    }else if([englishName isEqualToString:@"My Photo Stream"]){
        photoName = @"我的照片流";
    }else if([englishName isEqualToString:@"LHBrowerImage"]){
    photoName = @"测试";
    }else{
        photoName = [NSString stringWithFormat:@"%@",englishName];
    }
    return photoName;
}
@end
