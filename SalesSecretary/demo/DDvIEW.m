//
//  DDvIEW.m
//  Demo
//
//  Created by 张毅 on 2018/4/12.
//  Copyright © 2018年 zhangyi. All rights reserved.
//

#import "DDvIEW.h"
#import "Masonry.h"

@implementation DDvIEW

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _lab = [[DLabel alloc]initWithFrame:CGRectMake(10, 10, 40, 20)];
        _lab.backgroundColor = [UIColor redColor];
        [self addSubview:_lab];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    if (!ischange) {
        ischange = YES;
    }
    self.frame = CGRectMake(20, 80, 130, 60);
//    [_lab mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self).offset(10);
//        make.top.mas_equalTo(self).offset(10);
//        make.width.mas_equalTo(40);
//        make.height.mas_equalTo(20);
//
//    }];
//    self.frame = CGRectMake(20, 40, 130, 65);
//    _lab.frame = CGRectMake(11, 10, 40, 25);
}

@end
