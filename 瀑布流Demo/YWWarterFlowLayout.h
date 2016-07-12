//
//  YWWarterFlowLayout.h
//  瀑布流Demo
//
//  Created by wyw on 16/3/9.
//  Copyright © 2016年 wyw. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YWWarterFlowLayout;

@protocol YWWarterFlowLayoutDelegate <NSObject>

@required  //此方法必须实现 设置item的高度
- (CGFloat)warterFlowLayout:(YWWarterFlowLayout *)warterFlowLayout heightForItemAtIndex:(NSUInteger)index itemWidth:(CGFloat)itemWidth;

@optional
- (CGFloat)columnCountInWaterflowLayout:(YWWarterFlowLayout *)waterflowLayout;
- (CGFloat)columnMarginInWaterflowLayout:(YWWarterFlowLayout *)waterflowLayout;
- (CGFloat)rowMarginInWaterflowLayout:(YWWarterFlowLayout *)waterflowLayout;
- (UIEdgeInsets)edgeInsetsInWaterflowLayout:(YWWarterFlowLayout *)waterflowLayout;

@end

@interface YWWarterFlowLayout : UICollectionViewLayout

@property (weak, nonatomic) id<YWWarterFlowLayoutDelegate>delegate;

@end
