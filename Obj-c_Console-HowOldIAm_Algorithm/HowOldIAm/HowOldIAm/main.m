//
//  main.m
//  HowOldIAm
//
//  Created by Nikolay Dementiev on 21.10.16.
//  Copyright © 2016 mc373. All rights reserved.
//

#import <Foundation/Foundation.h>

NSDate* getBirthdayDate() {

		// Use the user's current calendar and time zone
		NSCalendar *calendar = [NSCalendar currentCalendar];
		[calendar setTimeZone: [NSTimeZone localTimeZone]];

		// Specify the date components manually (year, month, day, hour, minutes, etc.)
		NSDateComponents *timeZoneComps=[[NSDateComponents alloc] init];
		[timeZoneComps setYear:1985];
		[timeZoneComps setMonth:5];
		[timeZoneComps setDay:20];

		// transform the date compoments into a date, based on current calendar settings
		NSDate *date = [calendar dateFromComponents:timeZoneComps];

		return date;
}

void calculateSpentTime() {

		NSDate *currentDate = [NSDate date];
		NSTimeZone *tz = [NSTimeZone localTimeZone];
		NSInteger seconds = [tz secondsFromGMTForDate: currentDate];
		currentDate = [NSDate dateWithTimeInterval: seconds sinceDate: currentDate];

		NSDateFormatter *dateFormatterOutputConsole = [NSDateFormatter new];
		[dateFormatterOutputConsole setDateFormat:@"yyyy/MM/dd, HH:mm:ss"];

		NSLog(@" Current date is '%@'", [dateFormatterOutputConsole stringFromDate:currentDate]);

		NSDate *birthdayDate = getBirthdayDate();
		[dateFormatterOutputConsole setDateFormat:@"yyyy/MM/dd"];
		NSLog(@"Autor's  birthday is '%@'", [dateFormatterOutputConsole stringFromDate:birthdayDate]);

		NSTimeInterval secondsElapsed = fabs([currentDate timeIntervalSinceDate:birthdayDate]);

		NSUInteger y, d, h, s;

		s = ((NSUInteger) secondsElapsed) % 60;
		h = ((NSUInteger) secondsElapsed / (60*60))%24;
		d = ((NSUInteger) secondsElapsed / (60*60*24))%360;
		y =	((NSUInteger) secondsElapsed / (60*60*24*360));
		//		m = ((NSUInteger)(ti / 60)) % 60;

		NSString *str = [NSString stringWithFormat:@"%lu years, %02lu days, %02lu hours and %02lu seconds", y, d, h, s];

		NSLog(@"Author's age is: '%@'", str);
}


int main(int argc, const char * argv[]) {
		@autoreleasepool {
				// insert code here...

				calculateSpentTime();
		}
		return 0;
}
