# 💻 Guide de Développement sur DEV

## Vue d'ensemble

L'environnement **DEV** est votre sandbox de développement personnel. Contrairement aux autres environnements (INTEGRATION, UAT, PRODUCTION), DEV n'utilise **PAS** le pipeline CI/CD automatisé.

### Pourquoi ?

- **Développement rapide** : Push/pull instantané via VS Code
- **Tests personnels** : Chaque développeur travaille dans son propre espace
- **Itérations rapides** : Pas d'attente de validation ou de tests automatiques
- **Flexibilité** : Liberté totale pour expérimenter

Le pipeline CI/CD démarre uniquement à partir de la branche **`integration`**.

---

## 🛠️ Configuration de VS Code

### 1. Extensions requises

Installez **Salesforce Extension Pack** :
- Ouvrez VS Code
- Allez dans Extensions (Ctrl+Shift+X)
- Cherchez "Salesforce Extension Pack"
- Cliquez sur "Install"

Extensions incluses :
- Salesforce CLI Integration
- Apex
- Lightning Web Components
- Visualforce
- Aura Components

### 2. Authentification à votre sandbox DEV

```bash
# Dans le terminal VS Code
sf org login web --alias dev-sandbox --instance-url https://test.salesforce.com

# Définir comme org par défaut
sf config set target-org dev-sandbox
```

### 3. Vérifier la connexion

```bash
sf org display --target-org dev-sandbox
```

---

## 📝 Workflow quotidien sur DEV

### Scénario 1 : Créer une nouvelle classe Apex

1. **Créer le fichier localement**
   ```bash
   # Ouvrez la palette de commandes (Ctrl+Shift+P)
   # Tapez : "SFDX: Create Apex Class"
   # Nommez votre classe : MyNewClass
   ```

2. **Développer votre code**
   ```apex
   public class MyNewClass {
       public static String sayHello() {
           return 'Hello World!';
       }
   }
   ```

3. **Déployer vers la sandbox DEV**
   - Clic droit sur le fichier → "SFDX: Deploy Source to Org"
   - Ou utilisez Ctrl+Shift+P → "SFDX: Deploy This Source to Org"

4. **Tester dans l'org**
   ```bash
   sf apex run --target-org dev-sandbox --file scripts/test.apex
   ```

5. **Commiter dans Git**
   ```bash
   git add force-app/main/default/classes/MyNewClass.cls
   git add force-app/main/default/classes/MyNewClass.cls-meta.xml
   git commit -m "feat: add MyNewClass"
   git push origin develop
   ```

### Scénario 2 : Modifier un composant existant

1. **Récupérer la dernière version depuis l'org**
   ```bash
   # Clic droit sur le fichier/dossier
   # → "SFDX: Retrieve Source from Org"
   ```

2. **Modifier localement**

3. **Déployer les modifications**
   - Clic droit → "SFDX: Deploy Source to Org"

4. **Commiter**
   ```bash
   git add .
   git commit -m "fix: update email validation"
   git push origin develop
   ```

### Scénario 3 : Récupérer des changements faits directement dans l'org

Parfois vous faites des modifications directement dans l'interface Salesforce :

```bash
# Récupérer tout
sf project retrieve start --target-org dev-sandbox --manifest manifest/package.xml

# Ou récupérer un élément spécifique
sf project retrieve start --target-org dev-sandbox --metadata ApexClass:MyClass
```

---

## 🧪 Tests locaux

### Exécuter les tests Apex

```bash
# Tous les tests
sf apex run test --target-org dev-sandbox --test-level RunLocalTests

# Une classe spécifique
sf apex run test --target-org dev-sandbox --tests MyTestClass

# Avec couverture de code
sf apex run test --target-org dev-sandbox --tests MyTestClass --code-coverage
```

### Exécuter du code anonyme

```bash
# Créer un fichier scripts/test.apex
System.debug('Hello from anonymous apex');

# Exécuter
sf apex run --target-org dev-sandbox --file scripts/test.apex
```

---

## 🔄 Synchronisation avec Git

### Workflow recommandé

```bash
# Chaque matin
git checkout develop
git pull origin develop

# Pendant la journée
# ... développement via VS Code ...
# ... deploy vers la sandbox DEV ...

# En fin de journée
git add .
git commit -m "feat: description des changements"
git push origin develop

# Avant de partir
sf project retrieve start --target-org dev-sandbox --manifest manifest/package.xml
git status  # Vérifier qu'il n'y a pas de changements oubliés
```

### Conflits de synchronisation

Si quelqu'un a fait des modifications directement dans la sandbox :

```bash
# Récupérer les changements de l'org
sf project retrieve start --target-org dev-sandbox --manifest manifest/package.xml

# Vérifier les différences
git diff

# Résoudre manuellement si nécessaire
# Puis commiter
git add .
git commit -m "sync: merge changes from sandbox"
git push origin develop
```

---

## 📦 Commandes utiles VS Code

### Palette de commandes (Ctrl+Shift+P)

- **SFDX: Create Apex Class** - Créer une classe
- **SFDX: Create Apex Trigger** - Créer un trigger
- **SFDX: Create Lightning Web Component** - Créer un LWC
- **SFDX: Deploy Source to Org** - Déployer vers l'org
- **SFDX: Retrieve Source from Org** - Récupérer depuis l'org
- **SFDX: Execute Anonymous Apex** - Exécuter du code anonyme
- **SFDX: Run Apex Tests** - Lancer les tests

### Raccourcis clavier

- **Ctrl+Shift+P** : Ouvrir la palette de commandes
- **Clic droit sur fichier** : Menu contextuel Salesforce
- **Ctrl+`** : Ouvrir le terminal

---

## 🚀 Promotion vers INTEGRATION

Une fois votre développement terminé et testé sur DEV :

1. **Vérifier que tout est commité**
   ```bash
   git status
   # Doit être "clean"
   ```

2. **Merger vers integration**
   ```bash
   git checkout integration
   git pull origin integration
   git merge develop
   git push origin integration
   ```

3. **Le pipeline CI/CD démarre automatiquement**
   - Validation automatique
   - Tests Apex
   - Approbation manuelle requise (1 reviewer)
   - Déploiement vers INTEGRATION

4. **Vérifier le déploiement**
   - Allez dans GitHub Actions
   - Vérifiez que le workflow réussit
   - Approuvez le déploiement

---

## ⚠️ Bonnes pratiques

### À FAIRE ✅

- **Commiter régulièrement** (plusieurs fois par jour)
- **Tester localement** avant de commiter
- **Synchroniser avec Git** matin et soir
- **Utiliser des messages de commit clairs**
- **Récupérer les changements** de l'org avant de pousser

### À ÉVITER ❌

- **Ne pas faire de modifications directement dans l'org** sans les récupérer
- **Ne pas oublier de commiter** avant de partir
- **Ne pas pousser du code non testé** vers integration
- **Ne pas travailler sur plusieurs fonctionnalités** en même temps
- **Ne pas garder des changements non committés** pendant plusieurs jours

---

## 🆘 Dépannage

### "Org not found" ou erreur d'authentification

```bash
# Re-authentifiez-vous
sf org logout --target-org dev-sandbox
sf org login web --alias dev-sandbox --instance-url https://test.salesforce.com
sf config set target-org dev-sandbox
```

### "Source is out of sync"

```bash
# Récupérez la dernière version
sf project retrieve start --target-org dev-sandbox --manifest manifest/package.xml

# Vérifiez les différences
git status
git diff

# Résolvez les conflits et committez
```

### Déploiement échoue

```bash
# Voir les détails de l'erreur
sf project deploy report --target-org dev-sandbox

# Vérifier les dépendances
# Vérifier les tests
# Corriger et re-déployer
```

### LWC ne se met pas à jour

```bash
# Nettoyer le cache
# Dans VS Code : Ctrl+Shift+P
# Tapez : "Developer: Reload Window"

# Ou forcez le redéploiement
sf project deploy start --target-org dev-sandbox --source-dir force-app/main/default/lwc/myComponent --ignore-conflicts
```

---

## 📚 Ressources

### Documentation officielle
- [Salesforce Extensions for VS Code](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/)

### Aide-mémoire
- [Commandes Salesforce CLI](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_unified.htm)
- [VS Code Keyboard Shortcuts](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-windows.pdf)

---

## 🎓 Formation

Pour les nouveaux développeurs :

1. **Jour 1** : Installation de VS Code + Extensions
2. **Jour 2** : Authentification + Premier deploy/retrieve
3. **Jour 3** : Créer et déployer une classe Apex
4. **Jour 4** : Créer et déployer un LWC
5. **Semaine 2** : Workflow complet DEV → INTEGRATION

---

**Questions ?** Consultez [README.md](README.md) ou demandez à l'équipe DevOps.
