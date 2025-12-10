# 🚀 Guide d'Installation Rapide - CI/CD Salesforce

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
sf org login web --alias dev-sandbox --instance-url https://test.salesforce.com

# 2. Obtenir l'Auth URL
sf org display --target-org dev-sandbox --verbose
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
- Status checks : `validate` et `deploy`

#### Branche `uat`
- ✅ Require pull request
- ✅ Require 2 approvals
- ✅ Require status checks

#### Branche `integration`
- ✅ Require pull request
- ✅ Require 1 approval
- ✅ Require status checks

#### Branche `develop`
- ✅ Require pull request
- ✅ Require 1 approval

### 5. Tester le pipeline

```bash
# Créer une branche de test
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
1. Créez une PR vers `develop`
2. Vérifiez que les tests automatiques s'exécutent dans l'onglet **Actions**
3. Mergez la PR
4. Vérifiez que le déploiement vers DEV fonctionne

### 6. Workflow quotidien

```bash
# Développement sur DEV (via VS Code)
# - Utiliser Salesforce Extension Pack
# - Deploy/Retrieve directement depuis VS Code
# - Commiter dans 'develop' branch

# Promotion vers INTEGRATION (début du CI/CD)
git checkout integration
git merge develop
git push
# → Attendre approbation (1 reviewer) → Déploiement auto

# Promotion vers UAT
git checkout uat
git merge integration
git push
# → Attendre approbations (2 reviewers) → Déploiement auto

# Promotion vers PRODUCTION
git checkout main
git merge uat
git push
# → Attendre approbations (2+ reviewers) + timer → Déploiement
```

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
