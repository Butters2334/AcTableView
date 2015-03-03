//
//  ViewController.m
//  AcTableView-Demo
//
//  Created by Ancc on 15/2/13.
//  Copyright (c) 2015年 Ancc. All rights reserved.
//

#import "ViewController.h"
#import "AcTableView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AcTableView *tv = [[AcTableView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [tv addCellView:^AcContentView*{
        AcContentView *cView = [[AcContentView alloc]initWithHeight:40];
        cView.backgroundColor = [UIColor redColor];
        return cView;
    } touchEvent:^{
        NSLog(@"touch red");
    }];
    [tv addHeadView:^AcHeaderView*{
        AcHeaderView *cView = [[AcHeaderView alloc]initWithHeight:20];
        cView.backgroundColor = [UIColor lightGrayColor];
        return cView;
    }];
    [tv addCellView:^AcContentView*{
        AcContentView *cView = [[AcContentView alloc]initWithHeight:40];
        cView.backgroundColor = [UIColor greenColor];
        return cView;
    } touchEvent:^{
        NSLog(@"touch green");
    }];
    [tv addHeadView:^AcHeaderView*{
        AcHeaderView *cView = [[AcHeaderView alloc]initWithHeight:20];
        cView.backgroundColor = [UIColor lightGrayColor];
        return cView;
    }];
    [tv addCellView:^AcContentView*{
        AcContentView *cView = [[AcContentView alloc]initWithHeight:40];
        cView.backgroundColor = [UIColor blueColor];
        return cView;
    } touchEvent:^{
        NSLog(@"touch blue");
    }];
    [self.view addSubview:tv];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

@end
