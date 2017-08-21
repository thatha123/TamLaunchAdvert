//
//  ViewController.m
//  TamLaunchAdvertDemo
//
//  Created by xin chen on 2017/8/21.
//  Copyright © 2017年 涂怀安. All rights reserved.
//

#import "ViewController.h"
#import "TamLaunchAdvert.h"

@interface ViewController ()<TamLaunchAdvertDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
   
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSString *imgPath = [[NSBundle mainBundle] pathForResource:@"2" ofType:@"png"];
    NSURL *videoUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"qidong" ofType:@"mp4"]];//[NSURL URLWithString:@"http://125.90.58.142/xdispatch/7xldnc.dl1.z0.glb.clouddn.com/guanggao1.mp4"]
    [TamLaunchAdvert showWithImgPath:NULL videoUrl:videoUrl delegate:self];
//    [TamLaunchAdvert showWithImgPath:imgPath videoUrl:nil delegate:self];
}

#pragma mark - TamLaunchAdvertDelegate
-(void)pushLink
{
    NSLog(@"pushLink");
}

-(void)endAnimate
{
    NSLog(@"endAnimate");
}


@end
