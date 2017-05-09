//
//  PhotoHandleViewController.m
//  ZHXCustomCamera
//
//  Created by apple on 17/5/4.
//  Copyright © 2017年 com. All rights reserved.
//

#import "PhotoHandleViewController.h"
#import "CustomCollectionViewCell.h"

@interface PhotoHandleViewController () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) UICollectionView *bottomC;
@property (nonatomic,strong) NSMutableArray *filterArray;
@property (nonatomic,strong) UIImageView *imgV;

@end

@implementation PhotoHandleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"图片处理";
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.imgV = [[UIImageView alloc] initWithFrame:CGRectMake(20, 70, self.view.frame.size.width - 40, self.view.frame.size.height / 2)];
    self.imgV.image = self.img;
    self.imgV.contentMode = UIViewContentModeScaleAspectFill;
    self.imgV.clipsToBounds = YES;
    [self.view addSubview:self.imgV];
    self.filterArray = [[NSMutableArray alloc] initWithObjects:
                        @"OriginImage",
                        @"CIPhotoEffectChrome",
                        @"CIPhotoEffectFade",
                        @"CIPhotoEffectInstant",
                        @"CIPhotoEffectProcess",
                        @"CIPhotoEffectTransfer",
                        @"CISRGBToneCurveToLinear",
                        @"CIColorInvert",
                        @"CIColorPosterize",
                        @"CIFalseColor",
                        @"CIXRay",
                        @"CIThermal",
                        @"CISepiaTone",
                        @"CIColorMonochrome",
                        nil];
    
    UICollectionViewFlowLayout *flowLay = [[UICollectionViewFlowLayout alloc] init];
    flowLay.itemSize = CGSizeMake(100, 150);
    flowLay.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.bottomC = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imgV.frame) + 20, self.view.frame.size.width, 200) collectionViewLayout:flowLay];
    self.bottomC.backgroundColor = [UIColor whiteColor];
    self.bottomC.delegate = self;
    self.bottomC.dataSource = self;
    [self.view addSubview:self.bottomC];
    
    [self.bottomC registerClass:[CustomCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self fliterEvent:self.filterArray[indexPath.item]];
}

#pragma mark 滤镜处理事件
- (void)fliterEvent:(NSString *)filterName
{
    if ([filterName isEqualToString:@"OriginImage"]) {
        self.imgV.image = self.img;
        
    }else{
        //将UIImage转换成CIImage
        CIImage *ciImage = [[CIImage alloc] initWithImage:[self fixOrientation:self.img]];
        
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
        
        self.imgV.image = image;
    }
}

// 由于通过cgimageref 得到的图片 会逆时针转90度的,因此用以下方法得到正确图片
#pragma mark -------
- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.filterArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.img = [self fixOrientation:self.img];
    cell.filterName = self.filterArray[indexPath.item];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
