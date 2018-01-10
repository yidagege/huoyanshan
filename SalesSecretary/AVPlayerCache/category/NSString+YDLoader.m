//
//  NSString+YDLoader.m
//  SalesSecretary
//
//  Created by zhangyi on 2018/1/10.
//  Copyright © 2018年 iqiyi.com. All rights reserved.
//

#import "NSString+YDLoader.h"

@implementation NSString (YDLoader)

+ (NSString *)tempFilePath{
    return [[NSHomeDirectory( ) stringByAppendingPathComponent:@"tmp"] stringByAppendingPathComponent:@"MusicTemp.mp4"];

}

+ (NSString *)cacheFolderPath {
    return [[NSHomeDirectory( ) stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"MusicCaches"];
}

+ (NSString *)fileNameWithURL:(NSURL *)url {
    return [[url.path componentsSeparatedByString:@"/"] lastObject];
}

@end
