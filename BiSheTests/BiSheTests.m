//
//  BiSheTests.m
//  BiSheTests
//
//  Created by Jz on 16/1/29.
//  Copyright © 2016年 Jz. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JZWildDog.h"
#import "AFNetworking.h"
#import "Wilddog.h"


@interface BiSheTests : XCTestCase

@end

@implementation BiSheTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    XCTestExpectation *expectation =  [self expectationWithDescription:@"High Expectations"];
    NSString *urlCar = @"http://api.che300.com/service/getCarList?token=60998c88e30c16609dbcbe48f3216df3&zone=%d&page=100";
    //        NSMutableDictionary *carDic = [NSMutableDictionary dictionary];
    //    NSMutableArray *carArray = [NSMutableArray array];
    Wilddog *wildog = [[Wilddog alloc]initWithUrl:@"https://usedcar.wilddogio.com/"];


    for (int i=1; i<299; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:urlCar,i]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (data) {
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                    NSArray *carList = dic[@"car_list"];
                    [carList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        [[[wildog childByAppendingPath:[NSString stringWithFormat:@"cars"]] childByAutoId] updateChildValues:obj withCompletionBlock:^(NSError *error, Wilddog *ref) {
                            if (error) {

                            }
                        }];
                        
                        
                    }];
                }
                
                else{

                }
            });
        

        });

    }
    [self waitForExpectationsWithTimeout:6000.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
       
        // Put the code you want to measure the time of here.
    }];
}

@end
