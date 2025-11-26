------------------------------------- PARTIE 3

-- Lister tous les clients triés par date de création de compte (plus anciens → plus récents).
SELECT * FROM customers ORDER BY created_at DESC;

-- Lister tous les produits (nom + prix) triés par prix décroissant.
SELECT name_product, price_product FROM products ORDER BY price_product DESC;

-- Lister les commandes passées entre deux dates (par exemple entre le 1er et le 15 mars 2024).
SELECT * FROM orders WHERE created_at BETWEEN '2024-03-01' AND '2024-03-15';

-- Lister les produits dont le prix est strictement supérieur à 50 €.
SELECT * from products where price_product > 50;

-- Lister tous les produits d’une catégorie donnée (par exemple “Électronique”).
SELECT * from products where id_category = (SELECT id_category FROM categories WHERE name_category = 'Électronique');

------------------------------------ Partie 4 – Jointures simples

-- Lister tous les produits avec le nom de leur catégorie.
SELECT p.name_product, c.name_category FROM products AS p
INNER JOIN categories AS c
ON p.id_category = c.id_category;

-- Lister toutes les commandes avec le nom complet du client (prénom + nom).
SELECT o.status, c.firstname, c.lastname FROM customers AS c
INNER JOIN orders AS o 
ON c.id_customer = o.id_customer;

-- Lister toutes les lignes de commande avec :

-- le nom du client,
-- le nom du produit,
-- la quantité,
-- le prix unitaire facturé.
SELECT c.firstname, c.lastname, p.name_product, oq.quantity, p.price_product FROM orders AS o
INNER JOIN customers AS c
ON o.id_customer = c.id_customer
INNER JOIN order_items AS oq
ON o.id_order = oq.id_order
INNER JOIN products AS p
ON oq.id_product = p.id_product;

-- Lister toutes les commandes dont le statut est PAID ou SHIPPED.
SELECT status, created_at FROM orders WHERE status = 'PAID' OR status = 'SHIPPED';

----------------------------------- Partie 5 – Jointures avancées

-- Afficher le détail complet de chaque commande avec :

-- date de commande,
-- nom du client,
-- liste des produits,
-- quantité,
-- prix unitaire facturé,
-- montant total de la ligne (quantité × prix unitaire).
SELECT o.status, o.created_at AS date_commande, c.firstname, c.lastname, p.name_product, oq.quantity, p.price_product, SUM(oq.quantity * oq.unit_price) AS montant_total FROM orders AS o
INNER JOIN customers AS c
ON o.id_customer = c.id_customer
INNER JOIN order_items AS oq
ON o.id_order = oq.id_order
INNER JOIN products AS p
ON oq.id_product = p.id_product
GROUP BY o.id_order, c.firstname, c.lastname, p.name_product, oq.quantity, p.price_product;

-- Calculer le montant total de chaque commande et afficher uniquement :
-- l’ID de la commande,
-- le nom du client,
-- le montant total de la commande.
-- Afficher les commandes dont le montant total dépasse 100 €.
SELECT o.id_order, c.firstname, c.lastname, SUM(oq.quantity * oq.unit_price) AS montant_total FROM orders AS o
INNER JOIN customers AS c
ON o.id_customer = c.id_customer
INNER JOIN order_items AS oq
ON o.id_order = oq.id_order
GROUP BY o.id_order, c.firstname, c.lastname
HAVING SUM(oq.quantity * oq.unit_price) > 100;


-- Lister les catégories avec leur chiffre d’affaires total (somme du montant des lignes sur tous les produits de cette catégorie).
SELECT c.name_category, SUM(oq.quantity * oq.unit_price) AS chiffre_affaire FROM order_items AS oq
INNER JOIN products AS p
ON oq.id_product = p.id_product
INNER JOIN categories AS c
ON p.id_category = c.id_category
GROUP BY c.name_category;

-- SELECT c.name_category, SUM(oq.quantity * oq.price_product) AS chiffre_affaire FROM orders AS o
-- INNER JOIN customers AS c
-- ON o.id_customer = c.id_customer
-- INNER JOIN order_items AS oq
-- ON o.id_order = oq.id_order
-- GROUP BY c.name_category;

------------------------------------ Partie 6 – Sous-requêtes

--Lister les produits qui ont été vendus au moins une fois.
SELECT name_product FROM products WHERE (SELECT COUNT(*) FROM order_items WHERE id_product = products.id_product) > 0;

--Lister les produits qui n’ont jamais été vendus.
SELECT name_product FROM products WHERE (SELECT COUNT(*) FROM order_items WHERE id_product = products.id_product) IS NULL;

--Trouver le client qui a dépensé le plus (TOP 1 en chiffre d’affaires cumulé).
SELECT c.firstname, c.lastname, c.email, SUM(oq.quantity * oq.unit_price) AS chiffre_affaire FROM orders AS o
INNER JOIN customers AS c
ON o.id_customer = c.id_customer
INNER JOIN order_items AS oq
ON o.id_order = oq.id_order
GROUP BY c.firstname, c.lastname, c.email
ORDER BY chiffre_affaire DESC
LIMIT 1;

--Afficher les 3 produits les plus vendus en termes de quantité totale.
SELECT p.name_product, SUM(oq.quantity) AS quantite_totale FROM products AS p
INNER JOIN order_items AS oq    
ON p.id_product = oq.id_product
GROUP BY p.name_product
ORDER BY quantite_totale DESC
LIMIT 3;

--Lister les commandes dont le montant total est strictement supérieur à la moyenne de toutes les commandes.
SELECT id_order FROM orders 
WHERE (SELECT SUM(oq.quantity * oq.unit_price) FROM order_items AS oq WHERE oq.id_order = orders.id_order) >
      (SELECT AVG(oq.quantity * oq.unit_price) FROM order_items AS oq);

------------------------------------ Partie 7 – Statistiques & agrégats

--Calculer le chiffre d’affaires total (toutes commandes confondues, hors commandes annulées si souhaité).
SELECT SUM(oq.quantity * oq.unit_price) FROM order_items AS oq
INNER JOIN orders AS o
ON oq.id_order = o.id_order
WHERE status != 'CANCELLED';

--Calculer le panier moyen (montant moyen par commande).
SELECT AVG(oq.quantity * oq.unit_price) FROM order_items AS oq;

--Calculer la quantité totale vendue par catégorie.
SELECT c.name_category, SUM(oq.quantity) FROM order_items AS oq
INNER JOIN products AS p
ON oq.id_product = p.id_product
INNER JOIN categories AS c
ON p.id_category = c.id_category
GROUP BY c.name_category;

--Calculer le chiffre d’affaires par mois (au moins sur les données fournies).
SELECT EXTRACT(MONTH FROM oq.created_at) AS mois, SUM(oq.quantity * oq.unit_price) FROM order_items AS oq
INNER JOIN orders AS o
ON oq.id_order = o.id_order
GROUP BY mois;

--Formater les montants pour n’afficher que deux décimales.
SELECT ROUND(SUM(oq.quantity * oq.unit_price), 2) FROM order_items AS oq;

------------------------------------ Partie 8 – Logique conditionnelle (CASE)


-- Pour chaque commande, afficher :

-- l’ID de la commande,
-- le client,
-- la date,
-- le statut,
-- une version “lisible” du statut en français via CASE :

-- PAID → “Payée”
-- SHIPPED → “Expédiée”
-- PENDING → “En attente”
-- CANCELLED → “Annulée”
SELECT o.id_order, c.firstname, c.lastname, o.created_at, o.status,
CASE WHEN o.status = 'PAID' THEN 'Payée'
WHEN o.status = 'SHIPPED' THEN 'Expédiée'
WHEN o.status = 'PENDING' THEN 'En attente'
WHEN o.status = 'CANCELLED' THEN 'Annulée'
END AS statut_francais
FROM orders AS o    
INNER JOIN customers AS c
ON o.id_customer = c.id_customer;


-- Pour chaque client, calculer le montant total dépensé et le classer en segments :

-- < 100 € → “Bronze”
-- 100–300 € → “Argent”
-- > 300 € → “Or”
-- Afficher : prénom, nom, montant total, segment.
SELECT c.firstname, c.lastname, SUM(oq.quantity * oq.unit_price) AS montant_total,
CASE WHEN SUM(oq.quantity * oq.unit_price) < 100 THEN 'Bronze'
WHEN SUM(oq.quantity * oq.unit_price) BETWEEN 100 AND 300 THEN 'Argent'
WHEN SUM(oq.quantity * oq.unit_price) > 300 THEN 'Or'
END AS segment
FROM orders AS o
INNER JOIN customers AS c
ON o.id_customer = c.id_customer
INNER JOIN order_items AS oq
ON o.id_order = oq.id_order
GROUP BY c.firstname, c.lastname;

------------------------------------ Partie 9 – Challenge final

Proposer et écrire 5 requêtes d’analyse avancées supplémentaires parmi, par exemple :

-- Top 5 des clients les plus actifs (nombre de commandes).
SELECT c.firstname, c.lastname, COUNT(o.id_order) AS nb_commandes FROM orders AS o
INNER JOIN customers AS c
ON o.id_customer = c.id_customer
GROUP BY c.firstname, c.lastname
ORDER BY nb_commandes DESC
LIMIT 5;

-- Top 5 des clients qui ont dépensé le plus (CA total).
SELECT c.firstname, c.lastname, SUM(oq.quantity * oq.unit_price) AS chiffre_affaire FROM orders AS o
INNER JOIN customers AS c
ON o.id_customer = c.id_customer
INNER JOIN order_items AS oq
ON o.id_order = oq.id_order
GROUP BY c.firstname, c.lastname
ORDER BY chiffre_affaire DESC
LIMIT 5;

-- Les 3 catégories les plus rentables (CA total).
SELECT c.name_category, SUM(oq.quantity * oq.unit_price) AS chiffre_affaire FROM order_items AS oq
INNER JOIN products AS p
ON oq.id_product = p.id_product
INNER JOIN categories AS c
ON p.id_category = c.id_category
GROUP BY c.name_category
ORDER BY chiffre_affaire DESC
LIMIT 3;

-- Les produits qui ont généré au total moins de 10 € de CA.
SELECT p.name_product, SUM(oq.quantity * oq.unit_price) AS chiffre_affaire FROM order_items AS oq
INNER JOIN products AS p
ON oq.id_product = p.id_product
GROUP BY p.name_product
HAVING SUM(oq.quantity * oq.unit_price) < 10;

-- Les clients n’ayant passé qu’une seule commande.
SELECT c.firstname, c.lastname, COUNT(o.id_order) AS nb_commandes FROM orders AS o
INNER JOIN customers AS c
ON o.id_customer = c.id_customer
GROUP BY c.firstname, c.lastname
HAVING COUNT(o.id_order) = 1;

-- Les produits présents dans des commandes annulées, avec le montant “perdu”.
SELECT p.name_product, SUM(oq.quantity * oq.unit_price) AS chiffre_affaire FROM order_items AS oq
INNER JOIN products AS p
ON oq.id_product = p.id_product
INNER JOIN orders AS o
ON o.id_order = oq.id_order
WHERE o.status = 'CANCELLED'
GROUP BY p.name_product;

