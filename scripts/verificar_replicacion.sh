#!/bin/bash

echo "=== VERIFICAR ESTADO DE REPLICACION ==="
echo ""
echo "--- SERVIDOR PRIMARIO ---"
psql -h postgres-primario -U admin -d sistema_db_geografico_tec -c "SELECT client_addr, state, sync_state FROM pg_stat_replication;"

echo ""
echo "--- SERVIDOR REPLICA ---"
psql -h postgres-replica -U admin -d sistema_db_geografico_tec -c "SELECT pg_is_in_recovery();"

echo ""
echo "--- CANTIDAD DE REGISTROS PRIMARIO ---"
psql -h postgres-primario -U admin -d sistema_db_geografico_tec -c "SELECT tablename, (SELECT count(*) FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE') as total_tablas FROM pg_tables WHERE schemaname='public';"

echo ""
echo "--- CANTIDAD DE REGISTROS REPLICA ---"
psql -h postgres-replica -U admin -d sistema_db_geografico_tec -c "SELECT tablename, (SELECT count(*) FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE') as total_tablas FROM pg_tables WHERE schemaname='public';"