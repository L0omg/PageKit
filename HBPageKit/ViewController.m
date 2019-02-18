//
//  ViewController.m
//  HBPageKit
//
//  Created by LYP on 2018/9/14.
//  Copyright © 2018年 LYP. All rights reserved.
//

#import "ViewController.h"
#import "HBMenuPageViewController.h"
#import "HBMenuBar.h"
#import "UIPageControl+MenuBar.h"
#import "DemoViewController.h"
#import "HBScrollViewNestController+HBPageTrackerAdapter.h"

@interface ViewController ()
@property (nonatomic, strong) HBScrollViewNestController *nest;
@property (nonatomic, strong) HBPageViewController *containerVc;
@property (nonatomic, strong) HBMenuPageViewController *menuVc;
@property (nonatomic, strong) UIView *headerView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIPageControl *pgc = [[UIPageControl alloc] initWithFrame:CGRectMake(10, 70, 100, 30)];
    pgc.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    pgc.backgroundColor = [UIColor redColor];
    pgc.pageIndicatorTintColor = [UIColor blueColor];
    pgc.currentPageIndicatorTintColor = [UIColor greenColor];
    
    self.nest = [[HBScrollViewNestController alloc] init];
    self.nest.headerBottomPinHeight = 30;
    self.nest.headerTopPinEnable = YES;
    self.nest.containerView = self.view;
    self.nest.headerView = ({
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375, 100)];
        v.backgroundColor = [UIColor redColor];
        v.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        [v addSubview:pgc];
        v;
    });
    self.headerView = self.nest.headerView;
    
    HBMenuPageViewController *vc = [[HBMenuPageViewController alloc] init];
    vc.pageViewController = [[HBPageViewController alloc] initWithViewControllers:@[[self createVc], [self createVc], [self createVc], [self createVc], [self createVc], [self createVc], [self createVc], [self createVc]] selectIndex:2];
    [vc.pageViewController addTracker:self.nest];
    pgc.numberOfPages = vc.pageViewController.viewControllers.count;
    vc.menuBar = pgc;
    vc.menuBarIsEmbed = NO;
    vc.view.frame = self.view.bounds;
    [self addChildViewController:vc];
    [self.view insertSubview:vc.view atIndex:0];
    [vc didMoveToParentViewController:self];
    
    self.containerVc = vc.pageViewController;
    self.menuVc = vc;
}

- (UIViewController *)createVc {
    DemoViewController *vc = [DemoViewController new];
    static NSInteger tag = 0;
    vc.label.text = @(tag).description;
    tag ++;
    return vc;
}
- (IBAction)to2:(id)sender {
    self.nest.headerView = self.headerView;
    self.nest.headerView.frame = CGRectMake(0, 0, 375, rand()%200);
}
- (IBAction)to1:(id)sender {
    self.nest.headerView = nil;
}
- (IBAction)to:(id)sender {
    [self.containerVc jumpToPage:rand()%7];
}
- (IBAction)push:(id)sender {
    [self.navigationController pushViewController:[ViewController new] animated:YES];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}
@end
