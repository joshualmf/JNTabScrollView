//
//  JNTabScrollView.m
//  pageControl
//
//  Created by Joshua on 16/8/4.
//  Copyright © 2016年 Apple Inc. All rights reserved.
//

#import "JNTabScrollView.h"

#define JNTabHeiht                      (40.0f)
#define JNTabTitleFactor                (3/4.0f)
#define JNTabUnderLineWidth             (2.0f)
#define JNTabUnderLineAnimateInterval   (0.3f)
#define JNTabSplitLineHeight            (2.0f)

@interface JNTabScrollView ()

@property (nonatomic, strong) UIScrollView  *titleTab;
@property (nonatomic, strong) UIView        *selectedUnderLine;
@property (nonatomic, strong) UIScrollView  *contentView;


@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat contentHeight;
@end

@interface JNTabScrollView ()
{
    CGFloat     _tabButtonWidth;
    NSInteger   _currentIndex;
}
@end

@implementation JNTabScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    _titleTab = [[UIScrollView alloc] init];
    _contentView = [[UIScrollView alloc] init];
    _contentView.delegate = self;
    
    _currentIndex = 0;

    [self addSubview:_titleTab];
    [self addSubview:_contentView];
    
    [self initDefaultValue];
}

- (void)initDefaultValue
{
    self.fontColor = [UIColor blackColor];
    self.tabBackgroundColor = [UIColor whiteColor];
    self.underLineColor = [UIColor redColor];
    self.tabHeight = JNTabHeiht;
    [self updateFrame];
}

- (void)updateFrame
{
    self.width = self.frame.size.width;
    self.height = self.frame.size.height;
}

- (void)updateUI
{
    [_titleTab setBackgroundColor:self.tabBackgroundColor];
    [_contentView setBackgroundColor:[UIColor lightGrayColor]];
    
    [_titleTab setShowsHorizontalScrollIndicator:NO];
    [_contentView setShowsHorizontalScrollIndicator:NO];

    [_contentView setPagingEnabled:YES];

    [_titleTab setFrame:CGRectMake(0, 0, self.width, self.tabHeight)];
    [_contentView setFrame:CGRectMake(0, self.tabHeight + JNTabSplitLineHeight, self.width, self.height - self.tabHeight - JNTabSplitLineHeight)];

    [self setupTabs];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self updateFrame];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateUI];
}

- (void)setupTabs
{
    if (_dataSource && [_dataSource respondsToSelector:@selector(numberOfTabs)]) {
        NSInteger tabNum = [_dataSource numberOfTabs];
        CGFloat visibleNum = MIN(5.5, tabNum);
        _tabButtonWidth = self.width / visibleNum;
        
        [self drawSelectedUnderlineWithSize:CGSizeMake(_tabButtonWidth, JNTabUnderLineWidth)];
        
        for (int i = 0; i < tabNum; i++) {
            NSString *title = [_dataSource titleOfTabAtIndex:i];
            UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [titleButton setTitle:title forState:UIControlStateNormal];
            [titleButton setTitleColor:self.fontColor forState:UIControlStateNormal];
            [titleButton setTitleColor:self.underLineColor forState:UIControlStateFocused];
            
            [titleButton setBackgroundColor:[UIColor clearColor]];
            titleButton.frame = CGRectMake(i * _tabButtonWidth, self.tabHeight - self.tabHeight * JNTabTitleFactor, _tabButtonWidth, self.tabHeight * JNTabTitleFactor);
            titleButton.tag = i;
            [titleButton addTarget:self action:@selector(tabButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_titleTab addSubview:titleButton];
        }
        [_titleTab setContentSize:CGSizeMake(tabNum * _tabButtonWidth, self.tabHeight * JNTabTitleFactor)];
        
        for (int i = 0; i < tabNum; i++) {
            UIView *view = [_dataSource viewForTabAtIndex:i];
            view.frame = CGRectMake(i * self.width, 0, self.width, _contentView.frame.size.height);
            [_contentView addSubview:view];
        }
        [_contentView setContentSize:CGSizeMake(tabNum * self.width, _contentView.frame.size.height)];
        
        [self addSplitLine];
    }
}

- (void)drawSelectedUnderlineWithSize:(CGSize)lineSize
{
    CGFloat lineHeight = _titleTab.frame.size.height - lineSize.height;
    _selectedUnderLine = [[UIView alloc] initWithFrame:CGRectMake(0, lineHeight, lineSize.width, lineSize.height)];
    [_selectedUnderLine setBackgroundColor:self.underLineColor];
    [_titleTab addSubview:_selectedUnderLine];
}

- (void)addSplitLine
{
    UIView *splitLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.tabHeight, self.width, JNTabSplitLineHeight)];
    [splitLine setBackgroundColor:[UIColor lightGrayColor]];
    [self addSubview:splitLine];
}

- (void)tabButtonClicked:(UIButton *)button
{
    if (button) {
        if (button.tag >= 0) {
            [self switchToIndex:button.tag];
        }
    }
}

- (void)switchToIndex:(NSInteger)index
{
    [self moveUnderlineToIndex:index];
    [self scrollContentToIndex:index];
    _currentIndex = index;
}

- (void)moveUnderlineToIndex:(NSInteger)index
{
    CGRect pastRect = _selectedUnderLine.frame;
    
    CGRect nextRect = pastRect;
    nextRect.origin.x = index * _tabButtonWidth;
    
    [UIView animateWithDuration:JNTabUnderLineAnimateInterval animations:^{
        _selectedUnderLine.frame = nextRect;
    }];
    
    if (nextRect.origin.x + nextRect.size.width > _titleTab.contentOffset.x + self.width) {
        // 下划线游标超过屏幕最右侧
        [_titleTab setContentOffset:CGPointMake(nextRect.origin.x + _tabButtonWidth - self.width, _titleTab.contentOffset.y) animated:YES];
    } else if (_titleTab.contentOffset.x > nextRect.origin.x) {
        // 下划线游标超过屏幕最左侧
        [_titleTab setContentOffset:CGPointMake(nextRect.origin.x, _titleTab.contentOffset.y) animated:YES];
    }
}

- (void)scrollContentToIndex:(NSInteger)index
{
    [_contentView setContentOffset:CGPointMake(index * self.width, 0) animated:YES];
}


#pragma mark - scrollview scroll delegate

// called when scroll view grinds to a halt
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = ceil(_contentView.contentOffset.x / self.width);
    [self switchToIndex:index];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // TODO need to refine the scroll action
    if (scrollView.decelerating) {
        return;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
}
@end
