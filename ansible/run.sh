#!/bin/bash

# 1. Initialiser et appliquer la configuration OpenTofu
echo "🚀 Déploiement de l'infrastructure avec OpenTofu..."
tofu init
tofu apply -auto-approve

# 2. Récupérer l'adresse IP depuis les outputs
echo "💾 Récupération de l'adresse IP..."
IP_MAIN=$(tofu output -raw instance_ip)

# 3. Vérifier si l'IP est bien récupérée
if [ -z "$IP_MAIN" ] || [ "$IP_MAIN" == "╷" ]; then
    echo "❌ Erreur : Impossible de récupérer l'IP."
    exit 1
fi

echo "✅ IP récupérée : $IP_MAIN"

# 4. Attendre que le SSH soit prêt
echo "⏳ Attente du démarrage du service SSH sur $IP_MAIN..."
while ! nc -z $IP_MAIN 22; do
  sleep 5
done
echo "✅ Connection SSH possible !"

# 5. Lancer Ansible en passant l'IP dynamiquement
# ANSIBLE_HOST_KEY_CHECKING=False permet d'éviter l'erreur d'empreinte SSH
echo "🛠️ Configuration de la machine avec Ansible..."

ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i "$IP_MAIN," \
    --user ubuntu \
    --private-key ~/.ssh/id_rsa \
    ansible/playbook.yml

echo "🎉 Déploiement terminé avec succès !"
