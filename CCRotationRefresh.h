//
//  CCRotationRefresh.h
//
//  Created by Cocos on 2017/2/14.
//  Copyright © 2017年 Cocos. All rights reserved.
//
//  Usage:
//
//    __weak typeof(self) weakSelf = self;
//    self.rotationRefresh = [CCRotationRefresh rotationRefreshWithHeaderRefreshingBlock:^{
//        typeof(self) strongSelf = weakSelf;
//        [strongSelf.webView reload];
//    } inView:self.webView];
//
//    self.webView.scrollView.delegate = self.rotationRefresh;
//

#import <UIKit/UIKit.h>

typedef void(^CCHeaderWithRefreshingBlock)(void);

@interface CCRotationRefresh : UIButton <UITableViewDelegate>

//Default is NO
@property (assign, nonatomic) BOOL isStationary;
@property (copy, nonatomic) CCHeaderWithRefreshingBlock headerWithRefreshingBlock;


/**
 + instancetype method

 @param frame Provide with width and height
 @param imageName Provide with a static image
 @param traImageName Provide with a transform image.
 @param view Provide with container view.
 @return instancetype
 */
+ (instancetype)rotationRefreshWithFrame:(CGRect)frame imageName:(NSString *)imageName transformImageName:(NSString *)traImageName inView:(UIView *)view;



/**
 Quickly initialize a instancetype.

 @param block
 @param view
 @return
 */
+ (instancetype)rotationRefreshWithHeaderRefreshingBlock:(CCHeaderWithRefreshingBlock)block inView:(UIView *)view;

- (void)endTransform;



@end
