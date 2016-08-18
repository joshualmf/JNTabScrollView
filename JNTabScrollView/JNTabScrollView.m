//
//  JNTabScrollView.m
//  pageControl
//
//  Created by Joshua on 16/8/4.
//  Copyright © 2016年 JN. All rights reserved.
//

#import "JNTabScrollView.h"

#define JNTabHeiht                      (40.0f)
#define JNTabTitleFactor                (3/4.0f)
#define JNTabUnderLineWidth             (2.0f)
#define JNTabUnderLineAnimateInterval   (0.3f)
#define JNTabSplitLineHeight            (1.0f)

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
    NSMutableArray      *_tabButtons;
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
    _tabButtons = [[NSMutableArray alloc] init];
    _currentIndex = 0;
    _visibleCount = 5;
    _defaultIndex = -1;

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
    
    [self updateUI];
    
    if (_defaultIndex > 0) {
        [self switchToIndex:_defaultIndex animated:NO];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateFrame];
}

- (void)setupTabs
{
    if (_dataSource && [_dataSource respondsToSelector:@selector(numberOfTabs)]) {
        NSInteger tabNum = [_dataSource numberOfTabs];
        CGFloat visibleNum = MIN(self.visibleCount + 0.5, tabNum);
        _tabButtonWidth = self.width / visibleNum;
        
        [self drawSelectedUnderlineWithSize:CGSizeMake(_tabButtonWidth, JNTabUnderLineWidth)];
        [_tabButtons removeAllObjects];
        for (int i = 0; i < tabNum; i++) {
            NSString *title = [_dataSource titleOfTabAtIndex:i];
            UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [titleButton setTitle:title forState:UIControlStateNormal];
            [titleButton setTitleColor:self.fontColor forState:UIControlStateNormal];
            titleButton.frame = CGRectMake(i * _tabButtonWidth, self.tabHeight - self.tabHeight * JNTabTitleFactor, _tabButtonWidth, self.tabHeight * JNTabTitleFactor);
            titleButton.tag = i;
            [titleButton addTarget:self action:@selector(tabButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_titleTab addSubview:titleButton];
            [_tabButtons addObject:titleButton];
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
            [self switchToIndex:button.tag animated:YES];
        }
    }
}

- (void)switchToIndex:(NSInteger)index animated:(BOOL)animated
{
    if (![self needScrollForIndex:index]) {
        return;
    }
    
    //[self moveUnderlineToIndex:index];
    [self scrollContentToIndex:index animated:animated];
}

- (void)moveUnderlineToIndex:(NSInteger)index animated:(BOOL)animated
{
    CGRect pastRect = _selectedUnderLine.frame;
    
    CGRect nextRect = pastRect;
    nextRect.origin.x = index * _tabButtonWidth;
    
    if (animated) {
        [UIView animateWithDuration:JNTabUnderLineAnimateInterval animations:^{
            _selectedUnderLine.frame = nextRect;
        }];
    } else {
        _selectedUnderLine.frame = nextRect;
    }

    if (nextRect.origin.x + nextRect.size.width > _titleTab.contentOffset.x + self.width) {
        // 下划线游标超过屏幕最右侧
        [_titleTab setContentOffset:CGPointMake(nextRect.origin.x + _tabButtonWidth - self.width, _titleTab.contentOffset.y) animated:animated];
    } else if (_titleTab.contentOffset.x > nextRect.origin.x) {
        // 下划线游标超过屏幕最左侧
        [_titleTab setContentOffset:CGPointMake(nextRect.origin.x, _titleTab.contentOffset.y) animated:animated];
    }
    
    [self updateTabColor:index];
    [self updateUnderLinePosition:index animated:animated];
    
    _currentIndex = index;
    if (index == _defaultIndex) {
        // 初始化结束
        _defaultIndex = -1;
    }
}

- (void)updateTabColor:(NSInteger)index
{
    for (int i = 0; i < [_tabButtons count]; i++) {
        UIButton *titleButton = [_tabButtons objectAtIndex:i];
        if (index == i) {
            [titleButton setTitleColor:self.underLineColor forState:UIControlStateNormal];
        } else {
            [titleButton setTitleColor:self.fontColor forState:UIControlStateNormal];
        }
    }
}

- (void)updateUnderLinePosition:(NSInteger)index animated:(BOOL)animated
{
    CGFloat offsetMin = 0.0f;
    CGFloat offsetMax = _titleTab.contentSize.width - self.width;
    CGFloat offset = (index - 2) * _tabButtonWidth;
    CGFloat finalOffset = MIN(MAX(offset, offsetMin), offsetMax);
    
    [_titleTab setContentOffset:CGPointMake(finalOffset, 0) animated:animated];
}

- (BOOL)needScrollForIndex:(NSInteger)index
{
    return (index < [_tabButtons count] && _currentIndex != index);
}

- (void)scrollContentToIndex:(NSInteger)index animated:(BOOL)animated
{
    [_contentView setContentOffset:CGPointMake(index * self.width, 0) animated:animated];
}


#pragma mark - scrollview scroll delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 使用round就不用区分左滑还是右滑。
    // 当滑动超过半个屏幕的时候，触发tab滑动
    NSInteger index = round(_contentView.contentOffset.x / self.width);
    [self moveUnderlineToIndex:index animated:(_defaultIndex < 0)];
}
@end
