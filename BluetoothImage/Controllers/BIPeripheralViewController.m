//
//  BIPeripheralViewController.m
//  BluetoothImage
//
//  Created by Cho-Yeung Lam on 28/3/14.
//  Copyright (c) 2014 Cho-Yeung Lam. All rights reserved.
//

#import "BIPeripheralViewController.h"

@interface BIPeripheralViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UILabel *transferedDataCountInfo;
@property (strong, nonatomic) BIPeripheralHandler *peripheralHandler;
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) IBOutlet UIButton *chooseOrCanelButton;
@property (nonatomic) BOOL isSending;
- (IBAction)doChoosePhotoBtn:(id)sender;

@end

@implementation BIPeripheralViewController

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
    _peripheralHandler = [[BIPeripheralHandler alloc] initWithDelegate:self];
    _isSending = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        _progressView.progress = 0.0f;
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doChoosePhotoBtn:(id)sender {
    if (_isSending) {
        // TODO: cancel sending photo
    } else {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        [imagePickerController setDelegate:self];
        [self presentViewController:imagePickerController animated:YES completion: NULL];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:NO completion:NULL];
    [_peripheralHandler startAdvertising];
    
    _isSending = YES;
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [_imageView setImage:image];
    
    NSURL *url = [info objectForKey:UIImagePickerControllerReferenceURL];
    [self setFileNameWithURL:url];

    if (![[NSFileManager defaultManager] fileExistsAtPath:_fileName]) {
        CGDataProviderRef provider = CGImageGetDataProvider(image.CGImage);
        NSData *data = CFBridgingRelease(CGDataProviderCopyData(provider));
        if (![data writeToFile:_fileName atomically:YES]) {
            NSLog(@"Cannot write to file: %@", _fileName);
        }
    }
    
    _progressView.progress = 0.0f;
    [_chooseOrCanelButton setTitle:@"Cancel" forState:UIControlStateNormal];
}

- (void)setFileNameWithURL: (NSURL *)url {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _fileName = [defaults objectForKey:url.description];
    if (_fileName == nil) {
        NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirPath = [path objectAtIndex:0];
        _fileName = [NSString stringWithFormat:@"%@/%@", documentDirPath, [self getNewFileNameWithExt:url.pathExtension]];
        [defaults setObject:_fileName forKey:url.description];
    }
}

#pragma mark - BIPeripheralHandlerDelegate
- (void)didStartAdvertising {
    NSLog(@"Did start advertising");
}

- (void)didStopAdvertising {
    NSLog(@"Did Stop advertising...");
}

- (void)didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    if (_fileName) {
        [_peripheralHandler sendFile:_fileName];
    }
}

- (void)didUnSubscribeToCharacteristic:(CBCharacteristic*)characteristic {
    NSLog(@"central unsubscribe to characteristic");
}

- (void)updateProgressPercentage:(float)percent WithData:(ImageBlock *)imageBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        _progressView.progress = percent;
        unsigned long long transfered = percent * imageBlock.Total;
        _transferedDataCountInfo.text = [NSString stringWithFormat:@"Finished: %llu KB/%llu KB", transfered/1024, imageBlock.Total/1024];
        
        if (percent >= 1.0f) {
            [_progressView setHidden:YES];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Successed!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [av show];
            // delete the temp image file
            [[NSFileManager defaultManager] removeItemAtPath:_fileName error:nil];
        }
    });
}
#pragma mark - Helper
- (NSString *)getNewFileNameWithExt: (NSString*)ext {
    NSDate *curDate = [NSDate date];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    return [[fmt stringFromDate:curDate] stringByAppendingPathExtension:ext];
}

@end
