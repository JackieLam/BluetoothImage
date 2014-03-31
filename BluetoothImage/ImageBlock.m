//
//  Image.m
//  AppCache
//
//  Created by developer 03 on 14-3-28.
//  Copyright (c) 2014年 developer 03. All rights reserved.
//

#import "ImageBlock.h"

@implementation ImageBlock

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.imageType = [decoder decodeIntForKey:@"imageType"];
    self.Sender = [decoder decodeObjectForKey:@"Sender"];
    self.Receiver = [decoder decodeObjectForKey:@"author"];
    self.Data = [decoder decodeObjectForKey:@"Data"];
    self.Eof = [decoder decodeBoolForKey:@"Eof"];
    self.Name = [decoder decodeObjectForKey:@"Name"];
    self.Total = [decoder decodeIntForKey:@"Total"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInt:self.imageType forKey:@"imageType"];
    [encoder encodeObject:self.Sender forKey:@"Sender"];
    [encoder encodeObject:self.Receiver forKey:@"Reunceiver"];
    [encoder encodeObject:self.Data forKey:@"Data"];
    [encoder encodeBool:self.Eof forKey:@"Eof"];
    [encoder encodeObject:self.Name forKey:@"Name"];
    [encoder encodeInt:self.Total forKey:@"Total"];
}


@end