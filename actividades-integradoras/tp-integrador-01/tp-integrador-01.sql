--Listado con Apellido y nombres de los t�cnicos que, en promedio, hayan demorado m�s de 225 minutos en la prestaci�n de servicios.
SELECT T.Apellido, T.Nombre, AVG(S.Duracion) FROM Tecnicos T 
INNER JOIN Servicios S ON S.IDTecnico = T.ID
GROUP BY T.Apellido, T.Nombre
HAVING AVG(S.DURACION) > 225

--Listado con Descripci�n del tipo de servicio, el texto 'Particular' y la cantidad de clientes de tipo Particular. Luego a�adirle un listado con descripci�n del tipo de servicio, el texto 'Empresa' y la cantidad de clientes de tipo Empresa.
SELECT TP.Descripcion, 'Particular' AS Particulas, COUNT(DISTINCT S.IDCliente) AS Cantidad
FROM TiposServicio TP
INNER JOIN Servicios S ON TP.ID = S.IDTipo
INNER JOIN Clientes CL ON S.IDCliente = CL.ID
WHERE CL.Tipo LIKE 'P'
GROUP BY TP.Descripcion
UNION
SELECT TP.Descripcion, 'Empresa' AS Empresa, COUNT(DISTINCT S.IDCliente) AS Cantidad 
FROM TiposServicio TP
INNER JOIN Servicios S ON S.IDTipo = TP.ID
INNER JOIN Clientes CL ON CL.ID = S.IDCliente
WHERE CL.TIPO LIKE 'E'
GROUP BY TP.Descripcion

--Listado con Apellidos y nombres de los clientes que hayan abonado con las cuatro formas de pago.
SELECT C.Apellido, C.Nombre FROM Clientes C INNER JOIN Servicios S ON S.IDCliente = C.ID
GROUP BY C.ID, C.Apellido, C.Nombre
HAVING COUNT(DISTINCT S.FormaPago) = 4

--La descripci�n del tipo de servicio que en promedio haya brindado mayor cantidad de d�as de garant�a.
SELECT TOP 1 WITH TIES TS.Descripcion FROM Servicios S
INNER JOIN TiposServicio TS ON S.IDTipo = TS.ID
GROUP BY TS.Descripcion
ORDER BY AVG(S.DiasGarantia) ASC