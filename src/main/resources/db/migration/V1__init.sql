-- Crear el schema si no existe
CREATE SCHEMA IF NOT EXISTS deteccion_ip;

-- Crear tabla de registros de IP
CREATE TABLE deteccion_ip.ip_registros (
    ip_hash VARCHAR(64) PRIMARY KEY,
    primera_aparicion TIMESTAMP DEFAULT NOW()
);

-- Crear tabla con detalles adicionales de IPs
CREATE TABLE deteccion_ip.detalles_ip (
    ip_hash VARCHAR(64) PRIMARY KEY,
    latitud DECIMAL(9,6),
    longitud DECIMAL(9,6),
    proveedor_nube VARCHAR(100),
    tipo_dispositivo VARCHAR(100),
    FOREIGN KEY (ip_hash) REFERENCES deteccion_ip.ip_registros(ip_hash) ON DELETE CASCADE
);

-- Crear tabla para asociar usuarios con IPs
CREATE TABLE deteccion_ip.usuarios_ips (
    user_id UUID NOT NULL,
    ip_hash VARCHAR(64) NOT NULL,
    ultima_aparicion TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (user_id, ip_hash),
    FOREIGN KEY (ip_hash) REFERENCES deteccion_ip.ip_registros(ip_hash) ON DELETE CASCADE
);
