# 🚀 CI/CD Salesforce avec GitHub Actions

Pipeline complet de CI/CD pour déployer sur Salesforce avec un système de release basé sur les labels GitHub.

## 📋 Table des matières

- [Architecture](#architecture)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Configuration](#configuration)
- [Processus de Release](#processus-de-release)
- [Commandes Utiles](#commandes-utiles)
- [Dépannage](#dépannage)
- [Documentation](#documentation)

## 🏗️ Architecture

### Environnements

Le système est configuré avec **3 environnements obligatoires** :

| Environnement | Branche | Org Salesforce | Déploiement | Reviewers |
|--------------|---------|----------------|-------------|-----------|
| **INTEGRATION** | `integration` | Integration Sandbox | Automatique sur PR/Push | 1 |
| **PREPROD** | Release branches | Pré-production Sandbox | Manuel via Actions | 2 |
| **PRODUCTION** | `main` | Production | Manuel via Actions | 2+ |

**Note importante** : PREPROD n'a **pas de branche dédiée**. Les déploiements PREPROD se font manuellement via le workflow [`Deploy Release to Environment`](.github/workflows/deploy-release.yml) en utilisant des **release branches** (`release/vX.Y.Z`). Cela garantit que le **même package** exact est déployé sur PREPROD puis PRODUCTION.

**Besoin d'environnements supplémentaires ?** (QA, STAGING, etc.)
Consultez le guide [AJOUT_ENVIRONNEMENT.md](AJOUT_ENVIRONNEMENT.md) pour ajouter facilement des environnements intermédiaires entre INTEGRATION et PREPROD.

### Pipeline CI/CD

```
┌─────────────────────────────┐
│  Développement quotidien    │
│  feature/* → integration    │
└──────────┬──────────────────┘
           │ (automatique)
           ▼
┌─────────────────────────────┐
│  INTEGRATION Sandbox        │
│  - Déploiement auto         │
│  - Tests: RunLocalTests     │
└──────────┬──────────────────┘
           │ (manuel - labels)
           ▼
┌─────────────────────────────┐
│  Création Release           │
│  - Sélection PRs par label  │
│  - Branche release/vX.Y.Z   │
└──────────┬──────────────────┘
           │ (manuel)
           ▼
┌─────────────────────────────┐
│  PREPROD (Pré-production)   │
│  - Deploy manuel            │
│  - Tests: RunLocalTests     │
└──────────┬──────────────────┘
           │ (après validation)
           ▼
┌─────────────────────────────┐
│  PRODUCTION                 │
│  - Même package que PREPROD │
│  - Tests: RunLocalTests     │
└─────────────────────────────┘
```

## 📦 Prérequis

### Outils nécessaires

- **Git** >= 2.30
- **Salesforce CLI** (`sf`) >= 2.0.0
- **Node.js** >= 18.x
- Compte **GitHub** avec droits admin sur le repository
- Accès aux **3 orgs Salesforce** :
  - Integration Sandbox
  - PREPROD Sandbox
  - Production

### Connaissances requises

- Bases de Git et GitHub
- Salesforce Development (Apex, LWC, Metadata API)
- GitHub Actions (recommandé)

## 🛠️ Installation

### 1. Cloner le repository

```bash
git clone https://github.com/jeremy-legeay/salesforce-cicd.git
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

```
salesforce-cicd/
├── .github/
│   └── workflows/
│       ├── salesforce-cicd.yml              # Déploiement auto INTEGRATION
│       ├── create-release-package.yml       # Création de releases
│       ├── deploy-release.yml               # Déploiement PREPROD/PROD
│       └── auto-backport-hotfix.yml         # Backport automatique
├── force-app/                                # Code source Salesforce
│   └── main/
│       └── default/
│           ├── classes/
│           ├── lwc/
│           ├── triggers/
│           └── ...
├── manifest/
│   ├── package.xml                          # Métadonnées à déployer
│   └── releases/                            # Manifests de releases
│       └── v1.2.0.xml                       # (généré automatiquement)
├── sfdx-project.json                        # Configuration SFDX
├── .forceignore                             # Fichiers à ignorer
├── README.md                                # Ce fichier
├── RELEASE_PROCESS.md                       # Guide complet des releases
└── JWT_SETUP_GUIDE.md                       # Configuration JWT
```

### 2. Configurer l'authentification JWT

L'authentification utilise JWT (JSON Web Token) pour une connexion sécurisée sans mot de passe.

**Configuration requise pour chaque environnement** :

1. Créer une Connected App dans Salesforce
2. Générer un certificat et une clé privée
3. Configurer les secrets GitHub

📖 **Guide complet** : [JWT_SETUP_GUIDE.md](JWT_SETUP_GUIDE.md)

### 3. Configurer les GitHub Environments

Créer 3 environnements dans **Settings → Environments** :

#### INTEGRATION
- **Protection rules** : 1 reviewer required
- **Secrets** :
  - `SF_CONSUMER_KEY_INTEGRATION`
  - `SF_USERNAME_INTEGRATION`
  - `SF_PRIVATE_KEY_INTEGRATION`

#### PREPROD
- **Protection rules** : 2 reviewers required
- **Secrets** :
  - `SF_CONSUMER_KEY_PREPROD`
  - `SF_USERNAME_PREPROD`
  - `SF_PRIVATE_KEY_PREPROD`

#### PRODUCTION
- **Protection rules** : 2 reviewers required
- **Secrets** :
  - `SF_CONSUMER_KEY_PRODUCTION`
  - `SF_USERNAME_PRODUCTION`
  - `SF_PRIVATE_KEY_PRODUCTION`

### 4. Protéger les branches

Dans **Settings → Branches**, créez des règles pour :

- `main` : 2 reviewers, status checks required
- `integration` : 1 reviewer, status checks required

## 🚀 Processus de Release

### Développement quotidien

```bash
# 1. Créer une branche de feature
git checkout integration
git pull
git checkout -b feature/nouvelle-fonctionnalite

# 2. Développer et commiter
git add .
git commit -m "feat: ajouter nouvelle fonctionnalité"
git push origin feature/nouvelle-fonctionnalite

# 3. Créer une Pull Request vers integration
# 4. Ajouter un label de release (ex: release-v1.2.0) si cette PR doit être incluse dans une release
# 5. Après merge → déploiement automatique sur INTEGRATION
```

### Créer une release

1. **Aller dans Actions** → `Create Release Package`
2. **Run workflow** avec :
   - **Release version** : `v1.2.0`
   - **Label to filter PRs** : `release-v1.2.0`
   - **Base branch** : `integration`

Le workflow crée :
- Une branche `release/v1.2.0`
- Un manifest avec les métadonnées des PRs labelisées
- Une GitHub Release (draft)

### Déployer sur PREPROD

1. **Aller dans Actions** → `Deploy Release to Environment`
2. **Run workflow** avec :
   - **Release version** : `v1.2.0`
   - **Target environment** : `PREPROD`

### Déployer sur PRODUCTION

1. **Tester sur PREPROD** ✅
2. **Aller dans Actions** → `Deploy Release to Environment`
3. **Run workflow** avec :
   - **Release version** : `v1.2.0` (même version que PREPROD)
   - **Target environment** : `PRODUCTION`

### Hotfixes

Les hotfixes sur les branches `release/**` sont automatiquement backportés vers `integration` :

1. Créer une branche depuis `release/v1.2.0`
2. Développer le fix
3. Créer une PR vers `release/v1.2.0`
4. Merger → backport automatique vers `integration`

📖 **Guide détaillé** : [RELEASE_PROCESS.md](RELEASE_PROCESS.md)

## 🔧 Commandes utiles

### Salesforce CLI

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
```

### Git

```bash
# Voir les branches
git branch -a

# Synchroniser avec remote
git fetch --all
git pull

# Créer une release tag
git tag -a v1.0.0 -m "Release 1.0.0"
git push origin v1.0.0

# Voir les PRs avec un label spécifique
gh pr list --label release-v1.2.0 --state merged
```

📖 **Plus de commandes** : [GIT_COMMANDS.md](GIT_COMMANDS.md)

## 🐛 Dépannage

### Erreur d'authentification JWT

**Problème** : `ERROR: We encountered a JSON web token error`

**Solution** :
1. Vérifiez que la Connected App est approuvée dans Salesforce
2. Vérifiez que le certificat correspond à la clé privée
3. Vérifiez que l'utilisateur a les permissions nécessaires
4. Consultez [JWT_SETUP_GUIDE.md](JWT_SETUP_GUIDE.md)

### Tests Apex échouent

**Problème** : Les tests passent localement mais échouent dans le pipeline

**Solution** :
1. Vérifiez que tous les tests sont déployés
2. Vérifiez les dépendances de données
3. Utilisez `@TestSetup` pour créer des données de test
4. Consultez les logs détaillés dans GitHub Actions

### Workflow non visible

**Problème** : Le workflow manuel n'apparaît pas dans Actions

**Solution** :
Les workflows avec `workflow_dispatch` doivent être sur la branche `main` pour être visibles.

### "No PRs found with label X"

**Problème** : Le workflow de création de release ne trouve pas de PRs

**Solution** :
1. Vérifiez que les PRs sont bien **merged**
2. Vérifiez que le label correspond exactement
3. Vérifiez que le label existe dans le repository

### Backport automatique échoue

**Problème** : Le backport automatique crée un commentaire indiquant des conflits

**Solution** :
1. Suivez les instructions du commentaire automatique
2. Résolvez les conflits manuellement
3. Créez une PR manuelle vers `integration`

## 📖 Documentation

Ce projet contient plusieurs guides pour vous aider :

### Configuration
- **[JWT_SETUP_GUIDE.md](JWT_SETUP_GUIDE.md)** - Configuration de l'authentification JWT
- **[AJOUT_ENVIRONNEMENT.md](AJOUT_ENVIRONNEMENT.md)** - Guide pour ajouter des environnements intermédiaires (QA, STAGING, etc.)
- **[BEST_PRACTICES.md](BEST_PRACTICES.md)** - Bonnes pratiques Salesforce CI/CD

### Processus
- **[RELEASE_PROCESS.md](RELEASE_PROCESS.md)** - Guide complet du processus de release
- **[GIT_COMMANDS.md](GIT_COMMANDS.md)** - Commandes Git utiles

### Archive
- **[archive/](archive/)** - Documentation de référence archivée

## 📚 Ressources Externes

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

Pour toute question ou problème, ouvrez une issue sur GitHub.

---

**Bon déploiement ! 🎉**
