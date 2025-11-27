import psycopg
import datetime

DSN = "dbname=postgres-ecommerce user=tata password=secret host=postgres-ecommerce port=5432"

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

        with open("rapport.txt", "w") as f:
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
    with open("rapport.txt", "w") as f:
        f.write("Création du fichier")

if __name__ == "__main__":
    # init_db()
    create_file()
    create_rapport()