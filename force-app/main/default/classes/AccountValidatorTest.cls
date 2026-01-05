/**
 * @description Tests pour AccountValidator
 * @date 2026-01-05
 */
@isTest
private class AccountValidatorTest {

    @isTest
    static void testValidateAccountName_Success() {
        // Test avec un nom valide qui n'existe pas
        Test.startTest();
        Boolean result = AccountValidator.validateAccountName('Nouveau Compte Test');
        Test.stopTest();

        System.assertEquals(true, result, 'Un nom valide doit retourner true');
    }

    @isTest
    static void testValidateAccountName_EmptyString() {
        Test.startTest();
        try {
            AccountValidator.validateAccountName('');
            System.assert(false, 'Une exception aurait dû être levée pour un nom vide');
        } catch (AccountValidator.AccountException e) {
            System.assert(e.getMessage().contains('ne peut pas être vide'),
                'Le message doit indiquer que le nom ne peut pas être vide');
        }
        Test.stopTest();
    }

    @isTest
    static void testValidateAccountName_Null() {
        Test.startTest();
        try {
            AccountValidator.validateAccountName(null);
            System.assert(false, 'Une exception aurait dû être levée pour null');
        } catch (AccountValidator.AccountException e) {
            System.assert(e.getMessage().contains('ne peut pas être vide'),
                'Le message doit indiquer que le nom ne peut pas être vide');
        }
        Test.stopTest();
    }

    @isTest
    static void testValidateAccountName_TooShort() {
        Test.startTest();
        try {
            AccountValidator.validateAccountName('A');
            System.assert(false, 'Une exception aurait dû être levée pour un nom trop court');
        } catch (AccountValidator.AccountException e) {
            System.assert(e.getMessage().contains('au moins 2 caractères'),
                'Le message doit indiquer la longueur minimale');
        }
        Test.stopTest();
    }

    @isTest
    static void testValidateAccountName_DuplicateName() {
        // Créer un compte existant
        Account existingAccount = new Account(Name = 'Compte Existant');
        insert existingAccount;

        Test.startTest();
        try {
            AccountValidator.validateAccountName('Compte Existant');
            System.assert(false, 'Une exception aurait dû être levée pour un nom en double');
        } catch (AccountValidator.AccountException e) {
            System.assert(e.getMessage().contains('existe déjà'),
                'Le message doit indiquer que le compte existe déjà');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetAccountSafely_Success() {
        Account testAccount = new Account(
            Name = 'Test Account',
            Type = 'Customer',
            Industry = 'Technology'
        );
        insert testAccount;

        Test.startTest();
        Account result = AccountValidator.getAccountSafely(testAccount.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Le compte doit être trouvé');
        System.assertEquals(testAccount.Id, result.Id, 'Les IDs doivent correspondre');
        System.assertEquals('Test Account', result.Name, 'Le nom doit correspondre');
    }

    @isTest
    static void testGetAccountSafely_NullId() {
        Test.startTest();
        try {
            AccountValidator.getAccountSafely(null);
            System.assert(false, 'Une exception aurait dû être levée pour un ID null');
        } catch (AccountValidator.AccountException e) {
            System.assert(e.getMessage().contains('cannot be null'),
                'Le message doit indiquer que l\'ID ne peut pas être null');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetAccountSafely_NotFound() {
        // Créer un ID fictif qui n'existe pas
        Id fakeId = '001000000000000AAA';

        Test.startTest();
        try {
            AccountValidator.getAccountSafely(fakeId);
            System.assert(false, 'Une exception aurait dû être levée pour un compte introuvable');
        } catch (AccountValidator.AccountException e) {
            System.assert(e.getMessage().contains('not found'),
                'Le message doit indiquer que le compte n\'a pas été trouvé');
        }
        Test.stopTest();
    }
}
