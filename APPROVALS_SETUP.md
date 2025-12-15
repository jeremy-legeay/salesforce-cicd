# Configuration des Approbations GitHub

## Pourquoi des approbations ?

Les approbations permettent de contrôler les déploiements vers les environnements INTEGRATION, UAT et PRODUCTION. C'est une gate de sécurité pour éviter les déploiements accidentels.

## Configuration dans GitHub

### Étape 1 : Accéder aux Environments

1. Allez sur votre repository GitHub
2. Cliquez sur **Settings** (en haut)
3. Dans le menu de gauche : **Environments**
4. Vous devriez voir : INTEGRATION, UAT, PRODUCTION

### Étape 2 : Configurer INTEGRATION

1. Cliquez sur **INTEGRATION**
2. Section **Deployment protection rules** :
   - ✅ Cochez **Required reviewers**
   - Ajoutez des utilisateurs (vous-même pour commencer)
   - **Nombre de reviewers** : 1
3. (Optionnel) **Wait timer** : 0 minutes
4. Cliquez sur **Save protection rules**

### Étape 3 : Configurer UAT

1. Cliquez sur **UAT**
2. Section **Deployment protection rules** :
   - ✅ Cochez **Required reviewers**
   - Ajoutez des utilisateurs (Tech Lead, QA)
   - **Nombre de reviewers** : 1-2
3. (Optionnel) **Wait timer** : 5 minutes
4. Cliquez sur **Save protection rules**

### Étape 4 : Configurer PRODUCTION

1. Cliquez sur **PRODUCTION**
2. Section **Deployment protection rules** :
   - ✅ Cochez **Required reviewers**
   - Ajoutez des utilisateurs (Product Owner, Tech Lead)
   - **Nombre de reviewers** : 2 (recommandé)
3. **Wait timer** : 10 minutes (temps de réflexion obligatoire)
4. Cliquez sur **Save protection rules**

## Recommandations

### INTEGRATION
- **Reviewers** : Développeurs seniors
- **Nombre** : 1
- **Wait timer** : 0 min
- **Objectif** : Validation rapide du code

### UAT
- **Reviewers** : Tech Lead + QA Lead
- **Nombre** : 2
- **Wait timer** : 5 min
- **Objectif** : Validation fonctionnelle et technique

### PRODUCTION
- **Reviewers** : Product Owner + Tech Lead + CTO
- **Nombre** : 2-3
- **Wait timer** : 10-30 min
- **Objectif** : Validation business et impact utilisateurs

## Comment approuver un déploiement

### Lorsqu'un workflow attend une approbation :

1. Allez sur **Actions** dans GitHub
2. Cliquez sur le workflow en cours (orange avec icône d'horloge)
3. Vous verrez : **"This workflow is waiting for approval"**
4. Cliquez sur **Review deployments**
5. Cochez l'environnement (ex: INTEGRATION)
6. (Optionnel) Ajoutez un commentaire
7. Cliquez sur **Approve and deploy**

### Le workflow reprend alors automatiquement !

## Désactiver les approbations (développement/test)

Si vous voulez tester sans approbations :

1. Settings → Environments → INTEGRATION
2. Section **Deployment protection rules**
3. ❌ Décochez **Required reviewers**
4. Save

⚠️ **JAMAIS EN PRODUCTION** - Gardez toujours les approbations en PRODUCTION !

## Notifications

Pour recevoir des notifications quand une approbation est requise :

1. Paramètres GitHub (votre profil) → **Notifications**
2. ✅ Cochez **Actions** dans "Participating"
3. Vous recevrez un email quand un workflow attend votre approbation

## Historique des approbations

Pour voir qui a approuvé quoi :

1. Actions → Workflow run
2. Cliquez sur le job **deploy**
3. Vous verrez : "Approved by @username on [date]"

Ceci crée une trace d'audit pour la compliance.

## Exemple de workflow avec approbation

```
1. Développeur push sur integration
2. Job "validate" s'exécute automatiquement ✅
3. Job "deploy" attend approbation ⏸️
4. Email envoyé aux reviewers 📧
5. Reviewer approuve via GitHub UI ✅
6. Job "deploy" reprend et déploie 🚀
7. Job "verify" vérifie le déploiement ✅
```

## Troubleshooting

### "I don't see the Review deployments button"
→ Vous n'êtes pas dans la liste des reviewers. Ajoutez-vous dans Settings → Environments → [ENV] → Required reviewers

### "The deployment is stuck waiting"
→ Vérifiez que des reviewers sont configurés. Si aucun reviewer, le workflow attend indéfiniment.

### "I want to cancel a pending deployment"
→ Actions → Workflow → Cancel workflow (bouton en haut à droite)

## Sécurité

⚠️ **Bonnes pratiques** :
- Ne vous mettez PAS comme seul reviewer de PRODUCTION
- Utilisez au moins 2 reviewers pour PRODUCTION
- Activez le wait timer (10-30 min) pour PRODUCTION
- Gardez une trace écrite des raisons de chaque déploiement (dans les commentaires)

## Resources

- [GitHub Environments Documentation](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
- [Required Reviewers](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment#required-reviewers)
