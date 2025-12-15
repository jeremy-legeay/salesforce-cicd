# 🚀 CI/CD Salesforce - Guide Complet

## 👋 Bienvenue !

Ce package contient **TOUT** ce dont vous avez besoin pour mettre en place un pipeline CI/CD complet pour Salesforce avec GitHub Actions et 4 environnements.

---

## 📚 Documentation disponible

### 🌟 COMMENCEZ ICI

| Fichier | Description | Temps |
|---------|-------------|-------|
| **📖 [QUICK_START.md](QUICK_START.md)** | Installation rapide étape par étape | ⏱️ 10 min |
| **📘 [README.md](README.md)** | Documentation complète et détaillée | ⏱️ 30 min |
| **📋 [STRUCTURE.txt](STRUCTURE.txt)** | Vue d'ensemble de tous les fichiers | ⏱️ 2 min |

### 📖 Guides supplémentaires

| Fichier | Description | Pour qui ? |
|---------|-------------|-----------|
| **💡 [BEST_PRACTICES.md](BEST_PRACTICES.md)** | Bonnes pratiques et conventions | Toute l'équipe |
| **💻 [DEV_WORKFLOW.md](DEV_WORKFLOW.md)** | Guide développement sur DEV via VS Code | Développeurs |
| **⚙️ [ENVIRONMENTS_SETUP.md](ENVIRONMENTS_SETUP.md)** | Configuration GitHub détaillée | Admin/DevOps |
| **🔀 [GIT_COMMANDS.md](GIT_COMMANDS.md)** | Commandes Git essentielles | Développeurs |
| **📁 [FILE_STRUCTURE.md](FILE_STRUCTURE.md)** | Description de chaque fichier | Admin/DevOps |

---

## 🏗️ Fichiers techniques

### Configuration Salesforce

| Fichier | Usage |
|---------|-------|
| `sfdx-project.json` | Configuration du projet SFDX |
| `.forceignore` | Exclusions de déploiement Salesforce |
| `manifest/package.xml` | Définition des métadonnées à déployer |
| `manifest/destructiveChanges.xml` | Suppressions de métadonnées (optionnel) |

### GitHub Actions

| Fichier | Usage |
|---------|-------|
| `.github/workflows/salesforce-cicd.yml` | Pipeline CI/CD automatisé |

### Code Salesforce

| Fichier | Usage |
|---------|-------|
| `force-app/main/default/classes/SmokeTestClass.cls` | Tests post-déploiement |
| `force-app/main/default/classes/SmokeTestClass.cls-meta.xml` | Métadonnées de la classe |

### Scripts

| Fichier | Usage |
|---------|-------|
| `scripts/deploy.sh` | Script de déploiement manuel avancé |

### Git

| Fichier | Usage |
|---------|-------|
| `.gitignore` | Exclusions Git (secrets, cache, etc.) |

---

## 🎯 Par où commencer ?

### Si vous avez 10 minutes ⚡
1. Lisez [QUICK_START.md](QUICK_START.md)
2. Suivez les étapes pas à pas
3. Testez votre premier déploiement

### Si vous avez 1 heure 📚
1. Lisez [README.md](README.md) en entier
2. Configurez tous les environnements
3. Lisez [BEST_PRACTICES.md](BEST_PRACTICES.md)
4. Partagez avec l'équipe

### Si vous êtes pressé 🏃
1. Ouvrez [STRUCTURE.txt](STRUCTURE.txt)
2. Copiez tous les fichiers dans votre repo
3. Suivez la checklist dans QUICK_START.md

---

## ✅ Installation rapide (résumé)

```bash
# 1. Copier les fichiers
cp -r salesforce-cicd/* votre-repo/
cd votre-repo/

# 2. Commit
git add .
git commit -m "chore: setup CI/CD pipeline"
git push origin main

# 3. Configurer GitHub
# - Créer 4 environnements (DEV, INTEGRATION, UAT, PRODUCTION)
# - Ajouter 4 secrets SFDX_AUTH_URL
# - Protéger les branches

# 4. Tester
git checkout -b test/cicd
echo "test" >> README.md
git add README.md
git commit -m "test: verify pipeline"
git push origin test/cicd
# Créer une PR vers develop
```

---

## 📊 Vue d'ensemble du pipeline

```
┌─────────────┐
│   develop   │ ← DEV: Développement via VS Code (PAS de CI/CD)
└──────┬──────┘
       │ merge
       ▼
┌─────────────┐      ┌──────────────┐
│integration  │ ───► │ INTEGRATION  │ ← 🚀 DÉBUT du pipeline CI/CD
│             │      │ (1 reviewer) │
└──────┬──────┘      └──────────────┘
       │ merge
       ▼
┌─────────────┐      ┌──────────────┐
│     uat     │ ───► │     UAT      │
│             │      │ (2 reviewers)│
└──────┬──────┘      └──────────────┘
       │ merge
       ▼
┌─────────────┐      ┌──────────────┐
│    main     │ ───► │  PRODUCTION  │
│             │      │(2+ reviewers)│
└─────────────┘      │  + 10min     │
                     └──────────────┘
```

---

## 🔑 Secrets GitHub requis

Pour chaque environnement **du pipeline CI/CD**, créez un secret :

```
Environment: INTEGRATION
└── Secret: SFDX_AUTH_URL_INTEGRATION

Environment: UAT
└── Secret: SFDX_AUTH_URL_UAT

Environment: PRODUCTION
└── Secret: SFDX_AUTH_URL_PRODUCTION
```

**⚠️ Important** : Vous n'avez besoin que de **3 secrets** (pas DEV). L'environnement DEV est géré via VS Code.

**Comment générer un Auth URL ?**
```bash
sf org login web --alias my-org
sf org display --target-org my-org --verbose
# Copiez la ligne "Sfdx Auth Url"
```

---

## 🎓 Pour l'équipe de développement

### Documents essentiels à lire

1. **[GIT_COMMANDS.md](GIT_COMMANDS.md)** - Toutes les commandes Git nécessaires
2. **[BEST_PRACTICES.md](BEST_PRACTICES.md)** - Conventions de code et commits
3. **[README.md](README.md)** - Workflow de déploiement

### Workflow quotidien

```bash
# 1. Créer une feature branch
git checkout develop
git pull
git checkout -b feature/nouvelle-fonctionnalite

# 2. Développer
# ... faire vos modifications ...

# 3. Commit
git add .
git commit -m "feat: description"

# 4. Push et créer une PR
git push origin feature/nouvelle-fonctionnalite
# → Créer PR vers develop sur GitHub

# 5. Après merge → Auto-deploy sur DEV
```

---

## 🛠️ Pour les administrateurs

### Responsabilités

- ✅ Configurer les 4 environnements GitHub
- ✅ Gérer les secrets (Auth URLs)
- ✅ Configurer les branch protection rules
- ✅ Donner les accès aux reviewers
- ✅ Monitorer les déploiements
- ✅ Former l'équipe

### Documents à maîtriser

1. **[ENVIRONMENTS_SETUP.md](ENVIRONMENTS_SETUP.md)** - Configuration complète
2. **[README.md](README.md)** - Section Dépannage
3. **[BEST_PRACTICES.md](BEST_PRACTICES.md)** - Maintenance régulière

---

## 🐛 Dépannage rapide

| Problème | Solution |
|----------|----------|
| "Invalid client credentials" | Régénérer Auth URL → Mettre à jour secret GitHub |
| Tests échouent | Vérifier en local d'abord avec `sf apex run test` |
| Timeout | Augmenter `--wait` dans le workflow |
| Conflit de merge | Voir [GIT_COMMANDS.md](GIT_COMMANDS.md) section "Résolution de conflits" |
| Branche non protégée | Configurer dans Settings > Branches |

---

## 📞 Support

### Documentation officielle

- 🔗 [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/)
- 🔗 [GitHub Actions Documentation](https://docs.github.com/en/actions)
- 🔗 [Salesforce CLI Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/)

### Dans ce package

- Pour les questions techniques → [README.md](README.md)
- Pour les commandes Git → [GIT_COMMANDS.md](GIT_COMMANDS.md)
- Pour les bonnes pratiques → [BEST_PRACTICES.md](BEST_PRACTICES.md)
- Pour la configuration → [ENVIRONMENTS_SETUP.md](ENVIRONMENTS_SETUP.md)

---

## 📈 Statistiques du package

- **📁 Total fichiers** : 17
- **📄 Documentation** : 7 fichiers
- **⚙️ Configuration** : 6 fichiers
- **💻 Code** : 2 fichiers
- **📜 Scripts** : 1 fichier
- **🔒 Git** : 1 fichier

---

## ✅ Checklist finale

Avant de considérer l'installation terminée :

- [ ] Tous les fichiers copiés dans le repository
- [ ] Structure `.github/workflows/` créée
- [ ] 3 environnements configurés dans GitHub (pas DEV)
- [ ] 3 secrets SFDX_AUTH_URL ajoutés (pas DEV)
- [ ] Branch protection rules configurées
- [ ] VS Code installé + Salesforce Extension Pack
- [ ] Authentification VS Code vers sandbox DEV
- [ ] Premier test développement via VS Code
- [ ] Premier test pipeline sur `integration`
- [ ] Équipe formée sur le workflow
- [ ] Documentation distribuée à l'équipe
- [ ] Bonnes pratiques partagées
- [ ] Plan de maintenance établi

---

## 🎉 C'est parti !

Vous avez maintenant tout ce qu'il faut pour :
- ✅ Déployer automatiquement sur 4 environnements
- ✅ Valider le code avec des tests automatiques
- ✅ Contrôler les déploiements avec des approbations
- ✅ Suivre les bonnes pratiques Git et Salesforce
- ✅ Former votre équipe efficacement

**Bon déploiement ! 🚀**

---

*Questions ? Consultez [README.md](README.md) ou ouvrez une issue sur GitHub.*
