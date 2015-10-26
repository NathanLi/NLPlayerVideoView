//
//  DFDiskCache+nl_pathExtension.h
//  jobsradar
//
//  Created by nathan@hoomic.com on 15/10/23.
//  Copyright © 2015年 Hoomic. All rights reserved.
//

#import "DFDiskCache.h"

@interface DFDiskCache (nl_pathExtension)

/**
 *  @brief  filename 是否包含文件扩展名
 *          默认为 NO
 */
@property (nonatomic, assign) BOOL nl_filenameContainPathExtension;

@end
