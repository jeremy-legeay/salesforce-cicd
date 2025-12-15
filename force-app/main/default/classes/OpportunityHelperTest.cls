@isTest
private class OpportunityHelperTest {

    @TestSetup
    static void setupTestData() {
        // Create test account
        Account testAccount = new Account(
            Name = 'Test Account',
            Industry = 'Technology'
        );
        insert testAccount;

        // Create test opportunities
        List<Opportunity> testOpps = new List<Opportunity>();

        testOpps.add(new Opportunity(
            Name = 'Test Opp 1',
            AccountId = testAccount.Id,
            Amount = 100000,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10)
        ));

        testOpps.add(new Opportunity(
            Name = 'Test Opp 2',
            AccountId = testAccount.Id,
            Amount = 50000,
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(15)
        ));

        testOpps.add(new Opportunity(
            Name = 'Test Opp Closed',
            AccountId = testAccount.Id,
            Amount = 75000,
            StageName = 'Closed Won',
            CloseDate = Date.today().addDays(-5)
        ));

        insert testOpps;
    }

    @isTest
    static void testGetOpenOpportunities() {
        Test.startTest();
        List<Opportunity> opps = OpportunityHelper.getOpenOpportunities();
        Test.stopTest();

        System.assertNotEquals(null, opps, 'Opportunities list should not be null');
        System.assert(opps.size() >= 2, 'Should return at least 2 open opportunities');
    }

    @isTest
    static void testCalculatePipelineValue() {
        Test.startTest();
        Decimal pipelineValue = OpportunityHelper.calculatePipelineValue();
        Test.stopTest();

        System.assertNotEquals(null, pipelineValue, 'Pipeline value should not be null');
        System.assert(pipelineValue >= 150000, 'Pipeline value should be at least 150000');
    }

    @isTest
    static void testUpdateStage() {
        Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE Name = 'Test Opp 1' LIMIT 1];

        Test.startTest();
        OpportunityHelper.updateStage(opp.Id, 'Proposal/Price Quote');
        Test.stopTest();

        Opportunity updatedOpp = [SELECT StageName FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('Proposal/Price Quote', updatedOpp.StageName, 'Stage should be updated');
    }

    @isTest
    static void testGetOpportunitiesClosingThisMonth() {
        // Update an opportunity to close this month
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opp 1' LIMIT 1];
        opp.CloseDate = Date.today().toStartOfMonth().addDays(10);
        update opp;

        Test.startTest();
        List<Opportunity> oppsThisMonth = OpportunityHelper.getOpportunitiesClosingThisMonth();
        Test.stopTest();

        System.assertNotEquals(null, oppsThisMonth, 'Opportunities list should not be null');
        System.assert(oppsThisMonth.size() >= 1, 'Should return at least 1 opportunity closing this month');
    }

    @isTest
    static void testCalculatePipelineValueWithNoOpportunities() {
        // Delete all opportunities
        delete [SELECT Id FROM Opportunity];

        Test.startTest();
        Decimal pipelineValue = OpportunityHelper.calculatePipelineValue();
        Test.stopTest();

        System.assertEquals(0, pipelineValue, 'Pipeline value should be 0 when no opportunities exist');
    }
}
