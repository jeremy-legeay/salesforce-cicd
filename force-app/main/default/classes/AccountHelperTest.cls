@isTest
private class AccountHelperTest {

    @TestSetup
    static void setupTestData() {
        // Create test accounts
        List<Account> testAccounts = new List<Account>();

        testAccounts.add(new Account(
            Name = 'Test Account Hot',
            AnnualRevenue = 1500000,
            Industry = 'Technology'
        ));

        testAccounts.add(new Account(
            Name = 'Test Account Warm',
            AnnualRevenue = 500000,
            Industry = 'Finance'
        ));

        testAccounts.add(new Account(
            Name = 'Test Account Cold',
            AnnualRevenue = 50000,
            Industry = 'Retail'
        ));

        insert testAccounts;
    }

    @isTest
    static void testGetActiveAccounts() {
        Test.startTest();
        List<Account> accounts = AccountHelper.getActiveAccounts();
        Test.stopTest();

        System.assertNotEquals(null, accounts, 'Accounts list should not be null');
        System.assert(accounts.size() >= 0, 'Should return a list of accounts');
    }

    @isTest
    static void testUpdateAccountRatingHot() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account Hot' LIMIT 1];

        Test.startTest();
        AccountHelper.updateAccountRating(acc.Id, 1500000);
        Test.stopTest();

        Account updatedAcc = [SELECT Rating FROM Account WHERE Id = :acc.Id];
        System.assertEquals('Hot', updatedAcc.Rating, 'Rating should be Hot for revenue >= 1000000');
    }

    @isTest
    static void testUpdateAccountRatingWarm() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account Warm' LIMIT 1];

        Test.startTest();
        AccountHelper.updateAccountRating(acc.Id, 500000);
        Test.stopTest();

        Account updatedAcc = [SELECT Rating FROM Account WHERE Id = :acc.Id];
        System.assertEquals('Warm', updatedAcc.Rating, 'Rating should be Warm for revenue >= 100000');
    }

    @isTest
    static void testUpdateAccountRatingCold() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account Cold' LIMIT 1];

        Test.startTest();
        AccountHelper.updateAccountRating(acc.Id, 50000);
        Test.stopTest();

        Account updatedAcc = [SELECT Rating FROM Account WHERE Id = :acc.Id];
        System.assertEquals('Cold', updatedAcc.Rating, 'Rating should be Cold for revenue < 100000');
    }
}
