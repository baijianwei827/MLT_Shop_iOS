//
//  STAlertView.m
//  STAlertView
//
//  Created by Nestor on 09/28/2014.
//  Copyright (c) 2014 Nestor. All rights reserved.
//

#import "STAlertView.h"


typedef enum {
    STAlertViewTypeNormal,
    STAlertViewTypeTextField
} STAlertViewType;

@implementation STAlertView{
    STAlertViewBlock cancelButtonBlock;
    STAlertViewBlock otherButtonBlock;
    
    STAlertViewStringBlock textFieldBlock;
}

@synthesize alertView;


- (void) alertView:(UIAlertView *)theAlertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0 && cancelButtonBlock)
        cancelButtonBlock();
    else if (buttonIndex == 1 && theAlertView.tag == STAlertViewTypeNormal && otherButtonBlock)
        otherButtonBlock();
    else if (buttonIndex == 1 && theAlertView.tag == STAlertViewTypeTextField && textFieldBlock)
        textFieldBlock([alertView textFieldAtIndex:0].text);
    
}

- (void) alertViewCancel:(UIAlertView *)theAlertView
{
    if (cancelButtonBlock)
        cancelButtonBlock();
}

- (id) initWithTitle:(NSString*)title
             message:(NSString*)message
   cancelButtonTitle:(NSString *)cancelButtonTitle
   otherButtonTitles:(NSString *)otherButtonTitles
   cancelButtonBlock:(STAlertViewBlock)theCancelButtonBlock
    otherButtonBlock:(STAlertViewBlock)theOtherButtonBlock
{

    cancelButtonBlock = [theCancelButtonBlock copy];
    otherButtonBlock = [theOtherButtonBlock copy];
    
    alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
    alertView.tag = STAlertViewTypeNormal;
    
    [alertView show];
    
    return self;
}

- (id) initWithTitle:(NSString*)title
             message:(NSString*)message
       textFieldHint:(NSString*)textFieldMessage
      textFieldValue:(NSString *)texttFieldValue
   cancelButtonTitle:(NSString *)cancelButtonTitle
   otherButtonTitles:(NSString *)otherButtonTitles
   cancelButtonBlock:(STAlertViewBlock)theCancelButtonBlock
    otherButtonBlock:(STAlertViewStringBlock)theOtherButtonBlock
{
    
    cancelButtonBlock = [theCancelButtonBlock copy];
    textFieldBlock = [theOtherButtonBlock copy];
    
    alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
    alertView.tag = STAlertViewTypeTextField;

    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[alertView textFieldAtIndex:0] setPlaceholder:textFieldMessage];
    [[alertView textFieldAtIndex:0] setText:texttFieldValue];
    [alertView textFieldAtIndex:0].delegate = self;
    [alertView show];
    
    return self;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * aString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([alertView textFieldAtIndex:0] == textField)
    {
        if ([aString length] > 10) {
            textField.text = [aString substringToIndex:10];
            [DataTrans showWariningTitle:T(@"昵称应该在1-10个字符之间") andCheatsheet:nil andDuration:1.0f];
            return NO;
        }
    }
    return YES;
}

@end
