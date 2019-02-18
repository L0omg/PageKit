//
//  UIPageControl+MenuBar.m
//  HBPageKit
//
//  Created by LYP on 2018/9/19.
//  Copyright © 2018年 LYP. All rights reserved.
//

#import "UIPageControl+MenuBar.h"

@implementation UIPageControl (MenuBar)

#pragma mark - HBPageViewControllerTrackerProtocol
- (void)pageViewController:(HBPageViewController *)pageViewController
                scrollFrom:(NSInteger)from
                        to:(NSInteger)to
                   percent:(CGFloat)percent {
    self.currentPage = from;
}
@end
