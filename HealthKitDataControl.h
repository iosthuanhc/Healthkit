//
//  HealthKitDataControl.h
//  
//
//  Created by Ha Cong Thuan on 10/17/14.
//  Copyright © 2013-2015 GMO RunSystem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ENEShareData.h"
@import HealthKit;

@interface HealthKitDataControl : NSObject


+(float)isIOSversion;
+ (void) setupHealthKit;
+ (void)readUsersAgeFrom:(NSDate *)dateOfBirth;
+ (void)readUsersWeightFromHK;
//write
+ (void) writeStepToHK:(double)steps : (NSDate*) startTime : (NSDate*)endTime;
+ (void) writeHeartRateToHK:(double)rate :  (NSDate*) startTime : (NSDate*)endTime;
+ (void) writeBurnedCaloriesToHK:(double)kiloCalories :  (NSDate*) startTime : (NSDate*)endTime;
+ (void) writeDistanceIntoHealthStore:(double)distanceMeters : (NSDate*) startTime : (NSDate*)endTime;
+ (void) writeDistanceCyclingToHK:(double)distanceMeters : (NSDate*) startTime : (NSDate*)endTime;
+ (void)writeWeightIntoHealthStore:(double)weightInKilograms;
+ (void)writeheightIntoHealthStore:(double)heightInmet;
+ (void)writeBMItoHealthStore:(double)BMI;
+ (void)writeLBMtoHealthStore:(double)LBM;
+ (void)writeBMRtoHealthStore:(double)BMR;
// read
+ (void)readUsersStepFromHK:(NSDate*)startDate end:(NSDate*)endDate;
+ (void)readUsersStepDistamceFromHK;
+ (void)readHeartBeatFromHK;
+ (void)readHeartBeatFromHKWithCompletion:(void (^)(int heartRate ,NSError *error)) completion;
+(int) coutHeartBeat;
//-------
+(int)countUnit;
@end
//---------------------------
@interface HKUnit (HKManager)
+ (HKUnit *)heartBeatsPerMinuteUnit;
@end

@implementation HKUnit (HKManager)

+ (HKUnit *)heartBeatsPerMinuteUnit {
    return [[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]];
}

@end