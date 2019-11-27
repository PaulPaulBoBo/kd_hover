//
//  HoverObserverTableViewController.m
//  KD_Hover
//
//  Created by dzj on 2019/11/26.
//  Copyright © 2019 paul. All rights reserved.
//

#import "HoverObserverTableViewController.h"
#import "HoverObserverSubViewController.h"

@interface HoverObserverTableViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) KD_TableView *mainTableView;
@property (nonatomic, strong) HoverObserverSubViewController *subTableViewController;

@property (nonatomic, strong) NSMutableArray *headerDataArray;
@property (nonatomic, assign) BOOL canScroll;

@end

static NSInteger HeaderHeight = 150;
static NSInteger MainTableViewTag = 9001;

@implementation HoverObserverTableViewController

#pragma mark - life
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSelfData];
    [self.mainTableView reloadData];
    self.canScroll = YES;
    [self.subTableViewController.subTableView addObserver:self forKeyPath:@"contentOffset" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
}

-(void)dealloc {
    [self.subTableViewController.subTableView removeObserver:self forKeyPath:@"contentOffset"];
}

#pragma mark - Observer
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    CGFloat contentOffsetY = self.subTableViewController.subTableView.contentOffset.y;
    if(contentOffsetY <= 0) {
        self.canScroll = YES;
    } else {
        self.canScroll = NO;
    }
}

#pragma mark - self

-(void)initSelfData {
    for (int i = 0; i < 3; i++) {
        [self.headerDataArray addObject:@""];
    }
}
#pragma mark - delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        return self.headerDataArray.count;
    } else {
        return 1;
    }
}

static NSString *identifier = @"cell";
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:identifier];
        }
        if((indexPath.row + 1)%2 == 0) {
            cell.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.15];
            tableView.separatorColor = [UIColor whiteColor];
        } else {
            cell.backgroundColor = [UIColor whiteColor];
            tableView.separatorColor = [[UIColor redColor] colorWithAlphaComponent:0.15];
        }
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:identifier];
        }
        [cell.contentView addSubview:self.subTableViewController.view];
        [self.subTableViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(cell.contentView).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
            make.height.equalTo(@(KD_ScreenSize.height - HeaderHeight - KD_StatusBarHeight - KD_NavHeight));
        }];
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        return HeaderHeight;
    } else {
        return KD_ScreenSize.height - KD_StatusBarHeight - KD_NavHeight - HeaderHeight;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView.contentOffset.y < [self.mainTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]].origin.y - KD_StatusBarHeight - KD_NavHeight) {
        self.subTableViewController.canScroll = NO;
    } else {
        self.subTableViewController.canScroll = YES;
    }
    if(!self.canScroll) {
        [self.mainTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:(UITableViewScrollPositionTop) animated:NO];
    }
}

#pragma mark - lazy
-(KD_TableView *)mainTableView {
    if(_mainTableView == nil) {
        _mainTableView = [[KD_TableView alloc] initWithFrame:CGRectZero style:(UITableViewStylePlain)];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.tag = MainTableViewTag;
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [_mainTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
        [self.view addSubview:_mainTableView];
        [_mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
    }
    return _mainTableView;
}

-(NSMutableArray *)headerDataArray {
    if(_headerDataArray == nil) {
        _headerDataArray = [NSMutableArray new];
    }
    return _headerDataArray;
}

-(HoverObserverSubViewController *)subTableViewController {
    if(_subTableViewController == nil) {
        _subTableViewController = [[HoverObserverSubViewController alloc] init];
    }
    return _subTableViewController;
}

@end
