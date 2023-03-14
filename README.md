# LogIntoExperienceAsUser
This is a workaround to provide proxy login access to customer portals for non-system admins while in Lightning Experience. 

It dynamically constructs the proxy login URL for a particular customer portal.

Example Proxy Login URL: https://mycompany.my.salesforce.com/servlet/servlet.su?oid=00DS0000003Nko2&retURL=%2F0011U00001ttmCx&sunetworkid=0DB1U0000004Fpr&sunetworkuserid=005S000000QZeWF

Where oid = Organization Id, retURL = %2F + Person Account Id, sunetworkid = Portal Network Id, sunetworkuserid = Portal User Id

<a href="https://githubsfdeploy.herokuapp.com/app/githubdeploy/kevina-code/LogIntoExperienceAsUser?ref=master">
  <img src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png" alt="Deploy to Salesforce" />
</a>

Usage:
1. Deploy metadata (apex classes, VF page)
2. In LogIntoExperienceAsUserCtrl.cls, update the portalName variable to the name of your portal.
3. Create quick action called 'Log into Experience as User' on the account object and tie it to the LogIntoExperienceAsUserPg VF page.
4. Add quick action to the person account lightning record page.
5. Optionally create permission set to drive access to the quick action.
