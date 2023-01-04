--A) Realizar un procedimiento almacenado llamado sp_Agregar_Usuario que permita registrar un usuario en el sistema. El procedimiento debe recibir como parámetro DNI, Apellido, Nombre, Fecha de nacimiento y los datos del domicilio del usuario.

CREATE PROCEDURE sp_Agregar_Usuario(
	@DNI INT, 
	@APELLIDO VARCHAR(255),
	@NOMBRE VARCHAR(255),
	@FECHA_NAC DATE,
	@DOMICILIO VARCHAR(255)
)AS
BEGIN
	 BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @EXISTE_USUARIO BIT
			SELECT @EXISTE_USUARIO = COUNT(*) FROM USUARIOS WHERE DNI = @DNI
			IF @EXISTE_USUARIO = 0 
				BEGIN
					INSERT INTO USUARIOS (APELLIDOS, NOMBRES, FNAC, DOMICILIO, DNI, ESTADO)
					VALUES (@APELLIDO, @NOMBRE, @FECHA_NAC, @DOMICILIO, @DNI, 1)
				END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		RAISERROR('No se pudo dar de alta', 16, 1)
	END CATCH
END

/*
B) Realizar un procedimiento almacenado llamado sp_Agregar_Tarjeta que dé de alta una tarjeta. El procedimiento solo debe recibir el DNI del usuario.
Como el sistema sólo permite una tarjeta activa por usuario, el procedimiento debe:
Dar de baja la última tarjeta del usuario (si corresponde).
Dar de alta la nueva tarjeta del usuario
Traspasar el saldo de la vieja tarjeta a la nueva tarjeta (si corresponde)
*/
CREATE PROCEDURE sp_Agregar_Tarjeta (
    @DNI INT
)AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @EXISTE_TARJETA BIT
			DECLARE @ID_USUARIO INT
			SELECT @EXISTE_TARJETA = COUNT(*), @ID_USUARIO = US.IDUSUARIO FROM USUARIOS US
			INNER JOIN TARJETAS T ON US.IDUSUARIO = T.IDUSUARIO
			WHERE US.DNI = @DNI

			DECLARE @ID_TARJETA INT, @SALDO MONEY
			IF @EXISTE_TARJETA = 1 
				BEGIN
					SELECT @ID_TARJETA = T.IDTARJETA, @SALDO = T.SALDO FROM TARJETAS T 
					WHERE T.IDUSUARIO = @DNI

					UPDATE TARJETAS SET ESTADO = 0 WHERE IDUSUARIO = @DNI AND IDTARJETA = @ID_TARJETA

					INSERT INTO TARJETAS(IDUSUARIO, FECHA_ALTA, SALDO, ESTADO)
					VALUES (@ID_USUARIO, GETDATE(), @SALDO, 1)
				END
			ELSE
				BEGIN
					INSERT INTO TARJETAS(IDUSUARIO, FECHA_ALTA, SALDO, ESTADO)
					VALUES(@ID_USUARIO, GETDATE(), 0, 1)
				END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		RAISERROR('No se pudo dar de alta la tarjeta', 16, 1)
	END CATCH
END

/*
Realizar un procedimiento almacenado llamado sp_Agregar_Viaje que registre un viaje a una tarjeta en particular. El procedimiento debe recibir: Número de tarjeta, importe del viaje, nro de interno y nro de línea.
El procedimiento deberá:
Descontar el saldo
Registrar el viaje
Registrar el movimiento de débito

NOTA: Una tarjeta no puede tener una deuda que supere los $10.
*/
CREATE PROCEDURE sp_Agregar_Viaje(
	@NRO_TARJETA INT,
	@IMPORTE MONEY,
	@NRO_INTERNO INT,
	@LINEA INT
)AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @VER_SALDO MONEY
			SELECT @VER_SALDO = T.SALDO - @IMPORTE FROM TARJETAS T
		
			IF @VER_SALDO > 10  
				BEGIN
					INSERT INTO VIAJES (IDTARJETA, FECHA, COSTO, INTERNO, IDLINEA)
					VALUES (@NRO_TARJETA, GETDATE(), @IMPORTE, @NRO_INTERNO, @LINEA)

					UPDATE TARJETAS SET SALDO = SALDO - @IMPORTE WHERE NROTARJETA = @NRO_TARJETA

					DECLARE @VER_TIPO INT 
					SELECT @VER_TIPO = TP.ID FROM TIPO_MOVIMIENTO TP
					WHERE TP.NOMBRE = 'Debito'

					INSERT INTO MOVIMIENTOS (IDTARJETA, TIPO, FECHA_HORA, IMPORTE, ESTADO)
					VALUES (@NRO_TARJETA, @VER_TIPO, GETDATE(), @IMPORTE, 1)
				END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		RAISERROR('No se pudo ejecutar el registro', 16, 1)
	END CATCH
END

--D) Realizar un procedimiento almacenado llamado sp_Agregar_Saldo que registre un movimiento de crédito a una tarjeta en particular. El procedimiento debe recibir: El número de tarjeta y el importe a recargar. Modificar el saldo de la tarjeta.
CREATE PROCEDURE sp_Agregar_Saldo(
	@NRO_TARJETA INT,
	@IMPORTE MONEY
)AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @EXISTE_TARJETA BIT
			SELECT @EXISTE_TARJETA = COUNT(*) FROM TARJETAS T WHERE T.NROTARJETA = @NRO_TARJETA

			IF @EXISTE_TARJETA = 1 
			BEGIN
				IF @IMPORTE > 0
				BEGIN
					DECLARE @VER_TIPO INT 
							SELECT @VER_TIPO = TP.ID FROM TIPO_MOVIMIENTO TP
							WHERE TP.NOMBRE = 'Credito'

					INSERT INTO MOVIMIENTOS (IDTARJETA, TIPO, FECHA_HORA, IMPORTE, ESTADO) 
					VALUES (@NRO_TARJETA, @VER_TIPO, GETDATE(), @IMPORTE, 1)

					UPDATE TARJETAS SET SALDO = @IMPORTE WHERE NROTARJETA = @NRO_TARJETA
				END
			END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		RAISERROR('No se pudo ejecutar el registro', 16, 1)
	END CATCH
END

--E) Realizar un procedimiento almacenado llamado sp_Baja_Fisica_Usuario que elimine un usuario del sistema. La eliminación deberá ser 'en cascada'. Esto quiere decir que para cada usuario primero deberán eliminarse todos los viajes y recargas de sus respectivas tarjetas. Luego, todas sus tarjetas y por último su registro de usuario.
CREATE PROCEDURE sp_Baja_Fisica_Usuario (
    @ID_USUARIO INT
)
AS
BEGIN
    BEGIN TRY
		BEGIN TRANSACTION
		   DECLARE @EXISTE_USUARIO BIT
		   SELECT @EXISTE_USUARIO = COUNT(*) FROM USUARIOS US WHERE US.IDUSUARIO = @ID_USUARIO
		   IF(@EXISTE_USUARIO = 1)
				BEGIN
					 DELETE FROM VIAJES WHERE IDTARJETA IN ( 
						SELECT MOV.IDMOVIMIENTO FROM MOVIMIENTOS MOV
						INNER JOIN TARJETAS T ON T.IDTARJETA = MOV.IDTARJETA
						WHERE T.IDUSUARIO = @ID_USUARIO
					)

					DELETE FROM VIAJES WHERE IDTARJETA IN(
						SELECT T.IDTARJETA FROM TARJETAS T
					)
					DELETE FROM MOVIMIENTOS WHERE IDMOVIMIENTO IN ( 
						SELECT IDTARJETA FROM TARJETAS
						WHERE IDUSUARIO = @ID_USUARIO
					)

					DELETE FROM TARJETAS WHERE IDUSUARIO = @ID_USUARIO

					DELETE FROM USUARIOS WHERE IDUSUARIO = @ID_USUARIO
				END
		COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
		ROLLBACK TRANSACTION
        RAISERROR('No se pudo ejecutar baja fisica', 16, 1)
    END CATCH
END