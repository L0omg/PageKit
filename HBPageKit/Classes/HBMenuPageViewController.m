//
//  HBMenuPageViewController.m
//  HBPageKit
//
//  Created by LYP on 2018/9/19.
//  Copyright © 2018年 LYP. All rights reserved.
//

#import "HBMenuPageViewController.h"

@interface HBMenuPageViewController ()

@end

@implementation HBMenuPageViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _menuBarIsEmbed = YES;
    }
    return self;
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

- (void)setupContentView {
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    self.pageViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (self.menuBarIsEmbed &&
        self.menuBar) {
        self.menuBar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:self.menuBar];
    }
    
    [self layoutContentView];
}

- (void)layoutContentView {
    CGFloat pageOriginY = 0;
    if (self.menuBarIsEmbed &&
        self.menuBar) {
        self.menuBar.frame = CGRectMake(0, 0, self.view.frame.size.width, self.menuBar.frame.size.height);
        pageOriginY += self.menuBar.frame.size.height;
    }
    self.pageViewController.view.frame = CGRectMake(0, pageOriginY, self.view.frame.size.width, self.view.frame.size.height - pageOriginY);
}

#pragma mark - Getter
- (HBPageViewController *)pageViewController {
    if (!_pageViewController) {
        _pageViewController = [[HBPageViewController alloc] init];
    }
    return _pageViewController;
}

- (void)setMenuBar:(UIView<HBPageViewControllerTrackerProtocol> *)menuBar {
    if (_menuBar != menuBar) {
        if (_menuBar) {
            [self.pageViewController removeTracker:_menuBar];
        }
        _menuBar = menuBar;
        if (_menuBar) {
            [self.pageViewController addTracker:_menuBar];
        }
    }
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}
@end
