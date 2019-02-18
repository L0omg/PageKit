//
//  HBScrollViewNestController.h
//  HBPageKit
//
//  Created by LYP on 2018/9/19.
//  Copyright © 2018年 LYP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HBScrollViewNestController : NSObject
@property (nonatomic, assign) CGFloat headerBottomPinHeight; ///< Default :0
@property (nonatomic, assign) BOOL headerTopPinEnable; ///< Default: NO

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong, nullable) UIView *headerView;

- (void)willScrollTo:(UIScrollView *)scrollView;
- (void)didScrollTo:(UIScrollView *)scrollView;
@end

NS_ASSUME_NONNULL_END
