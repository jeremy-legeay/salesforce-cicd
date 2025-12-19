# 🚀 Processus de Release

Guide simplifié pour gérer les releases Salesforce avec GitHub Actions.

## 📋 Vue d'ensemble

Ce système permet de :
- ✅ Sélectionner les PRs à inclure dans une release via des **labels**
- ✅ Créer un package de release déployable
- ✅ Déployer le **même package** sur PREPROD puis PRODUCTION
- ✅ Backporter automatiquement les hotfixes vers `integration`

---

## 🔄 Workflow de développement

### 1. Développement quotidien

```
feature/ma-fonctionnalite → PR → integration → ORG INTEGRATION (automatique)
```

1. Créer une branche depuis `integration` : `feature/ma-fonctionnalite`
2. Développer et commiter les changements
3. Créer une Pull Request vers `integration`
4. **Ajouter un label de release** si cette PR doit être incluse dans une prochaine release (ex: `release-v1.2.0`)
5. Après merge, le déploiement sur ORG INTEGRATION se fait automatiquement

### 2. Labellisation des PRs

**Quand ajouter un label de release ?**
- Pendant la création de la PR, ou
- Avant la merge de la PR

**Format du label** : `release-v1.2.0` (créer le label dans GitHub si nécessaire)

**Exemple** :
- PR #15 → Label `release-v1.2.0` → Sera incluse dans la release v1.2.0
- PR #16 → Pas de label → Ne sera pas incluse dans la release v1.2.0

---

## 📦 Créer une Release

### Via GitHub UI (100% sans ligne de commande)

1. **Aller dans Actions** → `Create Release Package`

2. **Cliquer sur "Run workflow"**

3. **Remplir le formulaire** :
   - **Release version** : `v1.2.0` (format vX.Y.Z)
   - **Label to filter PRs** : `release-v1.2.0` (doit correspondre au label sur vos PRs)
   - **Base branch** : `integration` (par défaut)

4. **Lancer** : Le workflow va :
   - ✅ Trouver toutes les PRs merged avec le label `release-v1.2.0`
   - ✅ Créer la branche `release/v1.2.0`
   - ✅ Générer le manifest de release
   - ✅ Créer une GitHub Release (en draft)

5. **Résultat** :
   - Branche `release/v1.2.0` créée
   - GitHub Release visible dans l'onglet Releases (draft)
   - Liste des PRs incluses dans les release notes

### Vérification

- Consulter le **Summary** du workflow pour voir les PRs incluses
- Vérifier la **GitHub Release** (onglet Releases)
- Publier la release quand prêt

---

## 🎯 Déployer une Release

### Déploiement sur PREPROD

1. **Aller dans Actions** → `Deploy Release to Environment`

2. **Cliquer sur "Run workflow"**

3. **Remplir le formulaire** :
   - **Release version** : `v1.2.0`
   - **Target environment** : `PREPROD`

4. **Lancer** : Le workflow va :
   - ✅ Checkout de la branche `release/v1.2.0`
   - ✅ Authentification JWT sur PREPROD
   - ✅ Déploiement avec RunLocalTests
   - ✅ Vérification et validation

5. **Tester sur PREPROD** : Tests fonctionnels, validation métier

### Déploiement sur PRODUCTION

**⚠️ Important** : Déployez le **même package** testé sur PREPROD !

1. **Aller dans Actions** → `Deploy Release to Environment`

2. **Cliquer sur "Run workflow"**

3. **Remplir le formulaire** :
   - **Release version** : `v1.2.0` (même version que PREPROD)
   - **Target environment** : `PRODUCTION`

4. **Lancer** : Le déploiement utilisera exactement la même branche et le même code que PREPROD

5. **Après déploiement** :
   - Merger `release/v1.2.0` → `main`
   - Synchroniser `main` → `integration`

---

## 🔥 Hotfixes

### Appliquer un hotfix sur une release

Si un bug est découvert sur PREPROD ou PRODUCTION après une release :

1. **Créer une branche depuis la release** :
   ```bash
   git checkout release/v1.2.0
   git checkout -b hotfix/fix-bug-critique
   ```

2. **Développer le fix** et commiter

3. **Créer une PR vers `release/v1.2.0`**
   - Base: `release/v1.2.0`
   - Head: `hotfix/fix-bug-critique`

4. **Validation automatique** 🤖 :
   - Le workflow `Validate Hotfix PR` se déclenche automatiquement
   - **Validation sur PREPROD** (dry-run + RunLocalTests)
   - **Validation sur PRODUCTION** (dry-run + RunLocalTests)
   - Commentaires automatiques sur la PR avec résultats
   - ✅ La PR ne peut être mergée que si les 2 validations passent

5. **Merger la PR** (après validation réussie)

6. **Backport automatique** 🤖 :
   - Le workflow `Auto-Backport Hotfix` se déclenche automatiquement
   - Il crée une branche `backport/pr-XX-to-integration`
   - Il cherry-pick le commit
   - Il crée une PR vers `integration`

7. **Reviewer et merger** la PR de backport

8. **Re-déployer** la release mise à jour :
   - Actions → `Deploy Release to Environment` → PREPROD
   - Tests sur PREPROD
   - Actions → `Deploy Release to Environment` → PRODUCTION

### ✅ Avantages de la validation automatique

- **Détection précoce** : Les erreurs sont détectées avant le merge
- **Gain de temps** : Validation IDs générés pour quick deploy
- **Confiance** : Le hotfix est testé sur PREPROD et PROD avant merge
- **Traçabilité** : Commentaires automatiques sur la PR avec résultats détaillés

### En cas de conflits

Si le backport automatique échoue (conflits détectés) :

1. Un **commentaire sera ajouté** sur la PR d'origine avec les instructions manuelles
2. Suivre les commandes indiquées pour résoudre les conflits
3. Créer manuellement la PR de backport vers `integration`

---

## 📊 Récapitulatif des workflows

| Workflow | Déclenchement | Usage |
|----------|---------------|-------|
| **Salesforce CI/CD** | Push/PR sur `integration` | ✅ Automatique - Déploiement continu sur INTEGRATION |
| **Create Release Package** | Manuel (workflow_dispatch) | 📦 Créer une release avec les PRs labelisées |
| **Deploy Release to Environment** | Manuel (workflow_dispatch) | 🚀 Déployer une release sur PREPROD ou PRODUCTION |
| **Auto-Backport Hotfix** | PR merged sur `release/**` | 🔄 Automatique - Backporter les hotfixes vers integration |

---

## 🎓 Exemple complet

### Scénario : Release v1.2.0 avec 3 features

**Semaine 1-2 : Développement**

1. Dev A : Feature user profile
   - Branche `feature/user-profile` → PR #20 → Label `release-v1.2.0` → Merge

2. Dev B : Feature notifications
   - Branche `feature/notifications` → PR #21 → Label `release-v1.2.0` → Merge

3. Dev C : Bug fix mineur
   - Branche `fix/typo` → PR #22 → **Pas de label** → Merge

**Semaine 3 : Création de la release**

4. Actions → `Create Release Package`
   - Version: `v1.2.0`
   - Label: `release-v1.2.0`
   - Résultat : Branche `release/v1.2.0` avec PR #20 et #21 (pas la #22)

**Semaine 3 : Déploiement PREPROD**

5. Actions → `Deploy Release to Environment`
   - Version: `v1.2.0`
   - Target: `PREPROD`
   - Tests sur PREPROD OK ✅

**Semaine 4 : Bug découvert sur PREPROD**

6. Hotfix urgent
   - Branche `hotfix/fix-notif-bug` depuis `release/v1.2.0`
   - PR #25 vers `release/v1.2.0` → Merge
   - **Backport automatique** vers `integration` ✅

7. Re-déploiement PREPROD avec le fix
   - Actions → `Deploy Release to Environment`
   - Version: `v1.2.0` (mise à jour)
   - Target: `PREPROD`
   - Tests OK ✅

**Semaine 4 : Déploiement PRODUCTION**

8. Actions → `Deploy Release to Environment`
   - Version: `v1.2.0`
   - Target: `PRODUCTION`
   - Déploiement réussi ✅

9. Post-déploiement
   - Merger `release/v1.2.0` → `main`
   - Merger `main` → `integration`
   - Publier la GitHub Release

---

## ⚙️ Configuration requise

### Secrets GitHub

Configurer ces secrets dans **Settings → Environments** :

**INTEGRATION**
- `SF_CONSUMER_KEY_INTEGRATION`
- `SF_USERNAME_INTEGRATION`
- `SF_PRIVATE_KEY_INTEGRATION`

**PREPROD**
- `SF_CONSUMER_KEY_PREPROD`
- `SF_USERNAME_PREPROD`
- `SF_PRIVATE_KEY_PREPROD`

**PRODUCTION**
- `SF_CONSUMER_KEY_PRODUCTION`
- `SF_USERNAME_PRODUCTION`
- `SF_PRIVATE_KEY_PRODUCTION`

Voir [JWT_SETUP_GUIDE.md](JWT_SETUP_GUIDE.md) pour la configuration détaillée.

---

## 🆘 Dépannage

### "No PRs found with label X"
→ Vérifier que vos PRs merged ont bien le label spécifié

### "JWT secrets not configured"
→ Vérifier que les secrets sont dans le bon Environment (pas dans Repository secrets)

### "Cherry-pick failed - conflicts detected"
→ Suivre les instructions du commentaire automatique sur la PR

### Workflow non visible dans Actions
→ Les workflows avec `workflow_dispatch` doivent être sur `main` pour être visibles

---

## 📚 Documentation complémentaire

- [JWT_SETUP_GUIDE.md](JWT_SETUP_GUIDE.md) - Configuration JWT détaillée
- [AJOUT_ENVIRONNEMENT.md](AJOUT_ENVIRONNEMENT.md) - Ajouter des environnements intermédiaires (QA, STAGING, etc.)
- [GIT_COMMANDS.md](GIT_COMMANDS.md) - Commandes Git utiles
- [BEST_PRACTICES.md](BEST_PRACTICES.md) - Bonnes pratiques Salesforce
- [archive/](archive/) - Ancienne documentation (référence)
