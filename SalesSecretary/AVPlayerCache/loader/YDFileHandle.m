//
//  YDFileHandle.m
//  SalesSecretary
//
//  Created by zhangyi on 2018/1/10.
//  Copyright © 2018年 iqiyi.com. All rights reserved.
//

#import "YDFileHandle.h"
#import "NSString+YDLoader.h"

@interface YDFileHandle ()
@property (nonatomic, strong)NSFileHandle *writeFileHandle;
@property (nonatomic, strong) NSFileHandle * readFileHandle;
@end

@implementation YDFileHandle

+ (BOOL)createTempFile{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = [NSString tempFilePath];
    if ([manager fileExistsAtPath:path]) {
        [manager removeItemAtPath:path error:nil];
    }
    return [manager createFileAtPath:path contents:nil attributes:nil];
}

@end
