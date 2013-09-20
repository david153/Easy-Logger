//
//  ELViewController.h
//  Easy Logger
//
//  Created by DavidSumner on 8/29/13.
//  Copyright (c) 2013 DavidSumner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h> 
#import <DropboxSDK/DropboxSDK.h>
@class ELPatientData;


DBRestClient *restClient;
int enteredAge;


@interface ELViewController : UIViewController <MFMailComposeViewControllerDelegate, UITextFieldDelegate,UIAlertViewDelegate, DBRestClientDelegate>
@property (strong, nonatomic) IBOutlet UISegmentedControl *firstAgeDigit;
@property (strong, nonatomic) IBOutlet UISegmentedControl *secondAgeDigit;
@property (strong, nonatomic) IBOutlet UISegmentedControl *genderSelection;
@property (strong, nonatomic) IBOutlet UISegmentedControl *treatmentSelection;
@property (strong, nonatomic) IBOutlet UISegmentedControl *rotationSelection;
@property (strong, nonatomic) IBOutlet UITextField *diagnosisField;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UITextField *currentReportField;
@property (strong, nonatomic) IBOutlet UILabel *recordNumberLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIButton *addItemButton;
@property (strong, nonatomic) IBOutlet UIButton *confirmButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
//@property (strong, nonatomic) IBOutlet UIButton *dropBoxButton;

@property (nonatomic, strong) NSMutableArray *patientRecords;
@property (nonatomic, strong) ELPatientData *currentPatientRecord;
@property (nonatomic, strong) NSString *report;
@property (nonatomic, strong) NSString *confirmedReport;
@property (nonatomic,strong)  NSString *displayString;
@property (nonatomic, strong) NSString *dataString;
@property (strong, nonatomic) NSString *lastConfirmedReport;

- (IBAction) sendEmail;
- (IBAction) addItemToReportString;
- (IBAction) confirmEntry;
- (IBAction)cancelEntry:(id)sender;

- (Boolean)compileData;

@end
