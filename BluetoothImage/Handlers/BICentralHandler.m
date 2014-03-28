//
//  BICentralHandler.m
//  BluetoothImage
//
//  Created by Cho-Yeung Lam on 28/3/14.
//  Copyright (c) 2014 Cho-Yeung Lam. All rights reserved.
//

#import "BICentralHandler.h"
#import "SERVICES.h"

@interface BICentralHandler()

@property (nonatomic, strong) CBCentralManager *centralManager;

@end

@implementation BICentralHandler

- (id)initWithDelegate:(id)controller
{
    self = [super init];
    if (self) {
        self.delegate = controller;
        dispatch_queue_t centralQueue = dispatch_queue_create(QUEUE_CENTRALMANAGER, DISPATCH_QUEUE_SERIAL);
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:centralQueue options:@{CBCentralManagerOptionShowPowerAlertKey: @YES}];
    }
    return self;
}

#pragma mark -
#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    // Further implementatiton
    // ...
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    // Further implementatiton
    // ...
    
    [self.delegate didDiscoverPeripheralName:peripheral.name];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    // Further implementatiton
    // ...
    
    [self.delegate didConnectPeripheralName:peripheral.name error:nil];
}


- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    // Further implementatiton
    // ...
    
    [self.delegate didConnectPeripheralName:peripheral.name error:error];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    // Further implementatiton
    // ...
    
    [self.delegate didDisconnectPeripheralName:peripheral.name error:error];
}

#pragma mark -
#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{

}


#pragma mark - 
#pragma mark - Public Method

- (void)startScanning
{
    
}

- (void)stopScanning
{

}

@end
