//
//  Patient.h
//  Easy Logger
//
//  Created by DavidSumner on 8/30/13.
//  Copyright (c) 2013 DavidSumner. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Patient : NSObject

@property(nonatomic) NSNumber *age;
@property(nonatomic,strong) NSString *gender;
@property(nonatomic,strong) NSString *treatment;
@property(nonatomic,strong) NSString *therapy;
@property(nonatomic,strong) NSString *recordDate;


@end
