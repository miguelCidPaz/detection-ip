-- V2: Creación de la tabla particionada (actividad_ips)

CREATE TABLE deteccion_ip.actividad_ips (
    id SERIAL,
    ip_hash VARCHAR(64) NOT NULL,
    user_id UUID,
    fecha TIMESTAMP DEFAULT NOW(),
    evento VARCHAR(100),
    metadata JSONB,
    -- Se define la clave primaria compuesta: la columna 'fecha' también es la clave de partición
    PRIMARY KEY (fecha, id)
) PARTITION BY RANGE (fecha);

-- Limpieza previa de trigger/función (por si existían de una versión anterior)
DROP TRIGGER IF EXISTS actividad_ips_particiones ON deteccion_ip.actividad_ips;
DROP FUNCTION IF EXISTS deteccion_ip.crear_particion_actividad_ips();
