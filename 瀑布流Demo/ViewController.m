//
//  ViewController.m
//  瀑布流Demo
//
//  Created by wyw on 16/3/9.
//  Copyright © 2016年 wyw. All rights reserved.
//

#import "ViewController.h"
#import "YWWarterFlowLayout.h"
#import "XMGShop.h"
#import "XMGShopCell.h"
#import "MJRefresh/MJRefresh.h"
#import <MJExtension/MJExtension.h>

static NSString * const YWShopId = @"shop";

@interface ViewController ()<UICollectionViewDataSource,YWWarterFlowLayoutDelegate>

/* collectionview */
@property (weak, nonatomic) UICollectionView *collectionView;

/* 商品 */
@property (strong, nonatomic) NSMutableArray *shops;

@end

@implementation ViewController

- (NSMutableArray *)shops
{
    if (!_shops) {
        _shops = [NSMutableArray array];
    }
    return _shops;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // 布局
    [self setupLayout];
    // 刷新
    [self setupRefresh];
}

- (void)setupLayout
{
    // 创建布局
    YWWarterFlowLayout *layout = [[YWWarterFlowLayout alloc] init];
    layout.delegate = self;
    
    // 创建CollectionView
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.dataSource = self;
    [self.view addSubview:collectionView];
    
    // 注册
    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([XMGShopCell class]) bundle:nil] forCellWithReuseIdentifier:YWShopId];
    
    self.collectionView = collectionView;
}

- (void)setupRefresh
{
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewShops)];
    [self.collectionView.mj_header beginRefreshing];
    
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreShops)];
    self.collectionView.mj_footer.hidden = YES;
}

- (void)loadNewShops
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSArray *shops = [XMGShop mj_objectArrayWithFilename:@"1.plist"];
        [self.shops removeAllObjects];
        
        [self.shops addObjectsFromArray:shops];
        MYLog(@"解析plist文件： －－ %@",self.shops);
        // 刷新数据
        [self.collectionView reloadData];
        
        [self.collectionView.mj_header endRefreshing];
    });
}

- (void)loadMoreShops
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSArray *shops = [XMGShop mj_objectArrayWithFilename:@"1.plist"];
        [self.shops addObjectsFromArray:shops];
        
        // 刷新数据
        [self.collectionView reloadData];
        
        [self.collectionView.mj_footer endRefreshing];
    });
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // 当数据为0时，隐藏
    self.collectionView.mj_footer.hidden = self.shops.count == 0;
    // MYLog(@"商品数组的数量 －－ %ld",self.shops.count);
    return self.shops.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    XMGShopCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:YWShopId forIndexPath:indexPath];
    
    cell.shop = self.shops[indexPath.item];
    
    return cell;
}

#pragma mark - YWWarterFlowLayoutDelegate 代理事件
- (CGFloat)warterFlowLayout:(YWWarterFlowLayout *)warterFlowLayout heightForItemAtIndex:(NSUInteger)index itemWidth:(CGFloat)itemWidth
{
    XMGShop *shop = [[XMGShop alloc] init];
    shop = self.shops[index];
    return itemWidth *shop.h / shop.w;
}

- (CGFloat)rowMarginInWaterflowLayout:(YWWarterFlowLayout *)waterflowLayout
{
    return 10;
}

- (CGFloat)columnCountInWaterflowLayout:(YWWarterFlowLayout *)waterflowLayout
{
    return 3;
}

- (CGFloat)columnMarginInWaterflowLayout:(YWWarterFlowLayout *)waterflowLayout
{
    return 10;
}

- (UIEdgeInsets)edgeInsetsInWaterflowLayout:(YWWarterFlowLayout *)waterflowLayout
{
    UIEdgeInsets edgeInsets = {10,10,10,10};
    return edgeInsets;
}

@end














