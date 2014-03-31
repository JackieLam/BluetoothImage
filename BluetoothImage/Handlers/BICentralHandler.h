//
//  BICentralHandler.h
//  BluetoothImage
//
//  Created by Cho-Yeung Lam on 28/3/14.
//  Copyright (c) 2014 Cho-Yeung Lam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class ImageBlock;
@protocol BICentralHandlerDelegate <NSObject>

// Step 1: Discovering and connecting the peripheral
- (void)didDiscoverPeripheralName:(NSString *)peripheralName;
- (void)didConnectPeripheralName:(NSString *)peripheralName error:(NSError *)error; //Maybe useless
- (void)didDisconnectPeripheralName:(NSString *)peripheralName error:(NSError *)error;
// Step 2: Get the data of the peripheral
- (void)updateProgressPercentage:(float)percent WithImageBlock:(ImageBlock *)imageBlock; //will keep updating the percentage value when receiving data from peripheral, when percent == 1.0, the update is finished. Data is split into chunks. You should keep appending data in viewController until percent == 1.0, after which you could unarchive the data.

// After some attempts, the central handler failed to connect the peripheral.
- (void)didFailToConnectPeripheralName:(NSString *)peripheralName error:(NSError *)error;

@end

@interface BICentralHandler : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) id<BICentralHandlerDelegate> delegate;

- (id)initWithDelegate:(id)controller;
- (void)startScanning;
- (void)stopScanning;
- (void)connectToPeripheralName:(NSString *)peripheralName;

// Interface of retrieving cache
//- (void)continueTransferWithPeripheralName:(NSString *)peripheralName withFileName:(NSString *)fileName;

@end


