/**
 * @description Utilitaires pour hotfix - classe de test
 * @date 2026-01-07
 * @ticket PROD-99999
 */
public with sharing class HotfixUtils {

    /**
     * @description Retourne la version actuelle du hotfix
     * @return String Version du hotfix
     */
    public static String getHotfixVersion() {
        return 'v1.0.0-hotfix-3';
    }

    /**
     * @description Vérifie si une chaîne est valide
     * @param input Chaîne à vérifier
     * @return Boolean true si valide
     */
    public static Boolean isValid(String input) {
        return String.isNotBlank(input);
    }
}
