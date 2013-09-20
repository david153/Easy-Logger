//
//  ELPatientData.m
//  Easy Logger
//
//  Created by DavidSumner on 8/31/13.
//  Copyright (c) 2013 DavidSumner. All rights reserved.
//

#import "ELPatientData.h"


@implementation ELPatientData

-(id) init {
    
    self = [super init];
    
    if (self != nil)
    {
        _age = @(0);
        _gender = @"Male";
        _treatment = @"Therapy";
        _rotation = @"PEC";
        _diagnosis = @"";
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.age forKey:@"Age"];
    [coder encodeObject:self.gender forKey:@"gender"];
    [coder encodeObject:self.treatment forKey:@"Treatment"];
    [coder encodeObject:self.rotation  forKey:@"Rotation"];
    [coder encodeObject:self.diagnosis forKey:@"Diagnosis"];
    NSLog(@"Encoding went well!");
}

- (id)initWithCoder:(NSCoder *)coder {
    
    self = [super init];
    if(self){
        self.age = [coder decodeObjectForKey:@"Age"];
        self.gender = [coder decodeObjectForKey:@"Gender"];
        self.treatment = [coder decodeObjectForKey:@"Treatment"];
        self.rotation = [coder decodeObjectForKey:@"Rotation"];
        self.diagnosis = [coder decodeObjectForKey:@"Diagnosis"];
    }
    NSLog(@"Decoding went well!");

    return self;
}

@end
