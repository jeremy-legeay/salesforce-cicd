@isTest
private class SmokeTestClass {

    /**
     * Smoke test - basic sanity check
     * This test is always run on INTEGRATION environment
     */
    @isTest
    static void smokeTest() {
        // Basic smoke test - just verify the org is working
        System.assert(true, 'Smoke test passed');

        // Test that we can query standard objects
        Integer accountCount = [SELECT COUNT() FROM Account LIMIT 1];
        System.assert(accountCount >= 0, 'Should be able to query Account');
    }
}
