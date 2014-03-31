//
//  BIPeripheralHandler.h
//  BluetoothImage
//
//  Created by Cho-Yeung Lam on 28/3/14.
//  Copyright (c) 2014 Cho-Yeung Lam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "AppCache.h"

@protocol BIPeripheralHandlerDelegate <NSObject>

// Step 1: Advertising
- (void)didStartAdvertising;
- (void)didStopAdvertising;
- (void)didSubscribeToCharacteristic:(CBCharacteristic *)characteristic;
- (void)didUnSubscribeToCharacteristic:(CBCharacteristic*)characteristic;
// Step 2: Send data to central
- (void)updateProgressPercentage:(float)percent WithData:(ImageBlock *)imageBlock; //will keep updating the percentage value when sending data to peripheral, when percent == 1.0, the update is finished. Data is split into chunks. You should keep appending data in viewController until percent == 1.0, after which you could unarchive the data.

@end

@interface BIPeripheralHandler : NSObject<CBPeripheralManagerDelegate>
{
	AppCache *appCache;
	BOOL sendingLastBLock;
	NSString *filePath;
}

@property(weak, nonatomic) id<BIPeripheralHandlerDelegate, CBPeripheralManagerDelegate> delegate;

- (id)initWithDelegate:(id)controller;
- (void)startAdvertising;
- (void)stopAdvertising;
//- (void)sendImage:(UIImage*)image;
- (void)sendFile:(NSString*)path;

@end
