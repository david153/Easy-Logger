//
//  ELViewController.m
//  Easy Logger
//
//  Created by DavidSumner on 8/29/13.
//  Copyright (c) 2013 DavidSumner. All rights reserved.
//

#import "ELViewController.h"
#import <MessageUI/MessageUI.h> 
#import "ELPatientData.h"
#import <DropboxSDK/DropboxSDK.h>

@interface ELViewController ()


//Alert Tags
#define kMissingDataAlert 1001
#define kNoEmailAlert 1002
#define kMailNotSentAlert 1003
#define kErrorAlertTag 1004
#define kFileSavedToDropBoxTag 1005
#define kFileSaveFailedAlertTag 1006
#define kRepeatedRecordAlertTag 1007
#define kNoAgeAlertTag 1008

//Email Addresses
#define kBetsyAddress @"betsy.sumner@duke.edu"
#define kDavidAddress @"support@pentopuzzle.com"

//File Names
#define kDataString @"dataStringFile"
#define kPatientRecordsFile @"PatientRecords"

//Error Messages
#define kNoRecordsError @"Records Database Failed"

@end


@implementation ELViewController

#pragma mark Initialization Code

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Setup text Field Actions
    [self.diagnosisField setDelegate:self];
    [self.diagnosisField setReturnKeyType:UIReturnKeyDone];
    [self.diagnosisField addTarget:self
                         action:@selector(textFieldFinished)
                         forControlEvents:UIControlEventEditingDidEndOnExit];
    
    //Does the report string exist in the documents file?
    //If so load it into dataString
    //If not then create the string and save it to the documents file.
    //Do likewise with the Patient Records NSMutableArray.
    [self setUpDataString];
    [self setupPatientRecords];
  
    [_addItemButton setEnabled:YES];
    _addItemButton.alpha = 1.0;
    [_cancelButton setEnabled:NO];
    _cancelButton.alpha = 0.5;
    
    [_confirmButton setEnabled:NO];
    _confirmButton.alpha = 0.5;
    
    _report = @"";
    _lastConfirmedReport = @"";
    [self showRecentRecordsResults];
    
}

-(void) setUpDataString
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* docFilePath = [self dataFilePath:kDataString];
    
    //First try and load the database from the documents folder
    if ([fileManager fileExistsAtPath:docFilePath])
    {
        [self loadDataStringFromDocuments];
        
    } else {
        
        _dataString = @"Age\tGender\tTreatment\tRotation\tDiagnosis";
        [self saveDataStringToDocuments];
    }
}


-(void) setupPatientRecords
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* docFilePath = [self dataFilePath:kPatientRecordsFile];
    
    //First try and load the database from the documents folder
    _patientRecords = [[NSMutableArray alloc] init];
    if (![fileManager fileExistsAtPath:docFilePath])
    {
        if(![NSKeyedArchiver archiveRootObject:_patientRecords toFile:docFilePath])
            NSLog(@"Error in creating the Patient Records Array.");
        
    } else {
        NSLog(@"We are loading the Patient Records");
        _patientRecords = (NSMutableArray*)[NSKeyedUnarchiver unarchiveObjectWithFile:docFilePath];
    }
}



#pragma mark File Handling Code

//This method writes the contents of _dataString to a text file
//Called PatientData.txt

-(void) writeToTextFile
{
    //get the documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/PatientData.txt",
                          documentsDirectory];
    //create content - four lines of text
   
    //save content to the documents directory
    [_dataString writeToFile:fileName
              atomically:YES
                encoding:NSStringEncodingConversionAllowLossy
                   error:nil];
}


//This method loads _datastring as a string from the documents folder.
//It load it via decoding.
-(void) loadDataStringFromDocuments
{
    NSString* docFilePath = [self dataFilePath:kDataString];
    
    _dataString = (NSString*)[NSKeyedUnarchiver unarchiveObjectWithFile:docFilePath];
    NSLog(@"We found the data string in the documents directory");
}

//This method saves _dataString to the docuemtns fiolder as an encoded object.
-(void) saveDataStringToDocuments
{
    //NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* docFilePath =[self dataFilePath:kDataString];
    
    if(![NSKeyedArchiver archiveRootObject:_dataString toFile:docFilePath])
    {
        NSLog(@"Error in archiving Data String.");
    } else {
        NSLog(@"We saved the Data String to the Documnents directory");
    }
    
    //[self saveFileToDropbox];
}

//This method saves the current data record to a local database Array
//Called _patientRecords
-(void) savePatientRecords
{
    NSString* docFilePath = [self dataFilePath:kPatientRecordsFile];
    
    if(!_patientRecords)
    {
        [self ErrorAlert:kNoRecordsError];
        return;
    }
    
    [_patientRecords addObject:_currentPatientRecord];
    NSLog(@"There are %d patient records",_patientRecords.count);
    NSLog(@"This patient's age is %d",[_currentPatientRecord.age integerValue]);
    if(![NSKeyedArchiver archiveRootObject:_patientRecords toFile:docFilePath])
        NSLog(@"Error in archiving patient records database");
}

-(NSString *)dataFilePath:(NSString *)fileName
{
  	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
														 NSUserDomainMask, YES);
    
	NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *theFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
    
	return theFilePath;
}


-(void) textFieldFinished
{
    NSLog(@"Text entry done");
    
}


-(Boolean)compileData {
    
    if(_diagnosisField.text.length == 0)
    {
        [self noDiagnosisAlert];
        return NO;
    }
    
    int firstDigit = _firstAgeDigit.selectedSegmentIndex;
    int secondDigit = _secondAgeDigit.selectedSegmentIndex;
    _firstAgeDigit.selectedSegmentIndex = 0;
    _secondAgeDigit.selectedSegmentIndex = 0;
    
    int age = secondDigit+10*firstDigit;
    enteredAge = age;
     
    NSString *gender = @"Male";
    if(_genderSelection.selectedSegmentIndex > 0)
        gender = @"Female";
    
    NSString *treatment = @"Med Management";
    if(_treatmentSelection.selectedSegmentIndex > 0)
        treatment = @"Therapy";
    
    NSString *rotation = @"PEC";
    switch (_rotationSelection.selectedSegmentIndex) {
        case 0: rotation = @"PEC";
    break;
        case 1: rotation = @"CRH AAU";
            break;
        case 2: rotation = @"CRH Gero";
            break;
        case 3: rotation = @"Duke CL";
            break;
    }

//Show the results before submitting
    NSString *diagnosis = _diagnosisField.text;

    NSString *dataToDisplay = [NSString stringWithFormat:@"Age: %d\nGender: %@\nTreatment: %@\nRotation: %@\nDiagnosis: %@",age, gender,treatment,rotation,diagnosis];
//    NSDate *today = [NSDate date];
//    NSLog(@"Datw is: %@",today);
//
    NSString *dateAndTime = [self formDateAndTimeString];
    _report = [NSString stringWithFormat:@"\n%d\t%@\t%@\t%@\t%@\t%@",age,gender,treatment,rotation,diagnosis,dateAndTime];
    
    self.dataString = [self.dataString stringByAppendingString:_report];
    NSLog(@"Report string is %@",_report);
    
    _displayString = [NSString stringWithFormat:@"%@\n\n\n%@",dataToDisplay,_dataString];
    
    
    //Create a new patient record.
    //We will not add it to the array and save unless the email is sent.
    _currentPatientRecord = [[ELPatientData alloc]init];
    _currentPatientRecord.age = @(age);
    _currentPatientRecord.gender = gender;
    _currentPatientRecord.treatment = treatment;
    _currentPatientRecord.rotation = rotation;
    _currentPatientRecord.diagnosis = diagnosis;
    _currentPatientRecord.recordDate = dateAndTime;
    
    return YES;
}

-(IBAction) addItemToReportString
{
     if(![self compileData])
         return;
    _confirmedReport = @"";
    _currentReportField.text = _report;
   
    [_addItemButton setEnabled:NO];
    [_confirmButton setEnabled:YES];
    [_cancelButton setEnabled:YES];

    _addItemButton.alpha = 0.5;
    _confirmButton.enabled = YES;
    _confirmButton.alpha = 1.0;
    _cancelButton.enabled = YES;
    _cancelButton.alpha = 1.0;
}

- (IBAction) cancelEntry:(id)sender {
    _currentReportField.text = @"";
    _report = @"";
    _confirmedReport = @"";
    [_addItemButton setEnabled:YES];
    _addItemButton.alpha = 1.0;
    
     [_cancelButton setEnabled:NO];
    _cancelButton.alpha = 0.5;
    
    [_confirmButton setEnabled:NO];
    _confirmButton.alpha = 0.5;
}

-(IBAction) confirmEntry
{
    if ([_lastConfirmedReport isEqualToString:_report])
    {
        NSLog(@"Repeated Report");
        [self repeatedRecordAlert];
        return;
    }
    
    if (enteredAge == 0)
    {
        NSLog(@"No Age");
        [self noAgeAlert];
        return;
    }
    
    [self followUpConfirmEntry];
}

-(void) followUpConfirmEntry {
    [_addItemButton setEnabled:YES];
    _addItemButton.alpha = 1.0;
    
    [_cancelButton setEnabled:NO];
    _cancelButton.alpha = 0.5;
    
    [_confirmButton setEnabled:NO];
    _confirmButton.alpha = 0.5;
    
    [self loadDataStringFromDocuments];
    _dataString = [_dataString stringByAppendingString:_report];
    [self saveDataStringToDocuments];
    [self writeToTextFile];
    [self savePatientRecords];
    _currentReportField.text = @"";
    _confirmedReport = [_report copy];
    _lastConfirmedReport = [_report copy];
    
    [self showRecentRecordsResults];
    }

-(void) showRecentRecordsResults
{
    _recentRecordsField.text = @"";
    NSString *reportString = @"";
    int lastRecord = _patientRecords.count -1;
    int numberOfRecordsToShow = 4;
    if(_patientRecords.count < 4)
        numberOfRecordsToShow = _patientRecords.count;
        
    for (int i= 0; i < numberOfRecordsToShow; i++)
    {
        ELPatientData* patientRecord = (ELPatientData*)(_patientRecords[lastRecord-i]);
        reportString = [reportString stringByAppendingString:[NSString stringWithFormat:@"Age: %@ Diagnosis: %@ Treatment: %@ Rotation: %@\n",patientRecord.age, patientRecord.diagnosis, patientRecord.treatment, patientRecord.rotation] ];
    }
    NSLog(@"report String: %@",reportString);
    
    _recentRecordsField.text = reportString;

}

#pragma mark email code
-(NSString *) formDateAndTimeString
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMM dd, yyyy HH:mm"];
    
    NSDate *now = [[NSDate alloc] init];
    
    NSString *dateString = [format stringFromDate:now];
    return dateString;
}


- (IBAction) sendEmail
{
    
    if (![MFMailComposeViewController canSendMail])
    {//Add an Alert
        //[self noEmailAvailableAlert];
        
        [self showOKAlert:@"Email Not Available" withMessage:@"Check WiFi availability" AndTag:kNoEmailAlert];
        return;
    }
    
    
    int numberOfRecords = _patientRecords.count-1;
   
    int stopAtIndex = numberOfRecords - 3;
    NSString *mostRecentRecords = @"Most Recent Entrys:\n\n";
    NSString *dataToAppend = @"";
    ELPatientData *currentWorkingPatientData;
    
    for(int i = numberOfRecords; i > stopAtIndex; i--)
    {
        if(i < 0)
            break;
        
        currentWorkingPatientData = _patientRecords[i];
        dataToAppend = [NSString stringWithFormat:@"Age: %@   Diagnosis: %@\n",currentWorkingPatientData.age,currentWorkingPatientData.diagnosis];
        mostRecentRecords = [mostRecentRecords stringByAppendingString:dataToAppend];
        NSLog(@"Most recent records is: %@",mostRecentRecords);
    }

   
   // _recordNumberLabel.text = [NSString stringWithFormat:@"%d records",_patientRecords.count];
    NSString* docFilePath = [self dataFilePath:@"PatientData.txt"];
    
    NSData *reportData = [NSData dataWithContentsOfFile:docFilePath];
   
   	
	NSArray *toPeople = [[NSArray alloc] initWithObjects:kDavidAddress,nil];
	MFMailComposeViewController* emailController = [[MFMailComposeViewController alloc] init];
	
	emailController.mailComposeDelegate = self;
	
	[emailController setSubject:@"Patient Info"];
	[emailController setToRecipients:toPeople];
    ;

   
    NSString *messageBodyText = [NSString stringWithFormat:@"%@\n%d confirmed records",mostRecentRecords,_patientRecords.count];
    
            [emailController setMessageBody:messageBodyText isHTML:NO];
      
    [emailController addAttachmentData:reportData mimeType:@"text/plain" fileName:@"PatientData.txt"];
    [self presentViewController:emailController animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    NSLog(@"Mail was sent %u",result);
    //If the mail was sent successfully, then we save stuff elsewhere too.
    if(result == MFMailComposeResultSent)
    {
        NSLog(@"Mail was sent successfully");
        
    }
    
    //If sending mail failed but the user tried to send it
    //we still save the data.
    if(result == MFMailComposeResultFailed)
    {
         NSLog(@"Mail NOT SENT");
    }
    
	[self becomeFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil]; 
}

#pragma mark Alert Code

-(void) repeatedRecordAlert
{
    UIAlertView *repeatedRecordAlert = [[UIAlertView alloc] initWithTitle:@"Repeated Record?"
                                                         message:@"This is the same data as the previously entered record"
                                                        delegate:self cancelButtonTitle:@"Cancel Entry"  otherButtonTitles:@"Continue",nil];
    
    repeatedRecordAlert.tag = kRepeatedRecordAlertTag;
    [repeatedRecordAlert show];
    
}
              
-(void) noAgeAlert
        {
            UIAlertView *ageAlert = [[UIAlertView alloc] initWithTitle:@"No Age Entered"
                                                                          message:@"Did you mean to omit the age?"
                                                                         delegate:self cancelButtonTitle:@"Cancel Entry"  otherButtonTitles:@"Continue",nil];
            
            ageAlert.tag = kNoAgeAlertTag;
            [ageAlert show];
            
        }

-(void) ErrorAlert:(NSString *) errorType
  {
      UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:errorType
                                                             message:@"Tell David About this error!!"
                                                            delegate:self cancelButtonTitle:@"OK"  otherButtonTitles:nil];
      
      errorAlert.tag = kErrorAlertTag;
      [errorAlert show];
      
  }

-(void) noDiagnosisAlert
{
    UIAlertView *diagnosisAlert = [[UIAlertView alloc] initWithTitle:@"Missing Data"
                                                          message:@"There was no diagnosis!\nData will not be saved."
                                                         delegate:self cancelButtonTitle:@"OK"  otherButtonTitles:nil];
	
	diagnosisAlert.tag = kMissingDataAlert;
	[diagnosisAlert show];
}

-(void) mailNotSentAlert
{
    UIAlertView *diagnosisAlert = [[UIAlertView alloc] initWithTitle:@"Mail Not Sent"
                                                             message:@"There was an error in sending email!!"
                                                            delegate:self cancelButtonTitle:@"OK"  otherButtonTitles:nil];
	
	diagnosisAlert.tag = kMailNotSentAlert;
	[diagnosisAlert show];
    
}


-(void) noEmailAvailableAlert
{
    UIAlertView *noEmailAlert = [[UIAlertView alloc] initWithTitle:@"Not able to send email"
                                                             message:@"Check WiFi availablity!"
                                                            delegate:self cancelButtonTitle:@"OK"  otherButtonTitles:nil];
	
	noEmailAlert.tag = kNoEmailAlert;
	[noEmailAlert show];
    
}


//Useable Standard Notification Only Alert
-(void) showOKAlert:(NSString *)alertTitle withMessage:(NSString*)alertMessage AndTag:(int)alertTag
                                            
{
    UIAlertView *myAlert = [[UIAlertView alloc]
                                initWithTitle:alertTitle
                                message:alertMessage
                                delegate:self
                                cancelButtonTitle:@"OK"
                                otherButtonTitles:nil];
	
     myAlert.tag = alertTag;
    [myAlert show];
    
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
    {
        if (alertView.tag == kMissingDataAlert)
        {
            
        }
        
        if (alertView.tag == kNoEmailAlert)
        {
            
        }
        
        if(alertView.tag == kMailNotSentAlert)
        {
            
        }
        
        if(alertView.tag == kErrorAlertTag)
        {
            
        }
        
        
        if(alertView.tag == kRepeatedRecordAlertTag || alertView.tag == kNoAgeAlertTag)
        {
            NSLog(@"Button index was %d",buttonIndex);
            if(buttonIndex == 1)
            {
                [self followUpConfirmEntry];
                return;
            } else {
                [self cancelEntry:nil];
                return;
            }
        }

        
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
