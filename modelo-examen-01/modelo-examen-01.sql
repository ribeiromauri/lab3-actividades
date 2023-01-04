--Hacer un trigger que al cargar un cr�dito verifique que el importe del mismo sumado a los importes de los cr�ditos que actualmente solicit� esa persona no supere al triple de la declaraci�n de ganancias. S�lo deben tenerse en cuenta en la sumatoria los cr�ditos que no se encuentren cancelados. De no poder otorgar el cr�dito aclararlo con un mensaje.

CREATE TRIGGER tr_VerificarImporte ON CREDITOS
AFTER INSERT 
AS
BEGIN
	DECLARE @DNI VARCHAR(10)
	DECLARE @DEC_GANANCIAS MONEY, @SUMA_TOTAL MONEY
	
	SELECT @DNI = DNI FROM inserted
	SELECT @SUMA_TOTAL = IsNull(SUM(C.Importe), 0) FROM Creditos C WHERE C.DNI = @DNI AND C.Cancelado = 0 
	SELECT @DEC_GANANCIAS = DeclaracionGanancias FROM Personas WHERE DNI = @DNI

	IF @SUMA_TOTAL >= @DEC_GANANCIAS * 3 
	BEGIN 
		ROLLBACK TRANSACTION
		RAISERROR('No se pudo otorgar el credito', 16, 1)
	END
END
GO

--Hacer un trigger que al eliminar un cr�dito realice la cancelaci�n del mismo.
CREATE TRIGGER tr_EliminarCredito ON CREDITOS
INSTEAD OF DELETE
AS
BEGIN
	UPDATE CREDITOS SET Cancelado = 1 WHERE ID = (SELECT ID FROM deleted)
END
GO

--Hacer un trigger que no permita otorgar cr�ditos con un plazo de 20 o m�s a�os a personas cuya declaraci�n de ganancias sea menor al promedio de declaraci�n de ganancias.
CREATE TRIGGER tr_ValidarPromedioGanancias ON CREDITOS
AFTER INSERT
AS
BEGIN
	DECLARE @DNI VARCHAR(10)
	DECLARE @DEC_GANANCIAS MONEY, @AVG_GANANCIAS MONEY
	DECLARE @PLAZO SMALLINT

	SELECT @DNI = i.DNI, @PLAZO = i.Plazo FROM inserted i
	SELECT @DEC_GANANCIAS = P.DeclaracionGanancias FROM Personas P WHERE P.DNI = @DNI
	SELECT @AVG_GANANCIAS = AVG(DeclaracionGanancias) FROM Personas

	IF @PLAZO >= 10 AND @DEC_GANANCIAS < @AVG_GANANCIAS
	BEGIN
		ROLLBACK TRANSACTION
		RAISERROR('No se pudo otorgar el credito',16,1)
	END
END
GO
--Hacer un procedimiento almacenado que reciba dos fechas y liste todos los cr�ditos otorgados entre esas fechas. Debe listar el apellido y nombre del solicitante, el nombre del banco, el tipo de banco, la fecha del cr�dito y el importe solicitado.
CREATE PROCEDURE sp_ListarCreditoPorFechas(
	@F_INICIO DATE,
	@F_FIN DATE
)AS
BEGIN
	SELECT P.Apellidos, P.Nombres, B.Nombre, B.Tipo, C.Fecha, C.Importe FROM Creditos C 
	INNER JOIN Personas P ON C.DNI = P.DNI
	INNER JOIN Bancos B ON C.IDBanco = B.ID
	WHERE C.Fecha BETWEEN @F_INICIO AND @F_FIN
END