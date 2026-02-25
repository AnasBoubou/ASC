#!/bin/bash
 
# 1. Initialiser et appliquer la configuration OpenTofu
echo "🚀 Déploiement de l'infrastructure avec OpenTofu..."
tofu init
tofu apply -auto-approve
 
# 2. Récupérer l'adresse IP depuis les outputs
# On utilise -raw pour ne pas avoir de guillemets
echo "💾 Récupération de l'adresse IP..."
IP_MAIN=$(tofu output -raw main_instance_ip)
 
# 3. Vérifier si l'IP est bien récupérée
if [ -z "$IP_MAIN" ]; then
    echo "❌ Erreur : Impossible de récupérer l'IP."
    exit 1
fi
 
echo "✅ IP récupérée : $IP_MAIN"
 
# 4. Attendre que le SSH soit prêt (Optionnel mais conseillé)
# Parfois l'IP est là mais la machine n'a pas fini de démarrer
echo "⏳ Attente du démarrage du service SSH sur $IP_MAIN..."
while ! nc -z $IP_MAIN 22; do   
  sleep 5
done
 
# 5. Lancer Ansible en passant l'IP dynamiquement
# L'option -i (inventory) permet de passer l'IP directement avec une virgule à la fin
echo "🛠️ Configuration de la machine avec Ansible..."

    --user ubuntu \
    --private-key ~/.ssh/id_rsa \
    ansible/playbook.yml
 
echo "🎉 Déploiement terminé avec succès !"