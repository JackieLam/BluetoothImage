//
//  BICentralHandler.m
//  BluetoothImage
//
//  Created by Cho-Yeung Lam on 28/3/14.
//  Copyright (c) 2014 Cho-Yeung Lam. All rights reserved.
//

#import "BICentralHandler.h"
#import "SERVICES.h"
#import "ImageBlock.h"

@interface BICentralHandler()

@property (nonatomic, strong) CBCentralManager *centralManager;
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
        self.periNameMatchingDict = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark -
#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn) {
        // TODO: Alertion on opening the bluetooth
        return;
    }
	
    if (central.state == CBCentralManagerStatePoweredOn) {
        // Start scanning
		[_centralManager scanForPeripheralsWithServices:@[self.imageServiceUUID] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @NO }];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    self.periNameMatchingDict[peripheral.name] = peripheral; // Add the name to the matching dictionary
    [self.delegate didDiscoverPeripheralName:peripheral.name];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    if (peripheral.delegate == nil) {
        [peripheral setDelegate:self];
    }
    [peripheral discoverServices:@[self.imageServiceUUID]];
    [self.delegate didConnectPeripheralName:peripheral.name error:nil];
}


- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Fail to connect peripheral [REASON] : %@", [error localizedDescription]);
    [self.delegate didConnectPeripheralName:peripheral.name error:error];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self.delegate didDisconnectPeripheralName:peripheral.name error:error];
}

#pragma mark -
#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:self.imageServiceUUID]) {
            [peripheral discoverCharacteristics:@[self.originImageCharacteristicUUID] forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:self.originImageCharacteristicUUID]) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"didUpdateValueForCharacteristic Error");
        return;
    }
	
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
	dispatch_async(dispatch_get_main_queue(), ^{
        if ([stringFromData isEqualToString:@"EOM"]) {
#warning Unarchive to a ImageBlock model
            UIImage *image = [UIImage imageWithData:_dataReceive];
            
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
    
}

- (void)stopScanning
{

}

- (void)connectToPeripheralName:(NSString *)peripheralName
{
    CBPeripheral *per = self.periNameMatchingDict[peripheralName];
    [self.centralManager connectPeripheral:per options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @NO }];
}

@end
