/**
 * @description Tests pour CriticalProductionFix
 * @date 2025-12-19
 */
@isTest
private class CriticalProductionFixTest {

    @isTest
    static void testValidateProductName_Success() {
        Test.startTest();
        Boolean result = CriticalProductionFix.validateProductName('Valid Product Name');
        Test.stopTest();

        System.assertEquals(true, result, 'Un nom valide doit retourner true');
    }

    @isTest
    static void testValidateProductName_EmptyString() {
        Test.startTest();
        try {
            CriticalProductionFix.validateProductName('');
            System.assert(false, 'Une exception aurait dû être levée pour un nom vide');
        } catch (CriticalProductionFix.ProductException e) {
            System.assert(e.getMessage().contains('ne peut pas être vide'),
                'Le message doit indiquer que le nom ne peut pas être vide');
        }
        Test.stopTest();
    }

    @isTest
    static void testValidateProductName_Null() {
        Test.startTest();
        try {
            CriticalProductionFix.validateProductName(null);
            System.assert(false, 'Une exception aurait dû être levée pour null');
        } catch (CriticalProductionFix.ProductException e) {
            System.assert(e.getMessage().contains('ne peut pas être vide'),
                'Le message doit indiquer que le nom ne peut pas être vide');
        }
        Test.stopTest();
    }

    @isTest
    static void testValidateProductName_TooShort() {
        Test.startTest();
        try {
            CriticalProductionFix.validateProductName('AB');
            System.assert(false, 'Une exception aurait dû être levée pour un nom trop court');
        } catch (CriticalProductionFix.ProductException e) {
            System.assert(e.getMessage().contains('au moins 3 caractères'),
                'Le message doit indiquer la longueur minimale');
        }
        Test.stopTest();
    }

    @isTest
    static void testValidateProductName_InvalidCharacters() {
        Test.startTest();
        try {
            CriticalProductionFix.validateProductName('Product<script>alert(1)</script>');
            System.assert(false, 'Une exception aurait dû être levée pour des caractères invalides');
        } catch (CriticalProductionFix.ProductException e) {
            System.assert(e.getMessage().contains('caractères invalides'),
                'Le message doit indiquer les caractères invalides');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetProductSafely_Success() {
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            IsActive = true
        );
        insert testProduct;

        Test.startTest();
        Product2 result = CriticalProductionFix.getProductSafely(testProduct.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Le produit doit être trouvé');
        System.assertEquals(testProduct.Id, result.Id, 'Les IDs doivent correspondre');
    }

    @isTest
    static void testGetProductSafely_NullId() {
        Test.startTest();
        try {
            CriticalProductionFix.getProductSafely(null);
            System.assert(false, 'Une exception aurait dû être levée pour un ID null');
        } catch (CriticalProductionFix.ProductException e) {
            System.assert(e.getMessage().contains('cannot be null'),
                'Le message doit indiquer que l\'ID ne peut pas être null');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetProductSafely_NotFound() {
        // Créer un ID fictif qui n'existe pas
        Id fakeId = '01t000000000000AAA';

        Test.startTest();
        try {
            CriticalProductionFix.getProductSafely(fakeId);
            System.assert(false, 'Une exception aurait dû être levée pour un produit introuvable');
        } catch (CriticalProductionFix.ProductException e) {
            System.assert(e.getMessage().contains('not found'),
                'Le message doit indiquer que le produit n\'a pas été trouvé');
        }
        Test.stopTest();
    }
}
