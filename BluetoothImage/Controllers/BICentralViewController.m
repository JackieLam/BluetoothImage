//
//  BICentralViewController.m
//  BluetoothImage
//
//  Created by Cho-Yeung Lam on 28/3/14.
//  Copyright (c) 2014 Cho-Yeung Lam. All rights reserved.
//

#import "BICentralViewController.h"

#import "ImageBlock.h"
#import <sqlite3.h>

static NSString *CELL_IDENTIFIER = @"CellIdentifier";

@interface BICentralViewController ()
@property (strong, nonatomic) BICentralHandler *centralHandler;
@property (strong, nonatomic) NSMutableArray *peripherals;
@property (strong, nonatomic) UIAlertView *alertView;
@property (strong, nonatomic) IBOutlet UILabel *transferStatusInfo;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) NSInteger transferedDataCount;
@property (strong, nonatomic) IBOutlet UILabel *transferedDataCountInfo;
@property (nonatomic) BOOL isConnecting;
@end

@implementation BICentralViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _isConnecting = NO;
    _peripherals = [[NSMutableArray alloc] initWithCapacity:7];
    
    _centralHandler = [[BICentralHandler alloc] initWithDelegate:self];
    
    _progressView.progress = 0.0f;
    
    // Show devices list
    _alertView = [[UIAlertView alloc] initWithTitle:@"Select Device" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
    UITableView *deviceListView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 230, 200)];
    [deviceListView registerClass:[UITableViewCell class] forCellReuseIdentifier:CELL_IDENTIFIER];
    deviceListView.dataSource = self;
    deviceListView.delegate = self;
    [_alertView setValue:deviceListView forKeyPath:@"accessoryView"];
    [_alertView show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BICentralHandlerDelegate

- (void)didDiscoverPeripheralName:(NSString *)peripheral {
    // Add new peripheral to devices list
    BOOL alreadyDiscovered = NO;
    for (NSString *discoveredPeripheral in _peripherals) {
        if ([discoveredPeripheral isEqual:peripheral]) {
            alreadyDiscovered = YES;
        }
    }
    if (!alreadyDiscovered) {
        [_peripherals addObject:peripheral];
    }
}

- (void)didFailToConnectPeripheralName:(NSString *)peripheralName error:(NSError *)error {
    _isConnecting = NO;
    assert(_alertView != nil && _alertView.isVisible);
    _alertView.message = [NSString stringWithFormat:@"fail to connect with %@", peripheralName];
    if (error) {
        _alertView.message = [_alertView.message stringByAppendingFormat:@" with error: %@", error.description];
    }
}

- (void)didConnectPeripheralName:(NSString *)peripheral error:(NSError *)error
{
    _alertView.message = @"Successed!";
    [_centralHandler stopScanning];
    [_alertView dismissWithClickedButtonIndex:-1 animated:YES];
}

- (void)didDisconnectPeripheralName:(NSString *)peripheral error:(NSError *)error
{
    assert(!_alertView.isVisible);
    _isConnecting = NO;
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Info" message:[NSString stringWithFormat:@"disconnect with %@", peripheral] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
}

- (void)updateProgressPercentage:(float)percent WithImageBlock:(ImageBlock *)imageBlock;
{
    _progressView.progress = percent;
    unsigned long long transfered = percent * imageBlock.Total;
    _transferedDataCountInfo.text = [NSString stringWithFormat:@"Finished: %llu KB/%llu KB", transfered/1024, imageBlock.Total/1024];
    
    if (percent >= 1.0f) {
        _transferStatusInfo.text = @"Transfered Finished!";
        [_progressView setHidden:YES];
        
        // Load the image file and Display it.
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:imageBlock.Name];
        if (data == nil) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat: @"Cannot open the file: %@", imageBlock.Name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        } else {
            // TODO: use dispatch queue?
            UIImage *image = [UIImage imageWithData:[[NSFileManager defaultManager] contentsAtPath:imageBlock.Name]];
            [_imageView setImage:image];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_peripherals count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CELL_IDENTIFIER];
    }
    cell.textLabel.text = _peripherals[indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_isConnecting) {
        _isConnecting = YES;
        _alertView.message = [NSString stringWithFormat:@"connecting to %@...", _peripherals[indexPath.row]];
        [_centralHandler connectToPeripheralName:_peripherals[indexPath.row]];
    }
}

#pragma mark - Alert view delegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [_centralHandler stopScanning];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Helper
- (void)cleanUp
{
    [_peripherals removeAllObjects];
    _isConnecting = NO;
}

@end
