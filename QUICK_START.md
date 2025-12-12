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

### 3. Configurer l'authentification JWT

#### A. Créer les 3 environnements GitHub pour le CI/CD

Allez dans **Settings > Environments** de votre repo et créez :

| Environnement | Reviewers | Wait Timer | Notes |
|--------------|-----------|------------|-------|
| INTEGRATION | 1 | 0 min | Premier environnement du pipeline |
| UAT | 2 | 5 min | Tests utilisateurs |
| PRODUCTION | 2+ | 10 min | Production |

**Note** : L'environnement DEV n'a pas besoin de configuration GitHub car le développement se fait directement via VS Code (pas de CI/CD).

#### B. Générer le certificat SSL (une seule fois)

Sur votre machine locale, générez une paire clé/certificat :

```bash
# Générer la clé privée et le certificat (valide 100 ans)
openssl req -x509 -sha256 -nodes -days 36500 -newkey rsa:2048 -keyout server.key -out server.crt
```

Répondez aux questions (ou appuyez sur Enter pour accepter les valeurs par défaut) :
- **Country Name** : FR
- **State** : (votre région ou Enter)
- **Locality** : (votre ville ou Enter)
- **Organization Name** : (votre entreprise ou Enter)
- **Common Name** : github-cicd

Cela crée **2 fichiers** :
- `server.key` : clé privée (**à garder SECRET** et ne JAMAIS committer dans Git)
- `server.crt` : certificat public (à uploader dans Salesforce)

**IMPORTANT** : Ajoutez `server.key` au `.gitignore` pour éviter de le committer par erreur !

#### C. Créer une Connected App dans chaque org Salesforce

Pour **CHAQUE org** (INTEGRATION, UAT, PRODUCTION), répétez ces étapes :

1. Connectez-vous à l'org Salesforce
2. Allez dans **Setup** (⚙️ en haut à droite)
3. Quick Find → tapez **App Manager**
4. Cliquez sur **New Connected App** (en haut à droite)

**Configuration** :

**Basic Information**
- Connected App Name : `GitHub CI/CD JWT`
- API Name : `GitHub_CICD_JWT` (auto-généré)
- Contact Email : votre email

**API (Enable OAuth Settings)**
- ✅ **Enable OAuth Settings**
- Callback URL : `http://localhost:1717/OauthRedirect`
- ✅ **Use digital signatures** → Cliquez sur **Choose File** et uploadez `server.crt`

**Selected OAuth Scopes** (déplacez ces 3 scopes de "Available" vers "Selected") :
- **Access and manage your data (api)**
- **Perform requests on your behalf at any time (refresh_token, offline_access)**
- **Provide access to your data via the Web (web)**

**Autres options** :
- ✅ **Require Secret for Web Server Flow** (en bas)

Cliquez sur **Save** et **attendez 2-10 minutes** (Salesforce a besoin de temps pour activer l'app).

#### D. Récupérer le Consumer Key

Pour **chaque Connected App** créée :

1. **Setup → App Manager**
2. Trouvez **GitHub CI/CD JWT**
3. Cliquez sur **▼** à droite → **View**
4. Cliquez sur **Manage Consumer Details**
5. Vérifiez votre identité (code envoyé par email)
6. **Copiez le Consumer Key** (c'est le Client ID)

#### E. Configurer les secrets GitHub

Pour **chaque environnement** GitHub (INTEGRATION, UAT, PRODUCTION), configurez **3 secrets** :

**Exemple pour INTEGRATION** :

1. Allez dans **Settings → Environments → INTEGRATION**
2. Cliquez sur **Add Secret** et créez ces 3 secrets :

**Secret 1** : `SF_CONSUMER_KEY_INTEGRATION`
- Valeur : Le **Consumer Key** copié depuis la Connected App INTEGRATION

**Secret 2** : `SF_USERNAME_INTEGRATION`
- Valeur : Le **username Salesforce** de l'org INTEGRATION (ex: `admin@company-int.com`)

**Secret 3** : `SF_PRIVATE_KEY_INTEGRATION`
- Valeur : Le contenu **COMPLET** du fichier `server.key`
  ```bash
  # Pour afficher le contenu du fichier :
  cat server.key
  # Ou sur Windows :
  type server.key
  ```
  Copiez **TOUT** le contenu, incluant les lignes `-----BEGIN PRIVATE KEY-----` et `-----END PRIVATE KEY-----`

**Répétez pour UAT et PRODUCTION** avec les suffixes correspondants :
- **UAT** : `SF_CONSUMER_KEY_UAT`, `SF_USERNAME_UAT`, `SF_PRIVATE_KEY_UAT`
- **PRODUCTION** : `SF_CONSUMER_KEY_PRODUCTION`, `SF_USERNAME_PRODUCTION`, `SF_PRIVATE_KEY_PRODUCTION`

**Récapitulatif** :
- ✅ Utilisez le **même certificat** (server.key/server.crt) pour les 3 orgs
- ✅ Créez une **Connected App différente** dans chaque org avec ce même certificat
- ✅ Ne commitez **JAMAIS** `server.key` dans Git (ajoutez-le au `.gitignore`)
- ✅ L'environnement **DEV** est géré directement via VS Code (pas de secret nécessaire)
- ✅ Total de **9 secrets** à configurer (3 secrets × 3 environnements)

### 4. Créer et configurer les branches

#### A. Créer la structure de branches

**Important** : Les branches doivent être créées dans un **flux linéaire** pour permettre une promotion progressive du code.

```bash
# 1. Vous êtes déjà sur main
git checkout main

# 2. Créer integration à partir de main
git checkout -b integration
git push -u origin integration

# 3. Créer uat à partir de integration
git checkout -b uat
git push -u origin uat

# 4. Retour sur main
git checkout main
```

**Structure finale** :
```
integration → uat → main
    (INT)     (UAT)  (PROD)
```

#### B. Protéger les branches

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


### 5. Tester le pipeline

**Important** : Le premier environnement du CI/CD est `integration`. Vous allez donc faire un push direct sur `integration` pour tester.

```bash
# 1. Faire un changement minimal sur integration
git checkout integration
git pull origin integration

# Modifier un fichier (exemple : README)
echo "# Test CI/CD Pipeline" >> README.md

# Commit et push directement sur integration
git add README.md
git commit -m "test: verify CI/CD pipeline"
git push origin integration
```

**Le workflow se déclenche automatiquement** :

1. Le workflow **Validate & Test** s'exécute dans l'onglet **Actions**
   - Valide le déploiement avec tous les tests
   - Récupère un Job ID pour le Quick Deploy
   - ✅ Une fois terminé, le job `Deploy` attend

2. Le job **Deploy** attend l'approbation via **GitHub Environment**
   - Allez dans **Actions** > votre workflow en cours
   - Cliquez sur **Review deployments**
   - Sélectionnez l'environnement INTEGRATION
   - Cliquez sur **Approve and deploy**

3. Le **Quick Deploy** s'exécute instantanément (10-30 secondes)
   - Utilise le Job ID de l'étape 1
   - Aucun test relancé ⚡
   - Déploiement vers l'org INTEGRATION

4. Vérifiez dans les logs que tout s'est bien passé

**Note** :
- Le CI/CD fonctionne sur les branches `integration`, `uat` et `main`
- Pour les prochains déploiements, utilisez des feature branches et Pull Requests (voir section 6)

### 6. Workflow quotidien

```bash
# 1. DÉVELOPPEMENT LOCAL (DEV)
# - Créez une feature branch depuis 'integration'
# - Utilisez VS Code + Salesforce Extension Pack
# - Deploy/Retrieve directement depuis VS Code vers votre org DEV
# - Committez vos changements localement

git checkout integration
git pull origin integration
git checkout -b feature/my-new-feature

# Développement...
git add .
git commit -m "feat: ma nouvelle fonctionnalité"
git push -u origin feature/my-new-feature

# 2. PROMOTION VERS INTEGRATION (début du CI/CD)
# Créez une Pull Request de 'feature/my-new-feature' vers 'integration'
# → Créez une PR sur GitHub : feature/my-new-feature → integration
# → Attendre approbation (1 reviewer)
# → Merger la PR
# → Le workflow CI/CD se déclenche automatiquement sur 'integration'

# 3. PROMOTION VERS UAT (via release branch)
# Créez une release branch depuis 'integration'
git checkout integration
git pull origin integration
git checkout -b release/v1.2.0
git push -u origin release/v1.2.0
# → Créez une PR sur GitHub : release/v1.2.0 → uat
# → Attendre approbations (2 reviewers)
# → Merger la PR
# → Le workflow CI/CD se déclenche automatiquement sur 'uat'

# 4. PROMOTION VERS PRODUCTION
# Créez une Pull Request de 'uat' vers 'main'
git checkout uat
git pull origin uat
# → Créez une PR sur GitHub : uat → main
# → Attendre approbations (2+ reviewers) + wait timer
# → Merger la PR
# → Le workflow CI/CD se déclenche automatiquement sur 'main'
```

**Important** :
- Développez sur des feature branches créées depuis `integration`
- Utilisez des release branches pour packager plusieurs features vers UAT
- Chaque environnement (INTEGRATION, UAT, PRODUCTION) nécessite une approbation manuelle via GitHub Environments

### 7. Gestion avancée des branches

#### Schéma de la stratégie de branching (avec Release Branches)

```
                                     ┌─ release/v1.2.0 ─┐
                                     │    (PACKAGE)     │
                                     │                  ↓
    feature/xxx ──→ integration ─────┴──────────────→ uat ─────→ main
                        (INT)                         (UAT)      (PROD)
                                                                    ↓
                                                                    │
                       ↑                                            │
                       └──────────────── hotfix/xxx ────────────────┘
```

**Flux normal** :
1. **feature/xxx** → **integration** (PR depuis feature branch)
   - Développement sur feature branch (org DEV local via VS Code)
   - PR vers integration avec 1 approbation
   - Tests et validations sur INTEGRATION

2. **integration** → **release/v1.2.0** (créer une release branch)
   - Package plusieurs features testées sur INTEGRATION
   - 1 release = package cohérent de fonctionnalités

3. **release/v1.2.0** → **uat** (PR avec le package)
   - 1 seule PR pour tout le package
   - Déploiement vers UAT pour tests utilisateurs

4. **uat** → **main** (PR vers production)
   - Déploiement final en PRODUCTION

**Avantages** :
- ✅ Feature branches pour isolation du développement
- ✅ INTEGRATION = environnement de test pour chaque feature
- ✅ UAT = package cohérent testé (via release branches)
- ✅ Pas de dizaines de PR vers UAT
- ✅ Versioning clair (v1.2.0, v1.3.0, etc.)

**Hotfix** : `main → hotfix → main` puis merge dans `uat` et `integration`

#### A. Workflow Feature Branch → INTEGRATION

Pour développer et déployer sur INTEGRATION :

```bash
# 1. Créer une feature branch depuis integration
git checkout integration
git pull origin integration
git checkout -b feature/user-authentication

# 2. Développer localement (org DEV via VS Code)
# ... développement avec VS Code + Salesforce Extension Pack ...
# ... deploy/retrieve directement vers org DEV ...
git add .
git commit -m "feat: ajout système d'authentification"

# 3. Pousser la feature branch
git push -u origin feature/user-authentication

# 4. Créer une PR vers integration sur GitHub
# → PR titre : "feat: user authentication system"
# → Attendre approbation (1 reviewer)
# → Le CI/CD valide automatiquement (job Validate & Test)
# → Merger la PR

# 5. Le CI/CD se déclenche sur integration
# → Workflow Validate & Test (récupère Job ID)
# → Approbation Environment INTEGRATION
# → Quick Deploy vers org INTEGRATION

# 6. Tester sur l'org INTEGRATION
# Si OK → supprimer la feature branch et préparer pour UAT
# Si KO → corriger sur la feature branch et recommencer

# Supprimer la feature branch après merge
git branch -d feature/user-authentication
git push origin --delete feature/user-authentication
```

**Note** : Les feature branches permettent d'isoler le développement et de valider via PR avant déploiement sur INTEGRATION.

#### B. Workflow Release Branch → UAT (Package)

**Quand utiliser** : Lorsque vous avez plusieurs déploiements testés sur INTEGRATION et vous voulez créer un package cohérent pour UAT.

```bash
# 1. Créer une release branch depuis integration
git checkout integration
git pull origin integration
git checkout -b release/v1.2.0

# 2. (Optionnel) Ajustements finaux
# - Mise à jour numéro de version dans le code
# - Release notes
git add .
git commit -m "chore: prepare release v1.2.0"

# 3. Pousser la release branch
git push -u origin release/v1.2.0

# 4. Créer une PR vers uat sur GitHub
# → PR titre : "Release v1.2.0"
# → Description : Liste de tous les déploiements INTEGRATION inclus
# → Attendre approbation (2 reviewers)
# → Merger la PR

# 5. Le CI/CD se déclenche automatiquement sur uat
# → Validation + Approbation Environment → Quick Deploy vers UAT

# 6. Tag la release après déploiement réussi
git checkout uat
git pull origin uat
git tag -a v1.2.0 -m "Release v1.2.0"
git push origin v1.2.0

# 7. Supprimer la release branch
git branch -D release/v1.2.0
git push origin --delete release/v1.2.0
```

**Exemple de description de PR pour une release vers UAT** :

```markdown
# Release v1.2.0 → UAT

## Déploiements INTEGRATION inclus dans ce package

### Features
- ✅ User authentication system (déployé INT le 15/12)
- ✅ Dashboard analytics (déployé INT le 16/12)
- ✅ Email notifications (déployé INT le 18/12)

### Bug fixes
- 🐛 Fixed login validation error (déployé INT le 17/12)
- 🐛 Corrected date format display (déployé INT le 19/12)

## Tests
- ✅ Tous les déploiements testés individuellement sur INTEGRATION
- ✅ Package complet validé sur INTEGRATION
- ✅ Tous les tests Apex passent

## Calendrier
- Déploiement UAT : 20/12 (après approbations)
- Tests utilisateurs UAT : 20-22/12
- Déploiement PROD prévu : 23/12
```

**Cycle de release recommandé** :
- **Sprint 2 semaines** → 1 release UAT par sprint (package de ~10-20 déploiements INT)
- **Sprint 1 semaine** → 1 release UAT par semaine
- **Hotfix** → Release immédiate si critique

#### C. Gestion des Hotfix (correction urgente en production)

Si vous devez corriger un bug critique en production :

```bash
# 1. Créer hotfix depuis main
git checkout main
git pull origin main
git checkout -b hotfix/critical-bug-fix

# 2. Corriger le bug et tester
git add .
git commit -m "hotfix: correction bug critique"
git push -u origin hotfix/critical-bug-fix

# 3. Créer une PR vers main et merger
# → Déploiement immédiat en PROD

# 4. IMPORTANT : Reporter le fix dans toutes les branches
# Pour éviter que le bug revienne lors des prochains déploiements

# Merger dans uat
git checkout uat
git pull origin uat
git merge hotfix/critical-bug-fix
git push origin uat

# Merger dans integration
git checkout integration
git pull origin integration
git merge hotfix/critical-bug-fix
git push origin integration

# 5. Supprimer la branche hotfix
git branch -D hotfix/critical-bug-fix
git push origin --delete hotfix/critical-bug-fix
```

#### D. Synchronisation des branches (si désynchronisées)

Si une branche est en retard par rapport à la précédente :

```bash
# Exemple : uat est en retard par rapport à integration

# 1. Aller sur uat
git checkout uat
git pull origin uat

# 2. Merger integration dans uat
git merge integration

# 3. Résoudre les conflits si nécessaire
# Puis commiter et pousser
git push origin uat

# 4. Répéter pour main si nécessaire
git checkout main
git pull origin main
git merge uat
git push origin main
```

#### E. Nettoyage des branches obsolètes

```bash
# Lister toutes les branches
git branch -a

# Supprimer une branche locale
git branch -d nom-branche

# Supprimer une branche sur GitHub
git push origin --delete nom-branche

# Nettoyer les références aux branches remote supprimées
git fetch --prune
```

#### F. Stratégie de nommage des branches

**Conventions recommandées** :

```
feature/description-courte    → Nouvelle fonctionnalité
fix/description-bug           → Correction de bug
release/vX.Y.Z               → Package de features pour promotion
hotfix/description-urgente    → Correction urgente en production
refactor/description          → Refactoring sans changement fonctionnel
docs/description              → Documentation uniquement
test/description              → Ajout/modification de tests
chore/description             → Tâches techniques (dependencies, config, etc.)
```

**Exemples** :
```
feature/user-authentication
fix/login-validation-error
release/v1.2.0               ← Package de plusieurs features
release/v1.3.0-sprint24      ← Release avec numéro de sprint
hotfix/security-patch-xss
refactor/api-endpoints
docs/deployment-guide
test/apex-test-coverage
chore/update-dependencies
```

**Versioning sémantique pour les releases** :
```
v1.2.3
│ │ │
│ │ └─→ PATCH : Bug fixes uniquement
│ └───→ MINOR : Nouvelles features (non breaking)
└─────→ MAJOR : Breaking changes
```

### 8. Schéma du workflow Quick Deploy

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

### Configuration initiale
- [ ] Tous les fichiers copiés dans le bon répertoire
- [ ] Certificat SSL généré (`server.key` et `server.crt`)
- [ ] Connected App créée dans les 3 orgs (INTEGRATION, UAT, PRODUCTION)
- [ ] 3 environnements créés dans GitHub (INTEGRATION, UAT, PRODUCTION)
- [ ] 9 secrets JWT configurés (3 par environnement : `SF_CONSUMER_KEY`, `SF_USERNAME`, `SF_PRIVATE_KEY`)
- [ ] Structure de branches créée (`integration`, `uat` depuis `main`)
- [ ] Branches protégées configurées avec les règles appropriées
- [ ] Test du pipeline réussi sur `integration`

### Configuration développeur
- [ ] VS Code installé avec Salesforce Extension Pack
- [ ] Salesforce CLI installé et configuré
- [ ] Connexion à l'org DEV configurée dans VS Code
- [ ] Git configuré localement
- [ ] Documentation lue (README.md et BEST_PRACTICES.md)

### Formation équipe
- [ ] Équipe formée sur le workflow Git (feature branches, PR, merge)
- [ ] Équipe formée sur les approbations GitHub Environments
- [ ] Conventions de nommage des branches partagées
- [ ] Procédure de hotfix documentée et comprise

## ⚠️ Problèmes fréquents

### Erreur : "invalid_client_id" ou "invalid_grant"
→ Vérifiez le Consumer Key et que la Connected App est activée (attendre 2-10 min)
→ Vérifiez que le certificat `server.crt` uploadé correspond au `server.key` dans les secrets
→ Consultez le [JWT_SETUP_GUIDE.md](./JWT_SETUP_GUIDE.md) pour le dépannage détaillé

### Erreur : "JWT secrets not configured"
→ Vérifiez que les 3 secrets existent pour l'environnement (`SF_CONSUMER_KEY_*`, `SF_USERNAME_*`, `SF_PRIVATE_KEY_*`)
→ Vérifiez les noms des secrets (sensible à la casse)

### Tests échouent dans le pipeline
→ Vérifiez que tous les tests passent localement d'abord
→ Vérifiez les dépendances de données de test

### Déploiement timeout
→ Augmentez le `--wait` dans le workflow (ligne 93 et 158)
→ Vérifiez les processus asynchrones dans l'org

### Quick Deploy échoue avec "Job ID not found"
→ Le Job ID est valide pendant 4 jours seulement
→ Le Job ID doit correspondre à l'org cible
→ Relancez une validation complète pour obtenir un nouveau Job ID

### Branche non protégée
→ Assurez-vous d'avoir créé les règles dans Settings > Branches

### Conflits de merge entre branches
→ Synchronisez régulièrement les branches (voir section 7.C)
→ Utilisez `git merge` et non `git rebase` pour maintenir l'historique
→ En cas de conflit, résolvez manuellement puis testez avant de pousser

### Hotfix pas présent dans les branches
→ Assurez-vous de merger le hotfix dans TOUTES les branches
→ Ordre : `main` → `uat` → `integration`
→ Vérifiez avec `git log` que le commit est présent partout

### Branches désynchronisées
→ Utilisez `git log --oneline --graph --all` pour visualiser
→ Suivez la procédure de synchronisation (section 7.C)

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

## 📊 Résumé visuel du workflow complet

```
┌─────────────────────────────────────────────────────────────────┐
│                    DÉVELOPPEMENT                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Developer → feature/xxx (VS Code direct deploy to DEV org)     │
│                                                                  │
└──────────────────────────┬──────────────────────────────────────┘
                           │ PR to integration
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                    CI/CD PIPELINE                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. INTEGRATION (1 approbation PR + 1 approbation Env)          │
│     → Validate & Test (récupère Job ID)                         │
│     → Deploy (Quick Deploy ⚡)                                   │
│                                                                  │
│  2. UAT (2 approbations PR + 2 approbations Env)                │
│     → Validate & Test (récupère Job ID)                         │
│     → Deploy (Quick Deploy ⚡)                                   │
│                                                                  │
│  3. PRODUCTION (2+ approbations PR + 2+ approbations Env)       │
│     → Validate & Test (récupère Job ID)                         │
│     → Deploy (Quick Deploy ⚡)                                   │
│     → Wait Timer                                                 │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

Temps total de bout en bout : ~20-30 minutes
  (incluant validations + approbations)
Temps de déploiement réel : ~30 secondes par environnement ⚡
```

---

**Vous êtes prêt ! 🎉**

Pour toute question ou problème, consultez les logs GitHub Actions ou contactez l'équipe DevOps.
