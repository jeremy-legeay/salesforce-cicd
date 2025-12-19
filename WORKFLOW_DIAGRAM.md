# 🔄 Diagramme du Workflow CI/CD Salesforce

Ce document présente le flux détaillé du processus CI/CD avec architecture Release Branches.

---

## 📊 Vue d'ensemble du processus complet

```mermaid
flowchart TD
    Start([Développeur crée une feature]) --> Branch[Créer branche feature/xxx]
    Branch --> Dev[Développement + Commits]
    Dev --> PR1[Créer PR vers integration]
    PR1 --> Label{Ajouter label release ?}
    Label -->|Oui| LabelAdd[Ajouter label release-vX.Y.Z]
    Label -->|Non| Review1
    LabelAdd --> Review1[Review + Approbation]
    Review1 --> Merge1[Merge vers integration]

    Merge1 --> Deploy1[🤖 Déploiement AUTO sur INTEGRATION]
    Deploy1 --> Tests1[Tests Apex RunLocalTests]
    Tests1 --> Validation1{Tests OK ?}
    Validation1 -->|✅ Oui| Success1[Déployé sur ORG INTEGRATION]
    Validation1 -->|❌ Non| Fail1[Échec - Corriger les tests]
    Fail1 --> Dev

    Success1 --> Decision{Prêt pour release ?}
    Decision -->|Pas encore| End1([Fin - Attendre autres features])
    Decision -->|Oui| CreateRelease[Créer Release Package]

    CreateRelease --> Release1[🎯 Actions: Create Release Package]
    Release1 --> ReleaseInput[Version: v1.2.0<br/>Label: release-v1.2.0]
    ReleaseInput --> ReleaseBranch[Créer branche release/v1.2.0]
    ReleaseBranch --> FilterPRs[Filtrer PRs avec label]
    FilterPRs --> Manifest[Générer manifest]
    Manifest --> GHRelease[Créer GitHub Release draft]

    GHRelease --> DeployPreprod[🚀 Déployer sur PREPROD]
    DeployPreprod --> PreprodAction[Actions: Deploy Release]
    PreprodAction --> PreprodInput[Version: v1.2.0<br/>Env: PREPROD]
    PreprodInput --> Validate[Validation avec tests dry-run]
    Validate --> ValidateOK{Validation OK ?}
    ValidateOK -->|❌ Non| FixRelease[Corriger via hotfix]
    ValidateOK -->|✅ Oui| Approve1[Approbation manuelle 2 reviewers]
    Approve1 --> QuickDeploy1[Quick Deploy sur PREPROD]
    QuickDeploy1 --> TestPreprod[Tests fonctionnels PREPROD]

    TestPreprod --> PreprodOK{Tests PREPROD OK ?}
    PreprodOK -->|❌ Non| Hotfix[Créer hotfix]
    PreprodOK -->|✅ Oui| DeployProd[🚀 Déployer sur PRODUCTION]

    Hotfix --> HotfixBranch[Créer branche hotfix/xxx<br/>depuis release/v1.2.0]
    HotfixBranch --> HotfixDev[Développer le fix]
    HotfixDev --> HotfixPR[PR vers release/v1.2.0]
    HotfixPR --> HotfixMerge[Merge hotfix]
    HotfixMerge --> Backport[🤖 Backport AUTO vers integration]
    HotfixMerge --> DeployPreprod

    DeployProd --> ProdAction[Actions: Deploy Release]
    ProdAction --> ProdInput[Version: v1.2.0 même version<br/>Env: PRODUCTION]
    ProdInput --> ValidateProd[Validation avec tests dry-run]
    ValidateProd --> ValidateProdOK{Validation OK ?}
    ValidateProdOK -->|❌ Non| Emergency[Rollback ou hotfix urgent]
    ValidateProdOK -->|✅ Oui| Approve2[Approbation manuelle 2+ reviewers]
    Approve2 --> QuickDeploy2[Quick Deploy sur PRODUCTION]
    QuickDeploy2 --> ProdSuccess[✅ Déployé sur PRODUCTION]

    ProdSuccess --> PostDeploy[Post-déploiement]
    PostDeploy --> MergeMain[Merger release/v1.2.0 → main]
    MergeMain --> SyncInt[Synchroniser main → integration]
    SyncInt --> Cleanup[Optionnel: Supprimer release branch]
    Cleanup --> End2([✅ Release terminée])

    Emergency --> HotfixBranch

    style Start fill:#e1f5e1
    style Deploy1 fill:#fff4e6
    style Success1 fill:#e1f5e1
    style CreateRelease fill:#e3f2fd
    style DeployPreprod fill:#fff3e0
    style DeployProd fill:#ffe0e0
    style ProdSuccess fill:#c8e6c9
    style End2 fill:#c8e6c9
    style Fail1 fill:#ffcdd2
    style Hotfix fill:#fff9c4
    style Backport fill:#f3e5f5
```

---

## 🏗️ Architecture des branches

```mermaid
gitGraph
    commit id: "Initial commit"
    branch integration
    checkout integration
    commit id: "Setup CI/CD"

    branch feature/user-profile
    checkout feature/user-profile
    commit id: "Add user model"
    commit id: "Add profile page"
    checkout integration
    merge feature/user-profile tag: "PR #20 (label: release-v1.2.0)"

    branch feature/notifications
    checkout feature/notifications
    commit id: "Add notification service"
    commit id: "Add UI notifications"
    checkout integration
    merge feature/notifications tag: "PR #21 (label: release-v1.2.0)"

    branch feature/bug-fix-minor
    checkout feature/bug-fix-minor
    commit id: "Fix typo"
    checkout integration
    merge feature/bug-fix-minor tag: "PR #22 (no label)"

    branch release/v1.2.0
    checkout release/v1.2.0
    commit id: "Release v1.2.0" type: HIGHLIGHT

    branch hotfix/fix-notif
    checkout hotfix/fix-notif
    commit id: "Fix notification bug"
    checkout release/v1.2.0
    merge hotfix/fix-notif tag: "PR #25"

    checkout integration
    merge hotfix/fix-notif tag: "Backport auto"

    checkout main
    merge release/v1.2.0 tag: "v1.2.0 PRODUCTION"

    checkout integration
    merge main tag: "Sync"
```

---

## 🔄 Flux de déploiement par environnement

```mermaid
sequenceDiagram
    participant Dev as Développeur
    participant GH as GitHub
    participant INT as ORG INTEGRATION
    participant PP as ORG PREPROD
    participant PROD as ORG PRODUCTION

    Dev->>GH: 1. Push feature branch
    Dev->>GH: 2. Créer PR → integration
    Dev->>GH: 3. Ajouter label release-v1.2.0
    GH->>GH: 4. Review + Approve
    GH->>GH: 5. Merge PR

    activate GH
    Note over GH,INT: Workflow: Salesforce CI/CD
    GH->>INT: 6. Déploiement AUTO
    INT->>GH: 7. Tests OK ✅
    deactivate GH

    Dev->>GH: 8. Actions: Create Release Package
    Note over GH: Version: v1.2.0<br/>Label: release-v1.2.0
    GH->>GH: 9. Créer release/v1.2.0
    GH->>GH: 10. Générer manifest
    GH->>GH: 11. GitHub Release (draft)

    Dev->>GH: 12. Actions: Deploy Release → PREPROD
    activate GH
    Note over GH,PP: Workflow: Deploy Release
    GH->>PP: 13. Validation dry-run + tests
    PP->>GH: 14. Validation OK ✅
    GH-->>Dev: 15. Attente approbation (2 reviewers)
    Dev->>GH: 16. Approve
    GH->>PP: 17. Quick Deploy
    PP->>GH: 18. Déploiement OK ✅
    deactivate GH

    Dev->>PP: 19. Tests fonctionnels manuels
    PP-->>Dev: 20. Tests OK ✅

    Dev->>GH: 21. Actions: Deploy Release → PRODUCTION
    activate GH
    Note over GH,PROD: Workflow: Deploy Release
    GH->>PROD: 22. Validation dry-run + tests
    PROD->>GH: 23. Validation OK ✅
    GH-->>Dev: 24. Attente approbation (2+ reviewers)
    Dev->>GH: 25. Approve
    GH->>PROD: 26. Quick Deploy
    PROD->>GH: 27. Déploiement OK ✅
    deactivate GH

    Dev->>GH: 28. Merger release → main
    Dev->>GH: 29. Synchroniser main → integration
```

---

## 🔥 Flux de hotfix

```mermaid
flowchart LR
    Bug([🐛 Bug découvert<br/>sur PREPROD/PROD]) --> Checkout[git checkout release/v1.2.0]
    Checkout --> Create[git checkout -b<br/>hotfix/fix-bug]
    Create --> Fix[Développer le fix<br/>+ Tests]
    Fix --> Commit[git commit]
    Commit --> Push[git push origin hotfix/fix-bug]
    Push --> PR[Créer PR vers<br/>release/v1.2.0]
    PR --> Review[Review + Approve]
    Review --> Merge[Merge PR]

    Merge --> Auto[🤖 Auto-Backport Workflow]
    Auto --> CherryPick{Cherry-pick<br/>vers integration}
    CherryPick -->|✅ Succès| AutoPR[Créer PR auto<br/>vers integration]
    CherryPick -->|❌ Conflits| Comment[Commenter sur PR<br/>avec instructions manuelles]

    AutoPR --> MergeBack[Review + Merge<br/>vers integration]
    Comment --> Manual[Résolution manuelle<br/>des conflits]
    Manual --> ManualPR[PR manuelle<br/>vers integration]
    ManualPR --> MergeBack

    Merge --> Redeploy[Re-déployer release<br/>sur PREPROD/PROD]

    MergeBack --> Done([✅ Hotfix appliqué<br/>partout])
    Redeploy --> Done

    style Bug fill:#ffcdd2
    style Auto fill:#f3e5f5
    style Done fill:#c8e6c9
```

---

## 📦 Processus de création de release

```mermaid
flowchart TD
    Start([Actions: Create Release Package]) --> Input[Inputs:<br/>• Version: v1.2.0<br/>• Label: release-v1.2.0<br/>• Base: integration]
    Input --> Fetch[Fetch PRs mergées<br/>sur integration]
    Fetch --> Filter[Filtrer PRs avec<br/>label release-v1.2.0]

    Filter --> HasPRs{PRs trouvées ?}
    HasPRs -->|❌ Non| Error[❌ Erreur: No PRs found]
    HasPRs -->|✅ Oui| List[Liste des PRs:<br/>• PR #20: user-profile<br/>• PR #21: notifications]

    List --> CreateBranch[Créer branche<br/>release/v1.2.0]
    CreateBranch --> Cherry[Cherry-pick commits<br/>des PRs sélectionnées]
    Cherry --> Manifest[Générer manifest<br/>manifest/releases/v1.2.0.xml]
    Manifest --> Release[Créer GitHub Release<br/>Status: Draft]
    Release --> Summary[Afficher summary:<br/>• PRs incluses<br/>• Files changed<br/>• Release notes]
    Summary --> Success([✅ Release créée])

    Error --> End([❌ Échec])

    style Start fill:#e3f2fd
    style Success fill:#c8e6c9
    style Error fill:#ffcdd2
    style End fill:#ffcdd2
```

---

## ⚙️ Workflow de déploiement (Deploy Release)

```mermaid
flowchart TD
    Start([Actions: Deploy Release]) --> Input[Inputs:<br/>• Version: v1.2.0<br/>• Environment: PREPROD/PRODUCTION]
    Input --> Checkout[Checkout release/v1.2.0]
    Checkout --> Auth[Authentification JWT<br/>vers org cible]

    Auth --> Manifest{Manifest<br/>release existe ?}
    Manifest -->|✅ Oui| UseRelease[Utiliser manifest/releases/v1.2.0.xml]
    Manifest -->|❌ Non| UseDefault[Utiliser manifest/package.xml]

    UseRelease --> Validate[Validation dry-run<br/>+ RunLocalTests]
    UseDefault --> Validate

    Validate --> ValidResult{Validation OK ?}
    ValidResult -->|❌ Non| Fail[❌ Échec validation<br/>Afficher erreurs]
    ValidResult -->|✅ Oui| SaveID[Sauvegarder Validation ID]

    SaveID --> WaitApproval[⏸️ Attente approbation manuelle<br/>Reviewers requis]
    WaitApproval --> Approved{Approuvé ?}
    Approved -->|❌ Non| Cancel([Déploiement annulé])
    Approved -->|✅ Oui| QuickDeploy[Quick Deploy<br/>avec Validation ID]

    QuickDeploy --> DeployResult{Déploiement<br/>réussi ?}
    DeployResult -->|❌ Non| DeployFail[❌ Échec déploiement]
    DeployResult -->|✅ Oui| Success[✅ Déploiement réussi]

    Success --> Summary[Afficher summary:<br/>• Validation ID<br/>• Environment<br/>• Release version<br/>• Deployed by]
    Summary --> NextSteps{Environment ?}
    NextSteps -->|PREPROD| PreprodNext[Next steps:<br/>1. Tester sur PREPROD<br/>2. Déployer sur PROD<br/>3. Hotfix si besoin]
    NextSteps -->|PRODUCTION| ProdNext[Next steps:<br/>1. Merger release → main<br/>2. Sync main → integration<br/>3. Supprimer release branch]

    PreprodNext --> End([✅ Terminé])
    ProdNext --> End
    Fail --> End
    DeployFail --> End

    style Start fill:#fff3e0
    style Success fill:#c8e6c9
    style End fill:#c8e6c9
    style Fail fill:#ffcdd2
    style DeployFail fill:#ffcdd2
    style Cancel fill:#e0e0e0
    style WaitApproval fill:#fff9c4
```

---

## 🎯 Légende

| Symbole | Signification |
|---------|--------------|
| 🤖 | Action automatique (workflow GitHub Actions) |
| 🚀 | Déploiement vers un environnement |
| ⏸️ | Attente d'approbation manuelle |
| ✅ | Succès / Validation OK |
| ❌ | Échec / Erreur |
| 🐛 | Bug détecté |
| 🔥 | Hotfix urgent |
| 📦 | Package / Release |

---

## 📚 Références

- [README.md](README.md) - Documentation principale
- [RELEASE_PROCESS.md](RELEASE_PROCESS.md) - Guide du processus de release
- [AJOUT_ENVIRONNEMENT.md](AJOUT_ENVIRONNEMENT.md) - Ajouter des environnements
- [JWT_SETUP_GUIDE.md](JWT_SETUP_GUIDE.md) - Configuration JWT

---

**📌 Note** : Ces diagrammes utilisent la syntaxe Mermaid qui est supportée nativement par GitHub, GitLab, et la plupart des éditeurs Markdown modernes (VS Code, Obsidian, etc.).
