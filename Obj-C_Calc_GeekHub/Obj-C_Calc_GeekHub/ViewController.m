//
//  ViewController.m
//  Obj-C_Calc_GeekHub
//
//  Created by Nikolay Dementiev on 19.10.16.
//  Copyright © 2016 mc373. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *ConsoleOutput;
@property (weak, nonatomic) IBOutlet UITextField *inputData;

float calculateOperation(int oper);

typedef enum {
		none,
		plus,
		minus,
		multiply,
		devide
} Oper;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

		}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

//MARK: - operation
- (IBAction)inputDigitClicked:(UIButton *)sender {
		self.lastValue = [_inputData.text floatValue];
}

- (IBAction)operationButtonPlusClick:(UIButton *)sender {
		[self caltIt:1 description:sender.tag];
}

- (IBAction)operationButtonMinusClick:(UIButton *)sender{
}
- (IBAction)operationButtonMultiplyClick:(UIButton *)sender{
}
- (IBAction)operationButtonDevideClick:(UIButton *)sender{
}
- (IBAction)operationButtonEquelClick:(UIButton *)sender{
}

- (void) caltIt: (int)oper description:(long)descriptionOfOper {

		float result;
		result = calculateOperation(1);

		NSLog(@"Result of %d %ld %d is: %f", self.lastValue, (long)descriptionOfOper, self.curretValue, result);
		_ConsoleOutput.text = [NSString stringWithFormat:@"%.3f", result];

}

- (float) calculateOperation: (int) oper {
		float result;

		result = 0;

		switch (oper) {
				case 1:
						result = self.lastValue + self.curretValue;
						break;
				case 2:
						result = self.lastValue - self.curretValue;
						break;
				case 3:
						result = self.lastValue * self.curretValue;
						break;
				case 4:
						result = self.lastValue / self.curretValue;
						break;

				default:
						break;
		}

		return result;
}


@end
