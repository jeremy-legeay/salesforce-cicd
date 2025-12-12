# 🔐 Guide JWT Authentication - Salesforce CI/CD

Ce guide détaille la configuration de l'authentification JWT pour le pipeline CI/CD.

## 📋 Vue d'ensemble

L'authentification JWT (JSON Web Token) est **recommandée par Salesforce** pour les pipelines CI/CD car :
- ✅ Plus sécurisée que les Auth URLs
- ✅ Pas d'expiration du refresh token
- ✅ Contrôle granulaire des permissions
- ✅ Audit trail complet dans Salesforce

## 🚀 Configuration rapide

### Étape 1 : Générer le certificat SSL

```bash
# Sur votre machine locale
openssl req -x509 -sha256 -nodes -days 36500 -newkey rsa:2048 -keyout server.key -out server.crt
```

**Questions OpenSSL** (vous pouvez appuyer sur Enter pour tout accepter) :
```
Country Name (2 letter code) [AU]: FR
State or Province Name (full name) [Some-State]:
Locality Name (eg, city) []:
Organization Name (eg, company) [Internet Widgits Pty Ltd]:
Organizational Unit Name (eg, section) []:
Common Name (e.g. server FQDN or YOUR name) []: github-cicd
Email Address []:
```

**Fichiers créés** :
- `server.key` : Clé privée (à garder SECRET)
- `server.crt` : Certificat public (à uploader dans Salesforce)

**IMPORTANT** :
- ✅ Sauvegardez `server.key` dans un gestionnaire de mots de passe sécurisé
- ✅ Ne commitez JAMAIS `server.key` dans Git (déjà dans `.gitignore`)
- ✅ Utilisez le MÊME certificat pour les 3 orgs (INT, UAT, PROD)

### Étape 2 : Créer une Connected App dans Salesforce

**Pour CHAQUE org** (INTEGRATION, UAT, PRODUCTION) :

1. **Setup** → Quick Find → **App Manager**
2. **New Connected App**

**Configuration** :

| Section | Champ | Valeur |
|---------|-------|--------|
| Basic Information | Connected App Name | `GitHub CI/CD JWT` |
| Basic Information | API Name | `GitHub_CICD_JWT` |
| Basic Information | Contact Email | Votre email |
| API (Enable OAuth Settings) | Enable OAuth Settings | ✅ Coché |
| API (Enable OAuth Settings) | Callback URL | `http://localhost:1717/OauthRedirect` |
| API (Enable OAuth Settings) | Use digital signatures | ✅ Coché + Upload `server.crt` |
| Selected OAuth Scopes | Scopes | `api`, `refresh_token`, `web` |
| Additional Settings | Require Secret for Web Server Flow | ✅ Coché |

**Scopes OAuth à ajouter** (glisser de "Available" vers "Selected") :
- Access and manage your data (api)
- Perform requests on your behalf at any time (refresh_token, offline_access)
- Provide access to your data via the Web (web)

3. **Save** et **attendre 2-10 minutes** (propagation Salesforce)

### Étape 3 : Récupérer le Consumer Key

**Pour chaque Connected App** :

1. **Setup** → **App Manager**
2. Trouvez **GitHub CI/CD JWT** → **▼** → **View**
3. **Manage Consumer Details**
4. Vérifiez votre identité (code par email)
5. **Copiez le Consumer Key**

**Exemple de Consumer Key** :
```
3MVG9wt4IL4O5wvK8Z9Y1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ
```

### Étape 4 : Configurer les secrets GitHub

**Pour CHAQUE environnement** GitHub (INTEGRATION, UAT, PRODUCTION) :

1. **Settings** → **Environments** → **INTEGRATION** (par exemple)
2. **Add Secret** (créez 3 secrets)

#### Secret 1 : Consumer Key

**Nom** : `SF_CONSUMER_KEY_INTEGRATION`

**Valeur** : Le Consumer Key copié depuis Salesforce (étape 3)

#### Secret 2 : Username

**Nom** : `SF_USERNAME_INTEGRATION`

**Valeur** : Le username Salesforce de l'org

**Exemple** : `admin@company-int.com`

**Comment trouver le username** :
- Dans Salesforce → Setup → Users → votre utilisateur
- Ou : `sf org display --target-org <alias>`

#### Secret 3 : Private Key

**Nom** : `SF_PRIVATE_KEY_INTEGRATION`

**Valeur** : Le contenu COMPLET du fichier `server.key`

**Comment copier le fichier** :

Sur **Linux/Mac** :
```bash
cat server.key
```

Sur **Windows** (PowerShell) :
```powershell
Get-Content server.key | Set-Clipboard
```

Sur **Windows** (CMD) :
```cmd
type server.key
```

**Format attendu** (copiez TOUT, y compris les lignes BEGIN/END) :
```
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC...
...
...longue clé sur plusieurs lignes...
...
-----END PRIVATE KEY-----
```

**Répétez pour les 3 environnements** :

| Environnement | Consumer Key | Username | Private Key |
|--------------|-------------|----------|-------------|
| INTEGRATION | `SF_CONSUMER_KEY_INTEGRATION` | `SF_USERNAME_INTEGRATION` | `SF_PRIVATE_KEY_INTEGRATION` |
| UAT | `SF_CONSUMER_KEY_UAT` | `SF_USERNAME_UAT` | `SF_PRIVATE_KEY_UAT` |
| PRODUCTION | `SF_CONSUMER_KEY_PRODUCTION` | `SF_USERNAME_PRODUCTION` | `SF_PRIVATE_KEY_PRODUCTION` |

**Total : 9 secrets à configurer**

## ✅ Validation

### Test local de l'authentification JWT

```bash
# Test avec la clé locale
sf org login jwt \
  --client-id "VOTRE_CONSUMER_KEY" \
  --jwt-key-file server.key \
  --username "admin@company-int.com" \
  --alias test-jwt \
  --instance-url https://login.salesforce.com

# Vérifier la connexion
sf org display --target-org test-jwt
```

Si cela fonctionne, votre configuration JWT est correcte !

### Test du pipeline GitHub

1. Committez un petit changement sur la branche `integration`
2. Allez dans **Actions** → votre workflow
3. Vérifiez que l'étape "Authenticate to Salesforce" réussit

**Log attendu** :
```
Successfully authorized admin@company-int.com with org ID 00D...
```

## ⚠️ Dépannage

### Erreur : "invalid_client_id"

**Cause** : Le Consumer Key est incorrect ou la Connected App n'est pas encore activée

**Solution** :
1. Attendez 2-10 minutes après la création de la Connected App
2. Vérifiez le Consumer Key copié (pas d'espace, complet)
3. Vérifiez que la Connected App est bien dans l'org cible

### Erreur : "invalid_grant"

**Cause** : La clé privée ne correspond pas au certificat uploadé

**Solution** :
1. Vérifiez que vous avez uploadé le bon fichier `server.crt` dans Salesforce
2. Vérifiez que le secret `SF_PRIVATE_KEY_*` contient bien le contenu de `server.key`
3. Régénérez le certificat si nécessaire et reconfigurez la Connected App

### Erreur : "user hasn't approved this consumer"

**Cause** : L'utilisateur n'a pas approuvé la Connected App

**Solution** :
1. Connectez-vous manuellement une fois avec JWT :
   ```bash
   sf org login jwt \
     --client-id "CONSUMER_KEY" \
     --jwt-key-file server.key \
     --username "admin@company-int.com" \
     --instance-url https://login.salesforce.com
   ```
2. Ou dans Salesforce : Setup → Connected Apps → Manage Connected Apps → Approuvez l'app pour l'utilisateur

### Erreur : "JWT secrets not configured"

**Cause** : Un ou plusieurs secrets GitHub sont manquants

**Solution** :
1. Vérifiez que les 3 secrets existent dans l'environnement GitHub
2. Vérifiez les noms des secrets (sensible à la casse)
3. Vérifiez que les secrets sont dans le bon environnement (INTEGRATION, UAT, PRODUCTION)

### Erreur : "Failed to read jwt key file"

**Cause** : Le contenu de `SF_PRIVATE_KEY_*` est incorrect

**Solution** :
1. Vérifiez que vous avez copié TOUT le contenu incluant `-----BEGIN PRIVATE KEY-----` et `-----END PRIVATE KEY-----`
2. Vérifiez qu'il n'y a pas d'espaces ou caractères invisibles au début/fin
3. Recopiez le contenu directement depuis le fichier `server.key`

### Erreur : Permission denied

**Cause** : L'utilisateur n'a pas les permissions suffisantes dans l'org

**Solution** :
1. Utilisez un utilisateur avec profil System Administrator
2. Ou ajoutez les permissions nécessaires au profil/permission set de l'utilisateur

## 🔄 Rotation du certificat

Si vous devez changer le certificat (expiration, compromis, etc.) :

### 1. Générer un nouveau certificat

```bash
openssl req -x509 -sha256 -nodes -days 36500 -newkey rsa:2048 -keyout server-new.key -out server-new.crt
```

### 2. Mettre à jour les Connected Apps

Pour **chaque org** :
1. Setup → App Manager → GitHub CI/CD JWT → Edit
2. Dans "Use digital signatures", uploadez le nouveau `server-new.crt`
3. Save et attendre 2-10 minutes

### 3. Mettre à jour les secrets GitHub

Pour **chaque environnement** :
1. Settings → Environments → INTEGRATION (par exemple)
2. Éditez le secret `SF_PRIVATE_KEY_INTEGRATION`
3. Remplacez par le contenu de `server-new.key`

### 4. Tester

Lancez le pipeline pour vérifier que l'authentification fonctionne avec le nouveau certificat.

## 📚 Références

- [Salesforce JWT Bearer Flow](https://help.salesforce.com/s/articleView?id=sf.remoteaccess_oauth_jwt_flow.htm)
- [Salesforce CLI - org login jwt](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_org_commands_unified.htm#cli_reference_org_login_jwt_unified)
- [Connected App - Digital Signatures](https://help.salesforce.com/s/articleView?id=sf.remoteaccess_oauth_web_server_flow.htm)

## 🔒 Sécurité

**Bonnes pratiques** :
- ✅ Sauvegardez `server.key` dans un gestionnaire de secrets (1Password, LastPass, etc.)
- ✅ Ne partagez JAMAIS `server.key` par email ou chat
- ✅ Limitez l'accès aux secrets GitHub aux administrateurs uniquement
- ✅ Utilisez des profils avec permissions minimales pour le CI/CD si possible
- ✅ Activez l'audit trail dans Salesforce pour monitorer les connexions
- ✅ Renouvelez le certificat tous les 5-10 ans (valide 100 ans mais rotation recommandée)
- ❌ Ne commitez JAMAIS `server.key` dans Git (déjà protégé par `.gitignore`)

**En cas de compromission** :
1. Générez un nouveau certificat immédiatement
2. Mettez à jour les Connected Apps dans Salesforce
3. Mettez à jour les secrets GitHub
4. Révoquez l'ancien certificat en supprimant l'ancienne Connected App

---

**Configuration terminée ! 🎉**

Votre pipeline utilise maintenant l'authentification JWT sécurisée.
