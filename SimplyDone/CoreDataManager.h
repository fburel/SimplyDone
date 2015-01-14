//
//  CoreDataManager.h
//  SimplyDone
//
//  Created by Florian BUREL on 14/01/2015.
//  Copyright (c) 2015 Florian Burel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObjectContext;

@interface CoreDataManager : NSObject

+ (instancetype) sharedInstance;

@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;

@end
