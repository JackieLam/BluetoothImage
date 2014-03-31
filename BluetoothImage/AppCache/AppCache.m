//
//  AppCache.m
//  AppCache
//
//  Created by developer 03 on 14-3-28.
//  Copyright (c) 2014年 developer 03. All rights reserved.
//

#import "AppCache.h"
#import "ImageBlock.h"
//每个块的上限是2MB
static const unsigned long long BlockSize=100*1024;

@implementation AppCache

@synthesize Sender;
@synthesize BlockReceivedTable;
@synthesize BlockSendedTable;
@synthesize FileCapacity;
@synthesize ImageReceived;

+(AppCache *)shareManager{
    static AppCache *shareAppCacheInstance=nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate,^{
        shareAppCacheInstance=[[AppCache alloc]init];
    });
    return shareAppCacheInstance;
}

-(id)init{
    if (self) {
        assert(self!=nil);
        [self reStoreBaseData];
    }
    return self;
}

-(ImageBlock *)readDataIsLastBlockFromPath:(NSString *)path{
    //这里
    NSFileHandle *inFile=[NSFileHandle fileHandleForReadingAtPath:path];
    assert(inFile!=nil);
    [inFile seekToFileOffset:[self getOffSetWithFilePath:path andDict:self.BlockSendedTable]];
    NSData *data=[inFile readDataOfLength:BlockSize];
    ImageBlock *packet=[[ImageBlock alloc]init];
    //判断文件大小，缓存文件大小，避免每次都重新计算
    //在判断文件大小之后，才可以去判断文件是否到头了
    packet.Total=[self getFileCapacityWithName:path];
    if ([self isEof:inFile andFilename:path]) {
        packet.Eof=YES;
        [FileCapacity removeObjectForKey:path];
    }else{
        packet.Eof=NO;
        [self setNextBlockWith:path andDict:BlockSendedTable];
    }
    //packet.Name的名字应该是独特的，中间用“/”分隔
    packet.Name=[path lastPathComponent];
    packet.Data=data;
    packet.Sender=self.Sender;
    [inFile closeFile];
    return packet;
}

-(void)setNextBlockWith:(NSString *)path andDict:(NSMutableDictionary *)dict{
    //这里有问题，万一【dict objectforkey：path】为空
    int newValue=[[dict objectForKey:path]intValue]+1;
    [dict setObject:[NSNumber numberWithInt:newValue] forKey:path];
}
-(BOOL)isEof:(NSFileHandle *)handle andFilename:(NSString *)name{
    unsigned long long cur=[handle offsetInFile];
    unsigned long long end=[self getFileCapacityWithName:name];
    if(cur>=end){
        return YES;
    }
    return NO;
}

-(unsigned long long)getFileCapacityWithName:(NSString *)name{
    if([FileCapacity objectForKey:name]==nil){
        unsigned long long length=[[[NSFileManager defaultManager]contentsAtPath:name]length];
        [FileCapacity setObject:[NSNumber numberWithUnsignedLongLong:length] forKey:name];
    }
    return [[FileCapacity objectForKey:name]unsignedLongLongValue];
}

-(NSUInteger)getOffSetWithFilePath:(NSString *)path andDict:(NSMutableDictionary *) dict{
    if ([dict objectForKey:path]==nil) {
        [dict setObject:[NSNumber numberWithInteger:0] forKey:path];
        return 0*BlockSize;
    } else {
        return [[dict objectForKey:path]intValue]*BlockSize;
    }
}


-(NSString *)storeData:(ImageBlock *)image{
//    image.Name=@"/Users/developer03/Desktop/text/testImg.jpg";
    if ([self isFileExistentWithFileName:image.Name]==NO){
        [[NSFileManager defaultManager] createFileAtPath:image.Name contents:nil attributes:nil];
    }
    NSFileHandle *outFile=[NSFileHandle fileHandleForWritingAtPath:image.Name];
    unsigned long long length=[self getOffSetWithFilePath:image.Name andDict:BlockReceivedTable];
    [outFile seekToFileOffset:length];
    [outFile writeData:image.Data];
    [outFile closeFile];
    if (image.Eof) {
        [BlockReceivedTable removeObjectForKey:image.Name];
        [ImageReceived addObject:image.Name];
        //这里应该把NSData变成反序列化，还原成图片
        return @"100%";
    }else{
        [self setNextBlockWith:image.Name andDict:BlockReceivedTable];
        return [NSString stringWithFormat:@"%.1llu",(length+BlockSize)*100/image.Total];
    }
    
}

-(BOOL)isFileExistentWithFileName:(NSString *)fileName{
    if([BlockReceivedTable objectForKey:fileName]==nil)
        return NO;
    return YES;
}

//序列化
-(void)storeBaseData{
    //局部变量，只有在用的时候才创建
    NSString *BlockReceivedTablePath=[NSHomeDirectory() stringByAppendingString:@"/BlockReceivedTablePath1.plist"];
    NSString *BlockSendedTablePath=[NSHomeDirectory() stringByAppendingString:@"/BlockSendedTable1.plist"];
    NSString *FileCapacityPath=[NSHomeDirectory() stringByAppendingString:@"/FileCapacity1.plist"];
    NSString *SenderPath=[NSHomeDirectory() stringByAppendingString:@"/Sender1.plist"];
    NSString *ImageReceivedPath=[NSHomeDirectory() stringByAppendingString:@"/ImageReceived1.plist"];

    [self.BlockReceivedTable writeToFile:BlockReceivedTablePath atomically:YES];
    [self.BlockSendedTable writeToFile:BlockSendedTablePath atomically:YES];
    [self.FileCapacity writeToFile:FileCapacityPath atomically:YES];
    [self.Sender writeToFile:SenderPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [self.ImageReceived writeToFile:ImageReceivedPath atomically:YES];
}

//反序列化
-(void)reStoreBaseData{
    //局部变量，只有在用的时候才创建
    NSString *BlockReceivedTablePath=[NSHomeDirectory() stringByAppendingString:@"/BlockReceivedTablePath1.plist"];
    NSString *BlockSendedTablePath=[NSHomeDirectory() stringByAppendingString:@"/BlockSendedTable1.plist"];
    NSString *FileCapacityPath=[NSHomeDirectory() stringByAppendingString:@"/FileCapacity1.plist"];
    NSString *SenderPath=[NSHomeDirectory() stringByAppendingString:@"/Sender1.plist"];
    NSString *ImageReceivedPath=[NSHomeDirectory() stringByAppendingString:@"/ImageReceived1.plist"];
    
    //第一次打开应用程序时，下面4项是nil
    self.BlockReceivedTable=[self reStoreDictWithPath:BlockReceivedTablePath];
    self.BlockSendedTable=[self reStoreDictWithPath:BlockSendedTablePath];
    self.FileCapacity=[self reStoreDictWithPath:FileCapacityPath];
    self.Sender=[self reStroeSenderWithPath:SenderPath];
    self.ImageReceived=[self reStoreArrayWithPath:ImageReceivedPath];
}

-(NSMutableDictionary *)reStoreDictWithPath:(NSString *)path{
    NSMutableDictionary *temp=[[NSMutableDictionary alloc]initWithContentsOfFile:path];
    if(temp==nil)
        temp=[[NSMutableDictionary alloc]initWithCapacity:20];
    return temp;
}

-(NSString *)reStroeSenderWithPath:(NSString *)path{
    NSString *temp=[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if(temp==nil)
        temp=@"";
    return temp;
}
-(NSMutableArray *)reStoreArrayWithPath:(NSString *)path{
    NSMutableArray *temp=[NSMutableArray arrayWithContentsOfFile:path];
    if(temp==nil)
        temp=[[NSMutableArray alloc]initWithCapacity:20];
    return temp;
}

-(NSString *)getPercentageWithSendingFileName:(NSString *)name{
    unsigned long long capacity=[[FileCapacity objectForKey:name]unsignedLongLongValue];
    unsigned long long hadLoad=[[BlockSendedTable objectForKey:name]intValue]*BlockSize;
    NSString *percentage=[NSString stringWithFormat:@"%.1llu",hadLoad*100/capacity];
    return percentage;
}

@end
