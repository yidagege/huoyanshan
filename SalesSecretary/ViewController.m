//
//  ViewController.m
//  SalesSecretary
//
//  Created by zhangyi on 16/8/25.
//  Copyright © 2016年 iqiyi.com. All rights reserved.
//

#import "ViewController.h"
#import "GPUImageFilterViewController.h"
#import "BeautifyFilterViewController.h"
#import "AudioMixViewController.h"
#import "VideoMergeViewController.h"
#import "AVPlayerCacheViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellID = @"kcellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"GPUImage美颜";
    }else if (indexPath.row == 1) {
        cell.textLabel.text = @"BeautifyFilter美颜";
    }else if (indexPath.row == 2) {
        cell.textLabel.text = @"音频拼接与混合处理";
    }else if (indexPath.row == 3) {
        cell.textLabel.text = @"视频拼接处理";
    }else if (indexPath.row == 4) {
        cell.textLabel.text = @"AVPlayer的缓存实现";
    }
    else{
        cell.textLabel.text = @"";
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 20;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            [self collectAction:nil];
            break;
        case 1:
            [self broadCastAction:nil];
            break;
        case 2:
            [self audioHandle:nil];
            break;
        case 3:
            [self videoMerge];
            break;
        case 4:
            [self AVPlayerCache];
            break;
            
        default:
            break;
    }
}


-(void)collectAction:(id)sender
{
    GPUImageFilterViewController *GPUImageVC = [[GPUImageFilterViewController alloc] init];
    [self.navigationController pushViewController:GPUImageVC animated:YES];
}

-(void)broadCastAction:(id)sender
{
    BeautifyFilterViewController *BeautifyFilterVC = [[BeautifyFilterViewController alloc] init];
    [self.navigationController pushViewController:BeautifyFilterVC animated:YES];
}

-(void)audioHandle:(id)sender
{
    AudioMixViewController *audioVC = [[AudioMixViewController alloc] init];
    [self.navigationController pushViewController:audioVC animated:YES];
}

- (void)videoMerge{
    VideoMergeViewController *vvc = [[VideoMergeViewController alloc]init];
    [self.navigationController pushViewController:vvc animated:YES];
}

- (void)AVPlayerCache{
    AVPlayerCacheViewController *cvc = [[AVPlayerCacheViewController alloc]init];
    [self.navigationController pushViewController:cvc animated:YES];
}


@end
