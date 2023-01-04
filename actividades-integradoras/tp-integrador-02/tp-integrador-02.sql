-- 1) �Cu�l es la cantidad de pacientes que no se atendieron en el a�o 2015? 
SELECT COUNT(DISTINCT T.IDPACIENTE) FROM TURNOS T
WHERE YEAR(T.FECHAHORA) <> 2015

---- 2) �Cu�l es el costo de la consulta promedio de cualquier especialista en "Oftalmolog�a"?
SELECT AVG(M.COSTO_CONSULTA) FROM MEDICOS M 
INNER JOIN ESPECIALIDADES E ON M.IDESPECIALIDAD = E.IDESPECIALIDAD
WHERE E.NOMBRE LIKE 'OFTALMOLOG�A'

-- 3) �Cu�les son el/los paciente/s que se atendieron m�s veces? (indistintamente del sexo del paciente)
SELECT P.IDPACIENTE, P.APELLIDO, P.NOMBRE, COUNT(*) AS CANTIDAD FROM PACIENTES P
INNER JOIN TURNOS T ON T.IDPACIENTE = P.IDPACIENTE
GROUP BY P.IDPACIENTE, P.APELLIDO, P.NOMBRE
ORDER BY COUNT(*) DESC

-- 4) �Cu�l es el apellido del m�dico (sexo masculino) con m�s antig�edad de la cl�nica?
SELECT M.APELLIDO, M.FECHAINGRESO FROM MEDICOS M
WHERE M.SEXO LIKE 'M'
ORDER BY M.FECHAINGRESO ASC

-- 5) �Cu�ntos m�dicos tienen la especialidad "Gastroenterolog�a" � "Pediatr�a"?
SELECT COUNT(*) FROM MEDICOS M 
INNER JOIN ESPECIALIDADES E ON E.IDESPECIALIDAD = M.IDESPECIALIDAD
WHERE E.NOMBRE LIKE 'Gastroenterolog�a' OR E.NOMBRE LIKE 'Pediatr�a'

--6) �Qu� Obras Sociales cubren a pacientes que se hayan atendido en alg�n turno con alg�n m�dico de especialidad 'Odontolog�a'?
SELECT OBS.NOMBRE FROM OBRAS_SOCIALES OBS
INNER JOIN PACIENTES P ON P.IDOBRASOCIAL = OBS.IDOBRASOCIAL
INNER JOIN TURNOS T ON T.IDPACIENTE = P.IDPACIENTE
INNER JOIN MEDICOS M ON M.IDMEDICO = T.IDMEDICO
INNER JOIN ESPECIALIDADES E ON E.IDESPECIALIDAD = M.IDESPECIALIDAD
WHERE E.NOMBRE LIKE 'Odontolog�a'

-- 7) �Cu�ntos pacientes distintos se atendieron en turnos que duraron m�s que la duraci�n promedio?
-- Ejemplo hipot�tico: Si la duraci�n promedio de los turnos fuese 50 minutos. �Cu�ntos pacientes distintos se atendieron en turnos que duraron m�s que 50 minutos?

SELECT COUNT(DISTINCT T.IDPACIENTE) FROM TURNOS T WHERE T.DURACION > (
	SELECT AVG(T.DURACION) FROM TURNOS T
) 

-- 8) �Cu�ntos turnos fueron atendidos por la doctora Flavia Rice?
SELECT COUNT(*) FROM TURNOS T 
INNER JOIN MEDICOS M ON T.IDMEDICO = M.IDMEDICO
WHERE M.NOMBRE LIKE 'FLAVIA' AND M.APELLIDO LIKE 'RICE'

-- 9) �Cu�ntas m�dicas cobran sus honorarios de consulta un costo mayor a $1000?
SELECT COUNT(*) FROM MEDICOS M 
WHERE M.SEXO LIKE 'F' AND M.COSTO_CONSULTA > 1000

-- 10) �Cu�nto tuvo que pagar la consulta el paciente con el turno nro 146?
-- Teniendo en cuenta que el paciente debe pagar el costo de la consulta del m�dico menos lo que cubre la cobertura de la obra social. La cobertura de la obra social est� expresado en un valor decimal entre 0 y 1. Siendo 0 el 0% de cobertura y 1 el 100% de la cobertura.
-- Si la cobertura de la obra social es 0.2, entonces el paciente debe pagar el 80% de la consulta.
SELECT M.COSTO_CONSULTA - (M.COSTO_CONSULTA * OBS.COBERTURA) FROM TURNOS T 
INNER JOIN PACIENTES P ON P.IDPACIENTE = T.IDPACIENTE
INNER JOIN OBRAS_SOCIALES OBS ON OBS.IDOBRASOCIAL = P.IDOBRASOCIAL
INNER JOIN MEDICOS M ON M.IDMEDICO = T.IDMEDICO
WHERE T.IDTURNO = 146