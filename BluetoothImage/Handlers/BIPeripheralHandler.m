//
//  BIPeripheralHandler.m
//  BluetoothImage
//
//  Created by Cho-Yeung Lam on 28/3/14.
//  Copyright (c) 2014 Cho-Yeung Lam. All rights reserved.
//

#import "BIPeripheralHandler.h"
#import "SERVICES.h"
#import "AppCache.h"
#import "BIDataPacker.h"

@interface BIPeripheralHandler()

@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic *transferCharacteristic;
@property (strong, nonatomic) NSMutableData *dataToSend;
@property (readwrite, nonatomic) NSInteger sendDataIndex;

@end

@implementation BIPeripheralHandler

- (id)initWithDelegate:(id)controller
{
    self = [super init];
    if (self) {
        self.delegate = controller;
		appCache = [AppCache shareManager];
		sendingLastBLock = NO;
        dispatch_queue_t peripheralQueue = dispatch_queue_create(QUEUE_PERIPHERALMANAGER, DISPATCH_QUEUE_SERIAL);
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:peripheralQueue options:@{CBCentralManagerOptionShowPowerAlertKey: @YES}];
    }
    return self;
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:ORIGIN_IMAGE_CHARACTERISTIC] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
		
        CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:IMAGE_SERVICE_UUID] primary:YES];
		
        transferService.characteristics = @[_transferCharacteristic];
		
        [_peripheralManager addService:transferService];
    }
    
}


//- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary *)dict
//{
//
//}


- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if (error) {
        NSLog(@"start advertising error!!");
        [_peripheralManager stopAdvertising];
        if (_delegate != nil) {
            [_delegate didStopAdvertising];
        }
        return;
    }
    if (_delegate != nil) {
        [_delegate didStartAdvertising];
    }
}



- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    if (error) {
        NSLog(@"add service error!");
    }
}



- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic

{
    if (_delegate != nil) {
        [_delegate didSubscribeToCharacteristic:characteristic];
    }
	
    //stop advertising when the perpheralManager has one subscriber
    [_peripheralManager stopAdvertising];
}


- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    if (_delegate != nil) {
        [_delegate didUnSubscribeToCharacteristic:characteristic];
    }
}

//
//- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
//{
//
//}
//
//
//- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests
//{
//
//}


- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    [self sendData];
}



#pragma mark -

- (void)sendData {
	
    
	
    // We're sending data
    // Is there any left to send?
    if (self.sendDataIndex >= self.dataToSend.length) {
        if (sendingLastBLock) {
			sendingLastBLock = NO;
		}
		else
		{
			[self sendFile:filePath];
		}
        return;
    }
	
    // There's data left, so send until the callback fails, or we're done.
    BOOL didSend = YES;
	
    while (didSend) {
        // Work out how big it should be
        NSInteger amountToSend = self.dataToSend.length - self.sendDataIndex;
		
        // Can't be longer than 20 bytes
        if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
		
        // Copy out the data we want
        NSData *chunk = [NSData dataWithBytes:self.dataToSend.bytes+self.sendDataIndex length:amountToSend];
		
        didSend = [self.peripheralManager updateValue:chunk forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
		
        // If it didn't work, drop out and wait for the callback
        if (!didSend) {
            return;
        }
		
        NSString *stringFromData = [[NSString alloc] initWithData:chunk encoding:NSUTF8StringEncoding];
        NSLog(@"Sent: %@", stringFromData);
		
        // It did send, so update our index
        self.sendDataIndex += amountToSend;
		
        // Was it the last one?
        if (self.sendDataIndex >= self.dataToSend.length) {
			if (sendingLastBLock) {
				sendingLastBLock = NO;
                // TODO: auto stop advertisement when transmission complete?
                //[_peripheralManager stopAdvertising];
			}
			else
			{
				[self sendFile:filePath];
			}
            return;
        }
    }
}


- (void)startAdvertising
{
    [_peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:IMAGE_SERVICE_UUID]] }];
}

- (void)stopAdvertising
{
    [_peripheralManager stopAdvertising];
}

- (void)sendFile:(NSString *)path
{
    if (!path) {
        return;
    }
#warning DANGER!!! The Receiver's name could not be nil!
	ImageBlock *imgBlock = [appCache readDataIsLastBlockFromPath:path ToReceiver:nil];
	if (imgBlock.Eof) {
		sendingLastBLock = YES;
	}
    
	//to transfer ImageBlock into NSData
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:imgBlock];
    _dataToSend = [NSMutableData dataWithData:data];
    _dataToSend = [BIDataPacker serializeData:_dataToSend];
	
    //reset the sendDataIndex before sending
    _sendDataIndex = 0;
    [self sendData];
}


@end
