1. Install PHP 7.4 using `brew install php@7.4`
1. Run `composer update`
1. Copy and paste the `.env.example` file as `.env` and enter the db credentials to match your docker-compose.yaml file:
    ```DB_CONNECTION=mysql
    DB_HOST=database
    DB_PORT=3306
    DB_DATABASE=vulnerable_app
    DB_USERNAME=almostroot
    DB_PASSWORD=password123```
1. Run `docker-compose up -d`
1. Run `docker exec vuln-app php artisan migrate --seed`
1. App should be at `http://localhost:1234/`