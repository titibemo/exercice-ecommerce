##  Initalisation et description  du projet

Ce projet à pour but Analyse des ventes d’un site e-commerce. Nous nous servirons de postgreSQL avec l'interface graphique pgadmin ainsi que python.



Pour copier le projet utiliser la commande :

```bash
git clone https://github.com/titibemo/exercice-ecommerce
```

Dans le docker compose, un .env DOIT ETRE ajouter afin de faire fonctionner le projet,  pour cela créer un fichier .env et ajouter les variables d'environnements suivantes :

```bash
#### POSTGRESQL 
POSTGRES_PASSWORD="secret"
POSTGRES_USER="tata"
POSTGRES_DB="postgres-ecommerce"

#### pgadmin
PGADMIN_DEFAULT_EMAIL="a@a.fr"
PGADMIN_DEFAULT_PASSWORD="secret"
```

Ouvrez ensuite votre projet avec votre IDE, ouvrez un terminal et effectuez cette commande :

```bash
docker compose up --build
```

Un container exercice-ecommerce devrait être créé avec: un container postgres-ecommerce, un container pgadmin-ecommerce ainsi qu'un container python-ecommerce.
ouvrez le terminal de docker et effectuer cette commande pour pouvoir intéragir avec l'exercice:

```bash
docker exec -it python-ecommerce bash
```
puis
```bash
python main.py
```
Pour pouvoir lancer le script.

Une fois le script effectué, un fichier rapport.txt sera créé dans le container docker avec le récapitulatif des analyses.
Pour l'ouvrir, effectuer la commande suivante :

```bash
cat rapport.txt
```

## Supprimer le projet

Pour supprimer le projet effectuer cette commande via le termnial de votre IDE :

```bash
docker compose down -v
```
pour supprimer les containers et les volumes associés à ce projet.
