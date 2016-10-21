//
//  main.m
//  Obj-c_ConsoleCalc_GeekHub
//
//  Created by Nikolay Dementiev on 20.10.16.
//  Copyright © 2016 mc373. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
		none,
		plus,
		minus,
		multiply,
		devide
} Oper;

float num;
char operation;

float calculateOperation (NSArray *args) {

		Oper curOper = none;
		float result = 0;

		for (NSString *arg in args) {
				if ([arg isEqualToString:@"+"]) {
						curOper = plus;
				} else if ([arg isEqualToString:@"-"]) {
						curOper = minus;
				} else if ([arg isEqualToString:@"*"]) {
						curOper = multiply;
				} else if ([arg isEqualToString:@"/"]) {
						curOper = devide;
				} else {
						float value = [arg floatValue];
						switch(curOper) {
								case plus: result += value; break;
								case minus: result -= value; break;
								case multiply: result *= value; break;
								case devide: result /= value; break;
								case none: result = value; break;
								default: abort();
						}
						curOper = none;
				}
		}

		return result;
}


int main(int argc, const char * argv[]) {
		@autoreleasepool {
				NSMutableArray *args = [NSMutableArray new];

				NSLog(@"start calculation...");
				NSLog(@"1. Please, Enter The First Number: ");
				scanf("%f",&num);
				[args addObject:[NSString stringWithFormat:@"%@", @(num)]];

				getchar();
				NSLog(@"2. Please, Choose a mathematical operation '+', '-', '*', '/' : ");
				scanf("%c",&operation);
				[args addObject:[NSString stringWithFormat:@"%c", operation]];

				NSLog(@"3. Please, Enter The Second Number: ");
				scanf("%f",&num);
				[args addObject:[NSString stringWithFormat:@"%@", @(num)]];

				NSLog(@"result of '%@ %@ %@'  = '%.2f'", args[0],args[1], args[2], calculateOperation(args));
		}
		return 0;
}

