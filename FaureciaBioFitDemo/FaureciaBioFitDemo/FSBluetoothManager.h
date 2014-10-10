#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>

@protocol FSBluetoothDelegate <NSObject>

@optional
- (void)discoveredDevice:(CBPeripheral *)device;
- (void)discoveredServices:(CBPeripheral *)device;
- (void)discoveredCharacteristics:(CBService *)device;
- (void)updatedCharacteristicValue:(CBCharacteristic *)characteristic;

@end

@interface FSBluetoothManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>
+ (FSBluetoothManager *)sharedInstance;
@property (strong, nonatomic) NSMutableArray *foundDevices;
@property (strong, nonatomic) CBPeripheral *connectedDevice;

- (void) startScanningWith:(id<FSBluetoothDelegate>)delegate;
- (void) stopScanning;
- (void) disconnect;
- (void) updateDelegate:(id<FSBluetoothDelegate>)delegate;
- (CBPeripheral *) connectToDeviceByIndex:(NSInteger) index;
- (CBService *) getServiceAtIndex:(NSInteger) index;

@end
