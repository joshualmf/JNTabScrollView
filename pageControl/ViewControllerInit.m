//
//  ViewControllerInit.m
//  pageControl
//
//  Created by cmblife on 16/8/18.
//  Copyright © 2016年 Apple Inc. All rights reserved.
//

#import "ViewControllerInit.h"

@interface ViewControllerInit ()

@end

@implementation ViewControllerInit

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImage *image = [UIImage imageNamed:@"headline_title"];

    [self.imageView setImage:[self scaleAspectImage:image ToSize:self.imageView.frame.size]];
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

- (UIImage *)scaleAspectImage:(UIImage *)image ToSize:(CGSize)targetSize
{
    CGSize originSize = CGSizeMake([image size].width * image.scale, [image size].height * image.scale); //使用像素，而不是点
    CGFloat scale = MAX(targetSize.width / originSize.width, targetSize.height / originSize.height);
    CGSize expectSize = CGSizeMake(targetSize.width / scale, targetSize.height / scale);
    
    CGRect originRect = CGRectMake(0, 0, expectSize.width, expectSize.height);
    if ((originSize.width - expectSize.width) > CGFLOAT_MIN) {
        originRect.origin.x = (originSize.width - expectSize.width) / 2;
    }
    if ((originSize.height - expectSize.height) > CGFLOAT_MIN) {
        originRect.origin.y =  (originSize.height - expectSize.height) / 2;
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], originRect);
    UIImage *scaledImage = [UIImage imageWithCGImage:imageRef];
    
    return scaledImage;
}

@end
