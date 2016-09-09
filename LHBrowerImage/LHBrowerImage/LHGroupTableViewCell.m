//
//  LHGroupTableViewCell.m
//  LHBrowerImage
//
//  Created by lh on 16/9/5.
//  Copyright © 2016年 lh. All rights reserved.
//

#import "LHGroupTableViewCell.h"
#import "LHConst.h"
CG_INLINE CGRect
RectMake(CGFloat x, CGFloat y, CGFloat width, CGFloat height)
{
    CGRect rect;
    rect.origin.x = x*SCREEN_WIDTH/320; rect.origin.y = y*SCREEN_HEIGHT/568;
    rect.size.width = width*SCREEN_WIDTH/320; rect.size.height = height*SCREEN_HEIGHT/568;
    return rect;
}
@interface LHGroupTableViewCell()
@property (nonatomic,strong) UIImageView *leftImageView;//left image
@property (nonatomic,strong) UILabel *nameLabel;//album name
@end

@implementation LHGroupTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self createUI];
    }
    return self;
}

-(void)createUI{
    
    UIImageView *leftImage = [[UIImageView alloc]init];
    leftImage.frame = RectMake(0, 0, 72, 72);
    [self.contentView addSubview:leftImage];
    self.leftImageView = leftImage;
    UILabel *name = [[UILabel alloc]init];
    name.frame = RectMake(82, 21, 220, 30);
    name.textAlignment = NSTextAlignmentLeft;
    name.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:name];
    self.nameLabel = name;
    UIImageView *rightImage = [[UIImageView alloc]init];
    rightImage.frame = RectMake(293, (72-11.5)/2, 7, 11.5);
    rightImage.image = [UIImage imageNamed:@"icon01@2x"];
    [self.contentView addSubview:rightImage];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark -show ui
-(void)configUi:(LHPhotoAblumList *)album{
    
    [[LHPhotoList sharePhotoTool] requestImageForAsset:album.headImageAsset size:CGSizeMake(72*3, 72*3) resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image, NSDictionary *info) {
        self.leftImageView.image = image;
    }];
    self.nameLabel.text = [NSString stringWithFormat:@"%@ (%ld)",album.title,album.count];
    
}
@end
