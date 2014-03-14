//
//  RBTPeripheralManager.h
//  ReactiveBLE
//
//  Created by Eli Perkins on 2/28/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

/**
 * ReactiveCocoa interface to `CBPeripheralManager`
 */
@interface RBTPeripheralManager : NSObject

/**
 *  Creates a new instance of `RBTPeripheralManager`.
 *
 *  @param options Optional dictionary of options as described in "Central Manager Initialization Options"
 *  in the `CBPeripheralManager` documentation
 *
 *  @return A new instance of `RBTPeripheralManager`
 */
- (instancetype)initWithOptions:(NSDictionary *)options;

/**
 *  Observes the state of the receiver.
 *
 *  @return A signal that sends the current state of the receiver and the new state any time it changes.
 */
- (RACSignal *)stateSignal;

/**
 *  Advertises a peripheral with data.
 *
 *  @param advertisementData Optional dictionary containing the data to be advertised
 *
 *  @return A signal that sends complete once advertising has been terminated
 */
- (RACSignal *)startAdvertising:(NSDictionary *)advertisementData;

@end
