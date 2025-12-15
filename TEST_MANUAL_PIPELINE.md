# 🧪 Tester le Pipeline Manuel - Guide Rapide

## ⚡ Test Rapide (5 minutes)

Testez votre nouveau pipeline manuel en 3 étapes simples :

### Étape 1 : Accéder au workflow ⏱️ 30 secondes

1. Allez sur GitHub → Votre repository
2. Cliquez sur **Actions** (menu du haut)
3. Dans la liste à gauche, trouvez **"Salesforce Manual Pipeline"**
4. Cliquez dessus

Vous devriez voir un bouton **"Run workflow"** en haut à droite.

---

### Étape 2 : Lancer une validation ⏱️ 2 minutes

1. Cliquez sur le bouton **"Run workflow"**
2. Un formulaire apparaît avec 3 champs :

**Remplissez** :
- **Use workflow from** : Branch `feature/my-new-feature` (ou votre branche actuelle)
- **Target environment to deploy** : `INTEGRATION`
- **Action to perform** : `validate`
- **Validation Job ID** : *(laisser vide)*

3. Cliquez sur **"Run workflow"** (bouton vert)

**Résultat attendu** :
- Un nouveau workflow démarre
- Status passe à "Running" (orange)
- Après ~2 minutes : Status "Success" (vert) ✅

---

### Étape 3 : Récupérer le Job ID ⏱️ 30 secondes

1. Cliquez sur le workflow qui vient de se terminer
2. Cliquez sur le job **"Validate on INTEGRATION"**
3. Déroulez la section **"Validation Summary"** (tout en bas)
4. Vous verrez :

```
## ✅ Validation Successful

**Environment:** INTEGRATION
**Job ID:** 0Afd200000K9HqvCAF

### 🚀 Next Step: Deploy
...
```

5. **Copiez le Job ID** (ex: `0Afd200000K9HqvCAF`)

---

### Étape 4 : Déployer avec Quick Deploy ⏱️ 2 minutes

1. Retournez sur **Actions** → **Salesforce Manual Pipeline**
2. Cliquez à nouveau sur **"Run workflow"**
3. Cette fois, remplissez :

**Remplissez** :
- **Use workflow from** : `feature/my-new-feature`
- **Target environment to deploy** : `INTEGRATION`
- **Action to perform** : `deploy`
- **Validation Job ID** : `0Afd200000K9HqvCAF` *(collez votre Job ID)*

4. Cliquez sur **"Run workflow"**

**Résultat attendu** :
- Workflow démarre
- Après ~30 secondes : **Quick Deploy** terminé ⚡
- Status "Success" (vert) ✅
- Votre code est déployé sur l'org INTEGRATION ! 🎉

---

## ✅ Succès !

Si vous avez réussi ces 4 étapes, votre pipeline manuel fonctionne parfaitement ! 🎉

### Ce que vous avez appris :

1. ✅ Comment valider manuellement sur un environnement
2. ✅ Comment récupérer un Job ID
3. ✅ Comment faire un Quick Deploy
4. ✅ Interface du workflow manuel

---

## 🧪 Tests Avancés

### Test 1 : Rollback

Si vous voulez tester le rollback :

1. **Actions** → **Salesforce Manual Pipeline** → **Run workflow**
2. Remplissez :
   - Environment : `INTEGRATION`
   - Action : `rollback`
   - Job ID : *(laisser vide)*
3. Cliquez **Run workflow**

Résultat : Déploiement de la version Git précédente sur INTEGRATION

---

### Test 2 : Déploiement sans Job ID

Pour tester un déploiement "classique" (sans Quick Deploy) :

1. **Actions** → **Salesforce Manual Pipeline** → **Run workflow**
2. Remplissez :
   - Environment : `INTEGRATION`
   - Action : `deploy`
   - Job ID : *(laisser vide)*
3. Cliquez **Run workflow**

Résultat : Déploiement complet avec ré-exécution des tests (~2-3 minutes au lieu de 30 secondes)

---

### Test 3 : Validation sur UAT

⚠️ **Prérequis** : Avoir configuré les secrets JWT pour UAT

1. **Actions** → **Salesforce Manual Pipeline** → **Run workflow**
2. Remplissez :
   - Environment : `UAT`
   - Action : `validate`
   - Job ID : *(laisser vide)*
3. Cliquez **Run workflow**

Résultat : Validation sur l'org UAT avec **RunLocalTests** (tous les tests de l'org)

---

## 🚨 Dépannage

### Erreur : "JWT secrets not configured"

**Cause** : Les secrets JWT ne sont pas configurés pour cet environnement

**Solution** :
1. Allez sur **Settings** → **Environments** → **INTEGRATION**
2. Vérifiez que ces 3 secrets existent :
   - `SF_CONSUMER_KEY_INTEGRATION`
   - `SF_USERNAME_INTEGRATION`
   - `SF_PRIVATE_KEY_INTEGRATION`
3. Si manquants : Suivez [JWT_SETUP_GUIDE.md](JWT_SETUP_GUIDE.md)

---

### Erreur : "Failed to extract Job ID"

**Cause** : La validation a échoué, aucun Job ID n'a été créé

**Solution** :
1. Cliquez sur le workflow en erreur
2. Regardez les logs détaillés
3. Corrigez le problème (tests qui échouent, code invalide, etc.)
4. Relancez la validation

---

### Le workflow ne se lance pas

**Cause** : Le fichier workflow n'est pas encore sur GitHub

**Solution** :
1. Vérifiez que vous avez bien poussé vos changements :
   ```bash
   git push origin feature/my-new-feature
   ```
2. Le workflow doit être présent dans le repository pour apparaître dans Actions

---

### Le bouton "Run workflow" est grisé

**Cause** : Vous n'avez pas les permissions nécessaires

**Solution** :
- Assurez-vous d'être collaborateur du repository
- Ou forkez le repository et testez sur votre fork

---

## 📊 Comprendre l'Interface

### Status des Workflows

| Icône | Status | Signification |
|-------|--------|---------------|
| 🟠 | In progress | En cours d'exécution |
| 🟢 | Success | Terminé avec succès |
| 🔴 | Failure | Échec |
| ⚪ | Queued | En attente de démarrage |
| ⏸️ | Waiting | En attente d'approbation |

### Formulaire "Run workflow"

**Use workflow from** :
- Sélectionnez la branche Git à déployer
- Par défaut : branche actuelle

**Target environment** :
- `INTEGRATION` : Environnement de dev/test
- `UAT` : Environnement de recette
- `PRODUCTION` : Environnement de production

**Action** :
- `validate` : Valider le code (crée un Job ID)
- `deploy` : Déployer le code
- `rollback` : Revenir à la version précédente

**Validation Job ID** :
- Laisser vide pour validate ou rollback
- Remplir pour Quick Deploy après validation

---

## 🎓 Prochaines Étapes

Une fois que vous maîtrisez le pipeline manuel :

1. **Configurez UAT et PRODUCTION**
   - Suivez [JWT_SETUP_GUIDE.md](JWT_SETUP_GUIDE.md) pour UAT et PRODUCTION
   - Testez le pipeline complet INTEGRATION → UAT → PRODUCTION

2. **Configurez les approbations**
   - Suivez [APPROVALS_SETUP.md](APPROVALS_SETUP.md)
   - Ajoutez des reviewers pour chaque environnement

3. **Établissez un processus**
   - Décidez quand utiliser validate vs deploy direct
   - Définissez qui peut déployer sur chaque environnement
   - Créez une checklist de déploiement

4. **Documentez votre processus**
   - Créez un runbook pour les déploiements
   - Formez l'équipe au workflow manuel
   - Établissez des guidelines (qui fait quoi, quand)

---

## 📚 Documentation Complète

- **Guide complet du workflow manuel** : [MANUAL_PIPELINE_GUIDE.md](MANUAL_PIPELINE_GUIDE.md)
- **Comparaison workflows** : [WORKFLOWS_COMPARISON.md](WORKFLOWS_COMPARISON.md)
- **Setup JWT** : [JWT_SETUP_GUIDE.md](JWT_SETUP_GUIDE.md)
- **Setup Approbations** : [APPROVALS_SETUP.md](APPROVALS_SETUP.md)

---

**Bon test ! 🚀**

Si tout fonctionne, vous disposez maintenant d'un pipeline Salesforce CI/CD avec contrôle manuel total, exactement comme sur GitLab !
