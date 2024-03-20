1- first make sure that you have docker Docker Desktop app installed on your device.
2- run composer install to get vendor folder
3- change DB_USER , DB_PASSWORD and DB_ROOT_PASSWORD in the .env file then go to the docker   folder inside the project folder => mysql => init.sql  and change the DB_USER and DB_PASSWORD   such as in the .env file
4- run docker compose up -d --build
5- if every thing is fine go to docker desktop then the app container to see the app logs and check if the fpm is running this will take more time to see fpm running.
6- go to nginx container then ports and click on 80:80