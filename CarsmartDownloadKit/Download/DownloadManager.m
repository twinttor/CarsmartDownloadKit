//
//  DownloadManager.m
//  DownloadDemo
//
//  Created by carsmart on 2017/8/11.
//  Copyright © 2017年 carsmart. All rights reserved.
//

#import "DownloadManager.h"
#import <AFNetworking/AFNetworking.h>
#import "MD5Tool.h"

@interface DownloadManager()

@property(nonatomic,strong) NSURL *downloadUrl;

@property(nonatomic,assign) long long fileLength;
@property(nonatomic,assign) long long currentFileLength;

@property(nonatomic,strong) NSFileHandle *fileHandle;

@property(nonatomic,strong) NSURLSessionDataTask *downloadTask;

@property(nonatomic,strong) AFURLSessionManager *manager;

@property(nonatomic,strong) NSString *fileCachePath;

@end

@implementation DownloadManager

-(AFURLSessionManager *)manager {
    if (!_manager) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:config];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return _manager;
}

-(void)downloadWith:(NSURL *)url andProgress:(void (^)(long long, long long))progress andCompleted:(void (^)(NSHTTPURLResponse *,NSString *, NSError *))completed{
    if (url == nil) {
        return;
    }
    self.downloadUrl = url;
    
    self.fileCachePath = [self defaultFileCachePathWith:self.downloadUrl];
    
    self.currentFileLength = [self fileLengthWithPath:self.fileCachePath];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.downloadUrl];
    
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-",self.currentFileLength];
    
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    __weak typeof(self) weakSelf = self;
    
    self.downloadTask = [self.manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        weakSelf.fileLength = 0;
        [weakSelf.fileHandle closeFile];
        weakSelf.fileHandle = nil;
        weakSelf.downloadTask = nil;
        weakSelf.manager = nil;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSString *contentLength = (NSString *)[httpResponse.allHeaderFields valueForKey:@"Content-Length"];
            if ([contentLength isEqualToString:@"0"] && weakSelf.currentFileLength > 0) {
                completed(httpResponse,self.fileCachePath,nil);
            }else{
                completed(httpResponse,self.fileCachePath,error);
            }
        }else{
            completed(nil,self.fileCachePath,error);
        }
    }];

    [self.manager setDataTaskDidReceiveResponseBlock:^NSURLSessionResponseDisposition(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSURLResponse * _Nonnull response) {
        weakSelf.fileLength = response.expectedContentLength + self.currentFileLength;
        weakSelf.fileHandle = [NSFileHandle fileHandleForWritingAtPath:weakSelf.fileCachePath];
        return NSURLSessionResponseAllow;
    }];
    
    [self.manager setDataTaskDidReceiveDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSData * _Nonnull data) {
        [weakSelf.fileHandle seekToEndOfFile];
        [weakSelf.fileHandle writeData:data];
        weakSelf.currentFileLength += data.length;
        progress(weakSelf.currentFileLength,weakSelf.fileLength);
    }];
    
    [self.downloadTask resume];
}

-(void)resume{
    if (self.downloadTask == nil) {
        return;
    }
    
    if (self.downloadTask.state != NSURLSessionTaskStateRunning) {
        [self.downloadTask resume];
    }
}

-(void)suspend{
    if (self.downloadTask == nil) {
        return;
    }
    
    if (self.downloadTask.state == NSURLSessionTaskStateRunning) {
        [self.downloadTask suspend];
    }
}

-(NSString *)defaultFileCachePathWith:(NSURL *)downloadUrl{
    NSString *md5 = [MD5Tool MD5ForUpper32Bit:self.downloadUrl.absoluteString];
    NSString *diretoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",md5]];
    if (![NSFileManager.defaultManager fileExistsAtPath:diretoryPath]) {
        [NSFileManager.defaultManager createDirectoryAtPath:diretoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *fileCachePath = [diretoryPath stringByAppendingPathComponent:self.downloadUrl.lastPathComponent];
    if (![NSFileManager.defaultManager fileExistsAtPath:fileCachePath]) {
        [NSFileManager.defaultManager createFileAtPath:fileCachePath contents:nil attributes:nil];
    }
    NSLog(@"%@",fileCachePath);
    return fileCachePath;
}

-(long long)fileLengthWithPath:(NSString *)path{
    long long length = 0;
    if ([NSFileManager.defaultManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *info = [NSFileManager.defaultManager attributesOfItemAtPath:path error:&error];
        if (!error && info) {
            length = [info fileSize];
        }
    }
    return length;
}

@end
