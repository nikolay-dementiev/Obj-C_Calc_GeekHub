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

@property (weak, nonatomic) IBOutlet UIButton *operationButtonPlus;
@property (weak, nonatomic) IBOutlet UIButton *operationButtonMinus;
@property (weak, nonatomic) IBOutlet UIButton *operationButtonMultiply;
@property (weak, nonatomic) IBOutlet UIButton *operationButtonDevide;
@property (weak, nonatomic) IBOutlet UIButton *operationButtonEquel;

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



- (void)calculateOperation {

}

@end
