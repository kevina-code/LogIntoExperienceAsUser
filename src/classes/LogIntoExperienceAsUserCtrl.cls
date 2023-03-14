/**
 * Author     : Kevin Antonioli (braveitnow@pm.me)
 * Description: controller for VF page tied to action that allows people with assigned access to Log into Experience as User
 *  from person accounts, even in Production Orgs.
 *  This workaround cannot be done with LWC; must use VF (unless you find a way, but I haven't)
 *
 *  You may be wondering, "Why not just use the out of box 'Log into Experience As User' button?"?
 *  The answer is: That button doesn't show up on person accounts in Production orgs.
 *  If a dev or QA needs to proxy in as a portal user to troubleshoot, there
 *  is no out-of-box way to do that in Lightning Experience in a Production environment. Hence where this Apex class comes in.
 *
 *  You may be also wondering, "Why not just switch to classic when trying to log into experience as user in Production?"
 *  The answer is: only system admins have access to classic in production orgs. QA's are out of luck.
 *
 *  With this solution, you can create your own 'Log into Experience As User' action on the Account,
 *  and tie it to the LogIntoExperienceAsUserPg VF page.
 *  Then anyone with permissions assigned to the VF page, controller apex class, and button can use it to proxy login
 *  to customer portals in Production orgs.
 * Created    : 03.10.2023
 *
 */
public class LogIntoExperienceAsUserCtrl {
  public Account acct { get; set; }
  public User portalUser { get; set; }

  private static final String portalName = 'NAME_OF_YOUR_PORTAL'; // Change this to the name of your portal

  /**
   * @description: constructor to set instance variables (acct and portalUser)
   * @param controller (ApexPages.StandardController) : standard controller for Account
   */
  public LogIntoExperienceAsUserCtrl(ApexPages.StandardController controller) {
    acct = [
      SELECT Id, PersonContactId, Name
      FROM Account
      WHERE Id = :controller.getId()
    ];
    portalUser = Test.isRunningTest()
      ? new User(
          FirstName = 'Bob',
          LastName = 'Portalia',
          ContactId = acct.PersonContactId
        )
      : [SELECT Id FROM User WHERE ContactId = :acct.PersonContactId LIMIT 1];
  }

  /**
   * @description: assimilate the proxy URL using the data on the Account the custom 'Log in to Experience as User' button was clicked from
   * @param   null
   * @return  pageRef (ePageReference)
   */
  public PageReference redirectToProxyLink() {
    // Proxy login URL example:
    //  https://abccorp--abccorpfull.my.salesforce.com/servlet/servlet.su?oid=00DS0000003Nko2&retURL=%2F0011U00001ttmCx&sunetworkid=0DB1U0000004Fpr&sunetworkuserid=005S000000QZeWF
    Id orgId = [SELECT Id FROM Organization].Id;
    Id portalNetworkId = Test.isRunningTest()
      ? new Network(Id = '0DB28000022AOiJ').Id
      : [SELECT Id FROM Network WHERE Name = :portalName].Id;
    String subDomainWithProtocol = (System.URL.getSalesforceBaseURL()
        .toExternalForm())
      .split('\\.')[0];
    String proxyURL =
      subDomainWithProtocol.remove('--c') +
      '.my.salesforce.com/servlet/servlet.su?oid=' +
      orgId +
      '&retURL=%2F' +
      acct.Id +
      '&sunetworkid=' +
      portalNetworkId +
      '&sunetworkuserid=' +
      portalUser.Id;
    PageReference pageRef = new PageReference(proxyURL);
    pageRef.setRedirect(true);
    return pageRef;
  }
}