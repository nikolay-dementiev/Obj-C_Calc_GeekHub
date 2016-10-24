//
//  main.m
//  obj-c_Console_ ExpressionsAnalyzer
//
//  Created by Nikolay Dementiev on 21.10.16.
//  Copyright © 2016 mc373. All rights reserved.
//

#import <Foundation/Foundation.h>


//MARK: var &. interface func.
NSArray* operators;

NSMutableArray *stacks;
NSMutableArray *line;

NSString* getFunctionForAnalyze();
NSDecimalNumber* computeOperator (NSString* operator, NSDecimalNumber* firstOperand, NSDecimalNumber* secondOperand);
NSArray* tokenize (NSString* expression);
void addNumber (NSMutableString* numberBuf, unichar token, NSMutableArray* tokens);
BOOL precedenceOf (NSString* operator, NSString* otherOperator);
int precedenceOf1 (NSString* operator);
NSString* workwithReggex (NSString* str);


//MARK: - stack func.
int size (NSMutableArray* stack) {
		return (int)[stack count];
}

id pop (NSMutableArray* stack) {
		if (size(stack) < 1)
				return nil;

		id item = [stack lastObject];
		[stack removeLastObject];
		return item;
}

void push (id object, NSMutableArray* stack) {
		[stack addObject:object];
}

id peek (NSMutableArray* stack) {
		if (size(stack) < 1)
				return nil;

		return [stack lastObject];
}

BOOL empty(NSMutableArray* stack) { return [stack count] == 0;}

//MARK: - calc func.
//MARK: postfix func.
NSDecimalNumber* computePostfix(NSString *postfix) {
		operators = [NSArray arrayWithObjects: @"+", @"-", @"*", @"/", @"^", nil];
		stacks = [NSMutableArray new];

		NSString* strippedExpression = [postfix stringByTrimmingCharactersInSet:
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

		if (size(stacks) != 1) {
				NSLog(@"Error : Invalid RPN expression. Stack contains %d elements after computing expression, only one should remain.",	size(stacks));
				return nil;
		} else {
				NSDecimalNumber * result = pop(stacks);
				return result;
		}

		return 0;
}

//MARK: infix func.
BOOL hasBalancedBrackets (NSString* expression) {

		unichar c;
		int opened = 0, closed = 0;

		for (int i = 0; i< [expression length] ; i++) {
				c = [expression characterAtIndex: i];
				if (c == '(') opened++;
				else if (c == ')') closed++;
		}

		return opened == closed;
}

void print(NSMutableArray* stack){
  NSLog(@"[ %@ ]", [stack componentsJoinedByString: @" , "]);
}

NSString* parseInfix (NSString* infix) {
		if (! hasBalancedBrackets(infix)) {
				NSLog(@"Unbalanced brackets in expression");
				return nil;
		}

		stacks = [NSMutableArray new];
		NSMutableArray* opStack = stacks;
		NSMutableString* output = [NSMutableString stringWithCapacity:[infix length]];

		//		print(opStack);

		NSArray* tokens = tokenize(infix);
		for (NSString *token in tokens) {
				if (precedenceOf1(token) != 0) {
						// token is an operator, pop all operators of higher or equal precedence off the stack, and append them to the output
						NSString *op = peek(opStack);
						while (op && precedenceOf1(op) != 0 &&
									 precedenceOf(op, token)) {
								[output appendString: [NSString stringWithFormat: @"%@ ", pop(opStack)]];
								op = peek(opStack);
						}
						// then push the operator on the stack
						push(token, opStack);

						//print(opStack);

				} else if ([token compare: @"("] ==0) {
						// push opening brackets on the stack, will be dismissed later
						push(token, opStack);
				} else if ([token compare: @")"] ==0) {
						// closing bracket :
						// pop operators off the stack and append them to the output while the popped element is not the opening bracket
						NSString* op = pop(opStack);
		    while ( op  && ([op compare: @"("] != 0)) {
						[output appendString: [NSString stringWithFormat: @"%@ ", op]];
						op = pop(opStack);
				}
						if ( ! op || ([op compare: @"("]  != 0)) {
								NSLog(@"Error : unbalanced brackets in expression");
								return nil;
						}
				} else {
						//token is an operand, append it to the output
						[output appendString: [NSString stringWithFormat: @"%@ ", token]];
				}

				//print(opStack);
		}

		//pop remaining operators off the stack, and append them to the output
		while (! empty(opStack)) {
				[output appendString: [NSString stringWithFormat: @"%@ ", pop(opStack)]];
		}

		return [output stringByTrimmingCharactersInSet:
						[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

//MARK: - init
NSDecimalNumber* computeExpression (NSString* infix) {
		NSString* regexExpression = workwithReggex(infix);

		NSString* postfixExpression = parseInfix(regexExpression);

		if (postfixExpression) {
				return computePostfix(postfixExpression);
		}

		return nil;
}

void analyzeExpression() {

		NSString* funcForAnalyze = getFunctionForAnalyze();

		NSDecimalNumber* rez = computeExpression(funcForAnalyze);
		if (rez != nil) {
				NSLog(@"result: '%@ = %@'", funcForAnalyze, rez);
		} else {
				NSLog(@"Can't calculate result; smth wrong!");
		}
}

int main(int argc, const char * argv[]) {
		@autoreleasepool {

				analyzeExpression();
		}
		return 0;
}

//MARK: - Regular ext.
NSString* workwithReggex (NSString* str) {
		//NSMutableString *strW = [NSMutableString stringWithString: str];

		NSString* strW = str;
		//find sqr
		NSRegularExpression *regex = [[NSRegularExpression new] initWithPattern:@"\\*[\\s]?sqr(?=([ \\s]?)\\([0-9\\.]*\\))"
																																		options:0
																																			error:nil];
		long n = [regex numberOfMatchesInString:strW
																		options:0
																			range:NSMakeRange(0, [strW length])];

		if (n> 0)
		{
				NSArray *matches = [regex matchesInString:strW
																					options:0
																						range:NSMakeRange(0, [str length])];

				for (NSTextCheckingResult *match in matches)
				{
						NSString *matchText = [strW substringWithRange:[match range]];
						//NSLog(@"Found String:%@\n", matchText);
						strW = [strW stringByReplacingOccurrencesOfString:matchText withString:@"^"];

				}
		}

		return strW;
}

//MARK: - private methods

//MARK: postfix

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
				if ([[NSDecimalNumber zero] compare: secondOperand] == NSOrderedSame) {
						NSLog(@"Divide by zero !");
						return [NSDecimalNumber notANumber];
				}
				else
						result = [firstOperand decimalNumberByDividingBy: secondOperand];
		}

		return result;
}

//MARK: infix

NSArray* tokenize (NSString* expression) {
		NSMutableArray* tokens = [NSMutableArray arrayWithCapacity:[expression length]];

		unichar c;
		NSMutableString* numberBuf = [NSMutableString stringWithCapacity: 5];
		int length = (int)[expression length];
		BOOL nextMinusSignIsNegativeOperator = YES;

		for (int i = 0; i< length; i++) {
				c = [expression characterAtIndex: i];
				switch (c) {
						case '+':
						case '/':
						case '*':
						case '^':
								nextMinusSignIsNegativeOperator = YES;
								addNumber(numberBuf, c, tokens);
								break;
						case '(':
		    case ')':
								nextMinusSignIsNegativeOperator = NO;
								addNumber(numberBuf, c, tokens);
								break;
						case '-':
								if (nextMinusSignIsNegativeOperator){
										nextMinusSignIsNegativeOperator = NO;
										[numberBuf appendString : [NSString stringWithCharacters: &c length:1]];
								} else {
										nextMinusSignIsNegativeOperator = YES;
										addNumber(numberBuf, c, tokens);
								}

								break;
						case '1':
						case '2':
						case '3':
						case '4':
						case '5':
						case '6':
						case '7':
						case '8':
						case '9':
						case '0':
						case '.':
								nextMinusSignIsNegativeOperator = NO;
								[numberBuf appendString : [NSString stringWithCharacters: &c length:1]];
								break;
						case ' ':
								break;
						default:
								NSLog(@"Unsupported character in input expression : %c, discarding.", c);
								break;
				}
		}
		if ([numberBuf length] > 0)
				[tokens addObject:  [NSString stringWithString: numberBuf]];

		return tokens;
}

void addNumber (NSMutableString* numberBuf, unichar token, NSMutableArray* tokens) {
		if ([numberBuf length] > 0){
				[tokens addObject:  [NSString stringWithString: numberBuf]];
				[numberBuf setString:@""];
		}
		[tokens addObject: [NSString stringWithCharacters: &token length:1]];
}


int precedenceOf1 (NSString* operator) {
		if ([operator compare: @"+"] == 0)
				return 1;
		else if ([operator compare: @"-"] == 0)
				return 1;
		else if ([operator compare: @"*"] == 0)
				return 2;
		else if ([operator compare: @"/"] == 0)
				return 2;
		else if ([operator compare: @"^"] == 0) //sqr
				return 3;
		else //invalid operator
				return 0;
}

BOOL precedenceOf (NSString* operator, NSString* otherOperator) {
		return  precedenceOf1(operator)  >=  precedenceOf1(otherOperator);
}

//MARK: other
NSString* getFunctionForAnalyze() {
		return @"((3 + 4)/2 *sqr(2))* 5";//@"3 + 4 * 5";//"2+(3*4)/5"; //@"2+(3 * sqr(2) - sqrt(4))/5";
}

