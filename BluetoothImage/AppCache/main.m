//
//  main.m
//  AppCache
//
//  Created by developer 03 on 14-3-28.
//  Copyright (c) 2014年 developer 03. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppCache.h"
#import "ImageBlock.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        //单例测试代码通过
//        AppCache *a=[AppCache shareManager];
//        AppCache *b=[AppCache shareManager];
//        AppCache *c=[AppCache shareManager];
//        NSLog(@"%@",a);
//        NSLog(@"%@",b);
//        NSLog(@"%@",c);
//        
//        
//        NSMutableString *string=[[NSMutableString alloc]init];
//        for (int i=0; i<6168; ++i) {
//            [string appendString:@"qwertyuiop[]asdfghjkl;'/.,mnbvcxz\n"];
//        }
//        NSData *data=[string dataUsingEncoding:NSUTF8StringEncoding];
//        
//        NSMutableString *string1=[[NSMutableString alloc]init];
//        for(int i=0;i<6168;++i){
//             [string1 appendString:@"qwertyuiop[]asdfghjkl;'/.,mnbvcxz\n"];
//        }
//        NSData *data1=[string1 dataUsingEncoding:NSUTF8StringEncoding];
//        
//        ImageBlock *ia=[[ImageBlock alloc]init];
//        ia.Eof=NO;
//        ia.Data=data;
//        ia.Name=@"zihang";
//        NSLog(@"data %ld",[data length]);
//        NSLog(@"data1 %ld",[data1 length]);
//        
//        
//        ImageBlock *ib=[[ImageBlock alloc]init];
//        ib.Eof=YES;
//        ib.Data=data1;
//        ib.Name=@"zihang";
//        
//        //storedata test
//        [a storeData:ia];
//        [a storeData:ib];
//        
//        //read test
//        ImageBlock *ic=[b readDataIsLastBlockFromPath:@"zihang"];
//        NSLog(@"ib.data %ld",[ib.Data length]);
//        
//        //序列化与反序列化 test
//        [a storeBaseData];
        AppCache *d=[AppCache shareManager];
        [d reStoreBaseData];
        NSString *dir=[NSHomeDirectory() stringByAppendingString:@"/Desktop/testImg.jpg"];
        NSLog(dir);
        //test read success
        unsigned long long readcount=0;
        unsigned long long writecount=0;
        ImageBlock *temp;
        do {
            //test read
            temp=[d readDataIsLastBlockFromPath:dir];
            readcount+=[temp.Data length];

            //test write
            [d storeData:temp];
            writecount+=[temp.Data length];
            
            //test break
            if(readcount>3568757)
            {
                break;
            }

        } while (!temp.Eof);
        NSLog(@"had read %llu bytes",readcount);
        NSLog(@"had write %llu bytes",writecount);
        [d storeBaseData];
        
        
        
    }
    return 0;
}

