--  Automatización y Reglas de Negocio Avanzadas (Triggers y Eventos) 

-- 1. Trigger 1: trg_ValidarPesoGanado (BEFORE INSERT / BEFORE UPDATE) 

DELIMITER //

CREATE TRIGGER trg_ValidarPesoGanado_Insert
BEFORE INSERT ON ganado 
FOR EACH ROW
BEGIN
     
    IF NEW.peso <= 0 OR NEW.peso >= 1500.00 THEN
        
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El peso ingresado está fuera de los rangos biológicos válidos (1 - 1500 kg)';
    END IF; 
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER trg_ValidarPesoGanado_Update
BEFORE UPDATE ON ganado 
FOR EACH ROW
BEGIN
     
    IF NEW.peso <= 0 OR NEW.peso >= 1500.00 THEN
        
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El peso ingresado está fuera de los rangos biológicos válidos (1 - 1500 kg)';
    END IF; 
END //

DELIMITER ;

-- 2. Trigger 2: trg_AuditarAumentoSalario (AFTER UPDATE)

-- Antes de crear el trigger debo crear la tabla 

CREATE TABLE IF NOT EXISTS auditoria_salarios (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    empleado_id INT NOT NULL,
    salario_anterior DECIMAL(10,2) NOT NULL,
    salario_nuevo DECIMAL(10,2) NOT NULL,
    diferencia DECIMAL(10,2) NOT NULL,
    fecha_modificacion DATETIME NOT NULL
);


DELIMITER //

CREATE TRIGGER trg_AuditarAumentoSalario
AFTER UPDATE ON empleados  
FOR EACH ROW
BEGIN
   
    IF NEW.salario <> OLD.salario THEN
       	
        
        INSERT INTO auditoria_salarios (
            empleado_id, 
            salario_anterior, 
            salario_nuevo, 
            diferencia, 
            fecha_modificacion
        )
        VALUES (
            NEW.empleado_id,       
            OLD.salario,           
            NEW.salario,           
            (NEW.salario - OLD.salario), 
            NOW()                  
        );
        
    END IF; 
END //

DELIMITER ;


-- 3. Trigger 3: trg_ValidarIntervaloVacunacion (BEFORE INSERT) 

DELIMITER //

CREATE TRIGGER trg_ValidarIntervaloVacunacion
BEFORE INSERT ON vacunacion  
FOR EACH ROW
BEGIN
    
    DECLARE v_ultima_fecha DATE;

    
    SELECT MAX(fecha_aplicacion) 
    INTO v_ultima_fecha
    FROM vacunacion
    WHERE ganado_id = NEW.ganado_id 
      AND vacuna_id = NEW.vacuna_id;

    
    IF v_ultima_fecha IS NOT NULL AND DATEDIFF(NEW.fecha_aplicacion, v_ultima_fecha) < 30 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El animal ya recibió esta vacuna en un periodo menor a 30 días';
    END IF;

END //

DELIMITER ;

-- 4.Evento 1: evt_DepuracionAuditoriaMensual (Recurrente Mensual) 

CREATE TABLE IF NOT EXISTS bitacora_mantenimiento (
    id_bitacora INT AUTO_INCREMENT PRIMARY KEY,
    evento_nombre VARCHAR(100) NOT NULL,
    filas_purgadas INT NOT NULL,
    fecha_ejecucion DATETIME NOT NULL
);


SET GLOBAL event_scheduler = ON; 

DELIMITER //

CREATE EVENT evt_DepuracionAuditoriaMensual
ON SCHEDULE EVERY 1 MONTH 
STARTS CURRENT_TIMESTAMP 
DO
BEGIN
    
    DECLARE v_filas_eliminadas INT DEFAULT 0;

    DELETE FROM auditoria_salarios 
    WHERE fecha_modificacion < NOW() - INTERVAL 6 MONTH;
    
    
    SET v_filas_eliminadas = ROW_COUNT();
    
    INSERT INTO bitacora_mantenimiento (evento_nombre, filas_purgadas, fecha_ejecucion)
    VALUES ('evt_DepuracionAuditoriaMensual', v_filas_eliminadas, NOW());

END //

DELIMITER ;

-- 5. Evento 2: evt_CierreSemanalProduccionLeche (Recurrente Semanal)

CREATE TABLE IF NOT EXISTS resumen_semanal_fincas (
    id_resumen INT AUTO_INCREMENT PRIMARY KEY,
    finca_id INT NOT NULL,
    litros_totales DECIMAL(10,2) NOT NULL,
    semana_anio INT NOT NULL,
    fecha_cierre DATE NOT NULL
);


SET GLOBAL event_scheduler = ON; 

DELIMITER //

CREATE EVENT evt_CierreSemanalProduccionLeche
ON SCHEDULE EVERY 1 WEEK 
STARTS '2026-09-13 23:59:00' 
DO
BEGIN

    
    INSERT INTO resumen_semanal_fincas (finca_id, litros_totales, semana_anio, fecha_cierre)
    SELECT 
        g.finca_id,            
        SUM(pl.litros),         
        WEEK(CURDATE()),        
        CURDATE()               
    FROM produccion_leche pl
    JOIN ganado g ON pl.ganado_id = g.ganado_id
    WHERE pl.fecha >= CURDATE() - INTERVAL 7 DAY 
    GROUP BY g.finca_id;

END //

DELIMITER ;