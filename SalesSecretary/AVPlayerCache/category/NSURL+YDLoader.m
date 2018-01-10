//
//  NSURL+YDLoader.m
//  SalesSecretary
//
//  Created by zhangyi on 2018/1/10.
//  Copyright © 2018年 iqiyi.com. All rights reserved.
//

#import "NSURL+YDLoader.h"

@implementation NSURL (YDLoader)

- (NSURL *)customSchemeURL {
    NSURLComponents *components = [[NSURLComponents alloc]initWithURL:self resolvingAgainstBaseURL:NO];
    components.scheme = @"streaming";
    return [components URL];
}

- (NSURL *)originalSchemeURL {
    NSURLComponents *components = [[NSURLComponents alloc]initWithURL:self resolvingAgainstBaseURL:NO];
    components.scheme = @"http";
    return [components URL];
}


@end
