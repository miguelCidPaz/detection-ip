DROP FUNCTION IF EXISTS deteccion_ip.crear_particion_actividad_ips CASCADE;

CREATE OR REPLACE FUNCTION deteccion_ip.crear_particion_actividad_ips()
RETURNS TRIGGER AS $$
DECLARE
    nombre_particion TEXT;
    fecha_inicio TIMESTAMP;
    fecha_fin TIMESTAMP;
BEGIN
    nombre_particion := 'actividad_ips_' || TO_CHAR(NEW.fecha, 'YYYYMM');
    fecha_inicio := DATE_TRUNC('month', NEW.fecha);
    fecha_fin := fecha_inicio + INTERVAL '1 month';

    -- Verificar si la partición existe correctamente
    IF NOT EXISTS (
        SELECT 1 FROM pg_inherits 
        JOIN pg_class parent ON parent.oid = pg_inherits.inhparent
        JOIN pg_class child ON child.oid = pg_inherits.inhrelid
        WHERE parent.relname = 'actividad_ips' AND child.relname = nombre_particion
    ) THEN
        BEGIN
            EXECUTE format(
                'CREATE TABLE deteccion_ip.%I PARTITION OF deteccion_ip.actividad_ips 
                 FOR VALUES FROM (%L) TO (%L)', 
                nombre_particion, fecha_inicio, fecha_fin
            );
        EXCEPTION WHEN others THEN
            -- Manejo de concurrencia: si falla porque otro proceso creó la partición, ignorar el error
            NULL;
        END;
    END IF;

    -- Insertar en la partición correcta
    EXECUTE format(
        'INSERT INTO deteccion_ip.%I (id, ip_hash, user_id, fecha, evento, metadata) 
         VALUES ($1, $2, $3, $4, $5, $6)', 
        nombre_particion
    ) USING NEW.id, NEW.ip_hash, NEW.user_id, NEW.fecha, NEW.evento, NEW.metadata;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS actividad_ips_particiones ON deteccion_ip.actividad_ips;

CREATE TRIGGER actividad_ips_particiones
BEFORE INSERT ON deteccion_ip.actividad_ips
FOR EACH ROW EXECUTE FUNCTION deteccion_ip.crear_particion_actividad_ips();