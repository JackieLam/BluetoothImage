//
//  BICentralHandler.h
//  BluetoothImage
//
//  Created by Cho-Yeung Lam on 28/3/14.
//  Copyright (c) 2014 Cho-Yeung Lam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol BICentralHandlerDelegate <NSObject>

// Step 1: Discovering and connecting the peripheral
- (void)didDiscoverPeripheralName:(NSString *)peripheral;
- (void)didConnectPeripheralName:(NSString *)peripheral error:(NSError *)error;
- (void)didDisconnectPeripheralName:(NSString *)peripheral error:(NSError *)error;
// Step 2: Get the data of the peripheral
- (void)updateProgressPercentage:(float)percent WithData:(NSData *)data; //will keep updating the percentage value when receiving data from peripheral, when percent == 1.0, the update is finished. Data is split into chunks. You should keep appending data in viewController until percent == 1.0, after which you could unarchive the data.

@end

@interface BICentralHandler : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) id<BICentralHandlerDelegate> delegate;

- (void)startScanning;
- (void)stopScanning;

@end


