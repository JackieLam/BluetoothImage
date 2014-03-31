//
//  BIDataPacker.h
//  BluetoothImage
//
//  Created by 黎小凤 on 14-3-29.
//  Copyright (c) 2014年 Cho-Yeung Lam. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BI_EOF 255
#define BI_ESC 128

@interface BIDataPacker : NSObject
{
	NSMutableData* deserializeResult;
	NSMutableData* deserializeRest;
}

+(NSMutableData*) serializeData:(NSMutableData *)data;//use for pack NSData, in order to send correctively
-(NSMutableData*) deserializeData:(NSMutableData *)data;//use for unpack NSData, when the package is uncompleted return nil, else return the hole package

@end
