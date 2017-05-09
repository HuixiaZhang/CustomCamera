//
//  CustomCollectionViewCell.m
//  ZHXCustomCamera
//
//  Created by apple on 17/5/4.
//  Copyright © 2017年 com. All rights reserved.
//

#import "CustomCollectionViewCell.h"


@interface CustomCollectionViewCell ()

@property (nonatomic,strong) UIImageView *imgV;

@end

@implementation CustomCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self.contentView addSubview:self.imgV];
    }
    return self;
}

- (UIImageView *)imgV {
    if (!_imgV) {
        _imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 150)];
//        _imgV.backgroundColor = [UIColor cyanColor];
        
    }
    return _imgV;
}

- (void)setImg:(UIImage *)img {
    _img = img;
    _imgV.image = img;
}

- (void)setFilterName:(NSString *)filterName {
    
    _filterName = filterName;
    
    [self fliterEvent:filterName];
}

- (void)fliterEvent:(NSString *)filterName
{
    if ([filterName isEqualToString:@"OriginImage"]) {
        self.imgV.image = self.img;
        
    }else{

        //将UIImage转换成CIImage
        CIImage *ciImage = [[CIImage alloc] initWithImage:self.imgV.image];
        
        //创建滤镜
        CIFilter *filter = [CIFilter filterWithName:filterName keysAndValues:kCIInputImageKey, ciImage, nil];
        
        //已有的值不改变，其他的设为默认值
        [filter setDefaults];
        
        //获取绘制上下文
        CIContext *context = [CIContext contextWithOptions:nil];
        
        //渲染并输出CIImage
        CIImage *outputImage = [filter outputImage];
        
        //创建CGImage句柄
        CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
        
        //获取图片
        UIImage *image = [UIImage imageWithCGImage:cgImage];
        
        //释放CGImage句柄
        CGImageRelease(cgImage);
        
        //    imageView.image = image;
        
        self.imgV.image = image;
    }
}



@end
