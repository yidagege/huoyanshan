//
//  NSString+YDLoader.h
//  SalesSecretary
//
//  Created by zhangyi on 2018/1/10.
//  Copyright © 2018年 iqiyi.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (YDLoader)
/**
 *  临时文件路径
 */
+ (NSString *)tempFilePath;

/**
 *  缓存文件夹路径
 */
+ (NSString *)cacheFolderPath;

/**
 *  获取网址中的文件名
 */
+ (NSString *)fileNameWithURL:(NSURL *)url;
@end
