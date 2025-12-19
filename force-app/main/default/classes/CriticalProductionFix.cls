/**
 * @description Hotfix pour corriger un bug critique en production
 * @date 2025-12-19
 * @ticket PROD-12345
 */
public with sharing class CriticalProductionFix {

    /**
     * @description Correction du bug de calcul de prix qui causait des erreurs
     * @param productId ID du produit
     * @return Decimal Prix corrigé
     */
    public static Decimal calculateCorrectPrice(Id productId) {
        // AVANT (bug) : La division par zéro n'était pas gérée
        // APRÈS (fix) : Validation ajoutée pour éviter division par zéro

        Product2 product = [SELECT Id, Quantity__c, TotalPrice__c
                           FROM Product2
                           WHERE Id = :productId
                           LIMIT 1];

        // FIX CRITIQUE : Vérifier que la quantité n'est pas nulle
        if (product.Quantity__c == null || product.Quantity__c == 0) {
            throw new ProductException('Quantité invalide pour le produit ' + productId);
        }

        // Calcul sécurisé du prix unitaire
        Decimal unitPrice = product.TotalPrice__c / product.Quantity__c;

        return unitPrice;
    }

    /**
     * @description Exception personnalisée pour les erreurs produit
     */
    public class ProductException extends Exception {}
}
