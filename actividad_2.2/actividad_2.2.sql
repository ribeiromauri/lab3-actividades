--1 Por cada producto listar la descripción del producto, el precio y el nombre de la categoría a la que pertenece.
SELECT P.Descripcion, P.Precio, C.Nombre FROM Productos P
INNER JOIN Categorias C ON P.IDCategoria = C.ID

--2 Listar las categorías de producto de las cuales no se registren productos.
SELECT C.Nombre FROM Categorias C LEFT JOIN Productos P ON P.IDCategoria = C.ID WHERE P.IDCategoria IS NULL 

--3 Listar el nombre de la categoría de producto de aquel o aquellos productos que más tiempo lleven en construir.
SELECT TOP 1 WITH TIES C.Nombre FROM Categorias C INNER JOIN Productos P ON P.IDCategoria = C.ID ORDER BY P.DiasConstruccion DESC

--4 Listar apellidos y nombres y dirección de mail de aquellos clientes que no hayan registrado pedidos.
SELECT C.Apellidos, C.Nombres, C.Mail FROM Clientes C LEFT JOIN PEDIDOS P ON P.IDCliente = C.ID WHERE P.IDCliente IS NULL

--5 Listar apellidos y nombres, mail, teléfono y celular de aquellos clientes que hayan realizado algún pedido cuyo costo supere $1000000
SELECT C.Apellidos, C.Nombres, C.Mail, C.Telefono, C.Celular FROM Clientes C 
INNER JOIN PEDIDOS P ON P.IDCliente = C.ID 
WHERE P.COSTO > 1000000

--6 Listar IDPedido, Costo, Fecha de solicitud y fecha de finalización, descripción del producto, costo y apellido y nombre del cliente. Sólo listar aquellos registros de pedidos que hayan sido pagados.
SELECT P.ID, P.Costo, P.FechaSolicitud, P.FechaFinalizacion, PR.Descripcion, PR.Costo, C.Apellidos, C.Nombres FROM Pedidos P 
INNER JOIN Productos PR ON P.IDProducto = PR.ID
INNER JOIN Clientes C ON P.IDCliente = C.ID
WHERE P.Pagado = 1

--7 Listar IDPedido, Fecha de solicitud, fecha de finalización, días de construcción del producto, días de construcción del pedido (fecha de finalización - fecha de solicitud) y una columna llamada Tiempo de construcción con la siguiente información:
--'Con anterioridad' → Cuando la cantidad de días de construcción del pedido sea menor a los días de construcción del producto.
--'Exacto'' → Si la cantidad de días de construcción del pedido y el producto son iguales
--'Con demora' → Cuando la cantidad de días de construcción del pedido sea mayor a los días de construcción del producto.

SELECT P.ID, P.FechaSolicitud, P.FechaFinalizacion, A.DiasConstruccion, DATEDIFF(DAY, P.FechaSolicitud, P.FechaFinalizacion) AS DiasConstruccionPedidos,
	CASE 
		WHEN DATEDIFF(DAY, P.FechaSolicitud, P.FechaFinalizacion) < A.DiasConstruccion THEN 'Con anterioridad'
		WHEN DATEDIFF(DAY, P.FechaSolicitud, P.FechaFinalizacion) > A.DiasConstruccion THEN 'Con Demora'
		WHEN DATEDIFF(DAY, P.FechaSolicitud, P.FechaFinalizacion) = A.DiasConstruccion THEN 'Exacto'
	END AS TiempoConstruccion
FROM Pedidos P INNER JOIN Productos A ON P.IDProducto = A.ID

--8. Listar por cada cliente el apellido y nombres y los nombres de las categorías de aquellos productos de los cuales hayan realizado pedidos. No deben figurar registros duplicados.
SELECT DISTINCT C.Apellidos, C.Nombres, CAT.Nombre FROM Clientes C
INNER JOIN Pedidos PE ON PE.IDCliente = C.ID
INNER JOIN Productos PR ON PR.ID = PE.IDProducto
INNER JOIN Categorias CAT ON CAT.ID = PR.IDCategoria

--9. Listar apellidos y nombres de aquellos clientes que hayan realizado algún pedido cuya cantidad sea exactamente igual a la cantidad considerada mayorista del producto.
SELECT C.Apellidos, C.Nombres FROM CLIENTES C 
INNER JOIN Pedidos PE ON PE.IDCliente = C.ID
INNER JOIN Productos PR ON PE.IDProducto = PR.ID
WHERE PE.Cantidad = PR.CantidadMayorista

--10. Listar por cada producto el nombre del producto, el nombre de la categoría, el precio de venta minorista, el precio de venta mayorista y el porcentaje de ahorro que se obtiene por la compra mayorista a valor mayorista en relación al valor minorista.
SELECT PR.Descripcion, PR.Precio, PR.PrecioVentaMayorista, ((PR.Precio - PR.PrecioVentaMayorista)*100)/PR.PrecioVentaMayorista AS Ahorro FROM Productos PR 
INNER JOIN Categorias C ON C.ID = PR.IDCategoria 