//
//  TamLaunchAdvert.m
//  TamLaunchAdvertDemo
//
//  Created by xin chen on 2017/8/21.
//  Copyright © 2017年 涂怀安. All rights reserved.
//

#import "TamLaunchAdvert.h"
#import <AVFoundation/AVFoundation.h>

#define TamDefImgShowTime 3 //默认图片显示时间
#define TamPassBtnW 60 //跳过按钮宽

@interface TamLaunchAdvert()<CAAnimationDelegate>

@property(nonatomic,strong)UIButton *passBtn;
@property(nonatomic,strong)CAShapeLayer *shapeLayer;
@property(nonatomic,assign)float showTimer;
@property(nonatomic,strong)AVPlayer *player;

@property(nonatomic,copy)NSURL *videoUrl;//视频地址
@property(nonatomic,copy)NSString *imgPath;

@property(nonatomic,weak)id<TamLaunchAdvertDelegate> delegate;

@end

@implementation TamLaunchAdvert

static TamLaunchAdvert *_appLaunchAderView;

+(TamLaunchAdvert *)getInstance
{
    if (_appLaunchAderView == nil) {
        _appLaunchAderView = [[TamLaunchAdvert alloc]init];
    }
    return _appLaunchAderView;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.showTimer = TamDefImgShowTime;
    }
    return self;
}

+(void)showWithImgPath:(NSString *)imgPath videoUrl:(NSURL *)videoUrl delegate:(id<TamLaunchAdvertDelegate>)delegate
{
    if (imgPath.length != 0) {
        [TamLaunchAdvert getInstance].imgPath = imgPath;
        [[UIApplication sharedApplication].keyWindow addSubview:_appLaunchAderView];
        _appLaunchAderView.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *views = NSDictionaryOfVariableBindings(_appLaunchAderView);
        [[UIApplication sharedApplication].keyWindow addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_appLaunchAderView]-0-|" options:0 metrics:nil views:views]];
        [[UIApplication sharedApplication].keyWindow addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_appLaunchAderView]-0-|" options:0 metrics:nil views:views]];
        
        _appLaunchAderView.delegate = delegate;
        [_appLaunchAderView setupAppLaunchImgView];
    }else if([videoUrl absoluteString].length != 0){
        [TamLaunchAdvert getInstance].videoUrl = videoUrl;
        [[UIApplication sharedApplication].keyWindow addSubview:_appLaunchAderView];
        _appLaunchAderView.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *views = NSDictionaryOfVariableBindings(_appLaunchAderView);
        [[UIApplication sharedApplication].keyWindow addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_appLaunchAderView]-0-|" options:0 metrics:nil views:views]];
        [[UIApplication sharedApplication].keyWindow addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_appLaunchAderView]-0-|" options:0 metrics:nil views:views]];
        
        _appLaunchAderView.delegate = delegate;
        [_appLaunchAderView setupAppLaunchVideoView];
    }else{
        NSLog(@"无效");
    }
}

/**
 *  图片
 */
-(void)setupAppLaunchImgView
{
    UIImageView *imgView = [[UIImageView alloc]init];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.image = [UIImage imageWithContentsOfFile:self.imgPath];
    imgView.userInteractionEnabled = YES;
    [self addSubview:imgView];
    imgView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = NSDictionaryOfVariableBindings(imgView);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[imgView]-0-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imgView]-0-|" options:0 metrics:nil views:views]];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGes:)];
    tapGes.numberOfTapsRequired = 1;
    [imgView addGestureRecognizer:tapGes];
    
    [self.passBtn.layer addSublayer:self.shapeLayer];
}

-(void)tapGes:(UITapGestureRecognizer *)tapGes
{
    //    MSLog(@"跳转地址");
    if ([self.delegate respondsToSelector:@selector(pushLink)]) {
        [self.delegate pushLink];
    }
}

/**
 *  跳过按钮
 */
-(UIButton *)passBtn
{
    if (_passBtn == nil) {
        _passBtn = [[UIButton alloc]init];
        [_passBtn setTitle:@"跳过" forState:UIControlStateNormal];
        [_passBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_passBtn setBackgroundColor:[[UIColor blackColor]colorWithAlphaComponent:0.5]];
        _passBtn.layer.masksToBounds = YES;
        _passBtn.layer.cornerRadius = 30;
        [_passBtn addTarget:self action:@selector(passAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_passBtn];
        _passBtn.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *views = NSDictionaryOfVariableBindings(_passBtn);
        NSDictionary *valueDict = @{@"TamPassBtnW":@TamPassBtnW};
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_passBtn(TamPassBtnW)]-20-|" options:0 metrics:valueDict views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_passBtn(TamPassBtnW)]" options:0 metrics:valueDict views:views]];
    }
    return _passBtn;
}

/**
 *  点击跳过事件
 */
-(void)passAction:(UIButton *)sender
{
    [self.shapeLayer removeAnimationForKey:@"end"];
}

/**
 *完成动画
 */
-(void)showComplete
{
    [UIView animateWithDuration:1.0 animations:^{
        self.alpha = 0;
        self.transform = CGAffineTransformMakeScale(1.5, 1.5);
    }completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(endAnimate)]) {
            [self.delegate endAnimate];
        }
        [self removeNotification];
        [self removeObserverFromPlayerItem:_player.currentItem];
        [_player pause];
        [_player setRate:0];
        [_player.currentItem cancelPendingSeeks];
        [_player.currentItem.asset cancelLoading];
        _player = nil;
        
        [self removeFromSuperview];
        _appLaunchAderView = nil;
    }];
}

-(CAShapeLayer *)shapeLayer
{
    if (_shapeLayer == nil) {
        _shapeLayer = [[CAShapeLayer alloc]init];
        _shapeLayer.fillColor = [UIColor clearColor].CGColor;
        _shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        _shapeLayer.lineWidth = 2;
        _shapeLayer.strokeEnd = 1;
        _shapeLayer.strokeStart = 0;
        _shapeLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(2, 2, TamPassBtnW-4, TamPassBtnW-4)].CGPath;
        [self addAnimate:self.showTimer layer:_shapeLayer];
    }
    return _shapeLayer;
}

- (void)addAnimate:(NSTimeInterval)duration layer:(CALayer *)layer
{
    CABasicAnimation * endAnimation = [CABasicAnimation animationWithKeyPath: @"strokeEnd"];
    endAnimation.fromValue = @0;
    endAnimation.toValue = @1;
    endAnimation.duration = duration;
    endAnimation.repeatCount = 1;
    //    endAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    endAnimation.delegate = self;
    [layer addAnimation: endAnimation forKey: @"end"];
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStart:(CAAnimation *)anim
{
    NSLog(@"开始");
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSLog(@"停止");
    [self showComplete];
}

/**
 *  视频
 */
-(void)setupAppLaunchVideoView
{
    [self.player play];
}

-(AVPlayer *)player
{
    if (_player == nil) {
        NSURL *sourceMovieURL = self.videoUrl;//[self getFileUrl];
        //        AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:sourceMovieURL options:nil];
        //        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
        AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:sourceMovieURL];
        _player = [AVPlayer playerWithPlayerItem:playerItem];
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        playerLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        playerLayer.videoGravity = AVLayerVideoGravityResize;
        [self.layer addSublayer:playerLayer];
        [self addNotification];
        //        [self addProgressObserver];
        [self addObserverToPlayerItem:playerItem];
    }
    return _player;
}

/*
// *  取得本地文件路径
// *
// *  @return 文件路径
// */
//-(NSURL *)getFileUrl{
//    
//    NSString *path = @"";
//    NSURL *url=[NSURL fileURLWithPath:path];
//    return url;
//}

/* *  添加播放器通知
 */
-(void)addNotification{
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

/**
 *  播放完成通知
 *
 *  @param notification 通知对象
 */
-(void)playbackFinished:(NSNotification *)notification{
    NSLog(@"视频播放完成.");
}

-(void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)dealloc{
    [self removeNotification];
    [self removeObserverFromPlayerItem:self.player.currentItem];
}

#pragma mark - 监控
/**
 *  给播放器添加进度更新
 */
-(void)addProgressObserver{
    AVPlayerItem *playerItem=self.player.currentItem;
    //这里设置每秒执行一次
    //    WS(weakSelf);
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current=CMTimeGetSeconds(time);
        float total=CMTimeGetSeconds([playerItem duration]);
        NSLog(@"当前已经播放%.2fs.%f",current,current/total);
        if (current) {
            
        }
        
    }];
}

/**
 *  给AVPlayerItem添加监控
 *
 *  @param playerItem AVPlayerItem对象
 */
-(void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}
-(void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem{
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}
/**
 *  通过KVO监控播放器状态
 *
 *  @param keyPath 监控属性
 *  @param object  监视器
 *  @param change  状态改变
 *  @param context 上下文
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem=object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status==AVPlayerStatusReadyToPlay){
            float duration = CMTimeGetSeconds(playerItem.duration);
            if (duration != 0) {
                self.showTimer = duration;
            }
            [self.passBtn.layer addSublayer:self.shapeLayer];
            NSLog(@"正在播放...，视频总长度:%.2f",duration);
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array=playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        NSLog(@"共缓冲：%.2f",totalBuffer);
    }
}

+(void)play
{
    if(_appLaunchAderView.player.rate==0){ //说明时暂停
        [_appLaunchAderView.player play];
        //        YbrLog(@"播放1");
        //    }else if(self.player.rate==1){//正在播放
        //        [_player pause];
        //        YbrLog(@"暂停");
    }
}

@end
