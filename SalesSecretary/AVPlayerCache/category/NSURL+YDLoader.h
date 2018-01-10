//
//  NSURL+YDLoader.h
//  SalesSecretary
//
//  Created by zhangyi on 2018/1/10.
//  Copyright © 2018年 iqiyi.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (YDLoader)

/*自定义scheme*/
- (NSURL *)customSchemeURL;

/*还原scheme*/
- (NSURL *)originalSchemeURL;

@end
