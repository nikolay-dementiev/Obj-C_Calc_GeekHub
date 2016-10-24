//
//  main.m
//  obj-c_Console_ ExpressionsAnalyzer
//
//  Created by Nikolay Dementiev on 21.10.16.
//  Copyright © 2016 mc373. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString* getFunctionForAnalyze() {
		return @"3 + 4 * 5";//"2+(3*4)/5"; //@"2+(3 * sqr(2) - sqrt(4))/5";
}

NSArray* operators;

NSMutableArray *stacks;
NSMutableArray *line;

NSDecimalNumber* computeOperator (NSString* operator, NSDecimalNumber* firstOperand, NSDecimalNumber* secondOperand);

//void push(NSString *digit) {
//		[stacks addObject:digit];
//}
//
//int pop() {
//		NSInteger lenStack = [stacks count];
//		if (lenStack < 0) {
//				return -1;
//		} else if (lenStack == 0) {
//				return 0;
//		}
//		int res = [[stacks objectAtIndex:lenStack-1] intValue];
//		[stacks removeLastObject];
//		return res;
//}


/* Функция PRIOR возвpащает пpиоpитет аpифм. опеpации */
//int PRIOR(char a) {
//		int valueReturn = 0;
//  switch(a)
//  {
//			case '*':
//			case '/':
//					valueReturn = 3;
//					break;
//			case '-':
//			case '+':
//					valueReturn = 2;
//					break;
//
//			case '(':
//					valueReturn = 1;
//					break;
//	}
//		return valueReturn;
//}

int size (NSMutableArray* stack){
		return (int)[stack count];
}

id pop (NSMutableArray* stack) {
		if (size(stack) < 1)
				return nil;

		id item = [stack lastObject];
		[stack removeLastObject];
		return item;
}

void push(id object, NSMutableArray* stack) {
		[stack addObject:object];
}

//postfix
NSDecimalNumber* compute(NSString *S) {
		operators = [NSArray arrayWithObjects: @"+", @"-", @"*", @"/", @"^", nil];
		stacks = [NSMutableArray new];

		NSString* strippedExpression = [S stringByTrimmingCharactersInSet:
																		[NSCharacterSet whitespaceAndNewlineCharacterSet]];

		NSArray *tokens = [strippedExpression componentsSeparatedByString: @" "];

		for(NSString* token in tokens) {
				if ([operators containsObject:token]){
						// operator found : unstack 2 operands and use them as operator arguments
						NSDecimalNumber* secondOperand = (NSDecimalNumber*) pop(stacks);
						NSDecimalNumber* firstOperand= (NSDecimalNumber*) pop(stacks);


						if (! (firstOperand && secondOperand)){
								NSLog(@"Not enough operands on stack for given operator");
								return nil;
						}

						// compute result, and push it back on the stack
						NSDecimalNumber* result = computeOperator (token, firstOperand, secondOperand);

						if (result == [NSDecimalNumber notANumber])
								return result; // an error occured during operator calculation, bail early

						push (result, stacks);

				} else {
						//number found, push it on the stack
						NSDecimalNumber * operand = [NSDecimalNumber decimalNumberWithString : token];
						push (operand, stacks);//[stack push: operand];
				}
		}

		if (size(stacks) != 1){
				NSLog(@"Error : Invalid RPN expression. Stack contains %d elements after computing expression, only one should remain.",	size(stacks));
				return nil;
		} else {
				NSDecimalNumber * result = pop(stacks);
				return result;
		}

//		for (int i=0; i<[S length];i++)
//		{
//				NSString *chr = [S substringWithRange:NSMakeRange(i,1)];
////				if ([chr isEqualToString:@"+"])
////				{
////						int d1 = pop();
////						int d2 = pop();
////						if (d1!= -1 && d2!= -1){
////								push([NSString stringWithFormat:@"%d", d1+d2]);
////						}else{
////								return -1;
////						}
////				}else if ([chr isEqualToString:@"*"]){
////						int d1 = pop();
////						int d2 = pop();
////						if (d1!= -1 && d2!= -1){
////								push([NSString stringWithFormat:@"%d", d1*d2]);
////						}else{
////								return -1;
////						}
////				}else{
////						push(chr);
////				}
//
//
//		}
//
//		int res = pop();
//		[stacks removeAllObjects];
//		//[stacks release];
		return 0;
}

void analyzeExpression() {

		NSString* funcForAnalyze = getFunctionForAnalyze();
		//		NSExpression *expression = [NSExpression expressionWithFormat:funcForAnalyze];
		//
		//		NSNumber *result = [expression expressionValueWithObject:nil context:nil];
		//		NSLog(@"%@",result);

		compute(funcForAnalyze);

		//		int c,err;
		//  double x,y;
		//  char *p,*q;
		//  NSMutableData *line = [NSMutableData new];
		//  NSMutableArray *stk = [NSMutableArray new];
		//#define POP(z) z = [[stk lastObject] doubleValue]; \
		//[stk removeLastObject]
		//  while ((c=getchar())!=EOF) {
		//			if (c=='\n') c = 0;
		//			[line appendBytes:(void*)&c length:1];
		//			if (c) continue;
		//			[stk removeAllObjects];
		//			p = [line mutableBytes];
		//			err = 0;
		//			while (NULL!=(q=strtok(p," \t"))) {
		//					x = strtod(q,&p);
		//					err = *p;
		//					p = NULL;
		//					if (err) {
		//							err = q[1] || NULL==strchr("+-*/",*q) || 2>[stk count];
		//							if (err) break;
		//							POP(y); POP(x);
		//							switch (*q) {
		//									case '+': x += y; break;
		//									case '-': x -= y; break;
		//									case '*': x *= y; break;
		//									case '/': x /= y;
		//							}
		//					}
		//					[stk addObject:[NSNumber numberWithDouble:x]];
		//			}
		//			if (err || 1<[stk count]) puts("error");
		//			else if ([stk count]) {POP(x); printf("%f\n",x);}
		//			[line setLength:0];
		//	}

}

int main(int argc, const char * argv[]) {
		@autoreleasepool {
				// insert code here...
				//NSLog(@"Hello, World!");

				analyzeExpression();
		}
		return 0;
}

/* private methods */

NSDecimalNumber* computeOperator (NSString* operator, NSDecimalNumber* firstOperand, NSDecimalNumber* secondOperand) {

		NSDecimalNumber * result;

		if ([operator compare: @"+"] == 0) {
				result = [firstOperand decimalNumberByAdding: secondOperand];
		}else if ([operator compare: @"*"] == 0) {
				result = [firstOperand decimalNumberByMultiplyingBy: secondOperand];
		} else if ([operator compare: @"-"] == 0) {
				result = [firstOperand decimalNumberBySubtracting: secondOperand];
		} else if ([operator compare: @"^"] == 0) {
				result = [firstOperand decimalNumberByRaisingToPower: [secondOperand intValue]];
		} else if ([operator compare: @"/"] == 0) {
				if ([[NSDecimalNumber zero] compare: secondOperand] == NSOrderedSame){
						NSLog(@"Divide by zero !");
						return [NSDecimalNumber notANumber];
				}
				else
						result = [firstOperand decimalNumberByDividingBy: secondOperand];	}
		
		return result;
}
