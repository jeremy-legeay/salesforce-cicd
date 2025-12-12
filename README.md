# 🚀 CI/CD Salesforce avec GitHub Actions

Pipeline complet de CI/CD pour déployer automatiquement sur Salesforce avec 4 environnements et validation manuelle.

## 📋 Table des matières

- [Architecture](#architecture)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Configuration](#configuration)
- [Utilisation](#utilisation)
- [Workflow de déploiement](#workflow-de-déploiement)
- [Commandes utiles](#commandes-utiles)
- [Dépannage](#dépannage)

## 🏗️ Architecture

### Environnements

| Environnement | Branche | Org Salesforce | Validation manuelle | Reviewers | Notes |
|--------------|---------|----------------|-------------------|-----------|-------|
| **DEV** | `develop` | Dev Sandbox | N/A | N/A | Développement direct via VS Code (pas de CI/CD) |
| **INTEGRATION** | `integration` | Integration Sandbox | ✅ Oui | 1 | Premier environnement du pipeline CI/CD |
| **UAT** | `uat` | UAT Sandbox | ✅ Oui | 2 | Tests utilisateurs |
| **PRODUCTION** | `main` | Production | ✅ Oui + Timer | 2+ | Production |

### Pipeline CI/CD

```
┌─────────────────┐
│  Push/PR        │
│  (integration+) │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Validate       │
│  - Apex Tests   │
│  - Check Only   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Manual         │
│  Approval       │
│  (required)     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Deploy         │
│  - Full Deploy  │
│  - Run Tests    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Verify         │
│  - Smoke Tests  │
└─────────────────┘

Note: Le pipeline CI/CD démarre à partir de 'integration'.
DEV = développement direct via VS Code (sans CI/CD).
```

## 📦 Prérequis

### Outils nécessaires

- **Git** >= 2.30
- **Salesforce CLI** >= 2.0.0
- **Node.js** >= 18.x
- Compte **GitHub** avec droits admin sur le repository
- Accès aux **4 orgs Salesforce** :
  - Dev Sandbox
  - Integration Sandbox
  - UAT Sandbox
  - Production

### Connaissances requises

- Bases de Git et GitHub
- Salesforce Development (Apex, LWC, Metadata API)
- GitHub Actions (recommandé)

## 🛠️ Installation

### 1. Cloner le repository

```bash
git clone https://github.com/votre-org/salesforce-cicd.git
cd salesforce-cicd
```

### 2. Installer Salesforce CLI

```bash
# macOS
brew install sf

# Windows
npm install -g @salesforce/cli

# Linux
npm install -g @salesforce/cli
```

### 3. Vérifier l'installation

```bash
sf --version
# Devrait afficher: @salesforce/cli/2.x.x
```

## ⚙️ Configuration

### 1. Structure du projet

Assurez-vous d'avoir cette structure :

```
salesforce-cicd/
├── .github/
│   └── workflows/
│       └── salesforce-cicd.yml    # Pipeline principal
├── force-app/                      # Code source Salesforce
│   └── main/
│       └── default/
│           ├── classes/
│           ├── lwc/
│           ├── triggers/
│           └── ...
├── manifest/
│   ├── package.xml                 # Définition des métadonnées
│   └── destructiveChanges.xml      # Suppressions (optionnel)
├── scripts/
│   └── deploy.sh                   # Script de déploiement manuel
├── sfdx-project.json               # Configuration SFDX
├── .forceignore                    # Fichiers à ignorer
└── README.md
```

### 2. Configurer les environnements GitHub

Suivez le guide détaillé dans [ENVIRONMENTS_SETUP.md](./ENVIRONMENTS_SETUP.md)

Résumé :
1. Créer 4 environnements : `DEV`, `INTEGRATION`, `UAT`, `PRODUCTION`
2. Configurer les reviewers et protections
3. Ajouter les secrets `SFDX_AUTH_URL_{ENV}` pour chaque environnement

### 3. Générer les Auth URLs

Pour chaque org Salesforce :

```bash
# 1. Authentification
sf org login web --alias dev-sandbox --instance-url https://test.salesforce.com

# 2. Afficher l'Auth URL
sf org display --target-org dev-sandbox --verbose

# 3. Copier la valeur "Sfdx Auth Url"
# Format: force://PlatformCLI::xxxxxxxxxxxxx@xxxxx.my.salesforce.com
```

### 4. Ajouter les secrets dans GitHub

1. Allez dans **Settings > Secrets and variables > Actions**
2. Sélectionnez l'environnement (ex: DEV)
3. Cliquez sur **New environment secret**
4. Nom: `SFDX_AUTH_URL_DEV`
5. Valeur: l'Auth URL copiée
6. Répétez pour les 4 environnements

### 5. Protéger les branches

Dans **Settings > Branches**, créez des règles pour :

- `main` : 2 reviewers, status checks required
- `uat` : 2 reviewers, status checks required
- `integration` : 1 reviewer, status checks required
- `develop` : 1 reviewer

## 🚀 Utilisation

### Workflow standard

#### 1. Développement local (DEV)

L'environnement DEV est utilisé pour le développement quotidien :

```bash
# Travailler directement avec votre sandbox DEV via VS Code
# Utiliser Salesforce Extension Pack

# Récupérer depuis l'org
sf project retrieve start --target-org dev-sandbox

# Développer localement...

# Pousser vers l'org
sf project deploy start --target-org dev-sandbox

# Commiter dans Git
git add .
git commit -m "feat: nouvelle fonctionnalité"
git push origin develop
```

**Important** : L'environnement DEV n'est **pas** dans le pipeline CI/CD. Les développeurs travaillent directement avec leur sandbox via VS Code.

#### 2. Promotion vers INTEGRATION (début du CI/CD)

```bash
git checkout develop
git pull
git checkout -b feature/nouvelle-fonctionnalite
```

#### 2. Promotion vers INTEGRATION (début du CI/CD)

Une fois le développement terminé sur DEV, promouvoir vers INTEGRATION :

```bash
git checkout develop
git pull

# Fusionner vers integration
git checkout integration
git pull
git merge develop
git push origin integration
```

- Le pipeline CI/CD se déclenche automatiquement
- Validation et tests sont exécutés
- **1 reviewer requis** pour approuver le déploiement
- Après approbation → Déploiement automatique sur INTEGRATION

#### 3. Promotion vers UAT

```bash
git checkout uat
git pull
git merge integration
git push origin uat
```

- **2 reviewers requis**
- Déploiement vers UAT après approbation

#### 4. Promotion vers PRODUCTION

```bash
git checkout main
git pull
git merge uat
git push origin main
```

- **2+ reviewers requis** + timer de 10 minutes
- Déploiement vers PRODUCTION après approbation

## 📝 Workflow de déploiement

### Développement quotidien (DEV)

- Développement direct via VS Code
- Push/Pull avec Salesforce Extension Pack
- Pas de pipeline CI/CD
- Tests locaux recommandés

### Déploiements contrôlés (INTEGRATION → UAT → PRODUCTION)

1. Push sur la branche cible
2. Pipeline lance la validation
3. **Approbation manuelle requise** dans GitHub Actions
4. Après approbation → Déploiement
5. Vérification post-déploiement

### Approuver un déploiement

1. Allez dans **Actions** sur GitHub
2. Sélectionnez le workflow en attente
3. Cliquez sur **Review deployments**
4. Sélectionnez l'environnement
5. Cliquez sur **Approve and deploy**

## 🔧 Commandes utiles

### Déploiement manuel avec script

```bash
# Rendre le script exécutable
chmod +x scripts/deploy.sh

# Validation
./scripts/deploy.sh dev validate
./scripts/deploy.sh production validate

# Déploiement
./scripts/deploy.sh dev deploy
./scripts/deploy.sh production deploy
```

### Commandes Salesforce CLI

```bash
# Lister les orgs authentifiées
sf org list

# Se connecter à une org
sf org login web --alias my-org

# Déployer des métadonnées
sf project deploy start --manifest manifest/package.xml --target-org my-org

# Récupérer des métadonnées
sf project retrieve start --manifest manifest/package.xml --target-org my-org

# Exécuter des tests
sf apex run test --target-org my-org --test-level RunLocalTests

# Voir les détails d'une org
sf org display --target-org my-org --verbose

# Quick deploy (après validation réussie)
sf project deploy quick --job-id 0Af... --target-org my-org
```

### Git utiles

```bash
# Voir les branches
git branch -a

# Synchroniser avec remote
git fetch --all
git pull

# Créer une release tag
git tag -a v1.0.0 -m "Release 1.0.0"
git push origin v1.0.0

# Annuler le dernier commit (local uniquement)
git reset --soft HEAD~1
```

## 🐛 Dépannage

### Erreur d'authentification

**Problème** : `ERROR running force:auth:sfdxurl:store: Invalid client credentials`

**Solution** :
1. Régénérez l'Auth URL : `sf org display --target-org my-org --verbose`
2. Mettez à jour le secret dans GitHub
3. Relancez le workflow

### Tests Apex échouent

**Problème** : Les tests passent localement mais échouent dans le pipeline

**Solution** :
1. Vérifiez que tous les tests sont déployés
2. Vérifiez les dépendances de données
3. Utilisez `@TestSetup` pour créer des données de test
4. Consultez les logs détaillés dans GitHub Actions

### Timeout de déploiement

**Problème** : `ERROR: The client has timed out`

**Solution** :
1. Augmentez le timeout dans le workflow : `--wait 60`
2. Vérifiez les validations asynchrones (validation rules, flows)
3. Déployez en plusieurs fois si le package est trop gros

### Destructive changes non appliquées

**Problème** : Les suppressions ne fonctionnent pas

**Solution** :
1. Vérifiez le format de `destructiveChanges.xml`
2. Assurez-vous d'utiliser `--post-destructive-changes`
3. Les suppressions nécessitent que les éléments ne soient plus référencés

### Conflit de merge

**Problème** : Conflit lors du merge entre branches

**Solution** :
```bash
git checkout uat
git merge integration
# Résoudre les conflits manuellement
git add .
git commit -m "chore: resolve merge conflicts"
git push origin uat
```

## 📚 Ressources

- [Salesforce CLI Documentation](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/)
- [Metadata API Guide](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/)

## 🤝 Contribution

1. Fork le projet
2. Créez votre feature branch (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'feat: Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

## 📄 Licence

Ce projet est sous licence MIT.

## ✉️ Support

Pour toute question ou problème, ouvrez une issue sur GitHub ou contactez l'équipe DevOps.

---

**Bonne chance avec vos déploiements Salesforce ! 🎉**
#   T e s t   C I / C D  
 