//
//  HBMenuBar.m
//  HBPageKit
//
//  Created by LYP on 2018/9/19.
//  Copyright © 2018年 LYP. All rights reserved.
//

#import "HBMenuBar.h"

@implementation HBMenuBar

#pragma mark - HBPageViewControllerTrackerProtocol
- (void)pageViewController:(HBPageViewController *)pageViewController
                scrollFrom:(NSInteger)from
                        to:(NSInteger)to
                   percent:(CGFloat)percent {
    NSLog(@"%ld -> %ld, %g", from, to, percent);
}
@end
