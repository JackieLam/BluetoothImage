//
//  BIDataPacker.m
//  BluetoothImage
//
//  Created by 黎小凤 on 14-3-29.
//  Copyright (c) 2014年 Cho-Yeung Lam. All rights reserved.
//

#import "BIDataPacker.h"

@implementation BIDataPacker

-(id)init
{
	self = [super init];
	if (self)
	{
		deserializeRest = [[NSMutableData alloc] init];
		deserializeResult = [[NSMutableData alloc] init];
	}
	return self;
}

+(NSMutableData*) serializeData:(NSMutableData *)data
{
	const Byte *bytes = [data bytes];
	NSMutableData* result = [[NSMutableData alloc] init];
	Byte esc = BI_ESC;
	Byte eof = BI_EOF;
	for (int i = 0; i < data.length; ++i)
	{
		Byte curByte = bytes[i];
		if (curByte == BI_EOF || curByte == BI_ESC)
		{
			[result appendBytes:&esc length:1];
			
		}
		[result appendBytes:&curByte length:1];
	}
	[result appendBytes:&eof length:1];
	return result;
}



-(NSMutableData*)deserializeData:(NSMutableData *)data
{
	if (!data) {
		return nil;
	}
	NSMutableData *fullData = [[NSMutableData alloc] initWithData:deserializeRest];
	[deserializeRest setLength:0];
	[fullData appendData:data];
	const Byte *bytes = [fullData bytes];
	for (int i = 0; i < fullData.length; ++i)
	{
		Byte curByte = bytes[i];
		if (curByte == BI_ESC)
		{
			if (i + 1 < fullData.length)
			{
				curByte = bytes[++i];
			}
			else
			{
				deserializeRest = [NSMutableData dataWithBytes:&curByte length:1];
				return nil;
			}
		}
		else if(curByte == BI_EOF)
		{
			[deserializeRest appendBytes:&bytes[++i] length:data.length - i];
			NSMutableData *result = [[NSMutableData alloc] initWithData:deserializeResult];
			[deserializeResult setLength:0];
			return result;
		}
		[deserializeResult appendBytes:&curByte length:1];
	}
	return nil;
}



@end
