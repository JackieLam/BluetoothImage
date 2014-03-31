//
//  AppCache.h
//  AppCache
//
//  Created by developer 03 on 14-3-28.
//  Copyright (c) 2014年 developer 03. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageBlock.h"
@interface AppCache : NSObject
{
    NSMutableDictionary *BlockReceivedTable;//记录正在接受的块的块号，接受完毕后删除对应项
    NSMutableDictionary *BlockSendedTable;//记录正在发送的块的块号，发送完毕后删除对应项
    NSMutableDictionary *FileCapacity;//每个文件的大小
    NSMutableArray *ImageReceived;//已经接收的图片的路径
    NSString *Sender;//发送者的名字，可以是发送机器的uuid,有一个默认值
}

@property(nonatomic)NSString *Sender;
//记录某张图片接受到第几个分块，如果最后一块也接受完了，把对应的key/value删除
@property(nonatomic) NSMutableDictionary *BlockReceivedTable;
//记录某张图片发送到第几个分块，如果最后一块也发送完毕，把对应的key/value删除
@property(nonatomic) NSMutableDictionary *BlockSendedTable;
//记录正在发送的文件的大小，发送完毕后把对应key/value删除
@property(nonatomic) NSMutableDictionary *FileCapacity;
@property(nonatomic) NSMutableArray *ImageReceived;

//获取AppCache单例
+(AppCache *)shareManager;

//imageBlock是一个分块，接受完一个分块后调用该方法，其返回值是接受该文件的百分比
-(NSString *)storeData:(ImageBlock *)imageBlock;

//path是图片在闪存的路径，返回的NSMutableDictionary包含isLastBlock（最后一个分块）、data（Image对象）
//该方法会分块读取图片，读取完一个分块应该把该分块发送出去，删除该分块，再调用该方法，直到读完为止
-(ImageBlock *)readDataIsLastBlockFromPath:(NSString *)path;

//在应用程序结束的时候调用，把BlockReceivedTable、BlockSendedTable、FileCapacity和Sender储存到硬盘，下次打开应用的时候再把他们加载进内存
-(void)storeBaseData;

//在应用程序打开的时候调用，把上次保存的BlockReceivedTable、BlockSendedTable、FileCapacity和Sender恢复到内存
-(void)reStoreBaseData;

//获取发送某个文件的百分比
-(NSString *)getPercentageWithSendingFileName:(NSString *)flieName;

////返回含有已经接收的图片的路径的数组，该图片以NSData形式存在沙盒内
//-(NSMutableArray *)getReceivedImage;
@end
