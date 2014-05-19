//
//  TOTIPEntry.h
//  TOTIP
//
//  Created by Jeremy Foo on 19/5/14.
//  Copyright (c) 2014 LazyLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TOPTIPJSONMappedObject.h"

@interface TOTIPEntry : TOPTIPJSONMappedObject

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, copy, readonly) NSURL *entryURL;

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *summary;

@property (nonatomic, copy, readonly) NSString *category;
@property (nonatomic, copy, readonly) NSString *categoryID;

@property (nonatomic, copy, readonly) NSString *currency;
@property (nonatomic, copy, readonly) NSString *costString;
@property (nonatomic, assign, readonly) double price;

@property (nonatomic, copy, readonly) NSString *rentalCurrency;
@property (nonatomic, copy, readonly) NSString *rentalCostString;
@property (nonatomic, assign, readonly) double rentalPrice;

@property (nonatomic, copy, readonly) NSString *artist;
@property (nonatomic, copy, readonly) NSURL *artistURL;
@property (nonatomic, copy, readonly) NSString *publisher;
@property (nonatomic, copy, readonly) NSString *vendor;
@property (nonatomic, copy, readonly) NSString *copyright;

@property (nonatomic, copy, readonly) NSDate *releaseDate;

@property (nonatomic, strong, readonly) NSDictionary *images;

@end
