CREATE TABLE deteccion_ip.actividad_ips (
    id SERIAL,
    ip_hash VARCHAR(64) NOT NULL,
    user_id UUID,
    fecha TIMESTAMP DEFAULT NOW(),
    evento VARCHAR(100),
    metadata JSONB,
    PRIMARY KEY (fecha,id)
) PARTITION BY RANGE (fecha);

DROP TRIGGER IF EXISTS actividad_ips_particiones ON deteccion_ip.actividad_ips;
DROP FUNCTION IF EXISTS deteccion_ip.crear_particion_actividad_ips();
