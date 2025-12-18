# 🔀 Commandes Git pour le CI/CD Salesforce

## 📋 Table des matières
- [Configuration initiale](#configuration-initiale)
- [Workflow quotidien](#workflow-quotidien)
- [Gestion des branches](#gestion-des-branches)
- [Résolution de conflits](#résolution-de-conflits)
- [Commandes avancées](#commandes-avancées)
- [Corrections d'erreurs](#corrections-derreurs)

---

## Configuration initiale

### Cloner le repository
```bash
git clone https://github.com/votre-org/salesforce-cicd.git
cd salesforce-cicd
```

### Configurer votre identité
```bash
git config user.name "Votre Nom"
git config user.email "votre.email@company.com"
```

### Vérifier la configuration
```bash
git config --list
```

### Créer les branches principales (une seule fois)
```bash
# Créer integration depuis main
git checkout main
git checkout -b integration
git push origin integration

# Note : Les branches preprod et main sont gérées via les release branches
# Voir RELEASE_PROCESS.md pour plus de détails
```

---

## Workflow quotidien

### 1. Commencer une nouvelle fonctionnalité

```bash
# Se placer sur integration et récupérer les dernières modifications
git checkout integration
git pull origin integration

# Créer une nouvelle branche de feature
git checkout -b feature/JIRA-123-add-validation-rule

# Vérifier sur quelle branche vous êtes
git branch
# * feature/JIRA-123-add-validation-rule
```

### 2. Développer et commiter

```bash
# Voir les fichiers modifiés
git status

# Ajouter les fichiers au commit
git add force-app/main/default/classes/MyNewClass.cls
git add force-app/main/default/classes/MyNewClass.cls-meta.xml

# Ou ajouter tous les fichiers modifiés
git add .

# Commiter avec un message clair
git commit -m "feat(validation): add email validation rule for Contact"

# Pousser vers GitHub
git push origin feature/JIRA-123-add-validation-rule
```

### 3. Créer une Pull Request

```bash
# Après le push, GitHub affichera un lien pour créer une PR
# Ou allez sur GitHub UI : Pull Requests > New Pull Request
# Base: integration <- Compare: feature/JIRA-123-add-validation-rule
```

### 4. Après merge : nettoyer

```bash
# Supprimer la branche locale
git branch -d feature/JIRA-123-add-validation-rule

# Supprimer la branche remote (si pas automatique)
git push origin --delete feature/JIRA-123-add-validation-rule

# Mettre à jour integration
git checkout integration
git pull origin integration
```

---

## Gestion des branches

### Voir toutes les branches

```bash
# Branches locales
git branch

# Branches locales et remote
git branch -a

# Branches avec derniers commits
git branch -v
```

### Changer de branche

```bash
# Changer vers une branche existante
git checkout integration

# Créer et changer vers une nouvelle branche
git checkout -b feature/new-feature

# Créer une branche depuis une autre
git checkout -b feature/new-feature integration
```

### Promouvoir entre environnements

**Note** : Le système utilise des release branches pour PREPROD et PRODUCTION.
Consultez [RELEASE_PROCESS.md](RELEASE_PROCESS.md) pour le workflow complet.

#### Via Releases (recommandé)
```bash
# 1. Créer une release depuis integration via GitHub Actions
#    Actions → Create Release Package

# 2. Déployer sur PREPROD via GitHub Actions
#    Actions → Deploy Release to Environment → Target: PREPROD

# 3. Déployer sur PRODUCTION via GitHub Actions
#    Actions → Deploy Release to Environment → Target: PRODUCTION

# 4. Après déploiement PRODUCTION, synchroniser main
git checkout release/v1.2.0
git push origin release/v1.2.0
# Puis merger via PR : release/v1.2.0 → main
```

### Synchroniser les branches

```bash
# Récupérer toutes les modifications du remote
git fetch --all

# Mettre à jour la branche courante
git pull

# Mettre à jour toutes les branches
git fetch --all
git pull --all
```

---

## Résolution de conflits

### Détecter les conflits

```bash
git merge integration
# Auto-merging file.cls
# CONFLICT (content): Merge conflict in force-app/main/default/classes/MyClass.cls
# Automatic merge failed; fix conflicts and then commit the result.
```

### Résoudre les conflits

```bash
# 1. Voir les fichiers en conflit
git status

# 2. Ouvrir les fichiers et chercher les marqueurs de conflit:
# <<<<<<< HEAD
# Votre version
# =======
# Leur version
# >>>>>>> integration

# 3. Éditer manuellement pour garder la bonne version

# 4. Marquer comme résolu
git add force-app/main/default/classes/MyClass.cls

# 5. Finaliser le merge
git commit -m "chore: resolve merge conflict in MyClass"

# 6. Pousser
git push origin votre-branche
```

### Annuler un merge en cours

```bash
# Si vous voulez abandonner le merge
git merge --abort
```

---

## Commandes avancées

### Voir l'historique

```bash
# Historique simple
git log

# Historique graphique
git log --oneline --graph --all

# Historique d'un fichier
git log -- force-app/main/default/classes/MyClass.cls

# Derniers 5 commits
git log -5
```

### Comparer des versions

```bash
# Différences non commitées
git diff

# Différences entre deux branches
git diff integration..integration

# Différences d'un fichier spécifique
git diff integration..integration -- manifest/package.xml
```

### Stash (mettre de côté des modifications)

```bash
# Sauvegarder les modifications en cours
git stash

# Voir la liste des stash
git stash list

# Réappliquer le dernier stash
git stash pop

# Réappliquer un stash spécifique
git stash apply stash@{0}

# Supprimer un stash
git stash drop stash@{0}
```

### Cherry-pick (appliquer un commit spécifique)

```bash
# Appliquer un commit d'une autre branche
git cherry-pick <commit-hash>

# Exemple : récupérer un hotfix
git checkout integration
git cherry-pick abc1234
```

### Tags (versions)

```bash
# Créer un tag
git tag -a v1.0.0 -m "Release 1.0.0"

# Pousser le tag
git push origin v1.0.0

# Pousser tous les tags
git push origin --tags

# Voir les tags
git tag

# Supprimer un tag local
git tag -d v1.0.0

# Supprimer un tag remote
git push origin --delete v1.0.0
```

---

## Corrections d'erreurs

### Annuler le dernier commit (pas encore pushé)

```bash
# Garder les modifications
git reset --soft HEAD~1

# Supprimer les modifications
git reset --hard HEAD~1
```

### Modifier le dernier commit

```bash
# Ajouter des fichiers oubliés
git add forgotten-file.cls
git commit --amend --no-edit

# Modifier le message du commit
git commit --amend -m "New commit message"
```

### Annuler un commit déjà pushé

```bash
# Créer un nouveau commit qui annule les modifications
git revert <commit-hash>
git push origin votre-branche
```

### Forcer un push (⚠️ DANGEREUX)

```bash
# À utiliser UNIQUEMENT sur vos branches personnelles
git push origin feature/ma-branche --force

# ❌ JAMAIS sur integration, integration, preprod ou main
```

### Récupérer une branche supprimée

```bash
# Voir les branches supprimées récemment
git reflog

# Recréer la branche
git checkout -b feature/recovered <commit-hash>
```

### Nettoyer les branches obsolètes

```bash
# Supprimer les branches locales déjà mergées
git branch --merged integration | grep -v "integration" | xargs git branch -d

# Nettoyer les références remote obsolètes
git remote prune origin
```

---

## Bonnes pratiques

### Messages de commit

Suivre la convention :
```bash
git commit -m "type(scope): description"

# Types:
feat:     # Nouvelle fonctionnalité
fix:      # Correction de bug
refactor: # Refactoring
test:     # Ajout de tests
docs:     # Documentation
chore:    # Maintenance
style:    # Formatage (pas de changement de code)

# Exemples:
git commit -m "feat(validation): add email validation for Contact"
git commit -m "fix(trigger): correct null pointer in AccountTrigger"
git commit -m "test(api): add unit tests for REST endpoint"
git commit -m "docs(readme): update deployment instructions"
```

### Commits atomiques

```bash
# ✅ GOOD: Un commit par fonctionnalité
git add force-app/main/default/classes/EmailValidator.cls
git commit -m "feat: add email validator class"

git add force-app/main/default/classes/EmailValidatorTest.cls
git commit -m "test: add tests for email validator"

# ❌ BAD: Tout dans un seul commit
git add .
git commit -m "various changes"
```

### Synchronisation régulière

```bash
# Chaque matin
git checkout integration
git pull origin integration

# Avant de créer une PR
git checkout feature/ma-branche
git pull origin integration
# Résoudre les conflits si nécessaire
```

---

## Aide-mémoire rapide

```bash
# Commandes les plus utilisées
git status              # Voir l'état
git add .               # Ajouter tous les fichiers
git commit -m "msg"     # Commiter
git push                # Pousser
git pull                # Récupérer et merger
git checkout <branch>   # Changer de branche
git branch              # Voir les branches
git log                 # Voir l'historique
git diff                # Voir les différences
git stash               # Mettre de côté
git merge <branch>      # Merger une branche

# Configuration
git config --list       # Voir la config
git remote -v           # Voir les remotes

# Nettoyage
git branch -d <branch>  # Supprimer branche locale
git clean -fd           # Supprimer fichiers non trackés
```

---

## 🆘 En cas de problème

### "Je suis perdu, comment revenir à un état propre ?"
```bash
git stash               # Sauvegarder les modifications
git checkout integration    # Retour sur integration
git pull origin integration # Mise à jour
```

### "J'ai committé sur la mauvaise branche !"
```bash
git log                 # Noter le hash du commit
git reset --hard HEAD~1 # Annuler le commit
git checkout bonne-branche
git cherry-pick <hash>  # Appliquer sur la bonne branche
```

### "Mon merge a tout cassé !"
```bash
git merge --abort       # Annuler le merge en cours
# ou
git reset --hard origin/ma-branche  # Revenir à la version remote
```

---

**Gardez ce guide à portée de main ! 📖**
