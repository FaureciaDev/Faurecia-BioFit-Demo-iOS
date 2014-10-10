#import "FSDeviceScanViewController.h"
#import "FSBluetoothManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>

@interface FSDeviceScanViewController () {
    BOOL isScanning;
}
@property (weak, nonatomic) IBOutlet UIButton *toggleScan;
@property (weak, nonatomic) IBOutlet UITableView *deviceTable;

@property (strong, nonatomic) CBPeripheral *activePeripheral;


@end

@implementation FSDeviceScanViewController 

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.deviceTable.dataSource = self;
    self.deviceTable.delegate = self;
	
	self->isScanning = true;
	[self stopScanning];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tableIdentifier = @"tableCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
    }
	
	CBPeripheral *device = [self deviceByNum:indexPath.row];
	NSString *rowText;
	if(device != nil) {
		rowText = [NSString stringWithFormat:@"%@ id: %@", device.name, device.identifier.UUIDString];
	}
    
    cell.textLabel.text = rowText;
    
    return cell;
    
}

- (void) discoveredDevice:(CBPeripheral *)device {
	[self.deviceTable reloadData];
}

- (CBPeripheral *)deviceByNum:(NSInteger)num {
    NSMutableArray *devices = [FSBluetoothManager sharedInstance].foundDevices;
	
    return (num >= 0 && num < devices.count) ? (CBPeripheral *)[devices objectAtIndex:num] : nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [FSBluetoothManager sharedInstance].foundDevices.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[[FSBluetoothManager sharedInstance] connectToDeviceByIndex: indexPath.row];
    [self performSegueWithIdentifier: @"ShowDeviceDetail" sender: self.deviceTable];
}


- (void)startScanning
{
	NSLog(@"scanning is on");
    [self.toggleScan setTitle: @"Stop" forState: UIControlStateNormal];
	
	[[FSBluetoothManager sharedInstance] startScanningWith:self];
}

- (void)stopScanning
{
	NSLog(@"scanning is off");
    [self.toggleScan setTitle: @"Start" forState: UIControlStateNormal];
	[[FSBluetoothManager sharedInstance] stopScanning];
}

- (IBAction)toggleScanning:(id)sender {
    isScanning = !isScanning;
    if (isScanning) {
        [self startScanning];
    } else {
        [self stopScanning];
    }
}

@end
