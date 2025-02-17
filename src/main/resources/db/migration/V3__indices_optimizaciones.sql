CREATE INDEX idx_user_ip ON deteccion_ip.ip_registros (ip_hash);
CREATE INDEX idx_actividad_ips_fecha ON deteccion_ip.actividad_ips (fecha);
CREATE INDEX idx_actividad_ips_evento ON deteccion_ip.actividad_ips (evento);
