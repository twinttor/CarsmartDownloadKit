//
//  DownloadManager.h
//  DownloadDemo
//
//  Created by carsmart on 2017/8/11.
//  Copyright © 2017年 carsmart. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadManager : NSObject

/**
 建立下载任务

 @param url 下载链接
 @param progress 下载进度
 @param completed 下载完成的回调
 */
-(void)downloadWith:(NSURL *)url andProgress:(void (^)(long long received,long long total))progress andCompleted:(void(^)(NSHTTPURLResponse *response,NSString *fileCachePath,NSError *error))completed;

/**
 启动下载任务
 */
-(void)resume;

/**
 暂停／挂起下载任务
 */
-(void)suspend;
@end
