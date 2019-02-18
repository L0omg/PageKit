//
//  HBScrollViewNestController.m
//  HBPageKit
//
//  Created by LYP on 2018/9/19.
//  Copyright © 2018年 LYP. All rights reserved.
//

#import "HBScrollViewNestController.h"

typedef NS_ENUM(NSUInteger, HBNestHeaderState) {
    HBNestHeaderStateInit = 0,
    HBNestHeaderStateInContainer,
    HBNestHeaderStateInSubScroll,
    HBNestHeaderStateTopPinning,
    HBNestHeaderStateBottomPinning,
};

@interface HBScrollViewNestController ()
@property (nonatomic, strong) UIScrollView *curSubScrollView;
@property (nonatomic, assign) HBNestHeaderState headerState;
@end

@implementation HBScrollViewNestController
- (void)dealloc {
    self.curSubScrollView = nil;
    self.headerView = nil;
    NSLog(@"%s", __func__);
}

#pragma mark - Puclic Methods
- (void)willScrollTo:(UIScrollView *)scrollView {
    [self moveHeaderToContainerView];
    [self prepareSubScrollView:scrollView];
    [self adjustSubScrollViewContentOffset:scrollView];
}

- (void)didScrollTo:(UIScrollView *)scrollView {
    self.curSubScrollView = scrollView;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self.curSubScrollView) {
        if ([keyPath isEqualToString:@"contentOffset"]) {
            [self adjustHeader];
        } else if ([keyPath isEqualToString:@"contentSize"]) {
            
        }
    } else if (object == self.headerView) {
        if ([keyPath isEqualToString:@"frame"]) {
            CGRect oldFrame = [change[NSKeyValueChangeOldKey] CGRectValue];
            CGRect newFrame = [change[NSKeyValueChangeNewKey] CGRectValue];
            if (oldFrame.size.height != newFrame.size.height) {
                [self prepare];
            }
        }
    }
}

#pragma mark - Private Methods
- (void)installScrollView:(UIScrollView *)scrollView {
    [self prepare];
    if (!scrollView) return;
    [scrollView addObserver:self forKeyPath:@"contentOffset" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
    [scrollView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
}

- (void)uninstallScrollView:(UIScrollView *)scrollView {
    if (!scrollView) return;
    [scrollView removeObserver:self forKeyPath:@"contentOffset"];
    [scrollView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)installHeaderView:(UIView *)headerView {
    [self prepare];
    if (!headerView) return;
    [headerView addObserver:self forKeyPath:@"frame" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
}

- (void)uninstallHeaderView:(UIView *)headerView {
    if (!headerView) return;
    [headerView removeFromSuperview];
    [headerView removeObserver:self forKeyPath:@"frame"];
}

#pragma mark -Header View
- (void)moveHeaderToContainerView {
    if (!self.headerView) return;
    
    if (self.headerState != HBNestHeaderStateInSubScroll &&
        self.headerState != HBNestHeaderStateInit) return;
    self.headerState = HBNestHeaderStateInContainer;
    
    CGRect frame = [self.headerView convertRect:self.headerView.bounds toView:self.containerView];
    frame.origin.x = 0;
    [self.containerView addSubview:self.headerView];
    self.headerView.frame = frame;
}

- (void)moveHeaderToCurScrollView {
    if (!self.headerView) return;
    if (!self.curSubScrollView) return;
    
    self.headerState = HBNestHeaderStateInSubScroll;
    self.headerView.frame = (CGRect){CGPointZero, self.headerView.frame.size};

    UIScrollView *scrollView = self.curSubScrollView;
    if ([scrollView isKindOfClass:[UITableView class]]) {
        UITableView *tbl = (UITableView *)scrollView;
        [tbl.tableHeaderView addSubview:self.headerView];
    } else {
        [scrollView addSubview:self.headerView];
    }
}

- (void)adjustHeader {
    if (!self.headerView) return;
    
    CGFloat contentOffsetY = self.curSubScrollView.contentOffset.y;
    CGFloat headerWidth = CGRectGetWidth(self.headerView.frame);
    CGFloat headerHeight = CGRectGetHeight(self.headerView.frame);
    CGFloat maxOffset = headerHeight - self.headerBottomPinHeight;
    
    if (contentOffsetY >= maxOffset && self.headerBottomPinHeight > 0) {
        if (self.headerState != HBNestHeaderStateBottomPinning) {
            self.headerState = HBNestHeaderStateBottomPinning;
            self.headerView.frame = CGRectMake(0, -maxOffset, headerWidth, headerHeight);
            [self.containerView addSubview:self.headerView];
        }
    } else if (contentOffsetY < 0 && self.headerTopPinEnable) {
        if (self.headerState != HBNestHeaderStateTopPinning) {
            self.headerState = HBNestHeaderStateTopPinning;
            self.headerView.frame = CGRectMake(0, 0, headerWidth, headerHeight);
            [self.containerView addSubview:self.headerView];
        }
    } else {
        if (self.headerState != HBNestHeaderStateInSubScroll) {
            [self moveHeaderToCurScrollView];
        }
    }
}

- (void)adjustSubScrollViewContentOffset:(UIScrollView *)scrollView {
    if (!scrollView) return;
    
    UIScrollView *curScrollView = self.curSubScrollView;
    CGFloat targetOffsetY = fmax(curScrollView.contentOffset.y, 0);
    CGFloat curOffsetY = scrollView.contentOffset.y;
    CGFloat maxOffset = self.headerView.frame.size.height - self.headerBottomPinHeight;
    BOOL needChange = YES;
    if (targetOffsetY == curOffsetY) {
        needChange = NO;
    } else if (targetOffsetY <= 0 && curOffsetY == 0) {
        needChange = NO;
    } else if (targetOffsetY >= maxOffset && curOffsetY >= maxOffset) {
        needChange = NO;
    }
    
    if (needChange) {
        [scrollView layoutIfNeeded]; // fix bug: 当reloadData 之后立即修改contentOffset会导致不能准确的设置（ref：https://stackoverflow.com/questions/8640409/how-to-keep-uitableview-contentoffset-after-calling-reloaddata）
        scrollView.contentOffset = CGPointMake(0, targetOffsetY);
    }
}

#pragma mark -Prepare
- (void)prepare {
    [self prepareSubScrollView:self.curSubScrollView];
    [self prepareHeaderView];
}
- (void)prepareSubScrollView:(UIScrollView *)scrollView {
    if (!scrollView) return;
    
    // adjust insets
    if ([scrollView isKindOfClass:[UITableView class]]) {
        UITableView *tbl = (UITableView *)scrollView;
        UIView *headerBgView = [[UIView alloc] initWithFrame:self.headerView.bounds];
        tbl.tableHeaderView = headerBgView;
    } else {
        scrollView.contentInset = UIEdgeInsetsMake(self.headerView.bounds.size.height, 0, 0, 0);
    }
    scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(self.headerView.bounds.size.height, 0, 0, 0);
}

- (void)prepareHeaderView {
    self.headerState = HBNestHeaderStateInit;
    [self adjustHeader];
}

#pragma mark - Setter
- (void)setCurSubScrollView:(UIScrollView *)curSubScrollView {
    if (_curSubScrollView != curSubScrollView) {
        [self uninstallScrollView:_curSubScrollView];
        
        _curSubScrollView = curSubScrollView;
        [self installScrollView:_curSubScrollView];
    }
}

- (void)setHeaderView:(UIView *)headerView {
    if (_headerView != headerView) {
        [self uninstallHeaderView:_headerView];
        
        _headerView = headerView;
        [self installHeaderView:_headerView];
    }
}
@end
