# 📁 Structure du Projet CI/CD Salesforce

## Vue d'ensemble des fichiers

```
salesforce-cicd/
│
├── 📘 Documentation
│   ├── README.md                          # Documentation principale complète
│   ├── QUICK_START.md                     # Guide d'installation rapide (10 min)
│   ├── BEST_PRACTICES.md                  # Bonnes pratiques et conventions
│   └── ENVIRONMENTS_SETUP.md              # Configuration détaillée des environnements
│
├── 🔧 Configuration Salesforce
│   ├── sfdx-project.json                  # Configuration du projet SFDX
│   ├── .forceignore                       # Fichiers à exclure du déploiement
│   └── manifest/
│       ├── package.xml                    # Définition des métadonnées à déployer
│       └── destructiveChanges.xml         # Suppressions de métadonnées (optionnel)
│
├── 🤖 GitHub Actions
│   └── salesforce-cicd.yml                # Workflow principal CI/CD
│       ├── Job 1: Validate (tests + validation)
│       ├── Job 2: Deploy (avec approbation manuelle)
│       └── Job 3: Verify (smoke tests post-déploiement)
│
├── 💻 Code Salesforce
│   └── force-app/
│       └── main/
│           └── default/
│               └── classes/
│                   ├── SmokeTestClass.cls           # Tests post-déploiement
│                   └── SmokeTestClass.cls-meta.xml
│
├── 📜 Scripts
│   └── scripts/
│       └── deploy.sh                      # Script de déploiement manuel avancé
│
└── 🔒 Configuration Git
    └── .gitignore                         # Fichiers à exclure du repository

```

## Détail des fichiers

### 📘 Documentation (4 fichiers)

#### README.md
- **Usage** : Documentation principale du projet
- **Contenu** :
  - Architecture des 4 environnements
  - Prérequis et installation
  - Configuration complète
  - Workflow de déploiement
  - Commandes utiles
  - Dépannage

#### QUICK_START.md
- **Usage** : Guide d'installation rapide
- **Temps de lecture** : 5 minutes
- **Temps d'installation** : 10 minutes
- **Contenu** :
  - Installation pas à pas
  - Configuration minimale
  - Premier test
  - Checklist de vérification

#### BEST_PRACTICES.md
- **Usage** : Guide des bonnes pratiques
- **Contenu** :
  - Principes généraux du CI/CD
  - Gestion des branches
  - Tests Apex et couverture de code
  - Sécurité et secrets
  - Déploiement en production
  - Maintenance

#### ENVIRONMENTS_SETUP.md
- **Usage** : Configuration détaillée des environnements GitHub
- **Contenu** :
  - Création des 4 environnements
  - Configuration des secrets
  - Génération des Auth URLs
  - Protection des branches
  - Workflow de promotion

---

### 🔧 Configuration Salesforce (3 fichiers)

#### sfdx-project.json
- **Usage** : Configuration du projet Salesforce DX
- **Contenu** :
  - Répertoire de package
  - Version API (59.0)
  - Login URL

#### .forceignore
- **Usage** : Exclure certains fichiers du déploiement
- **Contient** :
  - Cache Salesforce
  - Fichiers de configuration IDE
  - Node modules
  - Tests LWC

#### manifest/package.xml
- **Usage** : Définir quelles métadonnées déployer
- **Contient** :
  - Apex Classes
  - Triggers
  - LWC / Aura Components
  - Objects, Fields, Layouts
  - Flows, Profiles, Permission Sets
  - Reports, Dashboards
  - Custom Settings, Labels

#### manifest/destructiveChanges.xml
- **Usage** : Supprimer des métadonnées lors du déploiement
- **⚠️ Attention** : À utiliser avec précaution en PRODUCTION
- **Exemple d'usage** : Supprimer des classes obsolètes, champs non utilisés

---

### 🤖 GitHub Actions (1 fichier)

#### .github/workflows/salesforce-cicd.yml
- **Usage** : Pipeline CI/CD automatisé
- **Déclenché par** : Push ou Pull Request sur develop, integration, uat, main

**Job 1: Validate (5-10 minutes)**
- Checkout du code
- Installation Salesforce CLI
- Authentification à l'org cible
- Exécution des tests Apex (RunLocalTests)
- Validation du déploiement (check-only)

**Job 2: Deploy (10-20 minutes)**
- ⏸️ Attente de l'approbation manuelle (selon environnement)
- Authentification
- Déploiement réel des métadonnées
- Exécution des tests
- Notification du résultat

**Job 3: Verify (2-5 minutes)**
- Tests de vérification post-déploiement (smoke tests)
- Vérification de l'état de l'org

**Environnements supportés** :
- DEV → Déploiement automatique (0 reviewer)
- INTEGRATION → 1 reviewer requis
- UAT → 2 reviewers requis + 5 min timer
- PRODUCTION → 2+ reviewers requis + 10 min timer

---

### 💻 Code Salesforce (2 fichiers)

#### force-app/main/default/classes/SmokeTestClass.cls
- **Usage** : Classe de tests post-déploiement
- **Tests inclus** :
  - Opérations CRUD de base
  - Déclenchement des triggers
  - Règles de validation
  - Permissions utilisateur
  - Custom settings
  - Opérations asynchrones
  - Intégrations externes (avec mock)

#### force-app/main/default/classes/SmokeTestClass.cls-meta.xml
- **Usage** : Métadonnées de la classe Apex
- **Version API** : 59.0

---

### 📜 Scripts (1 fichier)

#### scripts/deploy.sh
- **Usage** : Script bash pour déploiements manuels avancés
- **Commandes** :
  ```bash
  ./deploy.sh dev validate         # Valider DEV
  ./deploy.sh production deploy    # Déployer en PROD
  ```
- **Fonctionnalités** :
  - Validation de l'environnement
  - Vérification d'authentification
  - Support des destructive changes
  - Confirmation pour PRODUCTION
  - Logs colorés et détaillés
  - Gestion des erreurs

---

### 🔒 Configuration Git (1 fichier)

#### .gitignore
- **Usage** : Exclure certains fichiers du repository Git
- **Exclut** :
  - Cache Salesforce (.sfdx/, .sf/)
  - Node modules
  - Logs
  - Fichiers système (DS_Store, Thumbs.db)
  - Configuration IDE (.vscode/, .idea/)
  - **Auth files (CRITIQUE pour la sécurité)**
  - Certificats et clés

---

## 🎯 Fichiers par cas d'usage

### Premier déploiement
1. ✅ QUICK_START.md
2. ✅ README.md
3. ✅ ENVIRONMENTS_SETUP.md

### Développement quotidien
1. ✅ BEST_PRACTICES.md
2. ✅ package.xml (modifier selon besoins)
3. ✅ SmokeTestClass.cls (ajouter vos tests)

### Déploiement manuel
1. ✅ scripts/deploy.sh
2. ✅ manifest/package.xml

### Dépannage
1. ✅ README.md (section Dépannage)
2. ✅ Logs GitHub Actions
3. ✅ BEST_PRACTICES.md

---

## 📊 Statistiques

- **Total fichiers** : 14
- **Lignes de code workflow** : ~350
- **Lignes de documentation** : ~1200
- **Temps installation** : 10 minutes
- **Temps premier déploiement** : 15 minutes

---

## 🚀 Prochaines étapes

1. **Lire** QUICK_START.md pour installer rapidement
2. **Configurer** les 4 environnements dans GitHub
3. **Tester** avec un déploiement sur DEV
4. **Former** l'équipe avec BEST_PRACTICES.md
5. **Personnaliser** package.xml selon vos besoins
6. **Ajouter** vos propres tests Apex

---

## ✅ Checklist de mise en place

- [ ] Tous les fichiers copiés dans le repository
- [ ] Structure de répertoires créée correctement
- [ ] .github/workflows/ créé avec salesforce-cicd.yml
- [ ] 4 environnements configurés dans GitHub
- [ ] 4 secrets SFDX_AUTH_URL ajoutés
- [ ] Branches protégées configurées
- [ ] Premier test réussi sur develop
- [ ] Équipe formée sur le workflow
- [ ] Documentation lue par tous

---

**Bon déploiement ! 🎉**
