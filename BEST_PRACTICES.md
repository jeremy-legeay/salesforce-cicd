# 📖 Bonnes Pratiques CI/CD Salesforce

## 🎯 Principes généraux

### 1. **Un commit = Une fonctionnalité**
- Commit atomiques et cohérents
- Messages de commit clairs et descriptifs
- Suivre la convention : `type(scope): description`
  - `feat`: Nouvelle fonctionnalité
  - `fix`: Correction de bug
  - `refactor`: Refactoring sans changement de comportement
  - `test`: Ajout ou modification de tests
  - `docs`: Documentation
  - `chore`: Tâches de maintenance

### 2. **Tester avant de pusher**
Toujours tester localement avant de pousser :
```bash
# Déployer sur sandbox de dev
sf project deploy start --target-org dev-sandbox --manifest manifest/package.xml

# Exécuter les tests
sf apex run test --target-org dev-sandbox --test-level RunLocalTests

# Vérifier la couverture de code (>75% minimum)
```

### 3. **Pull Requests obligatoires**
- Jamais de push direct sur `integration`, `preprod` ou `main`
- Toujours passer par une Pull Request
- Code review systématique
- Tests automatiques passent avant merge

## 📝 Gestion des branches

### Nommage des branches

```
feature/XXX-description        # Nouvelle fonctionnalité
bugfix/XXX-description        # Correction de bug
hotfix/XXX-description        # Correction urgente en prod
refactor/XXX-description      # Refactoring
test/XXX-description          # Ajout/modification de tests
```

Exemples :
- `feature/JIRA-123-add-customer-validation`
- `bugfix/JIRA-456-fix-email-template`
- `hotfix/JIRA-789-critical-security-patch`

### Durée de vie des branches

- **Feature branches** : Maximum 3-5 jours
- **Branches longues** : Découper en plus petites fonctionnalités
- **Branches obsolètes** : Supprimer après merge

```bash
# Supprimer une branche locale
git branch -d feature/my-feature

# Supprimer une branche remote
git push origin --delete feature/my-feature
```

## 🧪 Tests Apex

### Couverture de code

- **Minimum requis** : 75% (Salesforce)
- **Objectif recommandé** : 85%+
- **Tests critiques** : 100% de couverture

### Bonnes pratiques de test

```apex
@isTest
public class MyClassTest {
    
    // ✅ GOOD : Utiliser @TestSetup pour les données communes
    @TestSetup
    static void setup() {
        // Créer les données de test une seule fois
        Account acc = new Account(Name = 'Test');
        insert acc;
    }
    
    // ✅ GOOD : Un test = Un scénario
    @isTest
    static void testSuccessfulOperation() {
        Test.startTest();
        // Votre logique
        Test.stopTest();
        
        // Assertions claires
        System.assertEquals(expected, actual, 'Clear message');
    }
    
    // ✅ GOOD : Tester les cas d'erreur
    @isTest
    static void testExceptionHandling() {
        Test.startTest();
        try {
            // Code qui devrait échouer
            System.assert(false, 'Should have thrown exception');
        } catch (Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }
    
    // ✅ GOOD : Tester les permissions
    @isTest
    static void testUserPermissions() {
        User testUser = createTestUser();
        System.runAs(testUser) {
            // Test avec l'utilisateur
        }
    }
}
```

### Ce qu'il faut éviter

```apex
// ❌ BAD : Test sans assertions
@isTest
static void testMethod() {
    MyClass.myMethod();
    // Pas d'assertion = test inutile
}

// ❌ BAD : Test avec données hardcodées
@isTest
static void testWithHardcodedId() {
    Account acc = [SELECT Id FROM Account WHERE Id = '001000000000AAA'];
    // Ne fonctionnera pas dans d'autres orgs
}

// ❌ BAD : Test sans Test.startTest()/stopTest()
@isTest
static void testAsync() {
    // Les méthodes async ne s'exécuteront pas correctement
    MyAsyncClass.futureMethod();
}

// ❌ BAD : Trop de logique dans un test
@isTest
static void testEverything() {
    // Test 1
    // Test 2
    // Test 3
    // Difficile à maintenir et débugger
}
```

## 📦 Gestion du package.xml

### Stratégies de déploiement

#### Option 1 : Tout déployer (*)
```xml
<types>
    <members>*</members>
    <n>ApexClass</n>
</types>
```
✅ Simple
❌ Peut déployer du code non souhaité

#### Option 2 : Déploiement sélectif
```xml
<types>
    <members>MyClass</members>
    <members>MyOtherClass</members>
    <n>ApexClass</n>
</types>
```
✅ Contrôle précis
❌ Maintenance manuelle

#### Option 3 : Par dossier (recommandé)
```xml
<types>
    <members>feature_set_1/*</members>
    <n>ApexClass</n>
</types>
```
✅ Équilibre entre contrôle et simplicité

### Ordre de déploiement

Certains métadonnées ont des dépendances :

1. **Custom Objects** et **Custom Fields**
2. **Record Types**
3. **Validation Rules**
4. **Workflow Rules** / **Process Builder**
5. **Flows**
6. **Apex Classes** (surtout celles sans dépendances)
7. **Apex Triggers**
8. **Lightning Components** (LWC, Aura)
9. **Profiles** et **Permission Sets** (en dernier)

## 🔐 Sécurité

### Données sensibles

**JAMAIS** commiter :
- Tokens / API Keys
- Mots de passe
- Auth URLs
- Informations personnelles (PII)
- Données de production

### Secrets dans GitHub

- Utiliser GitHub Secrets pour les credentials
- Renouveler les secrets régulièrement
- Limiter l'accès aux secrets (rôles)

### Audit des accès

```bash
# Voir qui a accès à l'org
sf org list

# Révoquer un accès
sf org logout --target-org alias-name
```

## 🚀 Déploiement en Production

### Checklist pré-déploiement

- [ ] Tous les tests passent (100%)
- [ ] Code review approuvée par 2+ personnes
- [ ] Documentation à jour
- [ ] Changelog mis à jour
- [ ] Plan de rollback préparé
- [ ] Validation réussie sur PREPROD
- [ ] Communication aux utilisateurs
- [ ] Fenêtre de maintenance planifiée
- [ ] Backup de la production effectué

### Procédure de déploiement

1. **Valider** d'abord (check-only deploy)
2. **Obtenir les approbations** nécessaires
3. **Planifier** une fenêtre de déploiement
4. **Communiquer** aux utilisateurs
5. **Déployer** en heures creuses si possible
6. **Vérifier** immédiatement après
7. **Monitorer** pendant 24h

### En cas de problème

#### Option 1 : Quick Fix
```bash
# Si le fix est rapide
git checkout -b hotfix/quick-fix
# Corriger le problème
git push origin hotfix/quick-fix
# Deploy via pipeline
```

#### Option 2 : Rollback
```bash
# Revenir à la version précédente
git revert <commit-hash>
git push origin main
# Re-déployer via pipeline
```

## 📊 Monitoring et alertes

### Métriques à surveiller

- **Couverture de code** : >75%
- **Temps de déploiement** : <15 minutes
- **Taux de succès** : >95%
- **Temps de build** : <5 minutes

### Logs à consulter

```bash
# Logs du dernier déploiement
sf project deploy report --job-id <jobId>

# Logs des tests
sf apex get test --test-run-id <testRunId>
```

## 🔄 Maintenance régulière

### Hebdomadaire
- Synchroniser integration avec les changements récents
- Nettoyer les branches obsolètes
- Vérifier les PRs en attente

### Mensuel
- Revoir les secrets et credentials
- Mettre à jour les dépendances (Salesforce CLI)
- Audit de sécurité des accès
- Revoir la couverture de code

### Trimestriel
- Évaluer les performances du pipeline
- Former l'équipe sur les nouvelles pratiques
- Mettre à jour la documentation
- Planifier les améliorations

## 📚 Resources

### Documentation officielle
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/)
- [GitHub Actions Best Practices](https://docs.github.com/en/actions/learn-github-actions/best-practices-for-github-actions)

### Outils recommandés
- **PMD** : Analyse statique de code
- **ESLint** : Linting pour LWC
- **Prettier** : Formatage de code
- **Husky** : Git hooks pour validation pré-commit

### Formation continue
- Salesforce Trailhead : "DevOps Basics"
- GitHub Learning Lab
- Participer aux Salesforce Developer Forums

## 💡 Tips et astuces

### Performance

```bash
# Déploiement parallèle (si possible)
sf project deploy start --manifest manifest/package.xml --target-org prod --async

# Utiliser Quick Deploy après validation
sf project deploy quick --job-id 0Af...
```

### Debugging

```bash
# Logs détaillés
sf project deploy start --manifest manifest/package.xml --verbose

# Tester un composant spécifique
sf apex run test --tests MyTestClass --target-org dev-sandbox
```

### Automatisation

```bash
# Script pour synchroniser les environnements
# Note : Utiliser les PRs et workflows GitHub Actions pour les déploiements réels

# Synchroniser integration avec main après un déploiement PRODUCTION
git checkout integration
git pull origin main
git push origin integration
```

## 🎓 Formation de l'équipe

### Onboarding des nouveaux développeurs

1. **Jour 1** : Setup environnement local
2. **Semaine 1** : Comprendre l'architecture et le workflow
3. **Semaine 2** : Premier déploiement en DEV
4. **Mois 1** : Autonomie sur les feature branches

### Knowledge sharing

- **Revues de code** : Apprendre des autres
- **Pair programming** : Partager les connaissances
- **Documentation** : Maintenir à jour
- **Post-mortems** : Apprendre des incidents

---

**N'oubliez pas : Un bon CI/CD, c'est 80% de process et 20% de technologie !**
