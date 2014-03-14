//
// Created by Eli Perkins on 3/14/14.
// Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#if TARGET_OS_IPHONE
#import <CoreBluetooth/CoreBluetooth.h>
#else
#import <IOBluetooth/IOBluetooth.h>
#endif

@interface RBTService : NSObject

@property(strong, readwrite, nonatomic) CBUUID *UUID;
@property(readwrite, nonatomic) BOOL isPrimary;
@property(retain, readwrite) NSArray *includedServices;
@property(retain, readwrite) NSArray *characteristics;

/**
* Initializes a new RBTService object
*
* @param UUID       The unique identifier for the service
* @param isPrimary  Indicates whether the service is the main service or secondary
*/
- (instancetype)initWithType:(CBUUID *)UUID primary:(BOOL)isPrimary;

@end