//
//  HBPageViewController.h
//  HBPageKit
//
//  Created by LYP on 2018/9/14.
//  Copyright © 2018年 LYP. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HBPageViewControllerDelegate, HBPageViewControllerTrackerProtocol;
@interface HBPageViewController : UIViewController
@property (nonatomic, strong, readonly) __kindof UIViewController *curVc;
@property (nonatomic, strong) NSArray <__kindof UIViewController *> *viewControllers;

//{ Delegate & Trackers
@property (nonatomic, weak) id <HBPageViewControllerDelegate>delegate;
@property (nonatomic, strong, readonly) NSSet <id<HBPageViewControllerTrackerProtocol>> *trackers; ///< Stong References Trackers

// Tracker Manager
- (void)addTracker:(id<HBPageViewControllerTrackerProtocol>)tracker;
- (void)removeTracker:(id<HBPageViewControllerTrackerProtocol>)tracker;
//}

- (void)jumpToPage:(NSInteger)index;

- (instancetype)initWithViewControllers:(NSArray <__kindof UIViewController *> *)viewControllers selectIndex:(NSInteger)selectIndex;
@end

@protocol HBPageViewControllerDelegate <NSObject>
@optional
- (void)pageViewController:(HBPageViewController *)pageViewController scrollFrom:(NSInteger)from to:(NSInteger)to percent:(CGFloat)percent;
- (void)pageViewController:(HBPageViewController *)pageViewController willScrollTo:(NSInteger)to;
- (void)pageViewController:(HBPageViewController *)pageViewController didScrollTo:(NSInteger)to;

@end

@protocol HBPageViewControllerTrackerProtocol <HBPageViewControllerDelegate>

@optional
//- (void)

@end
NS_ASSUME_NONNULL_END

