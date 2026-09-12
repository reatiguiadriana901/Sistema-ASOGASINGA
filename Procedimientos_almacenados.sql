-- PROCEDIMIENTOS ALMACENADOS

-- 1. Registrar producción de leche 

DELIMITER //

CREATE PROCEDURE sp_RegistrarProduccionLeche (
    IN p_codigo_arete VARCHAR(50),
    IN p_fecha DATE,
    IN p_litros DECIMAL(10,2)
)
BEGIN
    DECLARE v_ganado_id INT DEFAULT NULL;
    DECLARE v_nombre_tipo VARCHAR(50);
    DECLARE v_sexo VARCHAR(10);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    
    
    SELECT g.ganado_id, tg.nombre_tipo, g.sexo
    INTO v_ganado_id, v_nombre_tipo, v_sexo
    FROM ganado g
    JOIN tipos_ganado tg ON g.tipo_id = tg.tipo_id
    WHERE g.codigo_arete = p_codigo_arete;
    
   
    IF v_ganado_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No existe un animal con el código de arete indicado.';
    ELSEIF LOWER(v_nombre_tipo) = 'lechero' AND LOWER(v_sexo) = 'hembra' THEN
        
        INSERT INTO produccion_leche (ganado_id, fecha, litros)
        VALUES (v_ganado_id, p_fecha, p_litros);
    ELSE
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El animal especificado no corresponde a una hembra lechera.';
    END IF;
    
    
    COMMIT;
END //

DELIMITER ;

-- 2. Actualizacion de salario de empleado

DELIMITER //

CREATE PROCEDURE sp_ActualizarSalarioEmpleado (
IN p_empleado_id INT,
IN p_porcentaje DECIMAL(10,2),
OUT p_mensaje VARCHAR(100)
)

BEGIN
	DECLARE v_existe INT;
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    
    SELECT COUNT(*) INTO v_existe
    FROM empleados
    WHERE empleado_id = p_empleado_id;
    
    IF v_existe = 0 THEN 
    		SET p_mensaje = 'Error:El empleado no existe';
    	ELSE
    		UPDATE empleados
    		SET salario = salario * ( 1 + (p_porcentaje/100))
    		WHERE empleado_id = p_empleado_id;
    
    		SET p_mensaje = 'salario actualizado con exito';
    	END IF;
    		
    	COMMIT;
	
END //


DELIMITER ;

-- 3. Trasladar ganado a otra finca


DELIMITER //


CREATE PROCEDURE sp_TrasladarGanadoFinca (
IN p_ganado_id  INT,
IN p_finca_id INT,
OUT p_mensaje VARCHAR(100)
)

BEGIN
	
	DECLARE v_existe_ganado INT DEFAULT 0;
    DECLARE v_existe_finca INT DEFAULT 0;
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION; 
    
    SELECT COUNT(*) INTO v_existe_ganado
    FROM ganado
    WHERE ganado_id = p_ganado_id;
    
    SELECT COUNT(*) INTO v_existe_finca
    FROM fincas
    WHERE finca_id = p_finca_id;
    
    IF v_existe_ganado = 0 THEN
    
        SET p_mensaje = 'Error: El ganado especificado no existe.';
        ROLLBACK;
        
    ELSEIF v_existe_finca = 0 THEN
        SET p_mensaje = 'Error: La finca de destino no existe.';
        ROLLBACK;
    ELSE
    
    
     UPDATE ganado
        SET finca_id = p_finca_id
        WHERE ganado_id = p_ganado_id;

        SET p_mensaje = 'Traslado de ganado realizado con éxito.';
        COMMIT;
    END IF;

END //

DELIMITER ;

-- 4. Registrar vacunación

DELIMITER //

CREATE PROCEDURE sp_RegistrarVacunacion (
IN p_codigo_arete VARCHAR(50),
IN p_nombre VARCHAR(100),
IN p_veterinario_id INT,
IN p_observaciones VARCHAR(200),
OUT p_mensaje VARCHAR(100)
)

BEGIN
	
	DECLARE v_ganado_id INT DEFAULT NULL;
	DECLARE v_vacuna_id INT DEFAULT NULL;
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN 
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    
    
    SELECT ganado_id INTO v_ganado_id
    FROM ganado
    WHERE codigo_arete = p_codigo_arete;
    
    SELECT vacuna_id INTO v_vacuna_id
    FROM vacunas
    WHERE nombre = p_nombre;
    
    IF v_ganado_id IS NULL THEN
    
    SET p_mensaje = 'Error: El codigo de arete no existe.';
    ROLLBACK;
    
    ELSEIF v_vacuna_id IS NULL THEN
        SET p_mensaje = 'Error: La vacuna inggresada no existe.';
        ROLLBACK;
    ELSE
    
    INSERT INTO vacunacion (ganado_id, vacuna_id, veterinario_id, fecha, observaciones)
    VALUES (v_ganado_id, v_vacuna_id, p_veterinario_id, CURDATE(), p_observaciones);
    
    SET p_mensaje = 'Vacunacion registrada con exito';
    COMMIT;
    
    END IF;
    		
    	
	
END //


DELIMITER ;


-- 5. Reporte de gasto alimenticio
     		

CREATE PROCEDURE sp_ReporteGastoAlimento (
IN p_ganado_id  INT,
IN p_fecha_inicio DATE,
IN p_fecha_final DATE,
OUT p_mensaje VARCHAR(100),
OUT p_total_gastado DECIMAL(10,2)
)

BEGIN
	
	DECLARE v_existe_ganado INT DEFAULT 0;
    DECLARE v_existe_finca INT DEFAULT 0;
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION; 
    
    SELECT SUM(al.cantidad_kg * a.costo)
    INTO p_total_gastado
    FROM alimentos a
    JOIN alimentacion al ON a.alimento_id = al.alimento_id
    WHERE ganado_id = p_ganado_id AND al.fecha BETWEEN p_fecha_inicio AND p_fecha_final;
    
    	SET p_mensaje = 'Reporte generado ocn exito';
    COMMIT;
    
    END IF;
	
END //

DELIMITER ;
	