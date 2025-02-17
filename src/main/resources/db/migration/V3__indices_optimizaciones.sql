-- V3: Creación de índices para optimizar consultas

-- Comentario: El nombre idx_user_ip es un poco engañoso porque en realidad indexa 'ip_hash'.
-- A nivel funcional no es un error, pero podría renombrarse a ip_registros_ip_hash_idx.
CREATE INDEX idx_user_ip ON deteccion_ip.ip_registros (ip_hash);

-- Índices sobre la tabla padre particionada. Ojo con el tipo de índice (global vs local/particionado).
CREATE INDEX idx_actividad_ips_fecha ON deteccion_ip.actividad_ips (fecha);
CREATE INDEX idx_actividad_ips_evento ON deteccion_ip.actividad_ips (evento);
