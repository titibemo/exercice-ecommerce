#!/bin/bash

sleep 2

while true; do
    echo "🚀 Génération d’un nouveau rapport..."
    python main.py
    echo "📄 Rapport généré !"
    sleep 10   # attends 1 heure avant le prochain rapport
done
