# Configuration des Environnements GitHub

Ce document décrit comment configurer les 4 environnements dans GitHub pour le CI/CD Salesforce.

## Étapes de Configuration

### 1. Créer les Environnements dans GitHub

Allez dans votre repository GitHub : **Settings > Environments**

Créez les 3 environnements suivants pour le pipeline CI/CD :

#### Environnement 1 : INTEGRATION
- **Nom** : `INTEGRATION`
- **Protection** : 
  - ✅ Required reviewers : 1 reviewer minimum
- **Branch** : `integration`
- **Note** : Premier environnement du pipeline CI/CD

#### Environnement 2 : UAT
- **Nom** : `UAT`
- **Protection** :
  - ✅ Required reviewers : 2 reviewers minimum
  - ✅ Wait timer : 5 minutes (optionnel)
- **Branch** : `uat`

#### Environnement 3 : PRODUCTION
- **Nom** : `PRODUCTION`
- **Protection** :
  - ✅ Required reviewers : 2+ reviewers (équipe release)
  - ✅ Wait timer : 10 minutes
  - ✅ Deployment branches : Only main branch
- **Branch** : `main`

**Note importante** : L'environnement DEV n'a pas besoin de configuration GitHub car le développement se fait directement via VS Code sans passer par le pipeline CI/CD.

### 2. Configurer les Secrets par Environnement

Pour chaque environnement **du pipeline CI/CD**, ajoutez le secret suivant :

#### Secret : `SFDX_AUTH_URL_{ENV_NAME}`

Exemples :
- `SFDX_AUTH_URL_INTEGRATION`
- `SFDX_AUTH_URL_UAT`
- `SFDX_AUTH_URL_PRODUCTION`

**Note** : Vous n'avez besoin que de 3 secrets. L'environnement DEV est géré via VS Code.

### 3. Générer les Auth URLs Salesforce

Pour chaque org Salesforce, exécutez :

```bash
# 1. Authentifiez-vous à votre org
sf org login web --alias dev-sandbox --instance-url https://test.salesforce.com

# 2. Générez l'Auth URL
sf org display --target-org dev-sandbox --verbose

# 3. Copiez la valeur "Sfdx Auth Url"
# Elle ressemble à : force://PlatformCLI::xxxxx@xxxxx.my.salesforce.com
```

### 4. Ajouter les Secrets dans GitHub

1. Allez dans **Settings > Secrets and variables > Actions**
2. Pour chaque environnement, cliquez sur **New environment secret**
3. Ajoutez le secret avec la valeur Auth URL correspondante

## Structure des Branches

```
main (PRODUCTION)
  ↑
uat (UAT)
  ↑
integration (INTEGRATION) ← Premier environnement du pipeline CI/CD
  ↑
develop (DEV) ← Développement direct via VS Code (pas de CI/CD)
  ↑
feature/xxx (branches de développement)
```

**Important** : Le pipeline CI/CD ne se déclenche qu'à partir de la branche `integration`.

## Workflow de Déploiement

### Développement
```bash
# Travail quotidien sur DEV via VS Code
# Utiliser Salesforce Extension Pack pour deploy/retrieve
git checkout develop
git pull
# ... développement avec VS Code ...
git add .
git commit -m "feat: nouvelle fonctionnalité"
git push origin develop
```

### Pull Request vers develop
- Créez une PR si nécessaire pour code review
- Pas de déploiement automatique
- Le développeur déploie manuellement via VS Code

### Promotion vers INTEGRATION (DÉBUT DU CI/CD)
```bash
git checkout integration
git pull origin integration
git merge develop
git push origin integration
```
- Validation manuelle requise (1 reviewer)
- Pipeline CI/CD se déclenche automatiquement
- Déploiement vers INTEGRATION après approbation

### Promotion vers UAT
```bash
git checkout uat
git merge integration
git push origin uat
```
- Validation manuelle requise (2 reviewers)
- Déploiement vers UAT après approbation

### Promotion vers PRODUCTION
```bash
git checkout main
git merge uat
git push origin main
```
- Validation manuelle requise (2+ reviewers)
- Wait timer de 10 minutes
- Déploiement vers PRODUCTION après approbation

## Protection des Branches

Configurez les règles de protection dans **Settings > Branches** :

### Branch `main`
- ✅ Require a pull request before merging
- ✅ Require approvals : 2
- ✅ Require status checks to pass
- ✅ Require branches to be up to date
- ✅ Include administrators

### Branch `uat`
- ✅ Require a pull request before merging
- ✅ Require approvals : 2
- ✅ Require status checks to pass

### Branch `integration`
- ✅ Require a pull request before merging
- ✅ Require approvals : 1
- ✅ Require status checks to pass

### Branch `develop`
- ✅ Require a pull request before merging
- ✅ Require approvals : 1

## Vérification de la Configuration

Après configuration, testez avec :

```bash
# Test sur develop
git checkout develop
git commit --allow-empty -m "test: CI/CD configuration"
git push origin develop
```

Vérifiez dans l'onglet **Actions** que le workflow s'exécute correctement.
