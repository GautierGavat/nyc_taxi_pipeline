# NYC Taxi Pipeline - dbt & Snowflake 🚕

Ce projet transforme les données brutes des taxis New-Yorkais (025) en tables analytiques exploitables.

## Architecture
- **RAW** : Données brutes (Parquet) chargées dans Snowflake.
- **STAGING** : Nettoyage (Filtres distances < 100mi, montants > 0).
- **INTERMEDIATE** : Calcul des métriques (Vitesse, Catégories de distance, Rush Hours).
- **MART** : Tables agrégées pour la dataviz (Daily, Zone, Hourly).

## Installation & Exécution
1. Configurer le `profiles.yml` pour Snowflake.
2. Installer dbt : `pip install dbt-snowflake`
3. Lancer les transformations : `dbt run`
4. Lancer les tests : `dbt test`