//
//  YWWarterFlowLayout.m
//  瀑布流Demo
//
//  Created by wyw on 16/3/9.
//  Copyright © 2016年 wyw. All rights reserved.
//

#import "YWWarterFlowLayout.h"

/** 默认列数 */
static const NSInteger YWDefaultColumnCount = 3;
/** 默认列间距 */
static const NSInteger YWDefaultColumnMargin = 10;
/** 默认行间距 */
static const NSInteger YWDefaultRowMargin = 10;
/** 默认边缘值 */
static const UIEdgeInsets YWDefaultEdgeInset = {10,10,10,10};

@interface YWWarterFlowLayout()

/** 存放所有cell的属性 */
@property (strong, nonatomic) NSMutableArray *attriArray;

/** 存放所有列的当前高度 */
@property (nonatomic, strong) NSMutableArray *columnHeights;

/** 内容的高度 */
@property (nonatomic, assign) CGFloat contentHeight;

- (CGFloat)rowMargin;
- (CGFloat)columnMargin;
- (NSInteger)columnCount;
- (UIEdgeInsets)edgeInsets;

@end

@implementation YWWarterFlowLayout

#pragma mark - 常用数据处理
- (CGFloat)rowMargin
{
   if([self.delegate respondsToSelector:@selector(rowMarginInWaterflowLayout:)])
   {
       return [self.delegate rowMarginInWaterflowLayout:self];
   }else{
       return YWDefaultRowMargin;
   }
}
- (CGFloat)columnMargin
{
    if([self.delegate respondsToSelector:@selector(columnMarginInWaterflowLayout:)])
    {
        return [self.delegate columnMarginInWaterflowLayout:self];
    }else{
        return YWDefaultColumnMargin;
    }
}
- (NSInteger)columnCount
{
    if([self.delegate respondsToSelector:@selector(columnCountInWaterflowLayout:)])
    {
        return [self.delegate columnCountInWaterflowLayout:self];
    }else{
        return YWDefaultColumnCount;
    }
}

- (UIEdgeInsets)edgeInsets
{
    if([self.delegate respondsToSelector:@selector(edgeInsetsInWaterflowLayout:)])
    {
        return [self.delegate edgeInsetsInWaterflowLayout:self];
    }else{
        return YWDefaultEdgeInset;
    }
}

#pragma mark - 懒加载
- (NSMutableArray *)attriArray
{
    if (!_attriArray) {
        _attriArray = [NSMutableArray array];
    }
    return _attriArray;
}
- (NSMutableArray *)columnHeights
{
    if (!_columnHeights) {
        _columnHeights = [NSMutableArray array];
    }
    return _columnHeights;
}

#pragma mark - 1.初始化
- (void)prepareLayout
{
    [super prepareLayout];
    
    // 清除以前计算的所有高度
    [self.columnHeights removeAllObjects];
    
    for (NSInteger i = 0; i < self.columnCount; i++) {
        [self.columnHeights addObject:@(self.edgeInsets.top)];
    }

    [self.attriArray removeAllObjects];
    
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    
    for (NSInteger i = 0; i < count; i++) {
        NSIndexPath *indexpath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attri = [self layoutAttributesForItemAtIndexPath:indexpath];
        
        [self.attriArray addObject:attri];
    }
}

#pragma mark - 2.cell的排布
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return self.attriArray;
}

#pragma mark - 3.返回index位置对应的cell的属性
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *layoutAttribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    // 宽度：（view的宽度－左右边缘值 － 总的列间距 ）／ 列数
    // 高度： 根据商品来定
    // 坐标x：边缘值 ＋ 宽度 ＋ 总列间距
    // 坐标y：根据列的最大高度来定
    CGFloat attri_W = (self.collectionView.frame.size.width - self.edgeInsets.left - self.edgeInsets.right - self.columnMargin * (self.columnCount - 1)) / self.columnCount ;
    CGFloat attri_H = [self.delegate warterFlowLayout:self heightForItemAtIndex:indexPath.item itemWidth:attri_W];
    
    // 方法1：block找出高度最短的那一列
    __block NSInteger destColumn = 0;
    __block CGFloat ColumnMinHeight = MAXFLOAT;
    [self.columnHeights enumerateObjectsUsingBlock:^(NSNumber *currentColumnHeight, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGFloat currentHeight = currentColumnHeight.doubleValue;
        if (ColumnMinHeight > currentHeight) {
            ColumnMinHeight = currentHeight;
            destColumn = idx;
        }
    }];
    
    // 方法2:for循环找出高度最短的那一列
//    NSInteger destColumn = 0;
//    CGFloat ColumnMinHeight = [self.columnHeights[0] doubleValue];
//    for (NSInteger i = 1; i < YWDefaultColumnCount; i++) {
//
//        CGFloat currentHeight = [self.columnHeights[i] doubleValue];
//        if (ColumnMinHeight > currentHeight) {
//            ColumnMinHeight = currentHeight;
//            destColumn = i;
//        }
//    }

    CGFloat attri_X =  self.edgeInsets.left + destColumn * (attri_W + self.columnMargin);
    CGFloat attri_Y = ColumnMinHeight + self.edgeInsets.top;
    if (attri_Y != self.edgeInsets.top) {
        attri_Y += self.rowMargin;
    }
    
    layoutAttribute.frame = CGRectMake(attri_X,attri_Y,attri_W,attri_H);
    
    // 更新最短那列的高度
    self.columnHeights[destColumn] = @(CGRectGetMaxY(layoutAttribute.frame));
    
    // 记录内容的高度
    CGFloat columnHeight = [self.columnHeights[destColumn] doubleValue];
    if (self.contentHeight < columnHeight) {
        self.contentHeight = columnHeight;
    }
    
    return layoutAttribute;
}

#pragma mark - 4.返回collectionview的滚动范围
- (CGSize)collectionViewContentSize
{
//    CGFloat ColumnMaxHeight = [self.columnHeights[0] doubleValue];
//    for (NSInteger i = 1; i < self.columnCount; i++) {
//        
//        CGFloat currentHeight = [self.columnHeights[i] doubleValue];
//        if (ColumnMaxHeight < currentHeight) {
//            ColumnMaxHeight = currentHeight;
//        }
//    }
    
    return CGSizeMake(0, self.contentHeight);
}

@end
