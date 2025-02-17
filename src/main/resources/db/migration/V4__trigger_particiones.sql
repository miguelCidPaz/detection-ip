-- V4: Implementación del trigger para particionar automáticamente

-- Primero, eliminamos si existían versiones anteriores
DROP TRIGGER IF EXISTS actividad_ips_particiones ON deteccion_ip.actividad_ips;
DROP FUNCTION IF EXISTS deteccion_ip.crear_particion_actividad_ips CASCADE;

CREATE OR REPLACE FUNCTION deteccion_ip.crear_particion_actividad_ips()
RETURNS TRIGGER AS $$
DECLARE
    nombre_particion TEXT;
    fecha_inicio TIMESTAMP;
    fecha_fin TIMESTAMP;
BEGIN
    -- Nombre de la partición en base a YYYYMM
    nombre_particion := 'actividad_ips_' || TO_CHAR(NEW.fecha, 'YYYYMM');
    
    -- Rango de fechas de la partición: primer día de mes y el siguiente mes
    fecha_inicio := DATE_TRUNC('month', NEW.fecha);
    fecha_fin := fecha_inicio + INTERVAL '1 month';

    -- Verificar si la partición existe consultando pg_inherits
    IF NOT EXISTS (
        SELECT 1
        FROM pg_inherits
        JOIN pg_class parent ON parent.oid = pg_inherits.inhparent
        JOIN pg_class child ON child.oid = pg_inherits.inhrelid
        WHERE parent.relname = 'actividad_ips'
          AND child.relname = nombre_particion
    ) THEN
        -- Si no existe, la creamos dinámicamente
        EXECUTE format(
            'CREATE TABLE deteccion_ip.%I PARTITION OF deteccion_ip.actividad_ips
             FOR VALUES FROM (%L) TO (%L)',
            nombre_particion, fecha_inicio, fecha_fin
        );
    END IF;

    -- Insertamos en la partición apropiada
    EXECUTE format(
        'INSERT INTO deteccion_ip.%I (id, ip_hash, user_id, fecha, evento, metadata)
         VALUES ($1, $2, $3, $4, $5, $6)',
        nombre_particion
    )
    USING NEW.id, NEW.ip_hash, NEW.user_id, NEW.fecha, NEW.evento, NEW.metadata;

    -- Devuelve NULL para que el registro no entre en la tabla padre
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER actividad_ips_particiones
BEFORE INSERT ON deteccion_ip.actividad_ips
FOR EACH ROW
EXECUTE FUNCTION deteccion_ip.crear_particion_actividad_ips();
