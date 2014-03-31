//
//  BIPeripheralViewController.h
//  BluetoothImage
//
//  Created by Cho-Yeung Lam on 28/3/14.
//  Copyright (c) 2014 Cho-Yeung Lam. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BIPeripheralHandler.h"

@interface BIPeripheralViewController : UIViewController <BIPeripheralHandlerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end
