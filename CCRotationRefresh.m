//
//  CCRotationRefresh.m
//
//  Created by Cocos on 2017/2/14.
//  Copyright © 2017年 Cocos. All rights reserved.
//

#import "CCRotationRefresh.h"

static CGFloat const kTransformRotateRate = 0.05 * M_PI;

@interface CCRotationRefresh () {
    BOOL _touchEnd, _loading;
}

@property (strong, nonatomic) UIImageView *transformImageView;
@property (strong, nonatomic) UIImage     *image;
@property (strong, nonatomic) NSString    *trasImageName;
@property (assign, nonatomic) CGFloat     currentOffset;
@property (assign, nonatomic) CGFloat     originY;
@end

@implementation CCRotationRefresh
static CGFloat s_criticalValue;

+ (instancetype)rotationRefreshWithHeaderRefreshingBlock:(CCHeaderWithRefreshingBlock)block inView:(UIView *)view {
    CCRotationRefresh *rotationRefresh = [[self alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    rotationRefresh.headerWithRefreshingBlock = block;
    [rotationRefresh setUpWithImageName:@"CCRotationRefresh" transformImageName:@"CCRotationRefresh" inView:view];
    return rotationRefresh;
}

+ (instancetype)rotationRefreshWithFrame:(CGRect)frame imageName:(NSString *)imageName transformImageName:(NSString *)traImageName inView:(UIView *)view {
    if (![imageName length] || ![traImageName length]) {
        @throw [NSException exceptionWithName:@"Image name is zero" reason:@"You know that." userInfo:nil];
    }
    
    CCRotationRefresh *rotationRefresh = [[self alloc] initWithFrame:frame];
    [rotationRefresh setUpWithImageName:imageName transformImageName:traImageName inView:view];
    return rotationRefresh;
}

- (void)setUpWithImageName:(NSString *)imageName transformImageName:(NSString *)traImageName inView:(UIView *)view  {
    CGRect frame = self.frame;
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageName ofType:@"png"]]];
    UIImage *traImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:traImageName ofType:@"png"]]];
    [self setImage:image forState:UIControlStateNormal];
    self.transformImageView.image = traImage;
    self.trasImageName = traImageName;
    self.image = image;
    
    [view addSubview:self];
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view);
        make.top.equalTo(view).offset(-frame.size.height - 8);
        make.width.mas_equalTo(@(frame.size.width));
        make.height.mas_equalTo(@(frame.size.height));
    }];
    //Reset static value
    s_criticalValue = -42;
    self.originY = -frame.size.height - 8;
    s_criticalValue += self.originY;
}


- (void)startTransform {
    _touchEnd = NO;
    [_transformImageView.layer removeAllAnimations];
    [self setImage:[[UIImage alloc] init] forState:UIControlStateNormal];
    [self addSubview:self.transformImageView];
}

- (void)endTransform {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_transformImageView.layer removeAllAnimations];
        _loading = NO;
        [self setImage:self.image forState:UIControlStateNormal];
        if (!_isStationary) {
            [UIView animateWithDuration:0.35 animations:^{
                CGRect frame = self.frame;
                frame.origin.y = self.originY;
                self.frame = frame;
            } completion:^(BOOL finished) {
                [_transformImageView removeFromSuperview];
            }];
        }
    });
}

- (void)continueTransform {
    if (_touchEnd) {
        [_transformImageView.layer removeAllAnimations];
        CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        rotateAnimation.fromValue = @(2 * M_PI);
        rotateAnimation.toValue = @0;
        rotateAnimation.duration = 0.7f;
        rotateAnimation.repeatCount = HUGE;
        rotateAnimation.removedOnCompletion = NO;
        [_transformImageView.layer addAnimation:rotateAnimation forKey:@"rotationAnimation"];
        
        if (self.headerWithRefreshingBlock) {
            self.headerWithRefreshingBlock();
        }
    }
}

- (void)transformWithClockwise:(BOOL)clockwise {
    _transformImageView.transform = CGAffineTransformRotate(_transformImageView.transform,clockwise ? kTransformRotateRate : -kTransformRotateRate);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self startTransform];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    _touchEnd = YES;
    if (scrollView.contentOffset.y < s_criticalValue) {
        [self continueTransform];
        _loading = YES;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y > 0) return;
    if (scrollView.contentOffset.y < _currentOffset) {  //Roll up
        if(![_transformImageView.layer animationForKey:@"rotationAnimation"]) {
            [self transformWithClockwise:YES];
        }
    } else {  //Roll down
        if(![_transformImageView.layer animationForKey:@"rotationAnimation"]) {
            [self transformWithClockwise:NO];
        }
    }

    if (!_isStationary && !_loading) {
        CGRect frame = self.frame;
        
        if (scrollView.contentOffset.y > s_criticalValue) {
            frame.origin.y += -(scrollView.contentOffset.y - _currentOffset);
        }else {
            frame.origin.y = -s_criticalValue + self.originY;
        }
        
        NSLog(@"frame.origin.y = %f, s_criticalValue=%f, self.originY=%f",frame.origin.y, s_criticalValue,self.originY);
        
        self.frame = frame;
    }
    
    _currentOffset = scrollView.contentOffset.y;
}

- (UIImageView *)transformImageView {
    if (_transformImageView == nil) {
        _transformImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    }
    return _transformImageView;
}

@end
