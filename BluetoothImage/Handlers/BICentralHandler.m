//
//  BICentralHandler.m
//  BluetoothImage
//
//  Created by Cho-Yeung Lam on 28/3/14.
//  Copyright (c) 2014 Cho-Yeung Lam. All rights reserved.
//

#import "BICentralHandler.h"
#import "SERVICES.h"
//#import "ImageBlock.h"
#import "AppCache.h"

@interface BICentralHandler()

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *discoveredPeripheral;
@property (nonatomic, strong) CBUUID *imageServiceUUID;
@property (nonatomic, strong) CBUUID *originImageCharacteristicUUID;
@property (nonatomic, strong) CBUUID *thumbImageCharacteristicUUID;
@property (nonatomic, strong) NSMutableDictionary *periNameMatchingDict;

@property (nonatomic, strong) NSMutableData *dataReceive;
@property (nonatomic) NSInteger sendDataIndex;

@end

@implementation BICentralHandler

- (id)initWithDelegate:(id)controller
{
    self = [super init];
    if (self) {
        self.delegate = controller;
        
        dispatch_queue_t centralQueue = dispatch_queue_create(QUEUE_CENTRALMANAGER, DISPATCH_QUEUE_SERIAL);
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:centralQueue options:@{CBCentralManagerOptionShowPowerAlertKey: @YES}];
        
        self.imageServiceUUID = [CBUUID UUIDWithString:IMAGE_SERVICE_UUID];
        self.originImageCharacteristicUUID = [CBUUID UUIDWithString:ORIGIN_IMAGE_CHARACTERISTIC];
        self.thumbImageCharacteristicUUID = [CBUUID UUIDWithString:THUMB_IMAGE_CHARACTERISTIC];
        _periNameMatchingDict = [NSMutableDictionary dictionary];
        _dataReceive = [NSMutableData data];
    }
    return self;
}

#pragma mark -
#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn) {
        NSLog(@"[!] The Central Manager is turned down. ");
        return;
    }
	
    if (central.state == CBCentralManagerStatePoweredOn) {
        NSLog(@"[!] The Central Manager is on. ");
    }
}

// Callback from start scanning
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    self.periNameMatchingDict[peripheral.name] = peripheral;
    
    if (self.discoveredPeripheral.identifier != peripheral.identifier) {
        
        self.discoveredPeripheral = peripheral;
        NSLog(@"Begin to connect to the peripheral : %@", peripheral.identifier);
        [central connectPeripheral:peripheral options:nil];
    }
    
    [self.delegate didDiscoverPeripheralName:peripheral.name];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Connected to peripheral - %@", peripheral.name);
    [central stopScan];
    [_dataReceive setLength:0];
    [peripheral setDelegate:self];
    [peripheral discoverServices:@[self.imageServiceUUID]];
    [self.delegate didConnectPeripheralName:peripheral.name error:nil];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self cleanup];
    [NSThread sleepForTimeInterval:rand()%4];
    [central connectPeripheral:peripheral options:nil];
    
    [self.delegate didConnectPeripheralName:peripheral.name error:error];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    
    _discoveredPeripheral = nil;
//    [central scanForPeripheralsWithServices:@[self.imageServiceUUID] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    NSLog(@"[!] Disconnect the peripheral!");
    
    [self.delegate didDisconnectPeripheralName:peripheral.name error:error];
}

#pragma mark -
#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"  #   Services discovered !");
    if (error) {
        [self cleanup];
        return;
    }
    
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:self.imageServiceUUID]) {
            [peripheral discoverCharacteristics:@[self.originImageCharacteristicUUID] forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"  $   Characteristic discovered !");
    if (error) {
        [self cleanup];
        return;
    }

    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:self.originImageCharacteristicUUID]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"didUpdateValueForCharacteristic Error [REASON]: %@", [error localizedDescription]);
        return;
    }
	
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
	dispatch_async(dispatch_get_main_queue(), ^{
        if ([stringFromData isEqualToString:@"EOM"]) {
            
        // Finished and cancel the connection
            [peripheral setNotifyValue:NO forCharacteristic:characteristic];
            [_centralManager cancelPeripheralConnection:peripheral];
            
        // Finally unarchive the NSData
            ImageBlock *imageBlock = [NSKeyedUnarchiver unarchiveObjectWithData:_dataReceive];
            [self.delegate updateProgressPercentage:1.0f WithImageBlock:imageBlock];
        }
        else {
            [_dataReceive appendData:characteristic.value];
        }
    });
}

#pragma mark - 
#pragma mark - Public Method

- (void)startScanning
{
    [_centralManager scanForPeripheralsWithServices:@[self.imageServiceUUID] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @NO }];
}

- (void)stopScanning
{
    [_centralManager stopScan];
}

- (void)connectToPeripheralName:(NSString *)peripheralName
{
    CBPeripheral *per = self.periNameMatchingDict[peripheralName];
    [self.centralManager connectPeripheral:per options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @NO }];
}

- (void)continueTransferWithPeripheralName:(NSString *)peripheralName withFileName:(NSString *)fileName
{
    ImageBlock * imageBlock = [[AppCache shareManager] readDataIsLastBlockFromPath:fileName];
    CBPeripheral *per = self.periNameMatchingDict[peripheralName];
    
}

#pragma mark - Helper Method
- (void)cleanup
{
    if (_discoveredPeripheral.services != nil) {
        for (CBService *service in _discoveredPeripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:self.originImageCharacteristicUUID] || [characteristic.UUID isEqual:self.thumbImageCharacteristicUUID]) {
                        if (characteristic.isNotifying) {
                            [_discoveredPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            return;
                        }
                    }
                }
            }
        }
    }
    _discoveredPeripheral = nil;
    [_centralManager cancelPeripheralConnection:_discoveredPeripheral];
}

@end