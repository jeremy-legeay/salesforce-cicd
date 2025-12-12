# 🚀 Guide d'Installation Rapide - CI/CD Salesforce

## 💡 Comment fonctionne ce pipeline ?

Ce pipeline utilise le mécanisme de **Quick Deploy** de Salesforce pour un déploiement rapide et sécurisé :

1. **Validation complète** : À chaque Pull Request, tous les tests Apex sont exécutés (job `Validate & Test`)
2. **Récupération du Job ID** : Si la validation réussit, Salesforce retourne un Job ID valide pendant 4 jours
3. **Approbation manuelle** : Un reviewer approuve le déploiement via GitHub Environments
4. **Quick Deploy instantané** : Le job `Deploy` déploie instantanément en utilisant le Job ID, **sans relancer les tests**

**Avantages** :
- ⚡ Déploiement ultra-rapide (quelques secondes vs plusieurs minutes)
- 🛡️ Sécurité maximale (les tests sont obligatoires à l'étape de validation)
- ✅ Contrôle humain via approbations GitHub

## ⚡ Installation en 10 minutes

### 1. Structure du projet

Créez cette structure dans votre repository GitHub :

```
votre-repo/
├── .github/
│   └── workflows/
│       └── salesforce-cicd.yml          ← Fichier fourni
├── force-app/
│   └── main/
│       └── default/
│           ├── classes/
│           │   ├── SmokeTestClass.cls   ← Fichier fourni
│           │   └── SmokeTestClass.cls-meta.xml
│           ├── lwc/
│           ├── triggers/
│           └── ... (votre code Salesforce)
├── manifest/
│   ├── package.xml                       ← Fichier fourni
│   └── destructiveChanges.xml            ← Fichier fourni
├── scripts/
│   └── deploy.sh                         ← Fichier fourni
├── .forceignore                          ← Fichier fourni
├── .gitignore                            ← Fichier fourni
├── sfdx-project.json                     ← Fichier fourni
├── README.md                             ← Fichier fourni
├── BEST_PRACTICES.md                     ← Fichier fourni
└── ENVIRONMENTS_SETUP.md                 ← Fichier fourni
```

### 2. Copier les fichiers

1. Téléchargez tous les fichiers fournis
2. Copiez-les dans votre repository en respectant la structure ci-dessus
3. Committez et poussez :

```bash
git add .
git commit -m "chore: setup CI/CD pipeline"
git push origin main
```

### 3. Configurer GitHub Environments

#### A. Créer les 3 environnements pour le CI/CD

Allez dans **Settings > Environments** de votre repo et créez :

| Environnement | Reviewers | Wait Timer | Notes |
|--------------|-----------|------------|-------|
| INTEGRATION | 1 | 0 min | Premier environnement du pipeline |
| UAT | 2 | 5 min | Tests utilisateurs |
| PRODUCTION | 2+ | 10 min | Production |

**Note** : L'environnement DEV n'a pas besoin de configuration GitHub car le développement se fait directement via VS Code (pas de CI/CD).

#### B. Générer les Auth URLs

Pour CHAQUE org Salesforce :

```bash
# 1. Se connecter
sf org login web --alias GIT-CICD-PROD --instance-url https://jleg-cicd-prod-dev-ed.develop.my.salesforce.com

# 2. Obtenir l'Auth URL
sf org display --target-org GIT-CICD-INT --verbose
```

Copiez la ligne qui commence par `force://PlatformCLI::...`

#### C. Ajouter les secrets

Pour chaque environnement **du pipeline CI/CD** dans GitHub :

1. **Settings > Secrets and variables > Actions**
2. Sélectionnez l'environnement (ex: INTEGRATION)
3. **New environment secret**
4. Nom : `SFDX_AUTH_URL_INTEGRATION`
5. Valeur : Collez l'Auth URL
6. Répétez pour UAT et PRODUCTION

**Important** : Vous n'avez besoin que de **3 secrets** (INTEGRATION, UAT, PRODUCTION). L'environnement DEV est géré directement via VS Code.

### 4. Protéger les branches

Dans **Settings > Branches**, créez ces règles :

#### Branche `main` (PRODUCTION)
- ✅ Require pull request
- ✅ Require 2 approvals
- ✅ Require status checks to pass before merging
- ✅ Require branches to be up to date
- Status checks : `Validate & Test` uniquement

**Note** : Le job `Deploy` s'exécute **après** le merge et nécessite une approbation manuelle via GitHub Environments (2+ reviewers + timer).

#### Branche `uat`
- ✅ Require pull request
- ✅ Require 2 approvals
- ✅ Require status checks to pass before merging
- ✅ Require branches to be up to date
- Status checks : `Validate & Test` uniquement

**Note** : Le job `Deploy` s'exécute **après** le merge et nécessite une approbation manuelle via GitHub Environments (2 reviewers).

#### Branche `integration`
- ✅ Require pull request
- ✅ Require 1 approval
- ✅ Require status checks to pass before merging
- ✅ Require branches to be up to date
- Status checks : `Validate & Test` uniquement

**Note** : Le job `Deploy` s'exécute **après** le merge et nécessite une approbation manuelle via GitHub Environments (1 reviewer).

**Note** : Pas de CI/CD sur cette branche. Développement local uniquement.

### 5. Tester le pipeline

```bash
# Créer une branche de test depuis develop
git checkout develop
git checkout -b test/cicd-setup

# Faire un changement minimal
echo "# Test CI/CD" >> README.md

# Commit et push
git add README.md
git commit -m "test: verify CI/CD pipeline"
git push origin test/cicd-setup
```

Puis :
1. Créez une **Pull Request** de `test/cicd-setup` vers `integration` sur GitHub
2. Vérifiez que le workflow **Validate & Test** s'exécute dans l'onglet **Actions**
   - Ce job valide le déploiement avec tous les tests
   - Il récupère un Job ID pour le Quick Deploy
   - ✅ Une fois terminé, la PR peut être mergée
3. Mergez la PR (après approbation du reviewer de la PR)
4. **Le workflow se relance automatiquement** après le merge
5. Le job **Deploy** attend maintenant l'approbation via **GitHub Environment**
   - Allez dans **Actions** > votre workflow
   - Cliquez sur **Review deployments**
   - Approuvez le déploiement vers INTEGRATION
6. Le **Quick Deploy** s'exécute instantanément (10-30 secondes)
   - Utilise le Job ID de l'étape 2
   - Aucun test relancé ⚡

**Note** :
- La branche `develop` ne déclenche PAS le CI/CD. Le pipeline commence uniquement sur `integration`, `uat` et `main`.
- Le **Quick Deploy** permet de gagner du temps en évitant de relancer tous les tests au moment du déploiement.

### 6. Workflow quotidien

```bash
# 1. DÉVELOPPEMENT LOCAL (DEV)
# - Travaillez sur la branche 'develop'
# - Utilisez VS Code + Salesforce Extension Pack
# - Deploy/Retrieve directement depuis VS Code vers votre org DEV
# - Committez vos changements localement

git checkout develop
git add .
git commit -m "feat: ma nouvelle fonctionnalité"

# 2. PROMOTION VERS INTEGRATION (début du CI/CD)
# Créez une Pull Request de 'develop' vers 'integration'
git push origin develop
# → Créez une PR sur GitHub : develop → integration
# → Attendre approbation (1 reviewer)
# → Merger la PR
# → Le workflow CI/CD se déclenche automatiquement sur 'integration'

# 3. PROMOTION VERS UAT
# Créez une Pull Request de 'integration' vers 'uat'
git checkout integration
git pull
git push origin integration
# → Créez une PR sur GitHub : integration → uat
# → Attendre approbations (2 reviewers)
# → Merger la PR
# → Le workflow CI/CD se déclenche automatiquement sur 'uat'

# 4. PROMOTION VERS PRODUCTION
# Créez une Pull Request de 'uat' vers 'main'
git checkout uat
git pull
git push origin uat
# → Créez une PR sur GitHub : uat → main
# → Attendre approbations (2+ reviewers) + wait timer
# → Merger la PR
# → Le workflow CI/CD se déclenche automatiquement sur 'main'
```

**Important** :
- La branche `develop` est pour le développement local uniquement (pas de CI/CD)
- Le CI/CD commence à partir de `integration` via des Pull Requests
- Chaque environnement (INTEGRATION, UAT, PRODUCTION) nécessite une approbation manuelle via GitHub Environments

### 7. Schéma du workflow Quick Deploy

```
┌─────────────────────────────────────────────────────────────┐
│  Pull Request créée vers 'integration/uat/main'            │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
        ┌─────────────────────────────┐
        │   Job: Validate & Test      │
        │  - Checkout code            │
        │  - Run Apex Tests           │
        │  - Validate deployment      │
        │  - Récupère Job ID ✅       │
        └─────────────┬───────────────┘
                      │
                      ▼
        ┌─────────────────────────────┐
        │  APPROBATION #1             │
        │  Approbation de la PR       │
        │  (1-2 reviewers)            │
        └─────────────┬───────────────┘
                      │
                      ▼
        ┌─────────────────────────────┐
        │   MERGE de la PR            │
        │   Workflow se relance       │
        └─────────────┬───────────────┘
                      │
                      ▼
        ┌─────────────────────────────┐
        │  APPROBATION #2             │
        │  Approbation Environment    │
        │  via GitHub Actions UI      │
        │  (1-2 reviewers)            │
        └─────────────┬───────────────┘
                      │
                      ▼
        ┌─────────────────────────────┐
        │   Job: Deploy               │
        │  - Utilise Job ID           │
        │  - Quick Deploy ⚡          │
        │  - Aucun test relancé       │
        │  - Déploiement instantané   │
        └─────────────┬───────────────┘
                      │
                      ▼
        ┌─────────────────────────────┐
        │   Job: Verify               │
        │  - Smoke tests              │
        │  - Post-deployment checks   │
        └─────────────────────────────┘
```

**Important : Double approbation** :
- **Approbation #1** : Approbation de la Pull Request (protection de branche)
  - Se fait dans l'interface de la PR
  - Vérifie que le code est correct et que les tests passent
- **Approbation #2** : Approbation du déploiement (GitHub Environment)
  - Se fait dans l'onglet Actions après le merge
  - Décision finale de déployer en production

**Temps gagné avec Quick Deploy** :
- Validation initiale : ~5-10 minutes (avec tous les tests)
- Déploiement Quick Deploy : ~10-30 secondes ⚡
- VS déploiement classique : ~5-10 minutes à chaque fois

## 🎯 Checklist de configuration

- [ ] Tous les fichiers copiés dans le bon répertoire
- [ ] 3 environnements créés dans GitHub (INTEGRATION, UAT, PRODUCTION)
- [ ] 3 secrets SFDX_AUTH_URL configurés (pas besoin pour DEV)
- [ ] Branches protégées configurées
- [ ] Test du pipeline réussi sur `integration`
- [ ] VS Code configuré pour développement sur DEV
- [ ] Documentation lue (README.md et BEST_PRACTICES.md)
- [ ] Équipe formée sur le workflow

## ⚠️ Problèmes fréquents

### Erreur : "Invalid client credentials"
→ Régénérez l'Auth URL et mettez à jour le secret GitHub

### Tests échouent dans le pipeline
→ Vérifiez que tous les tests passent localement d'abord
→ Vérifiez les dépendances de données de test

### Déploiement timeout
→ Augmentez le `--wait` dans le workflow (ligne 75)
→ Vérifiez les processus asynchrones dans l'org

### Branche non protégée
→ Assurez-vous d'avoir créé les règles dans Settings > Branches

## 📚 Prochaines étapes

1. Lisez [BEST_PRACTICES.md](./BEST_PRACTICES.md)
2. Consultez [ENVIRONMENTS_SETUP.md](./ENVIRONMENTS_SETUP.md) pour les détails
3. Personnalisez le `package.xml` selon vos besoins
4. Ajoutez vos propres tests Apex
5. Configurez les notifications (Slack, Teams, email)

## 🆘 Support

En cas de problème :
1. Consultez les logs dans GitHub Actions
2. Vérifiez la documentation Salesforce CLI
3. Ouvrez une issue sur le repository
4. Contactez l'équipe DevOps

---

**Vous êtes prêt ! 🎉**
