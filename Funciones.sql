-- FUNCIONES

-- 1. Calcular edad en meses

DELIMITER //

CREATE FUNCTION fn_CalcularEdadMeses(
    p_ganado_id INT
)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
	
	DECLARE v_fecha_nacimiento DATE;


	SELECT fecha_nacimiento  
    INTO v_fecha_nacimiento
    FROM ganado g 
    WHERE g.ganado_id = p_ganado_id;
	
	RETURN TIMESTAMPDIFF(MONTH, v_fecha_nacimiento, CURDATE());
	

END //

DELIMITER ;


-- 2. Calcular Total de litros de leche en la finca

DELIMITER //

CREATE FUNCTION fn_TotalLitrosFinca(
    p_finca_id INT,
    p_fecha_inicio DATE,
    p_fecha_final DATE
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
	
	DECLARE v_total_litros DECIMAL(10,2) DEFAULT 0.0;
	
	SELECT SUM(litros) 
    INTO v_total_litros
    FROM produccion_leche pl
    JOIN ganado g ON pl.ganado_id = g.ganado_id
    WHERE g.finca_id = p_finca_id AND pl.fecha BETWEEN p_fecha_inicio AND p_fecha_final ; 
	
	RETURN IFNULL(v_total_litros, 0.00);
	

END //

DELIMITER ;


-- 3. Promedio de peso por raza

DELIMITER //

CREATE FUNCTION fn_PromedioPesoPorRaza(
    p_raza VARCHAR(50)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
	
	DECLARE v_peso_promedio DECIMAL(10,2) DEFAULT 0.00;

		SELECT AVG(peso) 
	    INTO v_peso_promedio
	    FROM ganado g
	    WHERE  g.raza = p_raza;
		
		RETURN IFNULL(v_peso_promedio, 0.00);
END //

DELIMITER ;
	
 		
-- 4. Contador de ganado por socio

DELIMITER //

CREATE FUNCTION fn_ContarGanadoPorSocio(
    p_socio_id INT
)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
	
	DECLARE v_cantidad_total_ganado INT DEFAULT 0;

		SELECT COUNT(*)  
	    INTO v_cantidad_total_ganado
	    FROM ganado g 
	    JOIN fincas f ON g.finca_id = f.finca_id
	    WHERE f.socio_id = p_socio_id;
		
		RETURN IFNULL(v_cantidad_total_ganado, 0);
END //

DELIMITER ;  		
    		
    		
-- 5. Costo total de alimentacion por animal

DELIMITER //

CREATE FUNCTION fn_CostoTotalAlimentacion(
    p_ganado_id INT
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
	
	DECLARE v_costo_alimentos_consumidos DECIMAL(10,2) DEFAULT 0;

		SELECT SUM(a.costo * al.cantidad_kg)  
	    INTO v_costo_alimentos_consumidos
	    FROM alimentos a 
	    JOIN alimentacion al ON al.alimento_id = a.alimento_id
	    WHERE al.ganado_id = p_ganado_id;
		
		RETURN IFNULL(v_costo_alimentos_consumidos, 0.00);
END //

DELIMITER ; 