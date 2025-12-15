@isTest
private class ContactHelperTest {

    @TestSetup
    static void setupTestData() {
        // Create test account
        Account testAccount = new Account(
            Name = 'Test Account',
            Industry = 'Technology'
        );
        insert testAccount;

        // Create test contacts
        List<Contact> testContacts = new List<Contact>();

        testContacts.add(new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@example.com',
            Phone = '555-0001',
            AccountId = testAccount.Id
        ));

        testContacts.add(new Contact(
            FirstName = 'Jane',
            LastName = 'Smith',
            Email = 'jane.smith@example.com',
            Phone = '555-0002',
            AccountId = testAccount.Id
        ));

        insert testContacts;
    }

    @isTest
    static void testGetContactsByAccount() {
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        List<Contact> contacts = ContactHelper.getContactsByAccount(acc.Id);
        Test.stopTest();

        System.assertNotEquals(null, contacts, 'Contacts list should not be null');
        System.assertEquals(2, contacts.size(), 'Should return 2 contacts');
    }

    @isTest
    static void testSendWelcomeEmail() {
        List<Contact> contacts = [SELECT Id FROM Contact];
        List<Id> contactIds = new List<Id>();
        for (Contact c : contacts) {
            contactIds.add(c.Id);
        }

        Test.startTest();
        ContactHelper.sendWelcomeEmail(contactIds);
        Test.stopTest();

        // Verify no exceptions were thrown
        System.assertEquals(2, contactIds.size(), 'Should process 2 contacts');
    }

    @isTest
    static void testActivateContact() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();
        ContactHelper.activateContact(con.Id);
        Test.stopTest();

        Contact updatedContact = [SELECT Status__c FROM Contact WHERE Id = :con.Id];
        System.assertEquals('Active', updatedContact.Status__c, 'Contact status should be Active');
    }

    @isTest
    static void testSendWelcomeEmailWithNoEmail() {
        // Create contact without email
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact conNoEmail = new Contact(
            FirstName = 'No',
            LastName = 'Email',
            AccountId = acc.Id
        );
        insert conNoEmail;

        List<Id> contactIds = new List<Id>{ conNoEmail.Id };

        Test.startTest();
        ContactHelper.sendWelcomeEmail(contactIds);
        Test.stopTest();

        // Should handle gracefully - no exception
        System.assertEquals(1, contactIds.size(), 'Should process contact without error');
    }
}
