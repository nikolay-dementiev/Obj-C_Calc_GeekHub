//
//  main.m
//  obj-c_Console_ ExpressionsAnalyzer
//
//  Created by Nikolay Dementiev on 21.10.16.
//  Copyright © 2016 mc373. All rights reserved.
//

#import <Foundation/Foundation.h>


//MARK: var &. interface func.
NSArray *operators;

NSMutableArray *stacks;
NSMutableArray *line;

NSString* getFunctionForAnalyze();
NSDecimalNumber* computeOperator (NSString *operator, NSDecimalNumber *firstOperand, NSDecimalNumber *secondOperand);
NSArray* tokenize (NSString *expression);
void addNumber (NSMutableString *numberBuf, unichar token, NSMutableArray *tokens);
BOOL precedenceOf (NSString *operator, NSString *otherOperator);
int precedenceOf1 (NSString *operator);
NSString* workwithReggex (NSString *str);
NSString* replaceTheSymbol (NSString *str, NSString *patternStr, NSString *replaceStr);


@interface NSDecimalNumber (sqrt)
- (NSDecimalNumber *) sqrt;
@end


//MARK: - stack func.

int size (NSMutableArray *stack) {
		return (int)[stack count];
}

id pop (NSMutableArray *stack) {
		if (size(stack) < 1) {
				return nil;
		}

		id item = [stack lastObject];
		[stack removeLastObject];
		return item;
}

void push (id object, NSMutableArray *stack) {
		[stack addObject:object];
}

id peek (NSMutableArray *stack) {
		if (size(stack) < 1) {
				return nil;
		}

		return [stack lastObject];
}

BOOL empty(NSMutableArray *stack) {
		return [stack count] == 0;
}

//MARK: - calc func.
//MARK: postfix func.

BOOL itsOperationBeetweenTwoNumbers (NSString *token) {
		NSArray *operatorsBeetweenTwoNumbers = [NSArray arrayWithObjects: @"+", @"-", @"*", @"/", nil];
		return [operatorsBeetweenTwoNumbers containsObject:token];
}

BOOL itsOperationOnOneNumber(NSString *token) {
		NSArray *operatorsBeetweenTwoNumbers = [NSArray arrayWithObjects: @"^", @"#", nil];
		return [operatorsBeetweenTwoNumbers containsObject:token];
}

NSDecimalNumber *computePostfix(NSString *postfix) {
		operators = [NSArray arrayWithObjects: @"+", @"-", @"*", @"/", @"^", @"#", nil];
		stacks = [NSMutableArray new];

		NSString *strippedExpression = [postfix stringByTrimmingCharactersInSet:
																		[NSCharacterSet whitespaceAndNewlineCharacterSet]];

		NSArray *tokens = [strippedExpression componentsSeparatedByString: @" "];

		for (NSString *token in tokens) {
				if ([operators containsObject:token]) {
						//оператор найден: вынуть 2 значение операнда и использовать
						//их в качестве аргументов оператора
						NSDecimalNumber *secondOperand = (NSDecimalNumber*) pop(stacks);
						NSDecimalNumber *firstOperand= (NSDecimalNumber*) pop(stacks);


						if ((!(firstOperand && secondOperand) && itsOperationBeetweenTwoNumbers(token)) || (!secondOperand && itsOperationOnOneNumber(token))) {
								NSLog(@"Not enough operands on stack for given operator: '%@'", token);
								return nil;
						}

						//вычислить результат, и вставьте его обратно в стек
						NSDecimalNumber *result = computeOperator (token, firstOperand, secondOperand);

						if (result == [NSDecimalNumber notANumber]) {
								return result; //Обнаружена ошибка при расчете оператора
						}

						push (result, stacks);

				} else {
						//number found, push it on the stack
						NSDecimalNumber  *operand = [NSDecimalNumber decimalNumberWithString : token];
						push (operand, stacks);
				}
		}

		if (size(stacks) != 1) {
				NSLog(@"Error : Invalid RPN expression. Stack contains %d elements after computing expression, only one should remain.",	size(stacks));
				return nil;
		} else {
				NSDecimalNumber  *result = pop(stacks);
				return result;
		}

		return 0;
}

//MARK: infix func.

BOOL hasBalancedBrackets (NSString *expression) {

		unichar c;
		int opened = 0, closed = 0;

		for (int i = 0; i< [expression length] ; i++) {
				c = [expression characterAtIndex: i];
				if (c == '(') {
						opened++;
				}
				else if (c == ')') {
						closed++;
				}
		}

		return opened == closed;
}

void print(NSMutableArray *stack){
  NSLog(@"[ %@ ]", [stack componentsJoinedByString: @" , "]);
}

NSString* parseInfix (NSString *infix) {
		if (! hasBalancedBrackets(infix)) {
				NSLog(@"Unbalanced brackets in expression");
				return nil;
		}

		stacks = [NSMutableArray new];
		NSMutableArray *opiStack = stacks;
		NSMutableString *output = [NSMutableString stringWithCapacity:[infix length]];

		NSArray *tokens = tokenize(infix);
		for (NSString *token in tokens) {
				if (precedenceOf1(token) != 0) {
						//токен является оператором, вынуть все операторы высшего или
						//равного приоритета из стека, и добавить их на выход
						NSString *op = peek(opiStack);
						while (op && precedenceOf1(op) != 0 &&
									 precedenceOf(op, token)) {
								[output appendString: [NSString stringWithFormat: @"%@ ", pop(opiStack)]];
								op = peek(opiStack);
						}
						// вставить оператор в стек
						push(token, opiStack);

				} else if ([token compare: @"("] ==0) {
						//вынуть открываюе скобки из стека, она будет вынута позже
						push(token, opiStack);
				} else if ([token compare: @")"] ==0) {
						// closing bracket :
						// вынуть операторы из стека и добавить их на выход,
						//в то время как вынутый элемент не является открывающей скобкой
						NSString *op = pop(opiStack);
		    while ( op  && ([op compare: @"("] != 0)) {
						[output appendString: [NSString stringWithFormat: @"%@ ", op]];
						op = pop(opiStack);
				}
						if (! op || ([op compare: @"("]  != 0)) {
								NSLog(@"Error : несбалансированные скобки в выражении");
								return nil;
						}
				} else {
						//token is an operand, append it to the output
						[output appendString: [NSString stringWithFormat: @"%@ ", token]];
				}
		}

		//вынуть остальные операторы из стека, и добавить их на выход
		while (! empty(opiStack)) {
				[output appendString: [NSString stringWithFormat: @"%@ ", pop(opiStack)]];
		}

		return [output stringByTrimmingCharactersInSet:
						[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

//MARK: - init

NSDecimalNumber *computeExpression (NSString *infix) {
		NSString *regexExpression = workwithReggex(infix);

		NSString *postfixExpression = parseInfix(regexExpression);

		if (postfixExpression) {
				return computePostfix(postfixExpression);
		}

		return nil;
}

void analyzeExpression() {

		NSString *funcForAnalyze = getFunctionForAnalyze();

		NSDecimalNumber *rez = computeExpression(funcForAnalyze);
		if (rez != nil) {
				NSLog(@"Результат: '%@ = %@'", funcForAnalyze, rez);
		} else {
				NSLog(@"Не удается вычислить результат; что-то неправильно!");
		}
}

int main(int argc, const char  *argv[]) {
		@autoreleasepool {
				analyzeExpression();
		}

		return 0;
}

//MARK: - Regular ext.

NSString* workwithReggex (NSString *str) {

		NSString *strW = str;

		strW = replaceTheSymbol (strW, @"\\*[\\s]?sqr(?=([\\s]?)\\([0-9\\.]*\\))", @"^");
		strW = replaceTheSymbol (strW, @"sqrt(?=([ \\s]?)\\([0-9\\.]*\\))", @"#"); //√

		return strW;
}

NSString *replaceTheSymbol (NSString *str, NSString *patternStr, NSString *replaceStr) {

		NSString *strW = str;
		NSRegularExpression *regex = [[NSRegularExpression new] initWithPattern:patternStr
																																		options:0
																																			error:nil];
		long n = [regex numberOfMatchesInString:strW
																		options:0
																			range:NSMakeRange(0, [strW length])];

		if (n > 0) {
				NSArray *matches = [regex matchesInString:strW
																					options:0
																						range:NSMakeRange(0, [str length])];

				for (NSTextCheckingResult *match in matches) {
						NSString *matchText = [strW substringWithRange:[match range]];
						strW = [strW stringByReplacingOccurrencesOfString:matchText withString:replaceStr];
				}
		}

		return strW;
}

//MARK: - private methods
//MARK: postfix

NSDecimalNumber* computeOperator (NSString *operator, NSDecimalNumber *firstOperand, NSDecimalNumber *secondOperand) {
		NSDecimalNumber *result;

		if ([operator compare: @"+"] == 0) {
				result = [firstOperand decimalNumberByAdding: secondOperand];
		} else if ([operator compare: @"*"] == 0) {
				result = [firstOperand decimalNumberByMultiplyingBy: secondOperand];
		} else if ([operator compare: @"-"] == 0) {
				result = [firstOperand decimalNumberBySubtracting: secondOperand];
		} else if ([operator compare: @"^"] == 0) {
				result = [firstOperand decimalNumberByRaisingToPower: [secondOperand intValue]];
		} else if ([operator compare: @"#"] == 0) {
				result = [secondOperand sqrt];
		} else if ([operator compare: @"/"] == 0) {
				if ([[NSDecimalNumber zero] compare: secondOperand] == NSOrderedSame) {
						NSLog(@"Divide by zero !");
						return [NSDecimalNumber notANumber];
				} else {
						result = [firstOperand decimalNumberByDividingBy: secondOperand];
				}
		}

		return result;
}

//MARK: infix

NSArray* tokenize (NSString *expression) {
		NSMutableArray *tokens = [NSMutableArray arrayWithCapacity:[expression length]];

		unichar c;
		NSMutableString *numberBuf = [NSMutableString stringWithCapacity: 5];
		int length = (int)[expression length];
		BOOL nextMinusSignIsNegativeOperator = YES;

		for (int i = 0; i< length; i++) {
				c = [expression characterAtIndex: i];
				switch (c) {
						case '+':
								// ** fall-through! **
						case '/':
								// ** fall-through! **
						case '*':
								// ** fall-through! **
						case '^':
								// ** fall-through! **
						case '#': {
								// code executed for value '+','/','*','*'
								nextMinusSignIsNegativeOperator = YES;
								addNumber(numberBuf, c, tokens);
								break;
						}
						case '(':
						case ')': {
								// code executed for value '(', ')'
								nextMinusSignIsNegativeOperator = NO;
								addNumber(numberBuf, c, tokens);
								break;
						}
						case '-': {
								if (nextMinusSignIsNegativeOperator) {
										nextMinusSignIsNegativeOperator = NO;
										[numberBuf appendString : [NSString stringWithCharacters: &c length:1]];
								} else {
										nextMinusSignIsNegativeOperator = YES;
										addNumber(numberBuf, c, tokens);
								}

								break;
						}
						case '1':
								// ** fall-through! **
						case '2':
								// ** fall-through! **
						case '3':
								// ** fall-through! **
						case '4':
								// ** fall-through! **
						case '5':
								// ** fall-through! **
						case '6':
								// ** fall-through! **
						case '7':
								// ** fall-through! **
						case '8':
								// ** fall-through! **
						case '9':
								// ** fall-through! **
						case '0':
								// ** fall-through! **
						case '.': {
								// code executed for value from '0' to '9' and '.'
								nextMinusSignIsNegativeOperator = NO;
								[numberBuf appendString : [NSString stringWithCharacters: &c length:1]];
								break;
						}
						case ' ':
								break;
						default:
								NSLog(@"Unsupported character in input expression : %c, discarding.", c);
								break;
				}
		}
		if ([numberBuf length] > 0) {
				[tokens addObject:  [NSString stringWithString: numberBuf]];
		}

		return tokens;
}

void addNumber (NSMutableString *numberBuf, unichar token, NSMutableArray *tokens) {
		if ([numberBuf length] > 0) {
				[tokens addObject:  [NSString stringWithString: numberBuf]];
				[numberBuf setString:@""];
		}
		[tokens addObject: [NSString stringWithCharacters: &token length:1]];
}

int precedenceOf1 (NSString *operator) {
		if ([operator compare: @"+"] == 0) {
				return 1;
		} else if ([operator compare: @"-"] == 0) {
				return 1;
		} else if ([operator compare: @"*"] == 0) {
				return 2;
		} else if ([operator compare: @"/"] == 0) {
				return 2;
		} else if ([operator compare: @"^"] == 0) { //sqr
				return 3;
		} else if ([operator compare: @"#"] == 0) { //sqrt
				return 3;
		} else { //invalid operator
				return 0;
		}
}

BOOL precedenceOf (NSString *operator, NSString *otherOperator) {
		return  precedenceOf1(operator)  >=  precedenceOf1(otherOperator);
}

//MARK: other
NSString* getFunctionForAnalyze() {
		return @"((sqrt(4) + 7)/2 *sqr(2))* 5";//@"3 + 4 * 5";//"2+(3*4)/5"; //@"2+(3 * sqr(2) - sqrt(4))/5";
}

@implementation NSDecimalNumber (sqrt)

- (NSDecimalNumber *)sqrt
{
		if ([self compare:[NSDecimalNumber zero]] == NSOrderedAscending) {
				return [NSDecimalNumber notANumber];
		}

		NSDecimalNumber *half = [NSDecimalNumber decimalNumberWithMantissa:5 exponent:-1 isNegative:NO];
		NSDecimalNumber *guess = [[self decimalNumberByAdding:[NSDecimalNumber one]] decimalNumberByMultiplyingBy:half];

		@try
		{
				const int NUM_ITERATIONS_TO_CONVERGENCE = 6;
				for (int i = 0; i < NUM_ITERATIONS_TO_CONVERGENCE; i++)
				{
						guess =
						[[[self decimalNumberByDividingBy:guess]
							decimalNumberByAdding:guess]
						 decimalNumberByMultiplyingBy:half];
				}
		}
		@catch (NSException *exception)
		{
				// deliberately ignore exception and assume the last guess is good enough
		}
		
		return guess;
}

@end

