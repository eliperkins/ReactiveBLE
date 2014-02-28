//
//  RBTCentralManager.m
//  ReactiveBLE
//
//  Created by Indragie Karunaratne on 2014-02-26.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "RBTCentralManager.h"

#if TARGET_OS_IPHONE
#import <CoreBluetooth/CoreBluetooth.h>
#else
#import <IOBluetooth/IOBluetooth.h>
#endif

@interface RBTCentralManager () <CBCentralManagerDelegate>
@property (nonatomic, readonly) dispatch_queue_t CBQueue;
@property (nonatomic, strong, readonly) RACScheduler *CBScheduler;
@property (nonatomic, strong, readonly) CBCentralManager *manager;
@end

@implementation RBTCentralManager

#pragma mark - Initialization

- (id)initWithOptions:(NSDictionary *)options
{
	if ((self = [super init])) {
		_CBQueue = dispatch_queue_create("com.indragie.RBTCentralManager.CoreBluetoothQueue", DISPATCH_QUEUE_SERIAL);
		_CBScheduler = [[RACTargetQueueScheduler alloc] initWithName:@"com.indragie.RBTCentralManager.CoreBluetoothScheduler" targetQueue:_CBQueue];
		_manager = [[CBCentralManager alloc] initWithDelegate:self queue:_CBQueue options:options];
	}
	return self;
}

- (id)init
{
	return [self initWithOptions:nil];
}

#pragma mark - State

- (RACSignal *)stateSignal
{
	@weakify(self);
	return [[[[[RACSignal
		defer:^{
			@strongify(self);
			return [RACSignal return:self.manager];
		}]
		concat:[[self rac_signalForSelector:@selector(centralManagerDidUpdateState:) fromProtocol:@protocol(CBCentralManagerDelegate)]
			reduceEach:^(CBCentralManager *manager) {
				return manager;
			}]]
		map:^(CBCentralManager *manager) {
			return @(manager.state);
		}]
		takeUntil:self.rac_willDeallocSignal]
		setNameWithFormat:@"RBTCentralManager -stateSignal"];
}

- (RACSignal *)scanForPeripheralsWithServices:(NSArray *)services options:(NSDictionary *)options
{
	return [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
		RACSerialDisposable *disposable = [[RACSerialDisposable alloc] init];
		[self.CBScheduler schedule:^{
			[self.manager scanForPeripheralsWithServices:services options:options];
			disposable.disposable = [[[self
				rac_signalForSelector:@selector(centralManager:didDiscoverPeripheral:advertisementData:RSSI:) fromProtocol:@protocol(CBCentralManagerDelegate)]
				reduceEach:^(CBCentralManager *manager, CBPeripheral *peripheral, NSDictionary *data, NSNumber *RSSI) {
					return RACTuplePack(peripheral, data, RSSI);
				}]
				subscribe:subscriber];
		}];
		return [RACDisposable disposableWithBlock:^{
			[disposable dispose];
			[self.CBScheduler schedule:^{
				[self.manager stopScan];
			}];
		}];
	}]
	takeUntil:[[self
		rac_signalForSelector:@selector(scanForPeripheralsWithServices:options:)]
		filter:^BOOL(RACTuple *args) {
			return ![args isEqual:RACTuplePack(services, options)];
		}]]
	setNameWithFormat:@"RBTCentralManager rbt_scanForPeripheralsWithServices: %@ options: %@", services, options];
}

- (RACSignal *)connectPeripheral:(CBPeripheral *)peripheral options:(NSDictionary *)options
{
	return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
		RACSerialDisposable *disposable = [[RACSerialDisposable alloc] init];
		[self.CBScheduler schedule:^{
			[self.manager connectPeripheral:peripheral options:options];
			
			RACDisposable *connectedDisposable = [[[[self
				rac_signalForSelector:@selector(centralManager:didConnectPeripheral:) fromProtocol:@protocol(CBCentralManagerDelegate)]
				reduceEach:^(CBCentralManager *manager, CBPeripheral *connectedPeripheral) {
					return connectedPeripheral;
				}]
				filter:^BOOL (CBPeripheral *connectedPeripheral) {
					return [connectedPeripheral isEqual:peripheral];
				}]
				subscribeNext:^(CBPeripheral *connectedPeripheral) {
					[subscriber sendNext:connectedPeripheral];
					[subscriber sendCompleted];
				}];
			RACDisposable *failedDisposable = [[[self
				rac_signalForSelector:@selector(centralManager:didFailToConnectPeripheral:error:) fromProtocol:@protocol(CBCentralManagerDelegate)]
				filter:^BOOL(RACTuple *args) {
					return [args.second isEqual:peripheral];
				}]
				subscribeNext:^(RACTuple *args) {
					[subscriber sendError:args.third];
				}];
			disposable.disposable = [RACCompoundDisposable compoundDisposableWithDisposables:@[ connectedDisposable, failedDisposable ]];
		}];
		return [RACDisposable disposableWithBlock:^{
			if (disposable.disposable) {
				[disposable dispose];
				[self.CBScheduler schedule:^{
					[self.manager cancelPeripheralConnection:peripheral];
				}];
			}
		}];
	}]
	setNameWithFormat:@"RBTCentralManager -connectToPeripheral: %@ options: %@", peripheral, options];
}

#pragma mark - CBCentralManagerDelegate

// Empty implementation because it's a required method.
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {}

@end
