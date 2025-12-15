# 🎮 Guide du Pipeline Manuel Salesforce

Ce guide explique comment utiliser le pipeline manuel step-by-step pour déployer sur INTEGRATION, UAT et PRODUCTION.

## 🎯 Vue d'ensemble

Le pipeline manuel vous permet de contrôler chaque étape du déploiement avec des **boutons** dans GitHub Actions, exactement comme sur GitLab.

### Workflow en 3 étapes

```
┌─────────────────┐
│  1. VALIDATE    │  ← Bouton "Run workflow" avec action=validate
└────────┬────────┘
         │ ✅ Job ID créé
         ▼
┌─────────────────┐
│  2. DEPLOY      │  ← Bouton "Run workflow" avec action=deploy + Job ID
└────────┬────────┘
         │ ✅ Déployé
         ▼
┌─────────────────┐
│  3. NEXT ENV    │  ← Répéter sur UAT, puis PRODUCTION
└─────────────────┘
```

## 🚀 Comment utiliser le pipeline

### Étape 1 : Accéder au workflow manuel

1. Allez sur GitHub → Votre repository
2. Cliquez sur **Actions** (en haut)
3. Dans la liste de gauche, cliquez sur **"Salesforce Manual Pipeline"**
4. Cliquez sur le bouton **"Run workflow"** (à droite)

### Étape 2 : Formulaire de lancement

Vous verrez un formulaire avec 3 champs :

#### 🎯 Target environment
- **INTEGRATION** : Environnement de développement/test
- **UAT** : Environnement de recette utilisateur
- **PRODUCTION** : Environnement de production

#### ⚙️ Action to perform
- **validate** : Valider le code sans déployer (crée un Job ID)
- **deploy** : Déployer le code (avec ou sans Job ID)
- **rollback** : Revenir à la version précédente

#### 🔑 Validation Job ID (optionnel)
- Laissez vide pour une validation
- Remplissez avec le Job ID après validation pour un Quick Deploy

---

## 📋 Scénario complet : Feature → Production

### 1️⃣ Déploiement sur INTEGRATION

#### A. Valider sur INTEGRATION

1. **Actions** → **Salesforce Manual Pipeline** → **Run workflow**
2. Remplissez :
   - Target environment : **INTEGRATION**
   - Action : **validate**
   - Validation Job ID : *(laisser vide)*
3. Cliquez **Run workflow**

**Résultat** :
- ✅ Tests exécutés (SmokeTestClass)
- ✅ Validation réussie
- ✅ **Job ID créé** : `0Afd200000K9HqvCAF` (exemple)

#### B. Copier le Job ID

1. Cliquez sur le workflow qui vient de se terminer
2. Cliquez sur **"Validate on INTEGRATION"**
3. Descendez jusqu'à **"Validation Summary"**
4. Copiez le **Job ID** affiché (ex: `0Afd200000K9HqvCAF`)

#### C. Déployer sur INTEGRATION

1. **Actions** → **Salesforce Manual Pipeline** → **Run workflow**
2. Remplissez :
   - Target environment : **INTEGRATION**
   - Action : **deploy**
   - Validation Job ID : `0Afd200000K9HqvCAF` *(collez le Job ID)*
3. Cliquez **Run workflow**

**Résultat** :
- ⚡ **Quick Deploy** (pas de ré-exécution des tests)
- ✅ Code déployé dans ORG INTEGRATION
- 🎉 INTEGRATION terminé !

---

### 2️⃣ Déploiement sur UAT

#### A. Créer une branche release (optionnel mais recommandé)

```bash
git checkout integration
git pull
git checkout -b release/v1.0.0
git push origin release/v1.0.0
```

#### B. Valider sur UAT

1. **Actions** → **Salesforce Manual Pipeline** → **Run workflow**
2. Remplissez :
   - Target environment : **UAT**
   - Action : **validate**
   - Validation Job ID : *(laisser vide)*
3. Cliquez **Run workflow**

**Résultat** :
- ✅ Tests exécutés (RunLocalTests - tous les tests de l'org)
- ✅ Validation réussie
- ✅ **Job ID créé** : `0Afd200000K9XyzCAF` (exemple)

#### C. Déployer sur UAT

1. **Actions** → **Salesforce Manual Pipeline** → **Run workflow**
2. Remplissez :
   - Target environment : **UAT**
   - Action : **deploy**
   - Validation Job ID : `0Afd200000K9XyzCAF` *(le Job ID de UAT)*
3. Cliquez **Run workflow**

**Résultat** :
- ⚡ Quick Deploy
- ✅ Code déployé dans ORG UAT
- 🎉 UAT terminé !

---

### 3️⃣ Déploiement sur PRODUCTION

#### A. Merger vers main

```bash
git checkout uat
git pull
git checkout main
git pull
git merge uat
git push origin main
```

#### B. Valider sur PRODUCTION

1. **Actions** → **Salesforce Manual Pipeline** → **Run workflow**
2. Remplissez :
   - Target environment : **PRODUCTION**
   - Action : **validate**
   - Validation Job ID : *(laisser vide)*
3. Cliquez **Run workflow**

**Résultat** :
- ✅ Tests exécutés (RunLocalTests)
- ✅ Validation réussie
- ✅ **Job ID créé** : `0Afd200000K9AbcCAF` (exemple)

#### C. Déployer sur PRODUCTION

⚠️ **ATTENTION : Déploiement en PRODUCTION**

1. **Actions** → **Salesforce Manual Pipeline** → **Run workflow**
2. Remplissez :
   - Target environment : **PRODUCTION**
   - Action : **deploy**
   - Validation Job ID : `0Afd200000K9AbcCAF` *(le Job ID de PRODUCTION)*
3. Cliquez **Run workflow**
4. **Attendre l'approbation** (si configurée)

**Résultat** :
- ⚡ Quick Deploy
- ✅ Code déployé dans ORG PRODUCTION
- 🎉 **Pipeline complet terminé !**

---

## 🔄 Rollback (retour arrière)

Si un déploiement cause des problèmes :

### Rollback sur n'importe quel environnement

1. **Actions** → **Salesforce Manual Pipeline** → **Run workflow**
2. Remplissez :
   - Target environment : *(l'environnement à rollback)*
   - Action : **rollback**
   - Validation Job ID : *(laisser vide)*
3. Cliquez **Run workflow**

**Résultat** :
- ⏪ Déploiement de la version Git précédente
- ✅ Org restauré à l'état précédent

---

## 📊 Avantages du Pipeline Manuel

### ✅ Contrôle total
- Vous décidez **quand** chaque étape s'exécute
- Boutons clairs dans l'interface GitHub
- Pas de déploiement automatique non souhaité

### ⚡ Quick Deploy
- Validation une fois, déploiement instantané
- Pas de ré-exécution des tests entre validate et deploy
- Gain de temps considérable

### 🎯 Step-by-step
- Une étape à la fois
- Vérification possible entre chaque étape
- Retour arrière facile

### 📝 Traçabilité
- Chaque action est enregistrée dans GitHub
- Historique complet des déploiements
- Audit trail pour la compliance

---

## 🆚 Comparaison avec l'ancien workflow automatique

| Feature | Ancien (Auto) | Nouveau (Manuel) |
|---------|---------------|------------------|
| Déclenchement | Push/PR automatique | Bouton manuel |
| Contrôle | Limité | Total |
| Validation | Automatique | À la demande |
| Déploiement | Auto après approbation | Bouton dédié |
| Quick Deploy | ✅ | ✅ |
| Rollback | ❌ | ✅ Bouton dédié |
| Flexibilité | Moyenne | Maximale |

---

## 🔧 Configuration requise

### Secrets GitHub (par environnement)

Pour chaque environnement (INTEGRATION, UAT, PRODUCTION) :

```
SF_CONSUMER_KEY_INTEGRATION
SF_USERNAME_INTEGRATION
SF_PRIVATE_KEY_INTEGRATION

SF_CONSUMER_KEY_UAT
SF_USERNAME_UAT
SF_PRIVATE_KEY_UAT

SF_CONSUMER_KEY_PRODUCTION
SF_USERNAME_PRODUCTION
SF_PRIVATE_KEY_PRODUCTION
```

### Environnements GitHub

Créez 3 environnements dans Settings → Environments :
- **INTEGRATION**
- **UAT**
- **PRODUCTION**

(Voir [APPROVALS_SETUP.md](APPROVALS_SETUP.md) pour la configuration des approbations)

---

## 💡 Tips & Best Practices

### 1. Toujours valider avant de déployer
```
✅ VALIDATE → DEPLOY (avec Job ID)
❌ DEPLOY direct (sans validation)
```

### 2. Tester dans l'ordre
```
INTEGRATION → UAT → PRODUCTION
```
Ne jamais sauter UAT !

### 3. Conserver les Job IDs
Copiez-les dans un fichier texte ou un ticket Jira pendant le processus.

### 4. Vérifier le summary
Après chaque étape, consultez le "Summary" du workflow qui contient :
- Le Job ID
- Les prochaines étapes
- Les instructions

### 5. Utiliser les branches release
```bash
# Pour UAT
git checkout -b release/v1.0.0

# Pour PRODUCTION
git tag v1.0.0
```

---

## 🆘 Troubleshooting

### "Validation failed"
→ Regardez les logs détaillés dans le job "Validate"
→ Corrigez les erreurs de code
→ Relancez la validation

### "Deploy without Job ID is slow"
→ Normal, c'est un déploiement complet
→ Utilisez toujours validate → deploy pour Quick Deploy

### "Job ID not found"
→ Le Job ID expire après 10 jours
→ Relancez une validation pour obtenir un nouveau Job ID

### "Secrets not configured"
→ Vérifiez Settings → Environments → [ENV] → Secrets
→ Assurez-vous que les 3 secrets existent

---

## 📚 Ressources

- [JWT_SETUP_GUIDE.md](JWT_SETUP_GUIDE.md) - Configuration JWT
- [APPROVALS_SETUP.md](APPROVALS_SETUP.md) - Configuration des approbations
- [QUICK_START.md](QUICK_START.md) - Guide de démarrage rapide

---

## 🎬 Exemple visuel

### Validation
![Validation Form](https://via.placeholder.com/600x200?text=Target:+INTEGRATION+|+Action:+validate)

### Déploiement
![Deploy Form](https://via.placeholder.com/600x200?text=Target:+INTEGRATION+|+Action:+deploy+|+JobID:+0Af...)

### Rollback
![Rollback Form](https://via.placeholder.com/600x200?text=Target:+UAT+|+Action:+rollback)

---

**Profitez de votre nouveau pipeline manuel ! 🚀**
