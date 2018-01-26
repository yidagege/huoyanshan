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

+ (void)writeTempFileData:(NSData *)data{
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:[NSString tempFilePath]];
    [handle seekToEndOfFile];
    [handle writeData:data];
}

+ (NSData *)readTempFileDataWithOffset:(NSUInteger)offset length:(NSUInteger)length{
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:[NSString tempFilePath]];
    [handle seekToFileOffset:offset];
    return [handle readDataOfLength:length];
}

+ (void)cacheTempFileWithFileName:(NSString *)name{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *cachefolderpath = [NSString cacheFolderPath];
    if (![manager fileExistsAtPath:cachefolderpath]) {
        [manager createDirectoryAtPath:cachefolderpath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *cachefilepath = [NSString stringWithFormat:@"%@/%@",cachefolderpath,name];
    BOOL success = [[NSFileManager defaultManager]copyItemAtPath:[NSString tempFilePath] toPath:cachefilepath error:nil];
    NSLog(@"cache file : %@", success ? @"success" : @"fail");
}

+ (NSString *)cacheFilePathExistWithURL:(NSURL *)url{
    NSString *cachefilepath = [NSString stringWithFormat:@"%@/%@",[NSString cacheFolderPath],[NSString fileNameWithURL:url]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachefilepath]) {
        return cachefilepath;
    }
    return nil;
}

+ (BOOL)clearCache{
    NSFileManager *manager = [NSFileManager defaultManager];
    return [manager removeItemAtPath:[NSString cacheFolderPath] error:nil];
}

@end
