//
//  HBPageViewController.m
//  HBPageKit
//
//  Created by LYP on 2018/9/14.
//  Copyright © 2018年 LYP. All rights reserved.
//

#import "HBPageViewController.h"

@interface HBPageViewController () <UIScrollViewDelegate>
@property (nonatomic, assign) NSInteger selectIdx;
@property (nonatomic, assign) NSInteger preToIdx;
@property (nonatomic, strong) NSMutableSet <id<HBPageViewControllerTrackerProtocol>> *internalTrackers;

@property (nonatomic, strong) UIScrollView *contentView;
@end

@implementation HBPageViewController
- (instancetype)initWithViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers
                            selectIndex:(NSInteger)selectIndex {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        [self commonInit];
        _viewControllers = viewControllers.copy;
        _selectIdx = selectIndex;
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _internalTrackers = [NSMutableSet set];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupContentView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutContentView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.curVc beginAppearanceTransition:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.curVc endAppearanceTransition];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.curVc beginAppearanceTransition:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.curVc endAppearanceTransition];
}

#pragma mark - Setup UI
- (void)setupContentView {
    self.view.backgroundColor = [UIColor whiteColor];
    [self layoutContentView];
    [self.view addSubview:self.contentView];
    [self setupViewControllers];
}

- (void)setupViewControllers {
    NSParameterAssert(self.viewControllers);
    NSParameterAssert(self.viewControllers.count > 0);
    NSParameterAssert(self.selectIdx >= 0 && self.selectIdx < self.viewControllers.count);
    
    [self tellTrackerWillScrollTo:self.selectIdx];
    
    [self addChildViewControllerIfNeeded:self.selectIdx];
    [self tellTrackerDidScrollTo:self.selectIdx];
}

- (void)layoutContentView {
    self.contentView.frame = self.view.bounds;
    self.contentView.contentOffset = CGPointMake(CGRectGetWidth(self.view.bounds) * self.selectIdx, 0);
    self.contentView.contentSize = (CGSize){CGRectGetWidth(self.view.bounds) * self.viewControllers.count, CGRectGetHeight(self.view.bounds)};
}

#pragma mark - Override
- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return NO;
}

#pragma mark - Public Methods
- (void)jumpToPage:(NSInteger)index {
    if (index < 0 || index >= self.viewControllers.count) return;
    
    [self.contentView setContentOffset:CGPointMake(self.contentView.bounds.size.width * index, 0) animated:NO];
}

#pragma mark Tracker Manage
- (void)addTracker:(id<HBPageViewControllerTrackerProtocol>)tracker {
    if (!tracker) return;
    [self.internalTrackers addObject:tracker];
}

- (void)removeTracker:(id<HBPageViewControllerTrackerProtocol>)tracker {
    if (!tracker) return;
    [self.internalTrackers removeObject:tracker];
}

#pragma mark - Protocol
#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat curIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
    NSInteger to = curIndex > self.selectIdx ? ceil(curIndex) : floor(curIndex);
    
    CGFloat percent = fmodf(scrollView.contentOffset.x, scrollView.frame.size.width) / scrollView.frame.size.width;
    if (percent > 0) {
        percent = (curIndex > self.selectIdx) ? percent : (1 - percent);
    }
    
    [self scrollTo:to percent:percent offset:scrollView.contentOffset.x];
}

#pragma mark - Private Mthods
- (void)scrollTo:(NSInteger)to percent:(CGFloat)percent offset:(CGFloat)offset {
    if (to < 0 || to >= self.viewControllers.count) return;
//    NSLog(@"cur :%ld, %ld -> %ld, percent :%g, offset :%g", self.selectIdx, self.preToIdx, to, percent, offset);
    
    // Add new child view
    [self addChildViewControllerIfNeeded:to];
    
    // Forward child appearance methods
    [self forwardChildsAppearenceMethodsWithToIndex:to percent:percent];
    
    // Tell Tracker Scroll Progress
    [self tellTrackerScrollProgressFrom:self.selectIdx to:to percent:percent];
    
    // Save pre to idx
    self.preToIdx = to;
}

- (void)addChildViewControllerIfNeeded:(NSInteger)idx {
    
    UIViewController *vc = self.viewControllers[idx];
    if (vc.parentViewController == self) return;
    
    vc.view.frame = CGRectMake(CGRectGetWidth(self.contentView.bounds) * idx, 0, CGRectGetWidth(self.contentView.bounds), CGRectGetHeight(self.contentView.bounds));
    vc.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self addChildViewController:vc];
    [self.contentView addSubview:vc.view];
    [vc didMoveToParentViewController:self];
}

- (void)forwardChildsAppearenceMethodsWithToIndex:(NSInteger)to percent:(CGFloat)percent {
    if (self.preToIdx != to &&
        self.selectIdx != to) { // 滑动到一个新的页面
        
        if (self.preToIdx != self.selectIdx) { // 已经滑出选中页面
            UIViewController *curVc = self.curVc;
            [curVc endAppearanceTransition];
            self.selectIdx = self.preToIdx;
            [self tellTrackerDidScrollTo:self.selectIdx];
        }
        
        UIViewController *curVc = self.curVc;
        UIViewController *toVc = self.viewControllers[to];
        [toVc beginAppearanceTransition:YES animated:YES];
        [curVc beginAppearanceTransition:NO animated:YES];
        [self tellTrackerWillScrollTo:to];
    }
    
    if (percent == 0) { // 停止滑动
        if (self.selectIdx == to) {
            if (self.preToIdx != self.selectIdx) {
                UIViewController *preToVc = self.viewControllers[self.preToIdx];
                UIViewController *curVc = self.curVc;
                
                [curVc beginAppearanceTransition:YES animated:YES];
                [preToVc beginAppearanceTransition:NO animated:YES];
                [curVc endAppearanceTransition];
                [preToVc endAppearanceTransition];
                [self tellTrackerDidScrollTo:self.selectIdx];
            }
        } else {
            UIViewController *toVc = self.viewControllers[to];
            UIViewController *curVc = self.curVc;
            
            [toVc endAppearanceTransition];
            [curVc endAppearanceTransition];
            
            self.selectIdx = to;
            [self tellTrackerDidScrollTo:self.selectIdx];
        }
    }
}

#pragma mark - Call Tracker Methods
- (void)tellTrackerWillScrollTo:(NSInteger)to {
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageViewController:willScrollTo:)]) {
        [self.delegate pageViewController:self willScrollTo:to];
    }
    
    [self.trackers enumerateObjectsUsingBlock:^(id<HBPageViewControllerTrackerProtocol>  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(pageViewController:willScrollTo:)]) {
            [obj pageViewController:self willScrollTo:to];
        }
    }];
}

- (void)tellTrackerDidScrollTo:(NSInteger)to {
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageViewController:didScrollTo:)]) {
        [self.delegate pageViewController:self didScrollTo:to];
    }
    
    [self.trackers enumerateObjectsUsingBlock:^(id<HBPageViewControllerTrackerProtocol>  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(pageViewController:didScrollTo:)]) {
            [obj pageViewController:self didScrollTo:to];
        }
    }];
}

- (void)tellTrackerScrollProgressFrom:(NSInteger)from to:(NSInteger)to percent:(CGFloat)percent {
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageViewController:scrollFrom:to:percent:)]) {
        [self.delegate pageViewController:self scrollFrom:self.selectIdx to:to percent:percent];
    }
    
    [self.trackers enumerateObjectsUsingBlock:^(id<HBPageViewControllerTrackerProtocol>  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(pageViewController:scrollFrom:to:percent:)]) {
            [obj pageViewController:self scrollFrom:self.selectIdx to:to percent:percent];
        }
    }];
}

#pragma mark - Getter
- (UIScrollView *)contentView {
    if (!_contentView) {
        _contentView = [[UIScrollView alloc] init];
        _contentView.delegate = self;
        _contentView.pagingEnabled = YES;
        _contentView.bounces = NO;
//        _contentView.indexDisplayMode = UIScrollViewIndexDisplayModeAlwaysHidden;
        _contentView.scrollsToTop = NO;
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _contentView;
}

- (UIViewController *)curVc {
    if (self.selectIdx >= 0 &&
        self.selectIdx < self.viewControllers.count) {
        return self.viewControllers[self.selectIdx];
    }
    return nil;
}

- (NSSet<id<HBPageViewControllerTrackerProtocol>> *)trackers {
    return self.internalTrackers.copy;
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}
@end
