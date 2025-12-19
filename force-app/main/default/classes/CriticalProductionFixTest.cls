/**
 * @description Tests pour CriticalProductionFix
 */
@isTest
private class CriticalProductionFixTest {

    @isTest
    static void testCalculateCorrectPrice_Success() {
        // Setup
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            Quantity__c = 10,
            TotalPrice__c = 100
        );
        insert testProduct;

        // Test
        Test.startTest();
        Decimal unitPrice = CriticalProductionFix.calculateCorrectPrice(testProduct.Id);
        Test.stopTest();

        // Verify
        System.assertEquals(10, unitPrice, 'Le prix unitaire doit être 10');
    }

    @isTest
    static void testCalculateCorrectPrice_NullQuantity() {
        // Setup
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            Quantity__c = null,
            TotalPrice__c = 100
        );
        insert testProduct;

        // Test & Verify
        Test.startTest();
        try {
            CriticalProductionFix.calculateCorrectPrice(testProduct.Id);
            System.assert(false, 'Une exception aurait dû être levée');
        } catch (CriticalProductionFix.ProductException e) {
            System.assert(e.getMessage().contains('Quantité invalide'),
                         'Le message d\'erreur doit mentionner la quantité invalide');
        }
        Test.stopTest();
    }

    @isTest
    static void testCalculateCorrectPrice_ZeroQuantity() {
        // Setup
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            Quantity__c = 0,
            TotalPrice__c = 100
        );
        insert testProduct;

        // Test & Verify
        Test.startTest();
        try {
            CriticalProductionFix.calculateCorrectPrice(testProduct.Id);
            System.assert(false, 'Une exception aurait dû être levée');
        } catch (CriticalProductionFix.ProductException e) {
            System.assert(e.getMessage().contains('Quantité invalide'),
                         'Le message d\'erreur doit mentionner la quantité invalide');
        }
        Test.stopTest();
    }
}
