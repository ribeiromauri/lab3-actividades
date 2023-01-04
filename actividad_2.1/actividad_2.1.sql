--Apellido, nombres y fecha de ingreso de todos los colaboradores
SELECT Apellidos, Nombres, A�oIngreso FROM Colaboradores

--Apellido, nombres y antig�edad de todos los colaboradores
SELECT Apellidos, Nombres, DATEDIFF(Y, A�oIngreso, YEAR(GETDATE())) AS Antiguedad FROM Colaboradores

--Apellido y nombres de aquellos colaboradores que trabajen part-time.
SELECT Apellidos, Nombres, ModalidadTrabajo FROM Colaboradores WHERE ModalidadTrabajo LIKE 'P'

--Apellido y nombres, antig�edad y modalidad de trabajo de aquellos colaboradores cuyo sueldo sea entre 50000 y 100000.
SELECT Apellidos, Nombres, DATEDIFF(Y, A�oIngreso, YEAR(GETDATE())) AS Antiguedad, ModalidadTrabajo FROM Colaboradores WHERE Sueldo BETWEEN 50000 AND 100000

--Apellidos y nombres y edad de los colaboradores con legajos 4, 6, 12 y 25.
SELECT Legajo, Apellidos, Nombres, DATEDIFF(YEAR, FechaNacimiento, GETDATE()) AS Edad FROM Colaboradores WHERE Legajo IN (4, 6, 12, 25)

--Todos los datos de todos los productos ordenados por precio de venta. Del m�s caro al m�s barato
SELECT * FROM Productos ORDER BY Precio DESC

--El nombre del producto m�s costoso.
SELECT TOP 1 Descripcion FROM Productos ORDER BY Precio DESC

--Todos los datos de todos los pedidos que hayan superado el monto de $20000.
SELECT * FROM Pedidos WHERE Costo > 20000

--Apellido y nombres de los clientes que no hayan registrado tel�fono.
SELECT Apellidos, Nombres FROM Clientes WHERE Telefono IS NULL 

--Apellido y nombres de los clientes que hayan registrado mail pero no tel�fono.
SELECT Apellidos, Nombres FROM Clientes WHERE Mail IS NOT NULL AND Telefono IS NULL

--Apellidos, nombres y datos de contacto de todos los clientes.
SELECT 
	Apellidos,
	Nombres,
	COALESCE(Celular, Telefono, Mail, 'Incontactable') AS Contacto
FROM Clientes 

--Apellidos, nombres y medio de contacto de todos los clientes. Si tiene celular debe figurar 'Celular'. Si no tiene celular pero tiene tel�fono fijo debe figurar 'Tel�fono fijo' de lo contrario debe figurar 'Email'. Si no posee ninguno de los tres debe figurar NULL.
SELECT Apellidos, Nombres,
	CASE
	WHEN Celular IS NOT NULL THEN 'Celular'
	WHEN Telefono IS NOT NULL THEN 'Telefono'
	WHEN Mail IS NOT NULL THEN 'Email'
	ELSE 'NULL'
	END AS 'MedioContacto'
FROM Clientes 

--Todos los datos de los colaboradores que hayan nacido luego del a�o 2000
SELECT * FROM Colaboradores WHERE YEAR(FechaNacimiento) > 2000

--Todos los datos de los colaboradores que hayan nacido entre los meses de Enero y Julio (inclusive)
SELECT * FROM Colaboradores WHERE MONTH(FechaNacimiento) IN (1, 2, 3, 4, 5, 6, 7)

--Todos los datos de los clientes cuyo apellido finalice con vocal
SELECT * FROM Clientes WHERE Apellidos LIKE '%[AEIOU]'

--Todos los datos de los clientes cuyo nombre comience con 'A' y contenga al menos otra 'A'. Por ejemplo, Ana, Anatasia, Aaron, etc
SELECT * FROM Clientes WHERE Nombres LIKE 'a%' AND Nombres LIKE '%a%' --VER

--Todos los colaboradores que tengan m�s de 10 a�os de antig�edad
SELECT * FROM Colaboradores WHERE DATEDIFF(Y, A�oIngreso, YEAR(GETDATE())) > 10

--Los c�digos de producto, sin repetir, que hayan registrado al menos un pedido
SELECT DISTINCT IDProducto FROM Pedidos 

--Todos los datos de todos los productos con su precio aumentado en un 20%
SELECT *, Precio+(Precio*20)/100 AS PrecioAumentado FROM Productos -- VER MISMA 

--Todos los datos de todos los colaboradores ordenados por apellido ascendentemente en primera instancia y por nombre descendentemente en segunda instancia.
SELECT * FROM Colaboradores ORDER BY Apellidos, Nombres DESC 