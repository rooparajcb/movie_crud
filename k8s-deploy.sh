#!/bin/bash

set -e

BASE_PATH="$(pwd)/kube_scripts"
STORAGE_FLAG_FILE="$BASE_PATH/.storage_done"

setup_storage() {
    if [[ -f "$STORAGE_FLAG_FILE" ]]; then
        echo "✅ Storage already set up, skipping..."
    else
        echo "🔹 Setting up storage (local-path-provisioner)..."
        bash "$BASE_PATH/setup-storage.sh"
        touch "$STORAGE_FLAG_FILE"
        echo "✅ Storage setup completed."
    fi
}

deploy_db() {
    setup_storage
    echo "🔹 Deploying MySQL StatefulSet + Service..."
    kubectl apply -f "$BASE_PATH/db-statefullset-svc.yml"
    echo "🔹 Waiting for MySQL pod to be running..."
    kubectl wait --for=condition=Ready pod -l app=mysql --timeout=180s
    echo "✅ MySQL deployed successfully."
}

deploy_app() {
    echo "🔹 Deploying Spring Boot App Deployment + NodePort Service..."
    kubectl apply -f "$BASE_PATH/app-deploy-svc.yml"
    echo "✅ Spring Boot app deployed successfully."
}

remove_db() {
    echo "🔹 Removing MySQL StatefulSet + Service..."
    kubectl delete -f "$BASE_PATH/db-statefullset-svc.yml" --ignore-not-found
    echo "✅ MySQL removed."
}

remove_app() {
    echo "🔹 Removing Spring Boot App Deployment + Service..."
    kubectl delete -f "$BASE_PATH/app-deploy-svc.yml" --ignore-not-found
    echo "✅ App removed."
}

show_menu() {
    echo ""
    echo "=== Kubernetes Deployment Menu ==="
    echo "1) Deploy DB"
    echo "2) Deploy App"
    echo "3) Remove DB"
    echo "4) Remove App"
    echo "5) Exit"
    echo "================================="
    read -p "Choose an option [1-5]: " choice

    case "$choice" in
        1) deploy_db ;;
        2) deploy_app ;;
        3) remove_db ;;
        4) remove_app ;;
        5) exit 0 ;;
        *) echo "❌ Invalid option" ;;
    esac
}

# Loop until user exits
while true; do
    show_menu
done
