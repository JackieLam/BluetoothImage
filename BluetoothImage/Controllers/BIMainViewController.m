//
//  BIMainViewController.m
//  BluetoothImage
//
//  Created by Cho-Yeung Lam on 28/3/14.
//  Copyright (c) 2014 Cho-Yeung Lam. All rights reserved.
//

#import "BIMainViewController.h"

#import "BIPeripheralViewController.h"
#import "BICentralViewController.h"

@interface BIMainViewController ()
- (IBAction)doSendBtn:(id)sender;
- (IBAction)doReceiveBtn:(id)sender;

@end

@implementation BIMainViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doSendBtn:(id)sender {
    BIPeripheralViewController *peripheralViewController = [[BIPeripheralViewController alloc] initWithNibName:@"BIPeripheralViewController" bundle:nil];
    peripheralViewController.title = @"Sender";
    [self.navigationController pushViewController:peripheralViewController animated:YES];
}

- (IBAction)doReceiveBtn:(id)sender {
    BICentralViewController *centralViewController = [[BICentralViewController alloc] initWithNibName:@"BICentralViewController" bundle:nil];
    centralViewController.title = @"Receiver";
    [self.navigationController pushViewController:centralViewController animated:YES];
}
@end
