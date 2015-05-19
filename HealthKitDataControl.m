//
//  HealthKitDataControl.m
//  eneSmile
//
//  Created by Ha Cong Thuan on 10/17/14.
//  Copyright © 2013-2015 GMO RunSystem. All rights reserved.
//

#import "HealthKitDataControl.h"

@implementation HealthKitDataControl{
    
}
HKHealthStore *healthStore;
int coutStep;
NSDate *stepBegin;
NSDate *stepEnd;
ENEShareData *shareWholeData;
int  hearBeat;
+(float)isIOSversion{
    float ioscheck=[[[UIDevice currentDevice] systemVersion] floatValue];
    return ioscheck;
    
}

+ (void) setupHealthKit
{
    /* You should always run this function first */
    
    if ([HKHealthStore isHealthDataAvailable])
    {
        
        healthStore = [[HKHealthStore alloc] init];
        
        NSSet *writeDataTypes = [self dataTypesToWrite];
        NSSet *readDataTypes = [self dataTypesToRead];
        
        /* Opening healtstore permission window and askind permissions for write and read data types */
        [healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError *error)
         {
             if (!success)
             {
                 //You didn't allow HealthKit to access these read/write data types. The error was: %@"error". If you're using a simulator, try it on a device.
                 
             }
             else //success
             {
                 //Healtkit ready
                 
             }
             
         }];
    }
    else
    {
        //Healthkit is not available for this device
    }
}
// Returns the types of data that Fit wishes to write to HealthKit.
+ (NSSet *)dataTypesToWrite
{
    HKQuantityType *basaEnergyBurnType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBasalEnergyBurned ];
    HKQuantityType *activeEnergyBurnType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKQuantityType *distance = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKQuantityType *cycle=[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling];
    HKQuantityType *steoCout=[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *dietaryCalorieEnergyType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
//    HKCharacteristicType *birthdayType = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
    HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    //HKCharacteristicType *sexType = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
    HKQuantityType *heartRate = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];

    HKQuantityType *leanBodyMass = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierLeanBodyMass];
    HKQuantityType *bodyMassIndex = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex];
    HKQuantityType *fatPercentage = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyFatPercentage];
    HKQuantityType *flightsClimbed = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed];
    return [NSSet setWithObjects:  distance, dietaryCalorieEnergyType,cycle,steoCout,activeEnergyBurnType,weightType,heightType,leanBodyMass,bodyMassIndex,fatPercentage,flightsClimbed,basaEnergyBurnType,heartRate, nil];
}


// Returns the types of data that Fit wishes to read from HealthKit.
+ (NSSet *)dataTypesToRead {
    shareWholeData = [[ENEShareData alloc] initWithApplicationGroupIdentifier:@"group.com.magiccloud.applewatch.eNePit"
                                                                 optionalDirectory:@"enePit"];
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
//    HKCharacteristicType *birthdayType = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
    HKQuantityType *steoCout=[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *distance = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    HKQuantityType *dietaryCalorieEnergyType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    HKQuantityType *activeEnergyBurnType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
//    HKQuantityType *hearthRateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
//    HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
//    HKCharacteristicType *sexType = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
     HKQuantityType *heartRate = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    return [NSSet setWithObjects: weightType,dietaryCalorieEnergyType,activeEnergyBurnType,steoCout,distance,heartRate, nil];
}

// Get the single most recent quantity sample from health store.
+ (void)fetchMostRecentDataOfQuantityType:(HKQuantityType *)quantityType withCompletion:(void (^)(HKQuantity *mostRecentQuantity, NSError *error))completion {
    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    //=======
    NSDate *startDate, *endDate; // Whatever you need in your case
    startDate=stepBegin;
    endDate=stepEnd;
    // Your interval: sum by hour
    NSDateComponents *intervalComponents = [[NSDateComponents alloc] init];
    intervalComponents.hour = 1;
    
    // Example predicate
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];

    // Since we are interested in retrieving the user's latest sample, we sort the samples in descending order, and set the limit to 1. We are not filtering the data, and so the predicate is set to nil.
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:quantityType predicate:predicate limit:2 sortDescriptors:@[timeSortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if (!results) {
            if (completion) {
                completion(nil, error);
            }
            return;
        }
        if (completion) {
            // If quantity isn't in the database, return nil in the completion block.
            HKQuantitySample *quantitySample = results.firstObject;
            HKQuantity *quantity = quantitySample.quantity;
            
            completion(quantity, error);
        }
    }];
    
    [healthStore executeQuery:query];
}
+ (void)fetchDataOfQuantityType:(HKQuantityType *)quantityType startDate:(NSDate *)startDate endDate:(NSDate *)endDate withCompletion:(void (^)(HKQuantity *mostRecentQuantity, NSError *error))completion {
    
    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    // Your interval: sum by hour
    NSDateComponents *intervalComponents = [[NSDateComponents alloc] init];
    intervalComponents.hour = 1;
    // Example predicate
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
    // Since we are interested in retrieving the user's latest sample, we sort the samples in descending order, and set the limit to 1. We are not filtering the data, and so the predicate is set to nil.
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:quantityType predicate:predicate limit:2 sortDescriptors:@[timeSortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if (!results) {
            if (completion) {
                completion(nil, error);
            }
            return;
        }
        if (completion) {
            // If quantity isn't in the database, return nil in the completion block.
            HKQuantitySample *quantitySample = results.firstObject;
            HKQuantity *quantity = quantitySample.quantity;
            completion(quantity, error);
        }
    }];
    
    [healthStore executeQuery:query];
}

- (void)storeHeartBeatsAtMinute:(double)beats startDate:(NSDate *)startDate endDate:(NSDate *)endDate completion:(void (^)(NSError *error))completion
{
    HKQuantityType *rateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    HKQuantity *rateQuantity = [HKQuantity quantityWithUnit:[HKUnit heartBeatsPerMinuteUnit]
                                                doubleValue:(double)beats];
    HKQuantitySample *rateSample = [HKQuantitySample quantitySampleWithType:rateType
                                                                   quantity:rateQuantity
                                                                  startDate:startDate
                                                                    endDate:endDate];
    
    [healthStore saveObject:rateSample withCompletion:^(BOOL success, NSError *error) {
        if(completion) {
            completion(error);
        }
    }];
}
+ (void)readHeartBeatFromHKWithCompletion:(void (^)(int heartRate ,NSError *error)) completion{
    NSCalendar *calenDar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    
    HKUnit *bpmUnit = [[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]];
    NSDate *startDate = [calenDar startOfDayForDate:now];
    NSDate *endDate = [calenDar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    
    HKQuantityType *heartCountType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
    if ([HKHealthStore isHealthDataAvailable])
    {
        [self fetchDataOfQuantityType:heartCountType startDate:startDate endDate:endDate withCompletion:^(HKQuantity *mostRecentQuantity, NSError *error) {
            if (!mostRecentQuantity){  //Either an error
                
            }else{//HeartBeat
                if (completion) {
                    double temCout=[mostRecentQuantity doubleValueForUnit:bpmUnit];
                    NSLog(@"Heart Beat %d:",(int)temCout);
                    hearBeat = temCout;
                    completion(temCout ,error);
                    [shareWholeData passMessageObject:@{@"datavalue" : [NSString stringWithFormat:@"%.d",(int)temCout]} identifier:@"bpmShareData"];
                }
            }
        }];
    }
}

+ (void)readUsersAgeFrom:(NSDate *)dateOfBirth{
 
}
+(int) coutHeartBeat{
    int cout = hearBeat;
    return cout;
}

+ (void)readUsersWeightFromHK
{
    if ([HKHealthStore isHealthDataAvailable])
    {
        
        NSMassFormatter *massFormatter = [[NSMassFormatter alloc] init];
        massFormatter.unitStyle = NSFormattingUnitStyleLong;
        
        // Query to get the user's latest weight, if it exists.
        HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
        
        [self fetchMostRecentDataOfQuantityType:weightType withCompletion:^(HKQuantity *mostRecentQuantity, NSError *error) {
            if (!mostRecentQuantity)
            {
                //Either an error occured fetching the user's weight information or none has been stored yet. "]];
            }
            else
            {
                
                // Determine the weight in the required unit.
                HKUnit *weightUnit = [HKUnit gramUnit];
                double weight = [mostRecentQuantity doubleValueForUnit:weightUnit];
                if(weight > 1000.0)
                {
                    weight = weight/1000.0; //grams to kilograms
                }
                
                //Weight:%f kg",weight]];
                
            }
        }];
        
    }
}

+ (void)readUsersStepFromHK:(NSDate*)startDate end:(NSDate*)endDate
{
    stepBegin=startDate;
    stepEnd=endDate;
    if ([HKHealthStore isHealthDataAvailable])
    {
        HKUnit *unit = [HKUnit countUnit];
        
        HKQuantityType *stepCountType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
        
        
        [self fetchMostRecentDataOfQuantityType:stepCountType withCompletion:^(HKQuantity *mostRecentQuantity, NSError *error) {
            if (!mostRecentQuantity)
            {
                //Either an error
                
            }
            else
            {
                double temCout=[mostRecentQuantity doubleValueForUnit:unit];
                coutStep=temCout;
                
            }
        }];
        
    }
}
+(int)countUnit{
    return coutStep;
}
+ (void)readUsersStepDistamceFromHK
{
    if ([HKHealthStore isHealthDataAvailable])
    {
        
        // Query to get the user's latest weight, if it exists.
        HKQuantityType *StepDistamce = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
        
        [self fetchMostRecentDataOfQuantityType:StepDistamce withCompletion:^(HKQuantity *mostRecentQuantity, NSError *error) {
            if (!mostRecentQuantity)
            {
                //Either an error occured fetching the user's weight information or none has been stored yet. "]];
            }
            else
            {
                
                
            }
        }];
        
    }
}



+ (void) writeHeartRateToHK:(double)rate :  (NSDate*) startTime : (NSDate*)endTime
{
    
    
    if ([HKHealthStore isHealthDataAvailable])
    {
        
        
        HKQuantityType *rateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
        
        HKQuantity *rateQuantity = [HKQuantity quantityWithUnit:[HKUnit heartBeatsPerMinuteUnit]
                                                    doubleValue:rate];
        HKQuantitySample *rateSample = [HKQuantitySample quantitySampleWithType:rateType
                                                                       quantity:rateQuantity
                                                                      startDate:startTime
                                                                        endDate:endTime];
        
        [healthStore saveObject:rateSample withCompletion:^(BOOL success, NSError *error)
         {
             if (!success)
             {
                 //An error occured saving the heart rate sample %f. The error was: %@.", rate,error]];
                 
             }
             else //success
             {
                 //Heart rate %f saved",rate]];
                 
                 
                 
             }
         }];
        
    }
    
}





+ (void) writeBurnedCaloriesToHK:(double)kiloCalories :  (NSDate*) startTime : (NSDate*)endTime
{
    
    if ([HKHealthStore isHealthDataAvailable])
    {
        
        
        HKQuantityType *qtype = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
        
        HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit kilocalorieUnit]
                                                doubleValue:kiloCalories];
        
        HKQuantitySample *rateSample = [HKQuantitySample quantitySampleWithType:qtype
                                                                       quantity:quantity
                                                                      startDate:startTime
                                                                        endDate:endTime];
        
        [healthStore saveObject:rateSample withCompletion:^(BOOL success, NSError *error)
         {
             if (!success)
             {
                 //An error occured saving the calories %f. The error was: %@.", kiloCalories,error]];
                 
             }
             else
             {
                 //Active calories %f kcal saved",kiloCalories]];
             }
         }];
        
    }
}

+ (void) writeStepToHK:(double)steps : (NSDate*) startTime : (NSDate*)endTime
{
    
    if ([HKHealthStore isHealthDataAvailable])
    {
        
        
        HKUnit *unit = [HKUnit countUnit];
        
        
        HKQuantity *quantity = [HKQuantity quantityWithUnit:unit doubleValue:steps];
        
        
        HKQuantityType *qtype = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
        
        
        HKQuantitySample *sample = [HKQuantitySample quantitySampleWithType:qtype
                                                                   quantity:quantity
                                                                  startDate:startTime
                                                                    endDate:endTime];
        
        [healthStore saveObject:sample withCompletion:^(BOOL success, NSError *error)
         {
             if (!success)
             {
                 //An error occured saving the distance sample %f. The error was: %@.", distanceMeters,error
                 
             }
             else //success
             {
                 //Distance %f m saved",distanceMeters
             }
         }];
        
    }
}



+ (void) writeDistanceIntoHealthStore:(double)distanceMeters : (NSDate*) startTime : (NSDate*)endTime
{
    
    if ([HKHealthStore isHealthDataAvailable])
    {
        
        
        HKUnit *unit = [HKUnit meterUnit];
        //HKUnit *unit = [HKUnit mileUnit];
        
        
        HKQuantity *quantity = [HKQuantity quantityWithUnit:unit doubleValue:distanceMeters];
        
        
        HKQuantityType *qtype = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
        
        
        HKQuantitySample *sample = [HKQuantitySample quantitySampleWithType:qtype
                                                                   quantity:quantity
                                                                  startDate:startTime
                                                                    endDate:endTime];
        
        [healthStore saveObject:sample withCompletion:^(BOOL success, NSError *error)
         {
             if (!success)
             {
                 //An error occured saving the distance sample %f. The error was: %@.", distanceMeters,error
                 
             }
             else //success
             {
                 //Distance %f m saved",distanceMeters
             }
         }];
        
    }
}
//HKQuantityTypeIdentifierDistanceCycling
+ (void) writeDistanceCyclingToHK:(double)distanceMeters : (NSDate*) startTime : (NSDate*)endTime
{
    
    if ([HKHealthStore isHealthDataAvailable])
    {
        
        
        HKUnit *unit = [HKUnit meterUnit];
        //HKUnit *unit = [HKUnit mileUnit];
        
        
        HKQuantity *quantity = [HKQuantity quantityWithUnit:unit doubleValue:distanceMeters];
        
        
        HKQuantityType *qtype = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
        
        
        HKQuantitySample *sample = [HKQuantitySample quantitySampleWithType:qtype
                                                                   quantity:quantity
                                                                  startDate:startTime
                                                                    endDate:endTime];
        
        [healthStore saveObject:sample withCompletion:^(BOOL success, NSError *error)
         {
             if (!success)
             {
                 //An error occured saving the distance sample %f. The error was: %@.", distanceMeters,error
                 
             }
             else //success
             {
                 //Distance %f m saved",distanceMeters
             }
         }];
        
    }
}
+ (void)writeWeightIntoHealthStore:(double)weightInKilograms {
    
    
    if ([HKHealthStore isHealthDataAvailable])
    {
        
        
        // HKUnit *weightUnit = [HKUnit poundUnit];
        HKUnit *weightUnit = [HKUnit gramUnit];
        
        double weight = weightInKilograms*1000.0; //kilograms to grams conversio
        
        HKQuantity *weightQuantity = [HKQuantity quantityWithUnit:weightUnit doubleValue:weight];
        
        HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
        
        NSDate *dateNow = [NSDate date];
        
        HKQuantitySample *weightSample = [HKQuantitySample quantitySampleWithType:weightType quantity:weightQuantity startDate:dateNow endDate:dateNow];
        
        [healthStore saveObject:weightSample withCompletion:^(BOOL success, NSError *error)
         {
             if (!success)
             {
                 //An error occured saving the weight sample %@. The error was: %@.", weightSample,error
                 
             }
             else
             {
                 //Weight %f kg saved",weightInKilograms
             }
             
         }];
        
    }
}
+ (void)writeheightIntoHealthStore:(double)heightInmet {
    
    
    if ([HKHealthStore isHealthDataAvailable])
    {
        
        HKUnit *heightUnit = [HKUnit meterUnit];
        
        double height = heightInmet*10.0; //Centimet to met conversio
        
        HKQuantity *heightQuantity = [HKQuantity quantityWithUnit:heightUnit doubleValue:height];
        
        HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
        
        NSDate *dateNow = [NSDate date];
        
        HKQuantitySample *heightSample = [HKQuantitySample quantitySampleWithType:heightType quantity:heightQuantity startDate:dateNow endDate:dateNow];
        
        [healthStore saveObject:heightSample withCompletion:^(BOOL success, NSError *error)
         {
             if (!success)
             {
                 //An error occured saving the weight sample %@. The error was: %@.", weightSample,error
                 
             }
             else
             {
                 //height %f met saved"
             }
             
         }];
        
    }
}

+ (void)writeBMItoHealthStore:(double)BMI {
    
    
    if ([HKHealthStore isHealthDataAvailable])
    {
        HKQuantity *BMIQuantity = [HKQuantity quantityWithUnit:nil doubleValue:BMI];
        
        HKQuantityType *BMIType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex];
        
        NSDate *dateNow = [NSDate date];
        
        HKQuantitySample *BMISample = [HKQuantitySample quantitySampleWithType:BMIType quantity:BMIQuantity startDate:dateNow endDate:dateNow];
        
        [healthStore saveObject:BMISample withCompletion:^(BOOL success, NSError *error)
         {
             if (!success)
             {
                 //An error occured saving the weight sample %@. The error was: %@.", weightSample,error
                 
             }
             else
             {
                 //height %f met saved"
             }
             
         }];
        
    }
}
+ (void)writeLBMtoHealthStore:(double)LBM {
    
    
    if ([HKHealthStore isHealthDataAvailable])
    {
        HKUnit *LBMUnit = [HKUnit moleUnitWithMolarMass:LBM];
        HKQuantity *LBMQuantity = [HKQuantity quantityWithUnit:LBMUnit doubleValue:LBM];
        
        HKQuantityType *LBMType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierLeanBodyMass];
        
        NSDate *dateNow = [NSDate date];
        
        HKQuantitySample *LBMSample = [HKQuantitySample quantitySampleWithType:LBMType quantity:LBMQuantity startDate:dateNow endDate:dateNow];
        
        [healthStore saveObject:LBMSample withCompletion:^(BOOL success, NSError *error)
         {
             if (!success)
             {
                 //An error occured saving the weight sample %@. The error was: %@.", weightSample,error
                 
             }
             else
             {
                 //height %f met saved"
             }
             
         }];
        
    }
}
+ (void)writeBMRtoHealthStore:(double)BMR {
    
    
    if ([HKHealthStore isHealthDataAvailable])
    {
        HKUnit *BMRUnit = [HKUnit kilocalorieUnit];
        HKQuantity *BMRQuantity = [HKQuantity quantityWithUnit:BMRUnit doubleValue:BMR];
        
        HKQuantityType *BMRType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBasalEnergyBurned];
        
        NSDate *dateNow = [NSDate date];
        
        HKQuantitySample *BMRSample = [HKQuantitySample quantitySampleWithType:BMRType quantity:BMRQuantity startDate:dateNow endDate:dateNow];
        
        [healthStore saveObject:BMRSample withCompletion:^(BOOL success, NSError *error)
         {
             if (!success)
             {
                 //An error occured saving the weight sample %@. The error was: %@.", weightSample,error
                 
             }
             else
             {
                 //height %f met saved"
             }
             
         }];
        
    }
}
@end
