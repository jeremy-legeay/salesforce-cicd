#!/bin/bash

###############################################################################
# Script de déploiement Salesforce avancé
# Usage: ./deploy.sh [dev|integration|uat|production] [validate|deploy]
###############################################################################

set -e  # Exit on error

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
ENVIRONMENT=$1
ACTION=$2
MANIFEST_PATH="manifest/package.xml"
DESTRUCTIVE_PATH="manifest/destructiveChanges.xml"

# Fonction de log
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Vérification des paramètres
if [ -z "$ENVIRONMENT" ] || [ -z "$ACTION" ]; then
    log_error "Usage: ./deploy.sh [dev|integration|uat|production] [validate|deploy]"
    exit 1
fi

# Validation de l'environnement
case $ENVIRONMENT in
    dev|integration|uat|production)
        log_info "Environnement cible: $ENVIRONMENT"
        ;;
    *)
        log_error "Environnement invalide. Utilisez: dev, integration, uat ou production"
        exit 1
        ;;
esac

# Validation de l'action
case $ACTION in
    validate|deploy)
        log_info "Action: $ACTION"
        ;;
    *)
        log_error "Action invalide. Utilisez: validate ou deploy"
        exit 1
        ;;
esac

# Détermination du niveau de test selon l'environnement
case $ENVIRONMENT in
    production)
        TEST_LEVEL="RunLocalTests"
        log_warning "PRODUCTION - Tous les tests locaux seront exécutés"
        ;;
    uat)
        TEST_LEVEL="RunLocalTests"
        log_info "UAT - Tests locaux activés"
        ;;
    integration)
        TEST_LEVEL="RunLocalTests"
        log_info "INTEGRATION - Tests locaux activés"
        ;;
    dev)
        TEST_LEVEL="RunSpecifiedTests"
        SPECIFIED_TESTS="TestClass1,TestClass2"  # Modifiez selon vos besoins
        log_info "DEV - Tests spécifiques uniquement"
        ;;
esac

# Alias de l'org
ORG_ALIAS="${ENVIRONMENT}-org"

log_info "======================================"
log_info "  Déploiement Salesforce"
log_info "======================================"
log_info "Environnement: $ENVIRONMENT"
log_info "Action: $ACTION"
log_info "Org Alias: $ORG_ALIAS"
log_info "Test Level: $TEST_LEVEL"
log_info "======================================"

# Vérification de l'authentification
log_info "Vérification de l'authentification..."
if ! sf org display --target-org $ORG_ALIAS > /dev/null 2>&1; then
    log_error "Impossible de se connecter à l'org $ORG_ALIAS"
    log_error "Veuillez vous authentifier avec: sf org login web --alias $ORG_ALIAS"
    exit 1
fi
log_success "Authentification OK"

# Validation de la metadata
log_info "Validation du package.xml..."
if [ ! -f "$MANIFEST_PATH" ]; then
    log_error "Le fichier $MANIFEST_PATH n'existe pas"
    exit 1
fi
log_success "Package.xml trouvé"

# Construction de la commande de déploiement
DEPLOY_CMD="sf project deploy start --target-org $ORG_ALIAS --manifest $MANIFEST_PATH"

# Ajout du niveau de test
if [ "$TEST_LEVEL" == "RunSpecifiedTests" ]; then
    DEPLOY_CMD="$DEPLOY_CMD --test-level $TEST_LEVEL --tests $SPECIFIED_TESTS"
else
    DEPLOY_CMD="$DEPLOY_CMD --test-level $TEST_LEVEL"
fi

# Ajout du mode validation (check-only) si demandé
if [ "$ACTION" == "validate" ]; then
    DEPLOY_CMD="$DEPLOY_CMD --dry-run"
    log_info "Mode VALIDATION activé (aucun changement ne sera appliqué)"
fi

# Ajout des destructive changes si le fichier existe
if [ -f "$DESTRUCTIVE_PATH" ] && grep -q "<members>" "$DESTRUCTIVE_PATH"; then
    log_warning "Destructive changes détectées - Suppressions prévues"
    DEPLOY_CMD="$DEPLOY_CMD --post-destructive-changes $DESTRUCTIVE_PATH"
    
    if [ "$ENVIRONMENT" == "production" ]; then
        read -p "⚠️  ATTENTION: Des suppressions seront effectuées en PRODUCTION. Continuer? (yes/no): " confirm
        if [ "$confirm" != "yes" ]; then
            log_info "Déploiement annulé"
            exit 0
        fi
    fi
fi

# Ajout des options supplémentaires
DEPLOY_CMD="$DEPLOY_CMD --wait 30 --verbose"

# Confirmation finale pour la production
if [ "$ENVIRONMENT" == "production" ] && [ "$ACTION" == "deploy" ]; then
    echo ""
    log_warning "╔════════════════════════════════════════════╗"
    log_warning "║  DÉPLOIEMENT EN PRODUCTION                 ║"
    log_warning "║  Cette action est IRRÉVERSIBLE             ║"
    log_warning "╚════════════════════════════════════════════╝"
    echo ""
    read -p "Êtes-vous sûr de vouloir déployer en PRODUCTION? (yes/no): " final_confirm
    if [ "$final_confirm" != "yes" ]; then
        log_info "Déploiement annulé"
        exit 0
    fi
fi

# Exécution du déploiement
log_info "Lancement du déploiement..."
echo ""
echo "Commande: $DEPLOY_CMD"
echo ""

if eval $DEPLOY_CMD; then
    echo ""
    log_success "======================================"
    if [ "$ACTION" == "validate" ]; then
        log_success "✅ VALIDATION RÉUSSIE"
    else
        log_success "✅ DÉPLOIEMENT RÉUSSI"
    fi
    log_success "======================================"
    
    # Statistiques post-déploiement
    log_info "Récupération des informations de l'org..."
    sf org display --target-org $ORG_ALIAS
    
    exit 0
else
    echo ""
    log_error "======================================"
    if [ "$ACTION" == "validate" ]; then
        log_error "❌ VALIDATION ÉCHOUÉE"
    else
        log_error "❌ DÉPLOIEMENT ÉCHOUÉ"
    fi
    log_error "======================================"
    log_error "Consultez les logs ci-dessus pour plus de détails"
    
    exit 1
fi
