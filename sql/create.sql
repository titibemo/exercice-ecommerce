-- PARTIE 1
ALTER TABLE IF EXISTS products DROP CONSTRAINT IF EXISTS fk_id_category;
ALTER TABLE IF EXISTS orders DROP CONSTRAINT IF EXISTS fk_id_customer;
ALTER TABLE IF EXISTS order_items DROP CONSTRAINT IF EXISTS fk_id_product;
DROP TABLE IF EXISTS order_items, orders, products, categories, customers;

CREATE TABLE IF NOT EXISTS categories(
   id_category INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
   name_category VARCHAR(100) NOT NULL UNIQUE,
   description_category VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS products(
   id_product INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
   name_product VARCHAR(100) NOT NULL,
   price_product DECIMAL(5,2) CHECK (price_product > 0),
   stock_product INT CHECK(stock_product > 0),
   id_category INT NOT NULL,

   CONSTRAINT fk_id_category FOREIGN KEY(id_category) REFERENCES categories(id_category)
);

CREATE TABLE IF NOT EXISTS customers(
   id_customer INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
   firstname VARCHAR(50) NOT NULL,
   lastname VARCHAR(50) NOT NULL,
   email VARCHAR(50) NOT NULL UNIQUE,
   created_at DATE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS orders(
   id_order INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
   created_at DATE DEFAULT CURRENT_TIMESTAMP,
   status VARCHAR(50) NOT NULL CHECK ("status" IN ('PENDING', 'PAID', 'SHIPPED', 'CANCELLED')),
   id_customer INT NOT NULL,

   CONSTRAINT fk_id_customer FOREIGN KEY(id_customer) REFERENCES customers(id_customer)
);

CREATE TABLE IF NOT EXISTS order_items(
   id_product INT NOT NULL,
   id_order INT NOT NULL,
   created_at DATE NOT NULL,
   quantity INT CHECK (quantity > 0),
   unit_price DECIMAL(5,2),

   CONSTRAINT fk_id_product FOREIGN KEY(id_product) REFERENCES products(id_product),
   CONSTRAINT fk_id_order FOREIGN KEY(id_order) REFERENCES orders(id_order)
);

--- extentions

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

