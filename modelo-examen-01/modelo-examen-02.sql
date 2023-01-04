--1 Hacer un trigger que al registrar una captura se verifique que la cantidad de capturas que haya realizado el competidor no supere las reglamentadas por el torneo. Tampoco debe permitirse registrar más capturas si el competidor ya ha devuelto veinte peces o más en el torneo. Indicar cada situación con un mensaje de error aclaratorio. Caso contrario, registrar la captura.
CREATE TRIGGER tr_VerificarCapturas ON CAPTURAS
AFTER INSERT
AS
BEGIN
	DECLARE @ID_COMP BIGINT, @ID_TORNEO BIGINT
	DECLARE @CANTIDAD SMALLINT, @CANTIDAD_DEV SMALLINT

	SELECT @ID_COMP = i.IDCompetidor, @ID_TORNEO = i.IDTorneo FROM inserted i
	SELECT @CANTIDAD = IsNull(SUM(C.ID), 0), @CANTIDAD_DEV = IsNull(SUM(C.Devuelta), 0)
	FROM Capturas C WHERE C.IDCompetidor = @ID_COMP AND C.IDTorneo = @ID_TORNEO

	IF @CANTIDAD > (SELECT T.CapturasPorCompetidor FROM Torneos T WHERE T.ID = @ID_TORNEO)
	BEGIN
		ROLLBACK TRANSACTION
		RAISERROR('Supera cantidad permitida por torneo', 16, 1)
	END

	IF @CANTIDAD_DEV >= 20 
	BEGIN
		ROLLBACK TRANSACTION
		RAISERROR('Supera cantidades ya devueltas', 16, 1)
	END
END
GO

--2 Hacer un trigger que no permita que al cargar un torneo se otorguen más de un millón de pesos en premios entre todos los torneos de ese mismo año. En caso de ocurrir indicar el error con un mensaje aclaratorio. Caso contrario, registrar el torneo.
CREATE TRIGGER tr_AgregarTorneo ON TORNEOS
AFTER INSERT 
AS
BEGIN
	DECLARE @SUMA_T MONEY
	SELECT @SUMA_T = SUM(T.Premio) FROM Torneos T WHERE T.Año = (SELECT i.Año FROM inserted i)
	IF @SUMA_T > 1000000 
	BEGIN
		ROLLBACK TRANSACTION
		RAISERROR ('El premio supera el millon entre los torneos del mismo año',16,1)
	END
END
GO
--3 Hacer un trigger que al eliminar una captura sea marcada como devuelta y que al eliminar una captura que ya se encuentra como devuelta se realice la baja física del registro.
CREATE TRIGGER tr_EliminarCaptura ON CAPTURAS
INSTEAD OF DELETE
AS
BEGIN
	DECLARE @VER_CAPTURA BIT
	SELECT @VER_CAPTURA = C.Devuelta FROM Capturas C WHERE C.ID = (SELECT d.ID FROM deleted d)
	IF @VER_CAPTURA = 0 
		BEGIN
			DELETE FROM Capturas WHERE ID = (SELECT d.ID FROM deleted d)
		END
	ELSE 
		BEGIN
			UPDATE CAPTURAS SET Devuelta = 1 WHERE ID = (SELECT d.ID FROM deleted d)
		END
END
GO

--4 Hacer un procedimiento almacenado que a partir de un IDTorneo indique los datos del ganador del mismo. El ganador es aquel pescador que haya sumado la mayor cantidad de puntos en el torneo. Se suman 3 puntos por cada pez capturado y se resta un punto por cada pez devuelto. Indicar Nombre, Apellido y Puntos.
-- NOTA: El primer puesto puede ser un empate entre varios competidores, en ese caso mostrar la información de todos los ganadores.
CREATE PROCEDURE sp_GanadorTorneo(
	@ID BIGINT
)
AS
BEGIN
	SELECT * FROM (
		SELECT C.Apellido, C.Nombre, (
			SELECT COUNT(CAP.ID) FROM Competidores C
			INNER JOIN Capturas CAP ON CAP.IDCompetidor = C.ID
			WHERE CAP.Devuelta = 0 AND CAP.IDTorneo = @ID
		)AS 'Capturados',
		(
			SELECT COUNT(CAP.ID)FROM Competidores C
			INNER JOIN Capturas CAP ON CAP.IDCompetidor = C.ID
			WHERE CAP.Devuelta = 1 AND CAP.IDTorneo = @ID
		)AS 'Devueltos'
		FROM Competidores C
		GROUP BY C.ID, C.Apellido, C.Nombre
	)AS TABLA 
END
