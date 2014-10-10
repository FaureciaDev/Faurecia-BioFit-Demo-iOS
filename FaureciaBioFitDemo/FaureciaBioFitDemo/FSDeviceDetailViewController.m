#import "FSDeviceDetailViewController.h"
#import "FSBluetoothManager.h"

@interface FSDeviceDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *outputLabel;
@property (strong, nonatomic) CBUUID  *notifiableGroupValuesUUID;
@property (strong, nonatomic) CBUUID  *notifiableGroupUUID;
@property (strong, nonatomic) CBCharacteristic  *notifyValuesCharacteristic;
@property (strong, nonatomic) CBCharacteristic  *notifyGroupCharacteristic;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigation;

@end

@implementation FSDeviceDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[[FSBluetoothManager sharedInstance] updateDelegate:self];
    self.notifiableGroupValuesUUID =    [CBUUID UUIDWithString:@"5957BE8F-C01F-4531-A529-0924398E4FE9"];
    self.notifiableGroupUUID =          [CBUUID UUIDWithString:@"B4A265CD-2786-432D-8E92-819B9113AA10"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSArray *)unpack_group:(NSData *)g size:(NSArray *)s time:(uint32_t *)t {
    NSMutableArray *ds = [NSMutableArray arrayWithCapacity:s.count];
    *t = 0;
    if (g.length >= sizeof(*t)) {
        uint8_t *g_bytes = (uint8_t *)g.bytes;

        memcpy(t, g_bytes, sizeof(*t));
        *t = CFSwapInt32LittleToHost(*t);

        size_t offset = sizeof(*t);
        size_t i = 0;

        while (offset < g.length && i < s.count) {
            size_t size = [s[i] integerValue];
            [ds addObject:[NSData dataWithBytes:(g_bytes + offset) length:size]];
            offset += size;
            ++i;
        }
    }
    return ds;
}

- (int8_t)unpack_int8:(NSData *)d {
    int8_t n = 0;
    if (d.length >= sizeof(n)) {
        memcpy(&n, d.bytes, sizeof(n));
    }
    return n;
}

-(void) updateDisplayedText {
    uint32_t t = 0;
    NSArray *data = [self unpack_group:self.notifyValuesCharacteristic.value size:@[@1] time:&t];
    if(data.count > 0) {
        int8_t stressLevel = [self unpack_int8: data[0]];
    
        NSString *message = [NSString stringWithFormat:@"Stress level: %d", stressLevel];
        if (stressLevel > 60) {
            message = [NSString stringWithFormat:@"%@\n\nStress level is getting high!\nConsider starting a massage to relax.", message];
        }
        [self.outputLabel setText:message];
    }
    else {
        [self.outputLabel setText:@"Waiting for communication..."];
    }
}

- (void) discoveredCharacteristics:(CBService *)service {
    for (int i = 0; i < [service.characteristics count]; ++i) {
        CBCharacteristic *characteristic = service.characteristics[i];
        if ([characteristic.UUID isEqual:self.notifiableGroupValuesUUID]) {
            self.notifyValuesCharacteristic = characteristic;
        }
        else if ([characteristic.UUID isEqual:self.notifiableGroupUUID]) {
            self.notifyGroupCharacteristic = characteristic;
            [self subscribeToCharacteristics];
        }
    }
	[self updateDisplayedText];
}

- (void) subscribeToCharacteristics {
    uint8_t stressID = 15;
    NSData *data = [NSData dataWithBytes:&stressID length:sizeof(stressID)];
    
    [[FSBluetoothManager sharedInstance].connectedDevice writeValue:data forCharacteristic:self.notifyGroupCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void)updatedCharacteristicValue:(CBCharacteristic *)characteristic {
	[self updateDisplayedText];
}

- (void) discoveredServices:(CBPeripheral *)device {
	[self updateDisplayedText];
}

- (void) discoveredDevice:(CBPeripheral *)device {
	[self updateDisplayedText];
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        [[FSBluetoothManager sharedInstance] disconnect];
        [self.navigationController popViewControllerAnimated:NO];
    }
    [super viewWillDisappear:animated];
}

@end
