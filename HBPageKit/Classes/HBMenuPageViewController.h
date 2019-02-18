//
//  HBMenuPageViewController.h
//  HBPageKit
//
//  Created by LYP on 2018/9/19.
//  Copyright © 2018年 LYP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBPageViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HBMenuPageViewController : UIViewController <HBPageViewControllerDelegate>
@property (nonatomic, strong, null_resettable) HBPageViewController *pageViewController;

//{ MenuBar Configure
@property (nonatomic, strong) UIView <HBPageViewControllerTrackerProtocol>* menuBar;
@property (nonatomic, assign) BOOL menuBarIsEmbed; ///< menuBar是否内嵌到MenuPageVC中，Default: YES
//}
@end

NS_ASSUME_NONNULL_END
