//
//  RBTPeripheralManager.m
//  ReactiveBLE
//
//  Created by Eli Perkins on 2/28/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "RBTPeripheralManager.h"

#if TARGET_OS_IPHONE
#import <CoreBluetooth/CoreBluetooth.h>
#else
#import <IOBluetooth/IOBluetooth.h>
#endif

@interface RBTPeripheralManager () <CBPeripheralManagerDelegate>
@property (nonatomic, readonly) dispatch_queue_t CBQueue;
@property (nonatomic, strong, readonly) RACScheduler *CBScheduler;
@property (nonatomic, strong, readonly) CBPeripheralManager *manager;
@end

@implementation RBTPeripheralManager

#pragma mark - Initialization

- (instancetype)initWithOptions:(NSDictionary *)options
{
    if ((self = [super init])) {
		_CBQueue = dispatch_queue_create("com.indragie.RBTCentralManager.CoreBluetoothQueue.peripheral", DISPATCH_QUEUE_SERIAL);
		_CBScheduler = [[RACTargetQueueScheduler alloc] initWithName:@"com.indragie.RBTCentralManager.CoreBluetoothScheduler.peripheral" targetQueue:_CBQueue];
		_manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:_CBQueue options:options];
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
        concat:[[self rac_signalForSelector:@selector(peripheralManagerDidUpdateState:) fromProtocol:@protocol(CBPeripheralManagerDelegate)]
                reduceEach:^(CBPeripheralManager *manager) {
                    return manager;
            }]]
        map:^(CBPeripheralManager *manager) {
            return @(manager.state);
        }]
        takeUntil:self.rac_willDeallocSignal]
        setNameWithFormat:@"RBTPeripheralManager -stateSignal"];
}

#pragma mark - Advertising

- (RACSignal *)startAdvertising:(NSDictionary *)advertisementData
{
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        RACSerialDisposable *disposable = [[RACSerialDisposable alloc] init];
		[self.CBScheduler schedule:^{
            @strongify(self);
            [self.manager startAdvertising:advertisementData];
            disposable.disposable = [[[self
                rac_signalForSelector:@selector(peripheralManagerDidStartAdvertising:error:) fromProtocol:@protocol(CBPeripheralManagerDelegate)]
                tryMap:^id(RACTuple *args, NSError **errorPtr) {
                    NSError *error = args.second;
                    if (error) {
                        *errorPtr = error;
                    }
                    return args;
                }]
                subscribe:subscriber];
        }];
        return [RACDisposable disposableWithBlock:^{
            [disposable dispose];
            [self.manager stopAdvertising];
        }];
    }];
}

#pragma mark - Services

- (RACSignal *)addService:(RBTService *)service {

}

@end
