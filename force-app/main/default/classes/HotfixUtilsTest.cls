/**
 * @description Tests pour HotfixUtils
 * @date 2026-01-07
 */
@isTest
private class HotfixUtilsTest {

    @isTest
    static void testGetHotfixVersion() {
        Test.startTest();
        String version = HotfixUtils.getHotfixVersion();
        Test.stopTest();

        System.assertNotEquals(null, version, 'La version ne doit pas être nulle');
        System.assert(version.contains('hotfix'), 'La version doit contenir "hotfix"');
    }

    @isTest
    static void testIsValid_ValidString() {
        Test.startTest();
        Boolean result = HotfixUtils.isValid('Test');
        Test.stopTest();

        System.assertEquals(true, result, 'Une chaîne valide doit retourner true');
    }

    @isTest
    static void testIsValid_EmptyString() {
        Test.startTest();
        Boolean result = HotfixUtils.isValid('');
        Test.stopTest();

        System.assertEquals(false, result, 'Une chaîne vide doit retourner false');
    }

    @isTest
    static void testIsValid_NullString() {
        Test.startTest();
        Boolean result = HotfixUtils.isValid(null);
        Test.stopTest();

        System.assertEquals(false, result, 'Une chaîne null doit retourner false');
    }
}
