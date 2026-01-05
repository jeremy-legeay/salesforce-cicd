/**
 * @description Hotfix pour corriger un bug critique en production
 * @date 2025-12-19
 * @ticket PROD-12345
 */
public with sharing class CriticalProductionFix {

    /**
     * @description Validation du nom de produit avec gestion des cas edge
     * AVANT (bug) : Acceptait des noms vides ou null, causant des erreurs
     * APRÈS (fix) : Validation stricte ajoutée
     * @param productName Nom du produit à valider
     * @return Boolean true si valide, sinon exception
     */
    public static Boolean validateProductName(String productName) {
        // FIX CRITIQUE : Vérifier que le nom n'est pas vide ou null
        if (String.isBlank(productName)) {
            throw new ProductException('Le nom du produit ne peut pas être vide');
        }

        // FIX : Vérifier la longueur minimale (évite les noms trop courts)
        if (productName.trim().length() < 3) {
            throw new ProductException('Le nom du produit doit contenir au moins 3 caractères');
        }

        // FIX : Vérifier les caractères spéciaux dangereux
        if (productName.contains('<') || productName.contains('>')) {
            throw new ProductException('Le nom du produit contient des caractères invalides');
        }

        return true;
    }

    /**
     * @description Récupère un produit de manière sécurisée
     * @param productId ID du produit
     * @return Product2 Le produit trouvé
     */
    public static Product2 getProductSafely(Id productId) {
        if (productId == null) {
            throw new ProductException('Product ID cannot be null');
        }

        List<Product2> products = [SELECT Id, Name, IsActive, ProductCode
                                   FROM Product2
                                   WHERE Id = :productId
                                   LIMIT 1];

        if (products.isEmpty()) {
            throw new ProductException('Product not found: ' + productId);
        }

        return products[0];
    }

    /**
     * @description Exception personnalisée pour les erreurs produit
     */
    public class ProductException extends Exception {}
}
