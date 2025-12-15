# 🔄 Comparaison des Workflows CI/CD

Vous disposez maintenant de **2 workflows** différents pour gérer vos déploiements Salesforce. Voici comment choisir le bon.

---

## 📋 Workflows Disponibles

### 1️⃣ Salesforce CI/CD Pipeline (Automatique)
**Fichier** : `.github/workflows/salesforce-cicd.yml`

**Déclenchement** : Automatique
- Push sur `integration`, `uat`, ou `main`
- Pull Request vers `integration`, `uat`, ou `main`

**Type** : Pipeline GitOps classique

### 2️⃣ Salesforce Manual Pipeline (Manuel)
**Fichier** : `.github/workflows/salesforce-pipeline.yml`

**Déclenchement** : Manuel via bouton "Run workflow"

**Type** : Pipeline GitLab-style avec contrôle total

---

## 🆚 Comparaison Détaillée

| Caractéristique | Workflow Automatique | Workflow Manuel |
|----------------|---------------------|-----------------|
| **Déclenchement** | ✅ Automatique (Push/PR) | 🎮 Bouton manuel |
| **Contrôle** | ⚙️ Via approbations | 🎯 Total (formulaire) |
| **Validation** | ✅ Auto sur PR | 🎮 Bouton "validate" |
| **Déploiement** | ✅ Auto après approbation | 🎮 Bouton "deploy" |
| **Quick Deploy** | ✅ Oui | ✅ Oui |
| **Rollback** | ❌ Manuel (git revert) | ✅ Bouton "rollback" |
| **Environnements** | 🔀 Détecté auto (branche) | 🎯 Choix manuel (dropdown) |
| **Tests** | ✅ Adaptatif par env | ✅ Adaptatif par env |
| **Flexibilité** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Simplicité** | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Audit** | ✅ Git commits | ✅ Workflow runs |
| **Formation requise** | 🟢 Faible | 🟡 Moyenne |

---

## 🎯 Quand Utiliser Chaque Workflow

### Utilisez le Workflow AUTOMATIQUE si :

✅ **Vous voulez un processus GitOps classique**
- Push sur une branche = déploiement automatique
- Workflow simple et prévisible
- Moins de clics dans l'interface

✅ **Votre équipe est habituée à Git**
- Les développeurs connaissent git flow
- Branches = environnements
- Merge = déploiement

✅ **Vous voulez forcer le processus linéaire**
- feature → integration → uat → main
- Pas de déploiement "hors ordre"
- Conformité stricte au flow

✅ **Déploiements fréquents sur INTEGRATION**
- Chaque commit déclenche validation/déploiement
- Feedback rapide
- CI/CD continu

### Utilisez le Workflow MANUEL si :

✅ **Vous voulez un contrôle total type GitLab**
- Décider exactement quand chaque action se produit
- Pas de "surprise" de déploiement automatique
- Workflow visible et cliquable

✅ **Déploiements planifiés**
- Déploiements à des horaires précis
- Validation le matin, déploiement l'après-midi
- Coordination avec d'autres équipes

✅ **Besoin de rollback facile**
- Bouton dédié pour revenir en arrière
- Pas besoin de git revert
- Urgence en production

✅ **Formation/démonstration**
- Montrer clairement chaque étape
- Boutons explicites
- Moins "magique" que l'auto

✅ **Déploiements multi-environnements flexibles**
- Tester directement sur UAT sans passer par INTEGRATION
- Re-valider sur PRODUCTION après un fix
- Scénarios non-linéaires

---

## 📊 Scénarios d'Utilisation

### Scénario 1 : Développement quotidien
**Recommandation** : **Workflow Automatique**

```bash
# Développeur
git checkout -b feature/my-feature
# ... code ...
git push origin feature/my-feature

# Pull Request → integration
# ✅ Workflow automatique valide
# ✅ Reviewer approuve
# ✅ Merge → déploiement auto sur INTEGRATION
```

**Avantages** :
- Rapide et fluide
- Pas de manipulation manuelle
- Process standard

---

### Scénario 2 : Release en production planifiée
**Recommandation** : **Workflow Manuel**

```
09:00 - Validation UAT
  → Actions > Manual Pipeline
  → Target: UAT, Action: validate
  → ✅ Job ID: 0Af...

10:00 - Déploiement UAT (après réunion)
  → Actions > Manual Pipeline
  → Target: UAT, Action: deploy, Job ID: 0Af...
  → ✅ Déployé

14:00 - Validation PRODUCTION
  → Actions > Manual Pipeline
  → Target: PRODUCTION, Action: validate
  → ✅ Job ID: 0Af...

16:00 - Déploiement PRODUCTION (fenêtre de maintenance)
  → Actions > Manual Pipeline
  → Target: PRODUCTION, Action: deploy, Job ID: 0Af...
  → ✅ Déployé
```

**Avantages** :
- Contrôle précis du timing
- Pas de déploiement accidentel
- Validation et déploiement séparés

---

### Scénario 3 : Hotfix urgent
**Recommandation** : **Workflow Manuel** (plus rapide)

```
1. Créer le fix
   git checkout -b hotfix/urgent-bug
   # ... fix ...
   git push

2. Déployer directement sur PRODUCTION
   → Actions > Manual Pipeline
   → Target: PRODUCTION, Action: deploy
   → ✅ Déployé immédiatement

3. Si problème → Rollback instantané
   → Actions > Manual Pipeline
   → Target: PRODUCTION, Action: rollback
   → ✅ Restauré en 2 minutes
```

**Avantages** :
- Déploiement le plus rapide possible
- Rollback en un clic
- Pas de passage obligatoire par INTEGRATION/UAT

---

## 🔀 Peut-on Utiliser les Deux ?

**OUI ! Les deux workflows coexistent parfaitement.**

### Stratégie Recommandée : Hybride

**Workflow Automatique** pour :
- ✅ INTEGRATION (dev quotidien)
- ✅ Pull Requests (validation automatique)

**Workflow Manuel** pour :
- ✅ UAT (déploiements planifiés)
- ✅ PRODUCTION (contrôle total)
- ✅ Rollbacks (urgences)
- ✅ Re-validations

### Configuration Hybride

**Désactiver les déploiements auto sur UAT/PROD** :

Modifiez `.github/workflows/salesforce-cicd.yml` :

```yaml
on:
  push:
    branches:
      - integration  # ✅ Garder auto sur INTEGRATION
      # - uat        # ❌ Désactiver auto sur UAT
      # - main       # ❌ Désactiver auto sur PRODUCTION
  pull_request:
    branches:
      - integration
      - uat
      - main
```

**Résultat** :
- Push sur INTEGRATION = déploiement auto ✅
- Push sur UAT/MAIN = validation seulement (via PR) ✅
- Déploiement UAT/PROD = Manuel uniquement ✅

---

## 🎓 Recommandations par Équipe

### Petite Équipe (1-3 devs)
**Recommandation** : **Workflow Automatique uniquement**
- Plus simple à comprendre
- Moins de clics
- Workflow GitOps standard

### Équipe Moyenne (4-10 devs)
**Recommandation** : **Hybride** (Auto INTEGRATION, Manuel UAT/PROD)
- Dev rapide sur INTEGRATION
- Contrôle sur releases
- Équilibre simplicité/contrôle

### Grande Équipe (10+ devs)
**Recommandation** : **Workflow Manuel uniquement**
- Contrôle total requis
- Déploiements coordonnés
- Audit et compliance
- Change management process

### Équipe Agile avec CI/CD Continu
**Recommandation** : **Workflow Automatique uniquement**
- Déploiement continu
- Trunk-based development
- Feature flags
- Rollback via code

### Équipe avec Releases Planifiées
**Recommandation** : **Workflow Manuel uniquement**
- Release trains
- Fenêtres de déploiement fixes
- Approbations business
- Change Advisory Board (CAB)

---

## 📚 Guides Détaillés

- **Workflow Automatique** : Voir [QUICK_START.md](QUICK_START.md)
- **Workflow Manuel** : Voir [MANUAL_PIPELINE_GUIDE.md](MANUAL_PIPELINE_GUIDE.md)
- **Approbations** : Voir [APPROVALS_SETUP.md](APPROVALS_SETUP.md)
- **JWT Setup** : Voir [JWT_SETUP_GUIDE.md](JWT_SETUP_GUIDE.md)

---

## 🚀 Commencer Maintenant

### Pour tester le Workflow Manuel :

1. Allez sur **GitHub → Actions**
2. Cliquez sur **"Salesforce Manual Pipeline"**
3. Cliquez sur **"Run workflow"**
4. Choisissez :
   - Target : **INTEGRATION**
   - Action : **validate**
5. Cliquez **"Run workflow"**
6. Suivez le guide [MANUAL_PIPELINE_GUIDE.md](MANUAL_PIPELINE_GUIDE.md)

### Pour tester le Workflow Automatique :

1. Créez une branche feature
2. Faites un commit
3. Push vers GitHub
4. Créez une Pull Request vers `integration`
5. Le workflow se déclenche automatiquement
6. Suivez le guide [QUICK_START.md](QUICK_START.md)

---

**Vous avez maintenant le meilleur des deux mondes ! 🎉**

Automatisation quand vous en avez besoin, contrôle manuel quand vous le voulez.
