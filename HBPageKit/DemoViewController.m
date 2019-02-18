//
//  DemoViewController.m
//  HBPageKit
//
//  Created by LYP on 2018/9/17.
//  Copyright © 2018年 LYP. All rights reserved.
//

#import "DemoViewController.h"

@interface TBL : UITableView

@end

@implementation TBL

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated {
    [super setContentOffset:contentOffset animated:animated];
//    NSLog(@"TBL A :%g", contentOffset.y);
}

- (void)setContentOffset:(CGPoint)contentOffset {
    [super setContentOffset:contentOffset];
//    NSLog(@"TBL :%g", contentOffset.y);
}

@end

@interface DemoViewController () <UITableViewDataSource, UITableViewDelegate>
@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor colorWithRed:(rand()%255 / 255.f) green:(rand()%255 / 255.f) blue:(rand()%255 / 255.f) alpha:1];
    [self.view addSubview:self.label];
    
    UITableView *tbl = [[TBL alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tbl.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tbl.dataSource = self;
    tbl.delegate = self;
    tbl.rowHeight = 100;
    
    if (@available(iOS 11.0, *)) {
        tbl.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.view addSubview:tbl];
    self.tbl = tbl;
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    NSLog(@"%p- %@ - %s", self, self.label.text, __func__);
//}
//
//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    NSLog(@"%p- %@ - %s", self, self.label.text, __func__);
//}
//
//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    NSLog(@"%p- %@ - %s", self, self.label.text, __func__);
//}
//
//- (void)viewDidDisappear:(BOOL)animated {
//    [super viewDidDisappear:animated];
//    NSLog(@"%p- %@ - %s", self, self.label.text, __func__);
//}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %ld", self.label.text, indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Getter
- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(50, 100, 250, 40)];
    }
    return _label;
}


- (void)dealloc {
    NSLog(@"%s", __func__);
}
@end
