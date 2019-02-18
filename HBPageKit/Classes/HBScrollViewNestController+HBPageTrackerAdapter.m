//
//  HBScrollViewNestController+HBPageTrackerAdapter.m
//  HBPageKit
//
//  Created by LYP on 2018/9/25.
//  Copyright © 2018年 LYP. All rights reserved.
//

#import "HBScrollViewNestController+HBPageTrackerAdapter.h"
#import "DemoViewController.h"

@implementation HBScrollViewNestController (HBPageTrackerAdapter)

- (void)pageViewController:(HBPageViewController *)pageViewController willScrollTo:(NSInteger)to {
    [self willScrollTo:[(DemoViewController *)[pageViewController.viewControllers objectAtIndex:to] tbl]];
}

- (void)pageViewController:(HBPageViewController *)pageViewController didScrollTo:(NSInteger)to {
    [self didScrollTo:[(DemoViewController *)[pageViewController.viewControllers objectAtIndex:to] tbl]];
}
@end
