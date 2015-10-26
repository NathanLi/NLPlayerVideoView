//
//  DFDiskCache+nl_pathExtension.m
//  jobsradar
//
//  Created by nathan@hoomic.com on 15/10/23.
//  Copyright © 2015年 Hoomic. All rights reserved.
//

#import "DFDiskCache+nl_pathExtension.h"
#import <objc/runtime.h>

@implementation DFDiskCache (nl_pathExtension)

+ (void)load {
  Method methodFilenameForKey = class_getInstanceMethod(self, @selector(filenameForKey:));
  Method nl_methodFilenameForKey = class_getInstanceMethod(self, @selector(nl_filenameForKey:));
  if (methodFilenameForKey && nl_methodFilenameForKey) {
    method_exchangeImplementations(methodFilenameForKey, nl_methodFilenameForKey);
  }
}

- (NSString *)nl_filenameForKey:(NSString *)key {
  NSString *filename = [self nl_filenameForKey:key];
  
  if (self.nl_filenameContainPathExtension) {
    if ([key.pathExtension length] > 0) {
      filename = [filename stringByAppendingPathExtension:key.pathExtension];
    }
  }
  return filename;
}

- (void)setNl_filenameContainPathExtension:(BOOL)nl_filenameContainPathExtension {
  objc_setAssociatedObject(self, @selector(nl_filenameContainPathExtension), @(nl_filenameContainPathExtension), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)nl_filenameContainPathExtension {
  return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end
