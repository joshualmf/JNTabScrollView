//
//  ViewController.m
//  pageControl
//
//  Created by cmblife on 16/8/4.
//  Copyright © 2016年 Apple Inc. All rights reserved.
//

#import "ViewController.h"

#define SCREEN_WIDTH        ([UIScreen mainScreen].bounds.size.width)

@interface ViewController ()
{
    NSArray *categoryArray;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    categoryArray = @[@"Test1", @"Test2", @"TestJN", @"hello", @"coober", @"line", @"asdf", @"kkkk"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    JNTabScrollView *view = [[JNTabScrollView alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, 600)];
    view.dataSource = self;
    view.underLineColor = [UIColor colorWithRed:0.92 green:0.07 blue:0.07 alpha:1.0];
    [view setDefaultIndex:2];
    [self.view addSubview:view];
}

- (NSInteger)numberOfTabs
{
    return [categoryArray count];
}

- (NSString *)titleOfTabAtIndex:(NSInteger)index
{
    return [categoryArray objectAtIndex:index];
}

- (UIView *)viewForTabAtIndex:(NSInteger)index
{
    UIView *currentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    lable.center = currentView.center;
    lable.text = [NSString stringWithFormat:@"%ld", (long)index];
    [currentView addSubview:lable];
    switch (index%2) {
        case 0:
            [currentView setBackgroundColor:[UIColor whiteColor]];
            break;
        case 1:
            [currentView setBackgroundColor:[UIColor grayColor]];
            break;
        default:
            break;
    }
    return currentView;
}


- (UIImage *)scaleAspectImage:(UIImage *)image ToSize:(CGSize)targetSize
{
    CGSize originSize = [image size];
    CGFloat scale = MAX(targetSize.width / originSize.width, targetSize.height / originSize.height);
    CGSize expectSize = CGSizeMake(targetSize.width / scale, targetSize.height / scale);
    
    CGRect originRect = CGRectMake(0, 0, originSize.width, originSize.height);
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
