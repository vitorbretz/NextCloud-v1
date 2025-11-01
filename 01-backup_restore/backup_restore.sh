  GNU nano 8.3                                                                                     backup_restore.sh
#!/bin/bash

# Configurações do PostgreSQL local (container)
PGUSER_LOCAL="nextcloud"
PGDATABASE_LOCAL="nextcloud"
PGPASSWORD_LOCAL="MySecurePass123!"

# Configurações do PostgreSQL no RDS da AWS
PGHOST_RDS="aurora-postgres-dev.cluster-c9226ous4oya.sa-east-1.rds.amazonaws.com"
PGPORT_RDS="5432"
PGUSER_RDS="nextcloud"
PGDATABASE_RDS="nextcloud"
PGPASSWORD_RDS="MySecurePass123!"

# Caminho para o arquivo de dump
DUMP_FILE="nextcloud_dump.sql"

# Fazendo o dump do banco de dados local
echo "Fazendo dump do banco de dados local..."
docker exec proj-nextcloud-db-1 pg_dump -U $PGUSER_LOCAL -d $PGDATABASE_LOCAL -F c -b -v > $DUMP_FILE

# Verificando se o dump foi bem-sucedido
if [ $? -eq 0 ]; then
    echo "Dump do banco de dados local concluído com sucesso!"
else
    echo "Erro ao fazer o dump do banco de dados local."
    exit 1
fi

# Preparando banco no RDS usando container
echo "Preparando banco no RDS..."
docker exec -e PGPASSWORD=$PGPASSWORD_RDS proj-nextcloud-db-1 psql -h $PGHOST_RDS -U $PGUSER_RDS -d postgres -c "DROP DATABASE IF EXISTS $PGDATABASE_RDS;"
docker exec -e PGPASSWORD=$PGPASSWORD_RDS proj-nextcloud-db-1 psql -h $PGHOST_RDS -U $PGUSER_RDS -d postgres -c "CREATE DATABASE $PGDATABASE_RDS;"

# Copiando dump para o container
echo "Copiando dump para o container..."
docker cp $DUMP_FILE proj-nextcloud-db-1:/tmp/

# Restaurando o dump no RDS
echo "Restaurando dump no RDS..."
docker exec -e PGPASSWORD=$PGPASSWORD_RDS proj-nextcloud-db-1 pg_restore --no-owner --no-acl -h $PGHOST_RDS -p $PGPORT_RDS -U $PGUSER_RDS -d $PGDATABASE_RDS -v /tmp/$DUMP_FILE

# Verificando se a restauração foi bem-sucedida
if [ $? -eq 0 ]; then
    echo "Restauração no RDS concluída com sucesso!"
else
    echo "Erro ao restaurar o dump no RDS."
    exit 1
fi