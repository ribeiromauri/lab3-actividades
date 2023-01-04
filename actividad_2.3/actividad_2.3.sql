--1 La cantidad de colaboradores que nacieron luego del año 1995.
SELECT COUNT(*) FROM Colaboradores WHERE YEAR(FechaNacimiento) > 1995

--2 El costo total de todos los pedidos que figuren como Pagado.
SELECT SUM(P.Costo) FROM Pedidos P WHERE P.Pagado = 1

--3 La cantidad total de unidades pedidas del producto con ID igual a 30.
SELECT COUNT(P.ID) FROM Pedidos P WHERE P.IDProducto = 30

--4 La cantidad de clientes distintos que hicieron pedidos en el año 2020.
SELECT COUNT(DISTINCT P.IDCliente) FROM CLIENTES C
INNER JOIN PEDIDOS P ON P.IDCliente = C.ID
WHERE YEAR(P.FechaSolicitud) = 2020

--5 Por cada material, la cantidad de productos que lo utilizan.
SELECT M.Nombre, M.ID, COUNT(P.ID) FROM MATERIALES M
INNER JOIN Materiales_x_Producto MXP ON MXP.IDMaterial = M.ID
INNER JOIN Productos P ON MXP.IDProducto = P.ID
GROUP BY M.ID, M.Nombre

--6 Para cada producto, listar el nombre y la cantidad de pedidos pagados.
SELECT PR.ID, PR.Descripcion, COUNT(PR.ID) FROM Productos PR
INNER JOIN Pedidos P ON P.IDProducto = PR.ID
WHERE P.Pagado = 1
GROUP BY PR.ID, PR.Descripcion

--7 Por cada cliente, listar apellidos y nombres de los clientes y la cantidad de productos distintos que haya pedido.
SELECT C.ID, C.Apellidos, C.Nombres, COUNT(DISTINCT PR.ID) FROM Clientes C
INNER JOIN Pedidos P ON C.ID = P.IDCliente
INNER JOIN Productos PR ON P.IDProducto = PR.ID
GROUP BY C.ID, C.Apellidos, C.Nombres

--8 Por cada colaborador y tarea que haya realizado, listar apellidos y nombres, nombre de la tarea y la cantidad de veces que haya realizado esa tarea.
SELECT C.Apellidos, C.Nombres, T.Nombre, COUNT(T.ID) FROM Colaboradores C
INNER JOIN Tareas_x_Pedido TXP ON TXP.Legajo = C.Legajo
INNER JOIN Tareas T ON TXP.IDTarea = T.ID
GROUP BY C.Apellidos, C.Nombres, T.Nombre

--9 Por cada cliente, listar los apellidos y nombres y el importe individual más caro que hayan abonado en concepto de pago.
SELECT C.ID, C.Apellidos, C.Nombres, MAX(P.Costo) FROM Clientes C
INNER JOIN Pedidos P ON P.IDCliente = C.ID
WHERE P.Pagado = 1
GROUP BY C.ID, C.Apellidos, C.Nombres

--10 Por cada colaborador, apellidos y nombres y la menor cantidad de unidades solicitadas en un pedido individual en el que haya trabajado.
SELECT COL.Legajo, COL.Apellidos, COL.Nombres, MIN(PE.Cantidad) FROM Colaboradores COL
INNER JOIN Tareas_x_Pedido TXP ON TXP.Legajo = COL.Legajo
INNER JOIN Pedidos PE ON TXP.IDPedido = PE.ID
GROUP BY COL.Legajo, COL.Apellidos, COL.Nombres
ORDER BY COL.Legajo ASC

--11 Listar apellidos y nombres de aquellos clientes que no hayan realizado ningún pedido. Es decir, que contabilicen 0 pedidos.
SELECT C.ID, C.Apellidos, C.Nombres, COUNT(PE.ID) FROM Clientes C 
LEFT JOIN Pedidos PE ON C.ID = PE.IDCliente
GROUP BY C.ID, C.Apellidos, C.Nombres
HAVING COUNT(PE.ID) = 0

--12 Obtener un listado de productos indicando descripción y precio de aquellos productos que hayan registrado más de 15 pedidos.
SELECT PR.ID, PR.Descripcion, PR.Precio, COUNT(PE.ID) FROM Productos PR 
INNER JOIN Pedidos PE ON PE.IDProducto = PR.ID
GROUP BY PR.ID, PR.Descripcion, PR.Precio
HAVING COUNT(PE.ID) > 15

--13 Obtener un listado de productos indicando descripción y nombre de categoría de los productos que tienen un precio promedio de pedidos mayor a $25000.
SELECT C.Nombre, PR.Descripcion, AVG(PE.Costo) FROM Categorias C
INNER JOIN Productos PR ON PR.IDCategoria = C.ID
INNER JOIN Pedidos PE ON PE.IDProducto = PR.ID
GROUP BY C.Nombre, PR.Descripcion
HAVING AVG(PE.COSTO) > 25000

--14 Apellidos y nombres de los clientes que hayan registrado más de 15 pedidos que superen los $15000.
SELECT C.ID, C.Apellidos, C.Nombres, COUNT(PE.ID) FROM CLIENTES C
INNER JOIN Pedidos PE ON PE.IDCliente = C.ID
WHERE PE.Costo > 15000
GROUP BY C.ID, C.Apellidos, C.Nombres
HAVING COUNT(PE.ID) > 15

--15 Para cada producto, listar el nombre, el texto 'Pagados'  y la cantidad de pedidos pagados. Anexar otro listado con nombre, el texto 'No pagados' y cantidad de pedidos no pagados.
SELECT PR.Descripcion, CONCAT('Pagados: ',COUNT(PR.ID)) FROM Productos PR 
INNER JOIN Pedidos P ON P.IDProducto = PR.ID
WHERE P.Pagado = 1
GROUP BY PR.Descripcion
UNION 
SELECT PR.Descripcion, CONCAT('No pagados: ',COUNT(PR.ID)) FROM Productos PR 
INNER JOIN Pedidos P ON P.IDProducto = PR.ID
WHERE P.Pagado = 0
GROUP BY PR.Descripcion

