//
//  Image.h
//  AppCache
//
//  Created by developer 03 on 14-3-28.
//  Copyright (c) 2014年 developer 03. All rights reserved.
//

#import <Foundation/Foundation.h>
//图片分块打包成Image，每个Image包含图片的一部分，用于断点重传以及出错重试

typedef enum : NSUInteger {
    IMAGETYPETHUMB,
    IMAGETYPEORIGIN,
} IMAGETYPE;

@interface ImageBlock : NSObject<NSCoding>

@property(nonatomic) IMAGETYPE imageType;
@property(nonatomic) NSString *Sender;
@property(nonatomic) NSString *Receiver;//断开重连时需要用到发送者和接受者的信息
@property(nonatomic) NSData *Data;//图片的块保存在Data
@property(nonatomic) BOOL Eof;//该Image是否是最后一个Image
@property(nonatomic) NSString *Name;//Data对应的图片的名字
@property(nonatomic) int Total;//该Image对应的图片的大小
//@property(nonatomic) NSUInteger *BreakPoint;//该Image的块号

@end
