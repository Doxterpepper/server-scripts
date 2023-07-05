
DB_USERNAME=admin
DB_PASSWORD=password1
NETWORK=keycloak-network

docker run --name keycloak --net $NETWORK jboss/keycloak -e POSTGRES_DB=keycloak -e POSTGRES_USER=$DB_USERNAME -e POSTGRES_PASSWORD=$DB_PASSWORD
