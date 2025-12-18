# Guide : Ajouter un environnement intermédiaire

Ce guide explique comment ajouter un environnement supplémentaire (STAGING, QA, DEV, etc.) entre INTEGRATION et PREPROD dans votre pipeline CI/CD Salesforce.

## Vue d'ensemble

### Architecture de base (3 environnements obligatoires)

Le système est configuré par défaut avec **3 environnements obligatoires** :

```
INTEGRATION → PREPROD → PRODUCTION
```

| Environnement | Branche | Org Type | Déploiement |
|--------------|---------|----------|-------------|
| INTEGRATION | `integration` | Integration Sandbox | Automatique (push) |
| PREPROD | Release branches | Pré-production Sandbox | Manuel via Actions |
| PRODUCTION | `main` | Production | Manuel via Actions |

### Pourquoi ajouter un environnement intermédiaire ?

Vous pourriez vouloir ajouter un environnement supplémentaire pour :

- **STAGING** : Tests de performance ou tests utilisateurs avant PREPROD
- **QA** : Tests qualité dédiés avec équipe QA séparée
- **DEV** : Environnement de développement partagé avant INTEGRATION
- **DEMO** : Environnement pour démonstrations clients

**Exemples d'architectures étendues** :

```
# Avec STAGING entre INTEGRATION et PREPROD
INTEGRATION → STAGING → PREPROD → PRODUCTION

# Avec QA entre INTEGRATION et PREPROD
INTEGRATION → QA → PREPROD → PRODUCTION

# Avec DEV avant INTEGRATION
DEV → INTEGRATION → PREPROD → PRODUCTION
```

## Avant de commencer

### Prérequis

- Les 3 environnements de base (INTEGRATION, PREPROD, PRODUCTION) sont configurés et fonctionnels
- Vous avez accès à :
  - Un Salesforce Sandbox pour le nouvel environnement
  - Les droits administrateur GitHub sur le repository
  - Le fichier `server.key` utilisé pour l'authentification JWT

### Ce dont vous aurez besoin

- Nom de l'environnement (ex: `STAGING`)
- Username Salesforce de l'org cible
- Accès Setup dans l'org Salesforce cible

### Estimation du temps

**30-45 minutes** pour la configuration complète

---

## Étape 1 : Planification

### 1.1 Choisir le nom de l'environnement

Choisissez un nom clair et conventionnel :

- **STAGING** : pré-production
- **QA** : tests qualité
- **DEV** : développement
- **DEMO** : démonstrations

**Convention de nommage** :
- Nom en MAJUSCULES (ex: `STAGING`)
- Branche Git en minuscules (ex: `staging`)
- Org alias en minuscules (ex: `staging`)

### 1.2 Déterminer la position dans le pipeline

Décidez où placer le nouvel environnement :

```
INTEGRATION → [VOTRE ENV] → PREPROD → PRODUCTION
```

### 1.3 Choisir le mode de déploiement

**Option A : Branche dédiée avec déploiement automatique**
- Une branche Git dédiée (ex: `staging`)
- Déploiement automatique lors du push sur cette branche
- Workflow `salesforce-cicd.yml` gère les déploiements

**Option B : Déploiement manuel via release branches**
- Pas de branche dédiée
- Déploiement manuel via workflow `deploy-release.yml`
- Utilise les release branches (`release/vX.Y.Z`)

**Recommandation** : Option A pour les environnements entre INTEGRATION et PREPROD, Option B pour les environnements après PREPROD.

---

## Étape 2 : Configuration Salesforce

### 2.1 Créer une Connected App avec JWT

**Suivez le guide JWT_SETUP_GUIDE.md** pour créer une Connected App dans le nouvel org Salesforce.

**Résumé des étapes** :

1. **Setup** → **App Manager** → **New Connected App**
2. Configurez :
   - Connected App Name: `GitHub CI/CD JWT`
   - API Name: `GitHub_CICD_JWT`
   - Enable OAuth Settings: ✅
   - Callback URL: `http://localhost:1717/OauthRedirect`
   - Use digital signatures: ✅ (uploadez `server.crt`)
   - OAuth Scopes: `api`, `refresh_token`, `web`
3. **Edit Policies** → **Permitted Users**: `Admin approved users are pre-authorized`
4. **Manage Profiles** → Ajoutez **System Administrator**
5. Copiez le **Consumer Key**

**IMPORTANT** : Utilisez le même certificat (`server.crt` / `server.key`) que pour les autres environnements.

### 2.2 Vérifier l'authentification localement

Testez la connexion JWT localement :

```bash
sf org login jwt \
  --client-id "VOTRE_CONSUMER_KEY" \
  --jwt-key-file server.key \
  --username "admin@company-staging.com" \
  --alias staging-test \
  --instance-url https://test.salesforce.com

sf org display --target-org staging-test
```

Si cela fonctionne, passez à l'étape suivante.

---

## Étape 3 : Configuration GitHub

### 3.1 Créer l'environnement GitHub

1. Allez dans **Settings** → **Environments**
2. Cliquez sur **New environment**
3. Nom: `STAGING` (en MAJUSCULES)
4. Cliquez sur **Configure environment**

### 3.2 Ajouter les 3 secrets

Dans l'environnement `STAGING`, ajoutez 3 secrets :

#### Secret 1 : SF_CONSUMER_KEY_STAGING

**Valeur** : Le Consumer Key copié depuis Salesforce

```
3MVG9wt4IL4O5wvK8Z9Y1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ
```

#### Secret 2 : SF_USERNAME_STAGING

**Valeur** : Le username Salesforce de l'org STAGING

```
admin@company-staging.com
```

#### Secret 3 : SF_PRIVATE_KEY_STAGING

**Valeur** : Le contenu COMPLET du fichier `server.key`

```
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC...
...
-----END PRIVATE KEY-----
```

### 3.3 Configurer les Required Reviewers

1. Dans l'environnement `STAGING`, section **Deployment protection rules**
2. Cochez **Required reviewers**
3. Ajoutez 1-2 reviewers selon vos besoins

**Recommandation** :
- INTEGRATION : 1 reviewer
- STAGING/QA : 1-2 reviewers
- PREPROD : 2 reviewers
- PRODUCTION : 2+ reviewers

---

## Étape 4 : Modifier les workflows

### 4.1 Workflow salesforce-cicd.yml (Option A - branche dédiée)

Si vous choisissez **Option A** (branche dédiée avec déploiement automatique), modifiez `.github/workflows/salesforce-cicd.yml`.

#### Modification 1 : Ajouter le trigger de branche

**Avant** (lignes 5-13) :

```yaml
on:
  push:
    branches:
      - integration
      - preprod
      - main
  pull_request:
    branches:
      - integration
      - preprod
      - main
```

**Après** :

```yaml
on:
  push:
    branches:
      - integration
      - staging      # ← AJOUT
      - preprod
      - main
  pull_request:
    branches:
      - integration
      - staging      # ← AJOUT
      - preprod
      - main
```

#### Modification 2 : Ajouter la détection d'environnement

**Avant** (lignes 61-77) :

```yaml
if [[ "$BRANCH" == "main" ]]; then
  echo "ENV_NAME=PRODUCTION" >> $GITHUB_OUTPUT
  echo "ORG_ALIAS=production" >> $GITHUB_OUTPUT
  echo "✅ Environment detected: PRODUCTION"
elif [[ "$BRANCH" == "preprod" ]]; then
  echo "ENV_NAME=PREPROD" >> $GITHUB_OUTPUT
  echo "ORG_ALIAS=preprod" >> $GITHUB_OUTPUT
  echo "✅ Environment detected: PREPROD"
elif [[ "$BRANCH" == "integration" ]]; then
  echo "ENV_NAME=INTEGRATION" >> $GITHUB_OUTPUT
  echo "ORG_ALIAS=integration" >> $GITHUB_OUTPUT
  echo "✅ Environment detected: INTEGRATION"
else
  echo "❌ Error: Branch $BRANCH is not configured for CI/CD"
  echo "Only integration, preprod, and main branches trigger deployments"
  exit 1
fi
```

**Après** :

```yaml
if [[ "$BRANCH" == "main" ]]; then
  echo "ENV_NAME=PRODUCTION" >> $GITHUB_OUTPUT
  echo "ORG_ALIAS=production" >> $GITHUB_OUTPUT
  echo "✅ Environment detected: PRODUCTION"
elif [[ "$BRANCH" == "preprod" ]]; then
  echo "ENV_NAME=PREPROD" >> $GITHUB_OUTPUT
  echo "ORG_ALIAS=preprod" >> $GITHUB_OUTPUT
  echo "✅ Environment detected: PREPROD"
elif [[ "$BRANCH" == "staging" ]]; then                    # ← AJOUT
  echo "ENV_NAME=STAGING" >> $GITHUB_OUTPUT                # ← AJOUT
  echo "ORG_ALIAS=staging" >> $GITHUB_OUTPUT               # ← AJOUT
  echo "✅ Environment detected: STAGING"                  # ← AJOUT
elif [[ "$BRANCH" == "integration" ]]; then
  echo "ENV_NAME=INTEGRATION" >> $GITHUB_OUTPUT
  echo "ORG_ALIAS=integration" >> $GITHUB_OUTPUT
  echo "✅ Environment detected: INTEGRATION"
else
  echo "❌ Error: Branch $BRANCH is not configured for CI/CD"
  echo "Only integration, staging, preprod, and main branches trigger deployments"  # ← MODIFIÉ
  exit 1
fi
```

**IMPORTANT** : Cette modification doit être répétée **3 fois** dans le fichier :
1. Job `validate` (lignes ~61-77)
2. Job `deploy` (lignes ~207-241)
3. Job `verify` (lignes ~317-351)

#### Modification 3 : Mettre à jour l'expression d'environnement (ligne 23)

**Avant** :

```yaml
environment: ${{ (github.event_name == 'pull_request' && github.base_ref || github.ref_name) == 'main' && 'PRODUCTION' || (github.event_name == 'pull_request' && github.base_ref || github.ref_name) == 'preprod' && 'PREPROD' || 'INTEGRATION' }}
```

**Après** :

```yaml
environment: ${{ (github.event_name == 'pull_request' && github.base_ref || github.ref_name) == 'main' && 'PRODUCTION' || (github.event_name == 'pull_request' && github.base_ref || github.ref_name) == 'preprod' && 'PREPROD' || (github.event_name == 'pull_request' && github.base_ref || github.ref_name) == 'staging' && 'STAGING' || 'INTEGRATION' }}
```

### 4.2 Workflow deploy-release.yml (Option B - déploiement manuel)

Si vous choisissez **Option B** (déploiement manuel via release), modifiez `.github/workflows/deploy-release.yml`.

#### Modification 1 : Ajouter l'option d'environnement

**Avant** (lignes 19-21) :

```yaml
target_environment:
  description: 'Target environment'
  required: true
  type: choice
  options:
    - PREPROD
    - PRODUCTION
```

**Après** :

```yaml
target_environment:
  description: 'Target environment'
  required: true
  type: choice
  options:
    - STAGING       # ← AJOUT
    - PREPROD
    - PRODUCTION
```

#### Modification 2 : Ajouter le mapping org alias

**Avant** (lignes 54-58) :

```yaml
if [[ "${{ github.event.inputs.target_environment }}" == "PRODUCTION" ]]; then
  echo "ORG_ALIAS=production" >> $GITHUB_OUTPUT
elif [[ "${{ github.event.inputs.target_environment }}" == "PREPROD" ]]; then
  echo "ORG_ALIAS=preprod" >> $GITHUB_OUTPUT
fi
```

**Après** :

```yaml
if [[ "${{ github.event.inputs.target_environment }}" == "PRODUCTION" ]]; then
  echo "ORG_ALIAS=production" >> $GITHUB_OUTPUT
elif [[ "${{ github.event.inputs.target_environment }}" == "PREPROD" ]]; then
  echo "ORG_ALIAS=preprod" >> $GITHUB_OUTPUT
elif [[ "${{ github.event.inputs.target_environment }}" == "STAGING" ]]; then  # ← AJOUT
  echo "ORG_ALIAS=staging" >> $GITHUB_OUTPUT                                   # ← AJOUT
fi
```

**IMPORTANT** : Cette modification doit être répétée **2 fois** dans le fichier :
1. Job `validate` (lignes ~54-58)
2. Job `quick-deploy` (lignes ~189-194)

---

## Étape 5 : Configuration Git

### 5.1 Créer la branche (Option A uniquement)

Si vous avez choisi **Option A** (branche dédiée), créez la branche :

```bash
# Depuis la branche integration
git checkout integration
git pull

# Créer la nouvelle branche
git checkout -b staging

# Pousser la branche vers GitHub
git push -u origin staging
```

### 5.2 Protéger la branche

1. Allez dans **Settings** → **Branches**
2. Sous **Branch protection rules**, cliquez **Add rule**
3. Branch name pattern: `staging`
4. Configurez les règles :
   - ✅ Require a pull request before merging
   - ✅ Require approvals: 1
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date before merging
5. **Save changes**

### 5.3 Configurer les règles de merge

Ajoutez les règles de merge dans la configuration de la branche :

- Autoriser merge depuis: `integration` uniquement
- Stratégie de merge: Merge commit (recommandé)

---

## Étape 6 : Test

### 6.1 Tester l'authentification GitHub Actions

Créez un commit de test sur la branche pour vérifier que l'authentification fonctionne :

```bash
# Sur la branche staging
echo "# Test STAGING" >> README_STAGING_TEST.md
git add README_STAGING_TEST.md
git commit -m "test: verify STAGING authentication"
git push
```

Vérifiez dans **Actions** que :
- Le workflow se déclenche automatiquement
- L'étape "Authenticate to Salesforce" réussit
- L'environnement détecté est `STAGING`

### 6.2 Tester un déploiement complet

#### Option A (branche dédiée)

1. Créez une PR depuis `integration` vers `staging`
2. Attendez la validation automatique
3. Mergez la PR
4. Vérifiez le déploiement automatique dans Actions

#### Option B (déploiement manuel)

1. Allez dans **Actions** → **Deploy Release to Environment**
2. Cliquez **Run workflow**
3. Sélectionnez :
   - Release version: `v1.0.0` (ou une release existante)
   - Target environment: `STAGING`
4. Validez le déploiement
5. Approuvez le quick deploy

### 6.3 Vérifications

Après un déploiement réussi, vérifiez :

- ✅ Le déploiement est visible dans Salesforce Setup → Deployment Status
- ✅ Les métadonnées sont présentes dans l'org STAGING
- ✅ Les tests Apex ont réussi
- ✅ Le coverage est suffisant (≥75%)

---

## Exemples complets

### Exemple 1 : Ajouter STAGING avec branche dédiée

**Contexte** : Vous voulez un environnement STAGING entre INTEGRATION et PREPROD pour des tests de performance.

**Configuration** :

```
INTEGRATION (auto) → STAGING (auto) → PREPROD (manuel) → PRODUCTION (manuel)
```

**Workflow** :

1. Feature branch → PR vers `integration` → merge → déploiement auto sur INTEGRATION
2. PR depuis `integration` vers `staging` → merge → déploiement auto sur STAGING
3. Tests de performance sur STAGING
4. Release depuis `staging` → déploiement manuel sur PREPROD
5. Tests PREPROD
6. Release depuis PREPROD → déploiement manuel sur PRODUCTION

**Modifications** :

- ✅ `salesforce-cicd.yml` : Ajouter `staging` dans triggers + détection environnement
- ✅ GitHub Environment `STAGING` avec 3 secrets
- ✅ Branche `staging` créée et protégée
- ✅ 1 reviewer requis sur `STAGING`

### Exemple 2 : Ajouter QA avec déploiement manuel

**Contexte** : Vous voulez un environnement QA entre INTEGRATION et PREPROD pour des tests qualité dédiés, sans branche dédiée.

**Configuration** :

```
INTEGRATION (auto) → QA (manuel) → PREPROD (manuel) → PRODUCTION (manuel)
```

**Workflow** :

1. Feature branch → PR vers `integration` → merge → déploiement auto sur INTEGRATION
2. Release depuis `integration` → déploiement manuel sur QA
3. Tests QA complets
4. Même release → déploiement manuel sur PREPROD
5. Tests PREPROD
6. Même release → déploiement manuel sur PRODUCTION

**Modifications** :

- ✅ `deploy-release.yml` : Ajouter option `QA` + mapping org alias
- ✅ GitHub Environment `QA` avec 3 secrets
- ✅ Pas de branche dédiée
- ✅ 2 reviewers requis sur `QA`

---

## Diagrammes

### Architecture avant ajout

```
┌─────────────┐
│ Feature     │
│ Branches    │
└──────┬──────┘
       │
       │ PR
       ▼
┌─────────────┐
│ INTEGRATION │ ← Déploiement automatique
│ (branche)   │
└──────┬──────┘
       │
       │ Create Release
       ▼
┌─────────────┐
│ Release     │
│ Branches    │
└──────┬──────┘
       │
       │ Manual Deploy
       ▼
┌─────────────┐
│     PREPROD     │ ← Déploiement manuel
└──────┬──────┘
       │
       │ Manual Deploy
       ▼
┌─────────────┐
│ PRODUCTION  │ ← Déploiement manuel
└─────────────┘
```

### Architecture après ajout de STAGING (Option A)

```
┌─────────────┐
│ Feature     │
│ Branches    │
└──────┬──────┘
       │
       │ PR
       ▼
┌─────────────┐
│ INTEGRATION │ ← Déploiement automatique
│ (branche)   │
└──────┬──────┘
       │
       │ PR
       ▼
┌─────────────┐
│   STAGING   │ ← Déploiement automatique  ← NOUVEAU
│ (branche)   │
└──────┬──────┘
       │
       │ Create Release
       ▼
┌─────────────┐
│ Release     │
│ Branches    │
└──────┬──────┘
       │
       │ Manual Deploy
       ▼
┌─────────────┐
│     PREPROD     │ ← Déploiement manuel
└──────┬──────┘
       │
       │ Manual Deploy
       ▼
┌─────────────┐
│ PRODUCTION  │ ← Déploiement manuel
└─────────────┘
```

### Architecture après ajout de QA (Option B)

```
┌─────────────┐
│ Feature     │
│ Branches    │
└──────┬──────┘
       │
       │ PR
       ▼
┌─────────────┐
│ INTEGRATION │ ← Déploiement automatique
│ (branche)   │
└──────┬──────┘
       │
       │ Create Release
       ▼
┌─────────────┐
│ Release     │
│ Branches    │
└──────┬──────┘
       │
       │ Manual Deploy (option QA)  ← NOUVEAU
       ├────────┐
       │        ▼
       │   ┌─────────────┐
       │   │     QA      │ ← Déploiement manuel
       │   └─────────────┘
       │
       │ Manual Deploy
       ▼
┌─────────────┐
│     PREPROD     │ ← Déploiement manuel
└──────┬──────┘
       │
       │ Manual Deploy
       ▼
┌─────────────┐
│ PRODUCTION  │ ← Déploiement manuel
└─────────────┘
```

---

## Dépannage

### Erreur : "JWT secrets not configured"

**Cause** : Les 3 secrets ne sont pas configurés dans l'environnement GitHub.

**Solution** :
1. Vérifiez dans **Settings** → **Environments** → **STAGING**
2. Vérifiez que les 3 secrets existent :
   - `SF_CONSUMER_KEY_STAGING`
   - `SF_USERNAME_STAGING`
   - `SF_PRIVATE_KEY_STAGING`
3. Vérifiez l'orthographe (sensible à la casse)

### Erreur : "Branch not configured for CI/CD"

**Cause** : La branche n'est pas ajoutée dans les triggers du workflow.

**Solution** :
1. Vérifiez `.github/workflows/salesforce-cicd.yml` lignes 5-13
2. Ajoutez votre branche dans `on.push.branches` et `on.pull_request.branches`

### Erreur : "user hasn't approved this consumer"

**Cause** : La Connected App n'est pas correctement configurée dans Salesforce.

**Solution** :
1. Dans Salesforce → Setup → App Manager → GitHub CI/CD JWT → Manage
2. **Edit Policies** → **Permitted Users**: `Admin approved users are pre-authorized`
3. **Manage Profiles** → Ajoutez **System Administrator**

### Workflow ne se déclenche pas

**Cause** : Les règles de protection de branche bloquent le push.

**Solution** :
1. Vérifiez les règles de protection de branche
2. Assurez-vous que les status checks ne bloquent pas le premier push
3. Désactivez temporairement "Require status checks" pour le premier push

### Déploiement échoue avec "invalid_grant"

**Cause** : Le certificat SSL ne correspond pas à la clé privée.

**Solution** :
1. Vérifiez que vous avez uploadé le bon `server.crt` dans Salesforce
2. Vérifiez que `SF_PRIVATE_KEY_STAGING` contient le bon contenu de `server.key`
3. Testez localement avec `sf org login jwt`

---

## Checklist de validation

Après avoir ajouté votre nouvel environnement, vérifiez :

- ✅ Connected App créée dans Salesforce avec JWT
- ✅ OAuth Policies configurées (Admin approved users + System Administrator profile)
- ✅ GitHub Environment créé avec les 3 secrets
- ✅ Reviewers configurés sur l'environnement GitHub
- ✅ Workflow(s) modifié(s) avec les nouvelles valeurs
- ✅ Branche créée et protégée (si Option A)
- ✅ Test d'authentification réussi
- ✅ Test de déploiement réussi
- ✅ Métadonnées déployées visibles dans l'org

---

## Ressources

- [JWT_SETUP_GUIDE.md](JWT_SETUP_GUIDE.md) : Guide complet de configuration JWT
- [RELEASE_PROCESS.md](RELEASE_PROCESS.md) : Processus de release
- [README.md](README.md) : Architecture complète du système
- [Salesforce JWT Flow](https://help.salesforce.com/s/articleView?id=sf.remoteaccess_oauth_jwt_flow.htm)
- [GitHub Environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)

---

Configuration terminée ! Votre nouvel environnement est prêt à être utilisé.
