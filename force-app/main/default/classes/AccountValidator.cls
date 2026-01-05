/**
 * @description Hotfix pour valider les comptes avant création
 * @date 2026-01-05
 * @ticket PROD-54321
 */
public with sharing class AccountValidator {

    /**
     * @description Valide qu'un nom de compte est acceptable
     * FIX: Ajout de validation pour éviter les doublons et les noms invalides
     * @param accountName Le nom du compte à valider
     * @return Boolean true si valide
     * @throws AccountException si le nom est invalide
     */
    public static Boolean validateAccountName(String accountName) {
        // FIX CRITIQUE: Vérifier que le nom n'est pas vide
        if (String.isBlank(accountName)) {
            throw new AccountException('Le nom du compte ne peut pas être vide');
        }

        // FIX: Vérifier la longueur minimale
        if (accountName.trim().length() < 2) {
            throw new AccountException('Le nom du compte doit contenir au moins 2 caractères');
        }

        // FIX: Vérifier qu'il n'existe pas déjà un compte avec ce nom
        Integer existingCount = [SELECT COUNT()
                                FROM Account
                                WHERE Name = :accountName.trim()];

        if (existingCount > 0) {
            throw new AccountException('Un compte avec ce nom existe déjà');
        }

        return true;
    }

    /**
     * @description Récupère un compte de manière sécurisée
     * @param accountId ID du compte
     * @return Account Le compte trouvé
     */
    public static Account getAccountSafely(Id accountId) {
        if (accountId == null) {
            throw new AccountException('Account ID cannot be null');
        }

        List<Account> accounts = [SELECT Id, Name, Type, Industry
                                  FROM Account
                                  WHERE Id = :accountId
                                  LIMIT 1];

        if (accounts.isEmpty()) {
            throw new AccountException('Account not found: ' + accountId);
        }

        return accounts[0];
    }

    /**
     * @description Exception personnalisée pour les erreurs de compte
     */
    public class AccountException extends Exception {}
}
