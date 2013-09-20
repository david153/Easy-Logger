//
//  ELPatientData.h
//  Easy Logger
//
//  Created by DavidSumner on 8/31/13.
//  Copyright (c) 2013 DavidSumner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ELPatientData : NSObject
@property(nonatomic, strong) NSNumber *age;
@property(nonatomic, strong) NSString *gender;
@property(nonatomic, strong) NSString *treatment;
@property(nonatomic, strong) NSString *rotation;
@property(nonatomic, strong) NSString *diagnosis;
@property(nonatomic,strong) NSString *recordDate;

@end

