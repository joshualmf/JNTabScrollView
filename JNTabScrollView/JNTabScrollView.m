
//
//  JNTabScrollView.m
//  pageControl
//
//

#import "JNTabScrollView.h"

#define JNTabHeiht                      (40.0f)
#define JNTabTitleFactor                (3/4.0f)
#define JNTabUnderLineWidth             (2.0f)
#define JNTabUnderLineAnimateInterval   (0.3f)
#define JNTabSplitLineHeight            (1.0f)

#define JNTabGap                        (20.0f)

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
    NSMutableArray      *_buttonLenghtArray;
    NSInteger            _tabNum;
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
    _buttonLenghtArray = [[NSMutableArray alloc] init];
    _currentIndex = 0;
    _visibleCount = 5;
    _defaultIndex = -1;
    _tabGap = JNTabGap;
    
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
    
    [_titleTab setBounces:NO];
    [_contentView setBounces:NO];
    [self setupTabs];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [self updateUI];
    
    if (_defaultIndex > 0 && _defaultIndex < _tabNum) {
        [self switchToIndex:_defaultIndex animated:NO];
    } else {
        _defaultIndex = -1;
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
        _tabNum = [_dataSource numberOfTabs];
        CGFloat visibleNum = MIN(self.visibleCount + 0.5, _tabNum);
        _tabButtonWidth = self.width / visibleNum;
        
        for (UIButton *button in _tabButtons) {
            [button removeFromSuperview];
        }
        [_tabButtons removeAllObjects];
        [_buttonLenghtArray removeAllObjects];
        
        // 计算tab的文字宽度
        for (int i = 0; i < _tabNum; i++) {
            NSString *title = [_dataSource titleOfTabAtIndex:i];
            
            CGRect actualSize = [title boundingRectWithSize: CGSizeMake(MAXFLOAT, 14.0f)
                                                    options: NSStringDrawingUsesLineFragmentOrigin
                                                 attributes: @{
                                                               NSFontAttributeName : [UIFont systemFontOfSize:14.0f]
                                                               }
                                                    context: nil];
            CGFloat buttonWidth = actualSize.size.width + JNTabGap;
            [_buttonLenghtArray addObject:@(buttonWidth)];
        }
        
        // 检查是否需要重新计算间隔
        [self updateTabGapIfNeeded];
        
        for (int i = 0; i < _tabNum; i++) {
            NSString *title = [_dataSource titleOfTabAtIndex:i];
            
            UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [titleButton setTitle:title forState:UIControlStateNormal];
            [titleButton setTitleColor:self.fontColor forState:UIControlStateNormal];
            [titleButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
            
            titleButton.frame = CGRectMake([self getTabStartX:i], self.tabHeight - self.tabHeight * JNTabTitleFactor, [self getTabWidth:i], self.tabHeight * JNTabTitleFactor);
            titleButton.tag = i;
            [titleButton addTarget:self action:@selector(tabButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_titleTab addSubview:titleButton];
            [_tabButtons addObject:titleButton];
        }
        
        [_titleTab setContentSize:CGSizeMake([self getTabStartX:(_tabNum - 1)] + [self getTabWidth:(_tabNum - 1)], self.tabHeight * JNTabTitleFactor)];
        
        for (int i = 0; i < _tabNum; i++) {
            UIView *view = [_dataSource viewForTabAtIndex:i];
            view.frame = CGRectMake(i * self.width, 0, self.width, _contentView.frame.size.height);
            [_contentView addSubview:view];
        }
        [_contentView setContentSize:CGSizeMake(_tabNum * self.width, _contentView.frame.size.height)];
        
        [self drawSelectedUnderlineWithSize:CGSizeMake(50, JNTabUnderLineWidth)];
        [self addSplitLine];
    }
}

- (CGFloat)getTabStartX:(NSInteger)index
{
    CGFloat startX = 0.0f;
    
    if (index < [_buttonLenghtArray count]) {
        for (int i = 0; i < index; i++) {
            startX += [(NSNumber *)[_buttonLenghtArray objectAtIndex:i] floatValue];
        }
        startX += _tabGap * index;
    }
    
    // 实际的文字长度加上间隔的长度
    return startX;
}

- (CGFloat)getTabWidth:(NSInteger)index
{
    CGFloat buttonWidth = 0.0f;
    if (index < [_buttonLenghtArray count]) {
        buttonWidth = [[_buttonLenghtArray objectAtIndex:index] floatValue] + _tabGap;
    }
    return buttonWidth;
}

- (void)updateTabGapIfNeeded
{
    // 判断如果当前的长度小于屏幕宽度，则重新计算间隔。
    CGFloat totalWidth = 0.0f;
    CGFloat textWidth = 0.0f;
    for (int i = 0; i < [_buttonLenghtArray count]; i++) {
        totalWidth += [[_buttonLenghtArray objectAtIndex:i] floatValue];
    }
    
    textWidth = totalWidth;
    totalWidth += [_buttonLenghtArray count] * _tabGap;
    
    if (totalWidth < self.width) {
        _tabGap = (self.width - textWidth) / [_buttonLenghtArray count];
    }
}

- (void)drawSelectedUnderlineWithSize:(CGSize)lineSize
{
    if (_selectedUnderLine == nil) {
        CGFloat lineHeight = _titleTab.frame.size.height - lineSize.height;
        _selectedUnderLine = [[UIView alloc] initWithFrame:CGRectMake([self getTabStartX:0] + (_tabGap / 2), lineHeight, [[_buttonLenghtArray objectAtIndex:0] floatValue], lineSize.height)];
        [_selectedUnderLine setBackgroundColor:self.underLineColor];
        [_titleTab addSubview:_selectedUnderLine];
    }
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
    [self scrollContentToIndex:index animated:animated];
    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollViewDidSelectTabAtIndex:)]) {
        [self.delegate scrollViewDidSelectTabAtIndex:index];
    }
}

- (void)moveUnderlineToIndex:(NSInteger)index animated:(BOOL)animated
{
    if (![self needScrollForIndex:index]) {
        return;
    }
    
    CGRect pastRect = _selectedUnderLine.frame;
    
    CGRect nextRect = pastRect;
    nextRect.origin.x = [self getTabStartX:index] + (_tabGap / 2);
    nextRect.size.width = [[_buttonLenghtArray objectAtIndex:index] floatValue];
    
    if (animated) {
        [UIView animateWithDuration:JNTabUnderLineAnimateInterval animations:^{
            _selectedUnderLine.frame = nextRect;
            [self updateUnderLinePosition:index animated:animated];
        }];
    } else {
        _selectedUnderLine.frame = nextRect;
        [self updateUnderLinePosition:index animated:animated];
    }
    
    if ([self getTabStartX:index] + [self getTabWidth:index] > _titleTab.contentOffset.x + self.width) {
        // 下划线游标超过屏幕最右侧
        //[_titleTab setContentOffset:CGPointMake([self getTabStartX:index] + [self getTabWidth:index] - self.width, _titleTab.contentOffset.y) animated:animated];
    } else if (_titleTab.contentOffset.x > [self getTabStartX:index]) {
        // 下划线游标超过屏幕最左侧
        //[_titleTab setContentOffset:CGPointMake([self getTabStartX:index], _titleTab.contentOffset.y) animated:animated];
    }
    
    [self updateTabColor:index];
    
    _currentIndex = index;
    
    if (index == _defaultIndex) {
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
    CGFloat offset = [self getTabStartX:index] - self.width / 2;
    CGFloat finalOffset = MIN(MAX(offset, offsetMin), MAX(offsetMax, offsetMin));
    
    [_titleTab setContentOffset:CGPointMake(finalOffset, 0) animated:animated];
}

- (BOOL)needScrollForIndex:(NSInteger)index
{
    return (index < [_tabButtons count] && _currentIndex != index);
}

- (void)scrollContentToIndex:(NSInteger)index animated:(BOOL)animated
{
    if (![self needScrollForIndex:index]) {
        return;
    }
    
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
