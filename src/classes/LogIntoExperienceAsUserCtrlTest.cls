/**
 * Author: Kevin Antonioli
 * Created: 03.10.2023
 * Provides apex test code coverage for the following classes: LogIntoExperienceAsUserCtrl.cls
 *
 * Assumptions:
 *  An account record type with the name of 'Person Account' has been created
 *  A custom profile called 'Customer Portal User' has been created
 *
 */
@isTest
public class LogIntoExperienceAsUserCtrlTest {
  private static String portalProfileName = 'Customer Portal User'; // Change to profile name of choice
  @isTest
  static void test_Controller() {
    Account accRecord = new account();
    accRecord.Name = 'Test Account 1';
    insert accRecord;

    Account accRecord2 = new account();
    accRecord2.Name = 'Test Account 2';
    insert accRecord2;

    contact conRecord = new contact();
    conRecord.AccountId = accRecord.id;
    conrecord.LastName = 'Test Contact 1';
    insert conRecord;

    AccountContactRelation acr = new AccountContactRelation();
    acr.AccountId = accRecord2.id;
    acr.ContactId = conRecord.id;
    insert acr;

    String personAcctRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Person Account')
      .getRecordTypeId();
    Account personAccount = new Account(Id = accRecord.Id);
    personAccount.recordTypeId = personAcctRecordTypeId;
    update personAccount;

    Schema.DescribeFieldResult userNameDescribe = User.UserName.getDescribe();
    Schema.SObjectField userNameField = userNameDescribe.getSObjectField();

    Schema.DescribeFieldResult emailDescribe = User.Email.getDescribe();
    Schema.SObjectField emailField = emailDescribe.getSObjectField();

    String uniqueUserName =
      'standarduser' +
      DateTime.now().getTime() +
      '@testorg.com';
    Map<SObjectField, String> fieldMap = new Map<SObjectField, String>();
    fieldMap.put(userNameField, uniqueUserName);
    fieldMap.put(emailField, 'test+Todd@decent.com');

    Profile portalProfile = [
      SELECT Id
      FROM Profile
      WHERE Name = :portalProfileName
    ];

    Test.startTest();
    PageReference portalLoginPage = Page.LogIntoExperienceAsUserPg;
    Test.setCurrentPage(portalLoginPage);
    portalLoginPage.getParameters().put('Id', String.valueOf(personAccount.Id));

    personAccount = [
      SELECT Id, PersonContactId
      FROM Account
      WHERE Id = :accRecord.Id
    ];

    ApexPages.StandardController sc = new ApexPages.StandardController(
      personAccount
    );
    LogIntoExperienceAsUserCtrl testProxyLogin = new LogIntoExperienceAsUserCtrl(
      sc
    );
    Pagereference pageRef = testProxyLogin.redirectToProxyLink();
    Test.stopTest();

    Assert.isNotNull(pageRef);
  }
}