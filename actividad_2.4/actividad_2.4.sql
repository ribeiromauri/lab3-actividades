--1. Los pedidos que hayan sido finalizados en menor cantidad de días que la demora promedio
SELECT * FROM Pedidos WHERE DATEDIFF(DAY, FechaSolicitud, FechaFinalizacion) < (
	SELECT AVG(DATEDIFF(DAY, FechaSolicitud, FechaFinalizacion)) FROM Pedidos
)

--2. Los productos cuyo costo sea mayor que el costo del producto de Roble más caro.
SELECT * FROM Productos PE WHERE PE.Costo > (
	SELECT MAX(PR.Costo) FROM Productos PR
	INNER JOIN Materiales_x_Producto MXP ON PR.ID = MXP.IDProducto
	INNER JOIN Materiales M ON MXP.IDMaterial = M.ID
	WHERE M.Nombre LIKE 'Roble'
)

--3. Los clientes que no hayan solicitado ningún producto de material Pino en el año 2022.
SELECT * FROM Clientes C WHERE C.ID NOT IN (
	SELECT PE.IDCliente FROM Pedidos PE
	INNER JOIN Productos PR ON PE.IDProducto = PR.ID
	INNER JOIN Materiales_x_Producto MXP ON MXP.IDProducto = PR.ID
	INNER JOIN Materiales M ON M.ID = MXP.IDMaterial
	WHERE M.Nombre LIKE 'Pino' AND YEAR(PE.FechaSolicitud) = 2022 AND PE.IDCliente IS NOT NULL
)

--4. Los colaboradores que no hayan realizado ninguna tarea de Lijado en pedidos que se solicitaron en el año 2021.
SELECT * FROM Colaboradores C WHERE C.Legajo NOT IN (
	SELECT TXP.Legajo FROM Tareas_x_Pedido TXP
	INNER JOIN Tareas T ON TXP.IDTarea = T.ID
	INNER JOIN Pedidos P ON TXP.IDPedido = P.ID
	WHERE YEAR(P.FechaSolicitud) = 2021 AND T.Nombre LIKE 'Lijado'
)

--5. Los clientes a los que les hayan enviado (no necesariamente entregado) al menos un tercio de sus pedidos.
Select * From (
    Select Cli.Apellidos, Cli.Nombres,
    (
        Select count(*) From Pedidos PE Where PE.IDCliente = Cli.ID
    ) as CantPedidos,
    (
        Select count(*) From Pedidos PE 
        Inner Join Envios E ON E.IDPedido = PE.ID
        Where PE.IDCliente = Cli.ID
    ) as CantEnviados
    From Clientes Cli
) As Tabla
Where Tabla.CantEnviados >= Tabla.CantPedidos/3.0

--6. Los colaboradores que hayan realizado todas las tareas (no necesariamente en un mismo pedido).
SELECT C.Legajo, C.Apellidos, C.Nombres, COUNT(DISTINCT T.ID) FROM Colaboradores C
INNER JOIN Tareas_x_Pedido TXP ON TXP.Legajo = C.Legajo
INNER JOIN Tareas T ON TXP.IDTarea = T.ID
GROUP BY C.Legajo, C.Apellidos, C.Nombres
HAVING COUNT(DISTINCT T.ID) = (SELECT COUNT(*) FROM Tareas)


--7. Por cada producto, la descripción y la cantidad de colaboradores fulltime que hayan trabajado en él y la cantidad de colaboradores parttime.

SELECT Descripcion, SUM(Colaboradores_FullTime) Colaboradores_FullTime, SUM(Colaboradores_PartTime) Colaboradores_PartTime FROM (
    SELECT PROD.ID, PROD.Descripcion AS Descripcion,
    (        
        SELECT COUNT(DISTINCT T.Legajo ) FROM Tareas_x_Pedido T
        INNER JOIN Pedidos PED ON PED.ID = T.IDPedido
        INNER JOIN Colaboradores COL ON COL.Legajo = T.Legajo
        WHERE PED.IDProducto = PROD.ID AND COL.ModalidadTrabajo = 'F'
    ) AS Colaboradores_FullTime,
    (
        SELECT COUNT(DISTINCT T.Legajo ) FROM Tareas_x_Pedido T
        INNER JOIN Pedidos PED ON PED.ID = T.IDPedido
        INNER JOIN Colaboradores COL ON COL.Legajo = T.Legajo
        WHERE PED.IDProducto = PROD.ID AND COL.ModalidadTrabajo = 'P'
    ) AS Colaboradores_PartTime
    FROM Productos PROD
) AS Productos
GROUP BY ID, Descripcion

--8. Por cada producto, la descripción y la cantidad de pedidos enviados y la cantidad de pedidos sin envío.
SELECT Descripcion, Cant_Pedidos_Enviados, (Cant_Pedidos_Totales - Cant_Pedidos_Enviados) AS Cant_Pedidos_Sin_Envio FROM (
    SELECT PROD.Descripcion,
        (
            SELECT COUNT(*) FROM Pedidos PED
            WHERE PED.IDProducto = PROD.ID
        ) AS Cant_Pedidos_Totales,
        (
            SELECT COUNT(*) FROM Pedidos PED
            INNER JOIN Envios ENV ON ENV.IDPedido = PED.ID
            WHERE PED.IDProducto = PROD.ID
        ) AS Cant_Pedidos_Enviados
    FROM Productos PROD
) AS Productos

--9. Por cada cliente, apellidos y nombres y la cantidad de pedidos solicitados en los años 2020, 2021 y 2022. (Cada año debe mostrarse en una columna separada)
SELECT CL.ID, CL.Apellidos, CL.Nombres,
(
	SELECT COUNT(*) FROM Pedidos P
	WHERE P.IDCliente = CL.ID AND YEAR(P.FechaSolicitud) = 2020
)AS '2020',
(
	SELECT COUNT(*) FROM Pedidos P
	WHERE P.IDCliente = CL.ID AND YEAR(P.FechaSolicitud) = 2021
)AS '2021',
(
	SELECT COUNT(*) FROM Pedidos P
	WHERE P.IDCliente = CL.ID AND YEAR(P.FechaSolicitud) = 2022
)AS '2022'
FROM Clientes CL

--10. Por cada producto, listar la descripción del producto, el costo y los materiales de construcción (en una celda separados por coma)
SELECT PR.Descripcion, PR.Costo,
(
	SELECT STRING_AGG(M.Nombre, ', ') FROM Materiales M 
	INNER JOIN Materiales_x_Producto MXP ON MXP.IDMaterial = M.ID
	WHERE PR.ID = MXP.IDProducto
)AS 'Materiales_Construccion'
FROM Productos PR

--11. Por cada pedido, listar el ID, la fecha de solicitud, el nombre del producto, los apellidos y nombres de los colaboradores que trabajaron en el pedido y la/s tareas que el colaborador haya realizado (en una celda separados por coma)
SELECT P.ID, P.FechaSolicitud, PR.Descripcion, COL.Nombres, COL.Apellidos, STRING_AGG(T.Nombre, ', ') AS Tareas 
FROM Pedidos P 
INNER JOIN Productos PR ON P.IDProducto = PR.ID
INNER JOIN Tareas_x_Pedido TXP ON TXP.IDPedido = P.ID
INNER JOIN Tareas T ON TXP.IDTarea = T.ID
INNER JOIN Colaboradores COL ON COL.Legajo = TXP.Legajo
GROUP BY P.ID, P.FechaSolicitud, PR.Descripcion, COL.Nombres, COL.Apellidos

--12 Las descripciones de los productos que hayan requerido el doble de colaboradores fulltime que colaboradores partime.
SELECT Descripcion FROM(
SELECT PR.ID, PR.Descripcion,
(
	SELECT COUNT(DISTINCT T.Legajo ) FROM Tareas_x_Pedido T
    INNER JOIN Pedidos PED ON PED.ID = T.IDPedido
    INNER JOIN Colaboradores COL ON COL.Legajo = T.Legajo
    WHERE PED.IDProducto = PR.ID AND COL.ModalidadTrabajo = 'F'
)AS Colaboradores_Fulltime,
(
	SELECT COUNT(DISTINCT T.Legajo ) FROM Tareas_x_Pedido T
    INNER JOIN Pedidos PED ON PED.ID = T.IDPedido
    INNER JOIN Colaboradores COL ON COL.Legajo = T.Legajo
    WHERE PED.IDProducto = PR.ID AND COL.ModalidadTrabajo = 'P'
)AS Colaboradores_Parttime
FROM Productos PR
)AS Productos
GROUP BY ID, Descripcion
HAVING SUM(Colaboradores_Fulltime) = SUM(Colaboradores_Parttime)*2

--13. Las descripciones de los productos que tuvieron más pedidos sin envíos que con envíos pero que al menos tuvieron un pedido enviado.
SELECT Descripcion FROM(
	SELECT PR.Descripcion,
	(
		SELECT COUNT(*) FROM Pedidos P
		WHERE P.IDProducto = PR.ID
	)AS Total_Pedidos,
	(
		SELECT COUNT(*) FROM Pedidos P
		INNER JOIN Envios E ON P.ID = E.IDPedido
		WHERE P.IDProducto = PR.ID
	)AS Total_Pedidos_Enviados
FROM Productos PR
)AS Productos
WHERE (Total_Pedidos - Total_Pedidos_Enviados) > Total_Pedidos_Enviados AND Total_Pedidos_Enviados > 0

--14. Los nombre y apellidos de los clientes que hayan realizado pedidos en los años 2020, 2021 y 2022 pero que la cantidad de pedidos haya decrecido en cada año. Añadirle al listado aquellos clientes que hayan realizado exactamente la misma cantidad de pedidos en todos los años y que dicha cantidad no sea cero.

SELECT Apellidos, Nombres FROM(
	SELECT CL.ID, CL.Apellidos, CL.Nombres, 
	(
		SELECT COUNT(*) FROM Pedidos P
		WHERE P.IDCliente = CL.ID AND YEAR(P.FechaSolicitud) = 2020
	)AS Pedidos_2020,
	(
		SELECT COUNT(*) FROM Pedidos P
		WHERE P.IDCliente = CL.ID AND YEAR(P.FechaSolicitud) = 2021
	)AS Pedidos_2021,
	(
		SELECT COUNT(*) FROM Pedidos P
		WHERE P.IDCliente = CL.ID AND YEAR(P.FechaSolicitud) = 2022
	)AS Pedidos_2022
	FROM Clientes CL
)AS Clientes
WHERE (Pedidos_2020 > Pedidos_2021 AND Pedidos_2021 > Pedidos_2022) OR
	  (Pedidos_2020 = Pedidos_2021 AND Pedidos_2021 = Pedidos_2022 AND Pedidos_2022 > 0)

	  