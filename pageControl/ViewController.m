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
@end
