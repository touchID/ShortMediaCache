//
//  ViewController.m
//  ShortMediaCacheDemo
//
//  Created by dangercheng on 2018/7/30.
//  Copyright © 2018年 DandJ. All rights reserved.
//

#import "ViewController.h"
#import "PlayerCell.h"
#import "ShortMediaManager.h"

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *videoUrls;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = YES;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 0.0;
    flowLayout.minimumInteritemSpacing = 0.0;
    flowLayout.footerReferenceSize = CGSizeZero;
    flowLayout.headerReferenceSize = CGSizeZero;
    flowLayout.sectionInset = UIEdgeInsetsZero;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    flowLayout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    _collectionView.collectionViewLayout = flowLayout;

    NSArray *videoUrls = @[
    @"http://localhost:3000/media/03_GD32开发板简介2__25pct_smaller.mp4",
    @"http://localhost:3000/media/03_GD32开发板简介2__25pct_smaller.mp4",
    @"http://localhost:3000/media/03_GD32开发板简介2__25pct_smaller.mp4",
    ];
    _videoUrls = videoUrls;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self scrollViewDidEndDecelerating:_collectionView];
    _collectionView.contentOffset = CGPointZero;
}

- (IBAction)clickCleanCacheBtn:(UIButton *)sender {
    NSString *cachedSizeStr = [[ShortMediaManager shareManager] totalCachedSizeStr];
    NSString *message = [NSString stringWithFormat:@"Confirm to clean cache? \n cache size:%@", cachedSizeStr];
    UIAlertController *alertControoler = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[ShortMediaManager shareManager] cleanCache];
    }];
    [alertControoler addAction:cancelAction];
    [alertControoler addAction:okAction];
    [self presentViewController:alertControoler animated:YES completion:nil];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _videoUrls.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PlayerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PlayerCell" forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"1====>enddisplay index: %ld, cell: %@, visibleCells: %@",(long)indexPath.row, cell, collectionView.visibleCells);
    PlayerCell *playerCell = (PlayerCell*)cell;
    NSString *videoStr = [_videoUrls objectAtIndex:indexPath.row];
    [playerCell stopPlayWithUrl:[NSURL URLWithString:videoStr]];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        NSInteger index = scrollView.contentOffset.y / self.collectionView.frame.size.height;
        NSArray *visibleCells = self.collectionView.visibleCells;
        NSString *videoStr = [self.videoUrls objectAtIndex:index];
        PlayerCell *cell = visibleCells.lastObject;
        NSLog(@"2====>scroll to cell %@ index: %ld, visibleCells:%d",cell, (long)index, visibleCells.count);
        [cell playVideoWithUrl:[NSURL URLWithString:videoStr]];
        [self resetPreloadWithIndex:index];
    });
}

- (void)resetPreloadWithIndex:(NSInteger)index {
    index ++;
    if(index >= _videoUrls.count) {
        return;
    }
    NSInteger maxPreloadCount = 3;
    NSMutableArray *preloadUrls = [NSMutableArray arrayWithCapacity:maxPreloadCount];
    for(NSInteger i = index; i < _videoUrls.count; i++) {
        NSString *videoUrlStr = _videoUrls[i];
        NSURL *videoUrl = [NSURL URLWithString:videoUrlStr];
        if(videoUrl) {
            [preloadUrls addObject:videoUrl];
            if(preloadUrls.count == maxPreloadCount) {
                break;
            }
        }
    }
    [[ShortMediaManager shareManager] resetPreloadingWithMediaUrls:preloadUrls];
}

@end
