#import "FSBluetoothManager.h"
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>

@interface FSDeviceScanViewController : UIViewController <FSBluetoothDelegate, UITableViewDelegate, UITableViewDataSource>

@end
