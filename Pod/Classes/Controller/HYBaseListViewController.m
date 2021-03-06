//
//  HYBaseListViewController.m
//  MyFirst
//
//  Created by fangyuxi on 16/3/16.
//  Copyright © 2016年 fangyuxi. All rights reserved.
//

#import "HYBaseListViewController.h"
#import "HYBaseCell.h"
#import "MJRefresh/MJRefresh.h"
#import "HYBaseCellModel.h"

@interface HYBaseListViewController ()

@property (nonatomic, strong, readwrite) MJRefreshHeader *refreshHeader;
@property (nonatomic, strong, readwrite) MJRefreshFooter *refreshFooter;

@end

@implementation HYBaseListViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.headerClass = NSClassFromString(@"MJRefreshNormalHeader");
    self.footerClass = NSClassFromString(@"MJRefreshAutoStateFooter");
    
    self.needHeader = YES;
    self.needFooter = YES;
    
    [self configHeaderFooterAppearance];
}

- (void)initView
{
    [self initTableViewSource];
    [self initTableView];

    [self.tableView layoutIfNeeded];
    
    [self p_registTableViewWithTableViewSource];
    [self p_tableViewAndSourceInitFinish];
}

- (void)makeLayout
{
    
}

- (void)initTableView
{
    NSLog(@"Yout Must create TableView in initTableView Method");
    [self doesNotRecognizeSelector:_cmd];
}

- (void)initTableViewSource
{
    NSLog(@"Yout Must create TableViewSource in initTableViewSource Method");
    [self doesNotRecognizeSelector:_cmd];
}

- (void)configHeaderFooterAppearance
{
    
}

- (void)p_tableViewAndSourceInitFinish
{
    NSAssert(self.tableView,@"The TableView instance must assign to the self.tableView");
    
    if (!self.tableView.hy_emptyDataSetDelegate){self.tableView.hy_emptyDataSetDelegate = self;}
    if (!self.tableView.hy_emptyDataSetSource){self.tableView.hy_emptyDataSetSource = self;}
    if (!self.tableView.delegate){self.tableView.delegate = self;}
    if (!self.tableView.dataSource) {self.tableView.dataSource = self.tableViewSource;}
}

#pragma mark registe cell-cellmodel

- (void)p_registTableViewWithTableViewSource
{
    for (Class aClass in [self.tableViewSource containedCellModelsClassArray])
    {
        Class cellClass = [self.tableViewSource cellClassForCellViewModelClass:aClass];
        NSString *cellIdentifier = [self.tableViewSource cellIdentifierForCellViewModelClass:aClass];
        NSString *cellNibPath = [[NSBundle mainBundle] pathForResource:NSStringFromClass(cellClass) ofType:@"nib"];
        if (cellNibPath)
        {
            [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(cellClass) bundle:nil] forCellReuseIdentifier:cellIdentifier];
        } else
        {
            [self.tableView registerClass:cellClass forCellReuseIdentifier:cellIdentifier];
        }
    }
}

#pragma mark controller refresh source

- (void)dragToRefresh
{
    [self.tableView.mj_header beginRefreshing];
}

- (void)dragToRefreshWithoutAnimation
{
    [self p_refreshViewBeginRefreshing];
}

#pragma mark table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *cellModels = self.tableViewSource.cellModels;
    NSArray *sectionArray = [cellModels objectAtIndex:indexPath.section];
    HYBaseCellModel *cellModel = [sectionArray objectAtIndex:indexPath.row];

    if (cellModel.cellHeight == HYBaseCellNoFrameHeightWhenUseAutoLayout)
    {
        CGFloat f = [tableView fd_heightForCellWithIdentifier:cellModel.reuseIdentifier
                                             cacheByIndexPath:indexPath
                                                configuration:^(HYBaseCell *cell) {
                                                    [cell resetCell];
                                                    cell.cellModel = cellModel;
                                                    [cell updateCell];
                                                }];
        
        return f;
    }
    
    return cellModel.cellHeight;
}

#pragma mark overwrite

- (void)bindViewModel
{
    
}

#pragma mark setter

- (void)setNeedHeader:(BOOL)needHeader
{
    _needHeader = needHeader;
    if (_needHeader)
    {
        [self p_addHeader];
    }
    else
    {
        self.tableView.mj_header = nil;
    }
}

- (void)setNeedFooter:(BOOL)needFooter
{
    _needFooter = needFooter;
    if (_needFooter && [self.tableViewSource canLoadMore])
    {
        [self p_addFooter];
    }
    else
    {
        self.tableView.mj_footer = nil;
    }
}

#pragma mark MJRefresh private

- (void)p_addHeader
{
    if (self.tableView.mj_header)
    {
        return;
    }
    
    if (!self.refreshHeader)
    {
        self.refreshHeader = [self.headerClass headerWithRefreshingTarget:self
                                                         refreshingAction:@selector(p_refreshViewBeginRefreshing)];
    }
    
    [self.tableView setMj_header:self.refreshHeader];
}

- (void)p_addFooter
{
    if (self.tableView.mj_footer)
    {
        return;
    }
    
    if (!self.refreshFooter)
    {
        self.refreshFooter = [self.footerClass footerWithRefreshingTarget:self
                                                         refreshingAction:@selector(p_refreshViewBeginLoadMore)];
    }
    
    [self.tableView setMj_footer:self.refreshFooter];
}

- (void)setHeaderClass:(Class)headerClass
{
    _headerClass = headerClass;
    self.refreshHeader = [self.headerClass headerWithRefreshingTarget:self
                                                     refreshingAction:@selector(p_refreshViewBeginRefreshing)];
    //重新调用set方法
    if (self.needHeader)
    {
        [self.tableView setMj_header:self.refreshHeader];
    }
}

- (void)setFooterClass:(Class)footerClass
{
    _footerClass = footerClass;
    self.refreshFooter = [self.footerClass footerWithRefreshingTarget:self
                                                   refreshingAction:@selector(p_refreshViewBeginLoadMore)];
    //重新调用set方法
    if (_needFooter && [self.tableViewSource canLoadMore])
    {
        [self.tableView setMj_footer:self.refreshFooter];
    }
}

- (void)p_refreshViewBeginRefreshing
{
    [self.tableViewSource refreshSource];
}

- (void)p_refreshViewBeginLoadMore
{
    [self.tableViewSource loadMoreSource];
}

#pragma mark empty view show conditions

- (BOOL)shouldShowEmptyDataSetRefreshView
{
    return [self p_emptyViewShowDefaultShowConditions];
}
- (BOOL)shouldShowEmptyDataSetContentView
{
    return [self p_emptyViewShowDefaultShowConditions];
}
- (BOOL)shouldShowEmptyDataSetErrorView
{
    return [self p_emptyViewShowDefaultShowConditions];
}

- (BOOL)p_emptyViewShowDefaultShowConditions
{
    if (self.tableViewSource.cellModels.count == 0)
    {
        return YES;
    }
    
    if (self.tableViewSource.cellModels.count != 0)
    {
        for (NSArray *sections in self.tableViewSource.cellModels)
        {
            if (sections.count != 0)
            {
                return NO;
            }
        }
    }
    return NO;
}

#pragma mark TableViewSourceDelegate

- (void)tableSourceDidStartRefresh:(HYBaseTableViewSource *)tableSource
{
    if ([self shouldShowEmptyDataSetRefreshView])
    {
        [self showEmptyView:self.emptyDataSetRefreshView];
    }
    
    if(self.needFooter)
    {
        self.tableView.mj_footer = nil;;
    }
}

- (void)tableSourceDidFinishRefresh:(HYBaseTableViewSource *)tableSource
{
    if ([self shouldShowEmptyDataSetContentView])
    {
        [self showEmptyView:self.emptyDataSetNoContentView];
    }
    
    [self.tableView.mj_header endRefreshing];
    
    if (self.needFooter)
    {
        if ([tableSource canLoadMore])
        {
            [self p_addFooter];
        }
        else
        {
            self.tableView.mj_footer = nil;
        }
    }
    
    [self.tableView reloadData];
}

- (void)tableSourceDidStartLoadMore:(HYBaseTableViewSource *)tableSource
{
    
}

- (void)tableSourceDidFinishLoadMore:(HYBaseTableViewSource *)tableSource
{
    if ([self shouldShowEmptyDataSetContentView])
    {
        [self showEmptyView:self.emptyDataSetNoContentView];
    }
    
    [self.tableView.mj_footer endRefreshing];
    
    [self showFooterIfNeeded];
    
    [self.tableView reloadData];
}

- (void)tableSource:(HYBaseTableViewSource *)tableSource
       refreshError:(NSError *)error
{
    if ([self shouldShowEmptyDataSetErrorView])
    {
        [self showEmptyView:self.emptyDataSetErrorView];
    }
    
    [self.tableView.mj_header endRefreshing];
    
    [self showFooterIfNeeded];
}

- (void)tableSource:(HYBaseTableViewSource *)tableSource
      loadMoreError:(NSError *)error
{
    if ([self shouldShowEmptyDataSetErrorView])
    {
        [self showEmptyView:self.emptyDataSetErrorView];
    }
    
    [self.tableView.mj_footer endRefreshing];
    
    [self showFooterIfNeeded];
}

- (void)showFooterIfNeeded
{
    if (self.needFooter)
    {
        if ([self.tableViewSource canLoadMore])
        {
            [self p_addFooter];
        }
        else
        {
            self.tableView.mj_footer = nil;
        }
    }
}

- (void)tableSource:(HYBaseTableViewSource *)source
didReceviedExtraData:(id)data
{
    
}

- (void)tableSourceDidClearAllData:(HYBaseTableViewSource *)tableSource
{
    self.tableView.mj_footer = nil;
    if ([self shouldShowEmptyDataSetContentView])
    {
        [self showEmptyView:self.emptyDataSetNoContentView];
    }
}

@end
