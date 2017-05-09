//
//  ViewController.m
//  ZHXCustomCamera
//
//  Created by apple on 17/5/4.
//  Copyright © 2017年 com. All rights reserved.
//

#import "ViewController.h"
#import "CustomCameraViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"主页";
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    button.backgroundColor = [UIColor grayColor];
    [button setTitle:@"相机" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(camera) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}

- (void)camera {
    
    CustomCameraViewController *custom = [[CustomCameraViewController alloc] init];
    [self.navigationController pushViewController:custom animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
