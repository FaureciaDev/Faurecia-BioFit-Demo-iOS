#import "FSBluetoothManager.h"

@interface FSBluetoothManager () {
    CBCentralManager *centralManager;
}

@property (strong, nonatomic) id<FSBluetoothDelegate> delegate;

@end

@implementation FSBluetoothManager

- (id)init {
    self = [super init];
    if (self) {
#if TARGET_IPHONE_SIMULATOR
        centralManager = nil;
#else
        dispatch_queue_t btle_queue = dispatch_queue_create("BTLE", DISPATCH_QUEUE_SERIAL);
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:btle_queue];
#endif
        _foundDevices = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (FSBluetoothManager *)sharedInstance {
    static FSBluetoothManager *this = nil;
    if (!this) {
        this = [[FSBluetoothManager alloc] init];
    }
    return this;
}
- (CBPeripheral *)connectToDeviceByIndex:(NSInteger)index {
    NSMutableArray *devices = self.foundDevices;
    CBPeripheral *device = (index >= 0 && index < devices.count) ? (CBPeripheral *)[devices objectAtIndex:index] : nil;
	
	[centralManager connectPeripheral:device options:nil];
	self.connectedDevice = device;
    [centralManager stopScan];
	
	return self.connectedDevice;
}

- (void) disconnect {
    [centralManager cancelPeripheralConnection:self.connectedDevice];
}

- (CBService *)getServiceAtIndex:(NSInteger) index {
	if (self.connectedDevice != nil && (index >= 0 && index < self.connectedDevice.services.count)) {
		return (CBService *)[self.connectedDevice.services objectAtIndex:index];
	}
	return nil;
}

- (void) updateDelegate:(id<FSBluetoothDelegate>) delegate {
	self.delegate = delegate;
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error {
	for (CBCharacteristic *characteristic in service.characteristics) {
        if (characteristic.properties & CBCharacteristicPropertyRead) {
            [self.connectedDevice readValueForCharacteristic:characteristic];
        }
        if (characteristic.properties & CBCharacteristicPropertyNotify) {
            NSLog(@"char %@ notifies", characteristic.UUID);
            [self.connectedDevice setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
		[self.delegate discoveredCharacteristics:service];
	});
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
	for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
		[self.delegate discoveredServices:peripheral];
	});
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"Characteristic value updated %@ %@", characteristic.UUID, characteristic.value);
    dispatch_async(dispatch_get_main_queue(), ^{
		[self.delegate updatedCharacteristicValue:characteristic];
	});
}

- (CBPeripheral *)addPeripheralIfNotExists:(CBPeripheral *)peripheral {
    for (CBPeripheral *device in self.foundDevices) {
        if ([device isEqual:peripheral]) {
            return device;
        }
    }
    [_foundDevices addObject:peripheral];
    return peripheral;
}

- (void)startScanningWith:(id<FSBluetoothDelegate>)delegate {
	self.delegate = delegate;
	[self startScanning];
}

- (void)startScanning {
    if (centralManager.state == CBCentralManagerStatePoweredOn) {
		[centralManager scanForPeripheralsWithServices:nil options:nil];
    }
}

- (void)stopScanning {
	[centralManager stopScan];
	[self.foundDevices removeAllObjects];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
    NSLog(@"connected: %@",  peripheral.name);
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    static CBCentralManagerState previousState = CBCentralManagerStateUnknown;
    switch ([centralManager state]) {
        case CBCentralManagerStatePoweredOn:
            NSLog(@"State: Powered On");
            break;
        case CBCentralManagerStateResetting:
            NSLog(@"State: Resetting");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"State: Unsupported");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"State: unauthorized");
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@"State: Powered Off");
            break;
        case CBCentralManagerStateUnknown:
            NSLog(@"State: Unknown");
            break;
    }
    previousState = [centralManager state];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
	[self addPeripheralIfNotExists:peripheral];
    dispatch_async(dispatch_get_main_queue(), ^{
		[self.delegate discoveredDevice:peripheral];
	});
}
@end
