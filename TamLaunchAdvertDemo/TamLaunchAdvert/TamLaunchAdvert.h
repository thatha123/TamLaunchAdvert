//
//  TamLaunchAdvert.h
//  TamLaunchAdvertDemo
//
//  Created by xin chen on 2017/8/21.
//  Copyright © 2017年 涂怀安. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TamLaunchAdvertDelegate <NSObject>

@optional
-(void)pushLink;
-(void)endAnimate;

@end

@interface TamLaunchAdvert : UIView

+(TamLaunchAdvert *)getInstance;
+(void)showWithImgPath:(NSString *)imgPath videoUrl:(NSURL *)videoUrl delegate:(id<TamLaunchAdvertDelegate>)delegate;
//+(void)play;//启动视频出现时双击home退出
-(void)showComplete;

@end
