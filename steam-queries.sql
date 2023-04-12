-- 1 Obtener el nombre de usuario, el título del juego, la fecha de lanzamiento y el precio de los juegos comprados 
-- por un usuario específico:

SELECT Users.username, Games.title, Games.release_date, Purchases.price
FROM Users 
JOIN Purchases ON Users.user_id = Purchases.user_id
JOIN Games ON Purchases.game_id = Games.game_id
WHERE Users.user_id = 2;

-- 2 Obtener el promedio de las calificaciones de los juegos de un desarrollador específico:

SELECT AVG(Ratings.rating)
FROM Games
JOIN Ratings ON Games.game_id = Ratings.game_id
WHERE Games.developer = 'Quinu';

-- 3 Obtener el nombre de usuario, el título del juego, y el tiempo jugado de los juegos en los 
-- que un usuario ha alcanzado un determinado número de logros:

SELECT Users.username, Games.title, Game_Progress.time_played
FROM Game_Progress 
JOIN Users ON Game_Progress.user_id = Users.user_id
JOIN Games ON Game_Progress.game_id = Games.game_id
WHERE Game_Progress.achievements >= 200;

-- 4 Obtener el nombre de usuario, el título del juego, y el tipo de transacción de las compras realizadas 
-- por un usuario específico:

SELECT Users.username, Games.title, Virtual_Currency_Transaction.type
FROM Virtual_Currency_Transaction
JOIN Users ON Virtual_Currency_Transaction.user_id = Users.user_id
JOIN Games ON Virtual_Currency_Transaction.game_id = Games.game_id
WHERE Virtual_Currency_Transaction.type = 'purchase' and Users.user_id = 1;

-- 5 Obtener el juego que ha generado más ingresos en un rango de fechas específico:

SELECT g.title, SUM(g.price) as total_income
FROM Games g
JOIN Purchases ON g.game_id = Purchases.game_id
WHERE purchase_date BETWEEN '2022-02-01' AND '2022-02-28'
GROUP BY title
ORDER BY total_income DESC
LIMIT 1;


-- vista del promedio de los videojuegos --

CREATE VIEW Game_Ratings AS
SELECT title, AVG(rating) as average_rating
FROM Games
JOIN Ratings ON Games.game_id = Ratings.game_id
GROUP BY title;

-- vista del total de logros de un usuario

CREATE VIEW User_Achievements AS
SELECT username, SUM(achievements) as total_achievements
FROM Users
JOIN Game_Progress ON Users.user_id = Game_Progress.user_id
GROUP BY username;

-- FUNCIONES

-- calcular cuanto ha generado un juego
drop function if exists calculate_game_total;
delimiter $$
CREATE FUNCTION calculate_game_total (titulo varchar(50)) 
RETURNS varchar(100)
deterministic
begin
	declare respuesta varchar(100);
	select   concat('el juego' ,' ',  titulo,' ' ,'ha generado',' ', sum(p.price), '€')   into respuesta 
	from Games g
	inner join Purchases p on g.game_id = p.game_id 
	where g.title = titulo;
	return respuesta;
end $$
delimiter ;

SELECT calculate_game_total('Nun, The (La monja)');

-- Crear una función para obtener el total de compras de un usuario
drop function if exists get_total_purchases;
DELIMITER $$
CREATE FUNCTION get_total_purchases(id INT) RETURNS INT
deterministic
BEGIN
    DECLARE total_purchases INT;
    
    -- Calcular el total de compras del usuario
    SELECT COUNT(*) INTO total_purchases FROM Purchases WHERE user_id = id;
    
    RETURN total_purchases;
END $$
DELIMITER ;

SELECT get_total_purchases(1);

-- PROCEDIMIENTOS

-- Crear un procedimiento que utilice la función get_total_purchases()
drop PROCEDURE if exists show_user_purchase_count;
DELIMITER $$
CREATE PROCEDURE show_user_purchase_count(IN usuario VARCHAR(255))
BEGIN
    DECLARE id INT;
    DECLARE purchase_count INT;
    
    -- Obtener el user_id del usuario con el nombre de usuario proporcionado
    SELECT user_id INTO id FROM Users WHERE username = usuario;
    
    -- Verificar si el usuario existe
    IF id IS NULL THEN
        SELECT 'Usuario no encontrado.';
    END IF;
    
    -- Obtener el total de compras del usuario utilizando la función get_total_purchases()
    SET purchase_count = get_total_purchases(id);
    
    -- Mostrar el total de compras del usuario
    SELECT CONCAT('El usuario ', usuario, ' ha realizado un total de ', purchase_count, ' compras.');
END $$
DELIMITER ;

call show_user_purchase_count('acoulthart1j');

-- procedimiento para mostrar las compras de un usuario
DROP PROCEDURE IF EXISTS ShowUserPurchases;
DELIMITER $$
CREATE PROCEDURE ShowUserPurchases(IN puser_id INT)
BEGIN
    DECLARE salida VARCHAR(10000) DEFAULT '========ESTADISTICAS=======';
    DECLARE titulo VARCHAR(255);
    DECLARE fecha DATE;
    DECLARE precio DECIMAL(10,2);
    DECLARE done BOOL DEFAULT FALSE;
    DECLARE username VARCHAR(255);
    DECLARE c1 CURSOR FOR
 		SELECT title, purchase_date, g.price
        FROM Games g
        JOIN Purchases p ON p.game_id = g.game_id
        WHERE p.user_id = puser_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    -- encabezado de la lista de compras
        SET salida = CONCAT(salida, '\n' , 'Lista de compras del usuario: ', puser_id);
    -- recorrer todas las compras del usuario
 
    OPEN c1;
  
    WHILE (NOT done) DO
        FETCH c1 INTO titulo, fecha, precio;
        IF (NOT done) THEN
             SET salida = CONCAT(salida, '\n', 'titulo del juego: ', titulo, ' - Fecha de compra: ', fecha, ' - Precio: ', precio);
        END IF;
    END WHILE;
    CLOSE c1;

    SELECT salida;
END $$
DELIMITER ;

CALL ShowUserPurchases(56);


-- procedimiento para realizar una compra de un juego y actualizar la balance de moneda virtual del usuario
drop procedure if exists BuyGame;
DELIMITER $$
CREATE PROCEDURE BuyGame(IN user_id INT, IN game_id INT)
BEGIN
    DECLARE game_price DECIMAL(10,2);
    DECLARE user_balance DECIMAL(10,2);
    
    -- obtener el precio del juego
    SELECT price INTO game_price 
   	FROM Games 
  	WHERE game_id = game_id
 	LIMIT 1;
    
    -- obtener el balance de moneda virtual del usuario
    SELECT balance INTO user_balance 
    FROM Virtual_Currency 
   	WHERE user_id = user_id
  	LIMIT 1;
    
    IF game_price <= user_balance THEN
       
        SELECT "Compra realizada exitosamente." AS message;
    ELSE
        SELECT "No tienes suficiente moneda virtual para realizar esta compra." AS message;
    END IF;
END $$

DELIMITER ;

call BuyGame(1,1); 

-- trigger 1

drop trigger if exists update_virtual_currency_balance;
DELIMITER $$
CREATE TRIGGER update_virtual_currency_balance 
AFTER INSERT ON Purchases FOR EACH ROW
BEGIN
    -- Actualiza el balance de moneda virtual del usuario después de una compra
    UPDATE Virtual_Currency vc 
    SET vc.balance = vc.balance - NEW.price
    WHERE vc.user_id = NEW.user_id;
END $$
DELIMITER ;

SELECT balance
FROM Virtual_Currency
WHERE user_id= 1;

INSERT INTO Purchases (purchase_id, game_id, user_id, purchase_date, price)
VALUES (1004, 1, 1, CURDATE(), 19.99);

-- trigger 2

DROP TRIGGER IF EXISTS update_progress;
DELIMITER $$
CREATE TRIGGER update_progress
BEFORE UPDATE ON Game_Progress
FOR EACH ROW
BEGIN
	 DECLARE tiempo INT;
    SET NEW.last_played = NOW();
    SET tiempo = NEW.time_played + OLD.time_played;
    SET NEW.time_played = tiempo;
END $$
DELIMITER ;

SELECT *
FROM Game_Progress
WHERE progress_id = 1; 

UPDATE Game_Progress
SET  time_played = 180
WHERE progress_id = 1; 


