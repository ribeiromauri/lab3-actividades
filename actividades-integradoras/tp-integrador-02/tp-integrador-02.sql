-- 1) ¿Cuál es la cantidad de pacientes que no se atendieron en el año 2015? 
SELECT COUNT(DISTINCT T.IDPACIENTE) FROM TURNOS T
WHERE YEAR(T.FECHAHORA) <> 2015

---- 2) ¿Cuál es el costo de la consulta promedio de cualquier especialista en "Oftalmología"?
SELECT AVG(M.COSTO_CONSULTA) FROM MEDICOS M 
INNER JOIN ESPECIALIDADES E ON M.IDESPECIALIDAD = E.IDESPECIALIDAD
WHERE E.NOMBRE LIKE 'OFTALMOLOGÍA'

-- 3) ¿Cuáles son el/los paciente/s que se atendieron más veces? (indistintamente del sexo del paciente)
SELECT P.IDPACIENTE, P.APELLIDO, P.NOMBRE, COUNT(*) AS CANTIDAD FROM PACIENTES P
INNER JOIN TURNOS T ON T.IDPACIENTE = P.IDPACIENTE
GROUP BY P.IDPACIENTE, P.APELLIDO, P.NOMBRE
ORDER BY COUNT(*) DESC

-- 4) ¿Cuál es el apellido del médico (sexo masculino) con más antigüedad de la clínica?
SELECT M.APELLIDO, M.FECHAINGRESO FROM MEDICOS M
WHERE M.SEXO LIKE 'M'
ORDER BY M.FECHAINGRESO ASC

-- 5) ¿Cuántos médicos tienen la especialidad "Gastroenterología" ó "Pediatría"?
SELECT COUNT(*) FROM MEDICOS M 
INNER JOIN ESPECIALIDADES E ON E.IDESPECIALIDAD = M.IDESPECIALIDAD
WHERE E.NOMBRE LIKE 'Gastroenterología' OR E.NOMBRE LIKE 'Pediatría'

--6) ¿Qué Obras Sociales cubren a pacientes que se hayan atendido en algún turno con algún médico de especialidad 'Odontología'?
SELECT OBS.NOMBRE FROM OBRAS_SOCIALES OBS
INNER JOIN PACIENTES P ON P.IDOBRASOCIAL = OBS.IDOBRASOCIAL
INNER JOIN TURNOS T ON T.IDPACIENTE = P.IDPACIENTE
INNER JOIN MEDICOS M ON M.IDMEDICO = T.IDMEDICO
INNER JOIN ESPECIALIDADES E ON E.IDESPECIALIDAD = M.IDESPECIALIDAD
WHERE E.NOMBRE LIKE 'Odontología'

-- 7) ¿Cuántos pacientes distintos se atendieron en turnos que duraron más que la duración promedio?
-- Ejemplo hipotético: Si la duración promedio de los turnos fuese 50 minutos. ¿Cuántos pacientes distintos se atendieron en turnos que duraron más que 50 minutos?

SELECT COUNT(DISTINCT T.IDPACIENTE) FROM TURNOS T WHERE T.DURACION > (
	SELECT AVG(T.DURACION) FROM TURNOS T
) 

-- 8) ¿Cuántos turnos fueron atendidos por la doctora Flavia Rice?
SELECT COUNT(*) FROM TURNOS T 
INNER JOIN MEDICOS M ON T.IDMEDICO = M.IDMEDICO
WHERE M.NOMBRE LIKE 'FLAVIA' AND M.APELLIDO LIKE 'RICE'

-- 9) ¿Cuántas médicas cobran sus honorarios de consulta un costo mayor a $1000?
SELECT COUNT(*) FROM MEDICOS M 
WHERE M.SEXO LIKE 'F' AND M.COSTO_CONSULTA > 1000

-- 10) ¿Cuánto tuvo que pagar la consulta el paciente con el turno nro 146?
-- Teniendo en cuenta que el paciente debe pagar el costo de la consulta del médico menos lo que cubre la cobertura de la obra social. La cobertura de la obra social está expresado en un valor decimal entre 0 y 1. Siendo 0 el 0% de cobertura y 1 el 100% de la cobertura.
-- Si la cobertura de la obra social es 0.2, entonces el paciente debe pagar el 80% de la consulta.
SELECT M.COSTO_CONSULTA - (M.COSTO_CONSULTA * OBS.COBERTURA) FROM TURNOS T 
INNER JOIN PACIENTES P ON P.IDPACIENTE = T.IDPACIENTE
INNER JOIN OBRAS_SOCIALES OBS ON OBS.IDOBRASOCIAL = P.IDOBRASOCIAL
INNER JOIN MEDICOS M ON M.IDMEDICO = T.IDMEDICO
WHERE T.IDTURNO = 146