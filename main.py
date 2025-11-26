import psycopg
import datetime

DSN = "dbname=postgres-ecommerce user=tata password=secret host=postgres-ecommerce port=5432"


def init_db():
    with psycopg.connect(DSN) as conn:
        with conn.cursor() as cur:
            # PARTIE 1 — Suppression des contraintes et tables
            cur.execute("ALTER TABLE IF EXISTS products DROP CONSTRAINT IF EXISTS fk_id_category;")
            cur.execute("ALTER TABLE IF EXISTS orders DROP CONSTRAINT IF EXISTS fk_id_customer;")
            cur.execute("ALTER TABLE IF EXISTS order_items DROP CONSTRAINT IF EXISTS fk_id_product;")
            cur.execute("DROP TABLE IF EXISTS order_items, orders, products, categories, customers;")

            # TABLE categories
            cur.execute("""
                CREATE TABLE IF NOT EXISTS categories(
                    id_category INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                    name_category VARCHAR(100) NOT NULL UNIQUE,
                    description_category VARCHAR(255)
                );
            """)

            # TABLE products
            cur.execute("""
                CREATE TABLE IF NOT EXISTS products(
                    id_product INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                    name_product VARCHAR(100) NOT NULL,
                    price_product DECIMAL(5,2) CHECK (price_product > 0),
                    stock_product INT CHECK(stock_product > 0),
                    id_category INT NOT NULL,
                    CONSTRAINT fk_id_category FOREIGN KEY(id_category) REFERENCES categories(id_category)
                );
            """)

            # TABLE customers
            cur.execute("""
                CREATE TABLE IF NOT EXISTS customers(
                    id_customer INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                    firstname VARCHAR(50) NOT NULL,
                    lastname VARCHAR(50) NOT NULL,
                    email VARCHAR(50) NOT NULL UNIQUE,
                    created_at DATE NOT NULL DEFAULT CURRENT_TIMESTAMP
                );
            """)

            # TABLE orders
            cur.execute("""
                CREATE TABLE IF NOT EXISTS orders(
                    id_order INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                    created_at DATE DEFAULT CURRENT_TIMESTAMP,
                    status VARCHAR(50) NOT NULL CHECK (status IN ('PENDING', 'PAID', 'SHIPPED', 'CANCELLED')),
                    id_customer INT NOT NULL,
                    CONSTRAINT fk_id_customer FOREIGN KEY(id_customer) REFERENCES customers(id_customer)
                );
            """)

            # TABLE order_items
            cur.execute("""
                CREATE TABLE IF NOT EXISTS order_items(
                    id_product INT NOT NULL,
                    id_order INT NOT NULL,
                    created_at DATE NOT NULL,
                    quantity INT CHECK (quantity > 0),
                    unit_price DECIMAL(5,2),
                    CONSTRAINT fk_id_product FOREIGN KEY(id_product) REFERENCES products(id_product),
                    CONSTRAINT fk_id_order FOREIGN KEY(id_order) REFERENCES orders(id_order)
                );
            """)

            cur.execute("""
            INSERT INTO categories (name_category, description_category) VALUES
            ('Électronique',       'Produits high-tech et accessoires'),
            ('Maison & Cuisine',   'Électroménager et ustensiles'),
            ('Sport & Loisirs',    'Articles de sport et plein air'),
            ('Beauté & Santé',     'Produits de beauté, hygiène, bien-être'),
            ('Jeux & Jouets',      'Jouets pour enfants et adultes');
            """)

            cur.execute("""
            INSERT INTO customers (firstname, lastname, email, created_at) VALUES
            ('Alice',  'Martin',    'alice.martin@mail.com',    '2024-01-10 14:32'),
            ('Bob',    'Dupont',    'bob.dupont@mail.com',      '2024-02-05 09:10'),
            ('Chloé',  'Bernard',   'chloe.bernard@mail.com',   '2024-03-12 17:22'),
            ('David',  'Robert',    'david.robert@mail.com',    '2024-01-29 11:45'),
            ('Emma',   'Leroy',     'emma.leroy@mail.com',      '2024-03-02 08:55'),
            ('Félix',  'Petit',     'felix.petit@mail.com',     '2024-02-18 16:40'),
            ('Hugo',   'Roussel',   'hugo.roussel@mail.com',    '2024-03-20 19:05'),
            ('Inès',   'Moreau',    'ines.moreau@mail.com',     '2024-01-17 10:15'),
            ('Julien', 'Fontaine',  'julien.fontaine@mail.com', '2024-01-23 13:55'),
            ('Katia',  'Garnier',   'katia.garnier@mail.com',   '2024-03-15 12:00');
            """)

            cur.execute("""
            INSERT INTO products (name_product, price_product, stock_product, id_category) VALUES
            ('Casque Bluetooth X1000',        79.99,  50,  (SELECT id_category FROM categories WHERE name_category = 'Électronique')),
            ('Souris Gamer Pro RGB',          49.90, 120,  (SELECT id_category FROM categories WHERE name_category = 'Électronique')),
            ('Bouilloire Inox 1.7L',          29.99,  80,  (SELECT id_category FROM categories WHERE name_category = 'Maison & Cuisine')),
            ('Aspirateur Cyclonix 3000',     129.00,  40,  (SELECT id_category FROM categories WHERE name_category = 'Maison & Cuisine')),
            ('Tapis de Yoga Comfort+',        19.99, 150,  (SELECT id_category FROM categories WHERE name_category = 'Sport & Loisirs')),
            ('Haltères 5kg (paire)',          24.99,  70,  (SELECT id_category FROM categories WHERE name_category = 'Sport & Loisirs')),
            ('Crème hydratante BioSkin',      15.90, 200,  (SELECT id_category FROM categories WHERE name_category = 'Beauté & Santé')),
            ('Gel douche FreshEnergy',         4.99, 300,  (SELECT id_category FROM categories WHERE name_category = 'Beauté & Santé')),
            ('Puzzle 1000 pièces "Montagne"', 12.99,  95,  (SELECT id_category FROM categories WHERE name_category = 'Jeux & Jouets')),
            ('Jeu de société "Galaxy Quest"', 29.90,  60,  (SELECT id_category FROM categories WHERE name_category = 'Jeux & Jouets'));
            """)

            cur.execute("""
            INSERT INTO orders (id_customer, created_at, status ) VALUES
            ((SELECT id_customer FROM customers WHERE email = 'alice.martin@mail.com'),    '2024-03-01 10:20', 'PAID'),
            ((SELECT id_customer FROM customers WHERE email = 'bob.dupont@mail.com'),      '2024-03-04 09:12', 'SHIPPED'),
            ((SELECT id_customer FROM customers WHERE email = 'chloe.bernard@mail.com'),   '2024-03-08 15:02', 'PAID'),
            ((SELECT id_customer FROM customers WHERE email = 'david.robert@mail.com'),    '2024-03-09 11:45', 'CANCELLED'),
            ((SELECT id_customer FROM customers WHERE email = 'emma.leroy@mail.com'),      '2024-03-10 08:10', 'PAID'),
            ((SELECT id_customer FROM customers WHERE email = 'felix.petit@mail.com'),     '2024-03-11 13:50', 'PENDING'),
            ((SELECT id_customer FROM customers WHERE email = 'hugo.roussel@mail.com'),    '2024-03-15 19:30', 'SHIPPED'),
            ((SELECT id_customer FROM customers WHERE email = 'ines.moreau@mail.com'),     '2024-03-16 10:00', 'PAID'),
            ((SELECT id_customer FROM customers WHERE email = 'julien.fontaine@mail.com'), '2024-03-18 14:22', 'PAID'),
            ((SELECT id_customer FROM customers WHERE email = 'katia.garnier@mail.com'),   '2024-03-20 18:00', 'PENDING');
            """)

            cur.execute("""
            INSERT INTO order_items (id_order, created_at, id_product, quantity, unit_price) VALUES
            ((SELECT id_order FROM orders WHERE id_order = (SELECT id_customer FROM customers WHERE email = 'alice.martin@mail.com')), '2024-03-01 10:20', (SELECT id_product FROM products WHERE name_product = 'Casque Bluetooth X1000'),         1,  79.99),
            ((SELECT id_order FROM orders WHERE id_order = (SELECT id_customer FROM customers WHERE email = 'alice.martin@mail.com')), '2024-03-01 10:20', (SELECT id_product FROM products WHERE name_product = 'Puzzle 1000 pièces "Montagne"'), 2,  12.99),
            ((SELECT id_order FROM orders WHERE id_order = (SELECT id_customer FROM customers WHERE email = 'bob.dupont@mail.com')),   '2024-03-04 09:12', (SELECT id_product FROM products WHERE name_product = 'Tapis de Yoga Comfort+'),        1,  19.99),
            ((SELECT id_order FROM orders WHERE id_order = (SELECT id_customer FROM customers WHERE email = 'chloe.bernard@mail.com')), '2024-03-08 15:02', (SELECT id_product FROM products WHERE name_product = 'Bouilloire Inox 1.7L'),          1,  29.99),
            ((SELECT id_order FROM orders WHERE id_order = (SELECT id_customer FROM customers WHERE email = 'chloe.bernard@mail.com')), '2024-03-08 15:02', (SELECT id_product FROM products WHERE name_product = 'Gel douche FreshEnergy'),        3,   4.99),
            ((SELECT id_order FROM orders WHERE id_order = (SELECT id_customer FROM customers WHERE email = 'david.robert@mail.com')),  '2024-03-09 11:45', (SELECT id_product FROM products WHERE name_product = 'Haltères 5kg (paire)'),          1,  24.99),
            ((SELECT id_order FROM orders WHERE id_order = (SELECT id_customer FROM customers WHERE email = 'emma.leroy@mail.com')),    '2024-03-10 08:10', (SELECT id_product FROM products WHERE name_product = 'Crème hydratante BioSkin'),      2,  15.90),
            ((SELECT id_order FROM orders WHERE id_order = (SELECT id_customer FROM customers WHERE email = 'julien.fontaine@mail.com')),'2024-03-18 14:22', (SELECT id_product FROM products WHERE name_product = 'Jeu de société "Galaxy Quest"'), 1,  29.90),
            ((SELECT id_order FROM orders WHERE id_order = (SELECT id_customer FROM customers WHERE email = 'katia.garnier@mail.com')), '2024-03-20 18:00', (SELECT id_product FROM products WHERE name_product = 'Souris Gamer Pro RGB'),          1,  49.90),
            ((SELECT id_order FROM orders WHERE id_order = (SELECT id_customer FROM customers WHERE email = 'katia.garnier@mail.com')), '2024-03-20 18:00', (SELECT id_product FROM products WHERE name_product = 'Gel douche FreshEnergy'),        2,   4.99);
            """)


    print("Base initialisée !")

def create_rapport():
    with psycopg.connect(DSN) as conn:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT SUM(oq.quantity * oq.unit_price) FROM order_items AS oq
                INNER JOIN orders AS o
                ON oq.id_order = o.id_order
                WHERE status != 'CANCELLED';
            """)
            chiffres_affaires = cur.fetchall()
            
            cur.execute("""
                SELECT AVG(oq.quantity * oq.unit_price) FROM order_items AS oq;
            """)
            panier_moyens = cur.fetchall()

            cur.execute("""
                SELECT c.name_category, SUM(oq.quantity) FROM order_items AS oq
                INNER JOIN products AS p
                ON oq.id_product = p.id_product
                INNER JOIN categories AS c
                ON p.id_category = c.id_category
                GROUP BY c.name_category;
            """)
            total_by_category = cur.fetchall()

            cur.execute("""
                SELECT EXTRACT(MONTH FROM oq.created_at) AS mois, SUM(oq.quantity * oq.unit_price) FROM order_items AS oq
                INNER JOIN orders AS o
                ON oq.id_order = o.id_order
                GROUP BY mois;
            """)
            chiffre_affaire_par_moi = cur.fetchall()

            date = datetime.datetime.now()

        with open("test.txt", "w") as f:
            f.write(f"=========== date : {date} =========\n\n")

            f.write("=========== chiffres d'affaire =========\n")
            for chiffres_affaire in chiffres_affaires:
                f.write(str(chiffres_affaire) + "\n")
            f.write("\n")

            f.write("=========== panier moyen =========\n")
            for panier_moyen in panier_moyens:
                f.write(str(panier_moyen) + "\n")
            f.write("\n")

            f.write("=========== total par catégorie =========\n")
            for total in total_by_category:
                f.write(str(total) + "\n")
            f.write("\n")

            f.write("=========== total par mois =========\n")
            for mois in chiffre_affaire_par_moi:
                f.write(str(mois) + "\n")




def create_file():
    with open("test.txt", "w") as f:
        f.write("test")

if __name__ == "__main__":
    init_db()
    create_file()
    create_rapport()