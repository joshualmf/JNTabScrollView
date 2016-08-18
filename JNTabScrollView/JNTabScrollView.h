//
//  JNTabScrollView.h
//  pageControl
//
//  Created by Joshua on 16/8/4.
//  Copyright © 2016年 JN. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JNTabScrollViewDelegate <NSObject>

@end

@protocol  JNTabScrollViewDataSource <NSObject>

- (NSInteger)numberOfTabs;
- (NSString *)titleOfTabAtIndex:(NSInteger)index;
- (UIView *)viewForTabAtIndex:(NSInteger)index;

@end

@interface JNTabScrollView : UIView <UIScrollViewDelegate>

@property (nonatomic, weak) id<JNTabScrollViewDelegate> delegate;
@property (nonatomic, weak) id<JNTabScrollViewDataSource> dataSource;

@property (nonatomic, strong) UIColor *fontColor;
@property (nonatomic, strong) UIColor *underLineColor;
@property (nonatomic, strong) UIColor *tabBackgroundColor;
@property (nonatomic, assign) CGFloat tabHeight;

@property (nonatomic, readonly) NSInteger currentIndex;
@property (nonatomic, assign) NSInteger defaultIndex;

@property (nonatomic, assign) NSInteger visibleCount;
@end
