USE computer_shop_1;


-- Смотрим кто из пользователей на какую сумму сделал заказов
SELECT 
u.id AS 'user_id',
CONCAT(u.firstname , ' ',u.lastname) AS 'имя пользователя',
SUM(p.price * op.total) AS 'total_price'
FROM users u 
JOIN orders o ON o.user_id = u.id 
JOIN orders_products op ON op.order_id = o.id 
JOIN products p ON p.id = op.product_id
GROUP BY u.id
ORDER BY total_price DESC;

-- Выводим список пользователей с указанием товара который они купили, но не оставили отзыва
SELECT 
u.id,
CONCAT(u.firstname, ' ',u.lastname) AS 'имя пользователя',
p.name AS 'название товара'
FROM users u 
JOIN orders o ON o.user_id = u.id 
JOIN orders_products op ON op.order_id=o.id 
JOIN products p ON p.id=op.product_id
LEFT JOIN reviews r ON r.from_user_id = u.id AND r.product_id = p.id
WHERE r.from_user_id IS NULL;

-- Выводим список с названиями купленных товаров без использования JOIN
SELECT
(SELECT products.id FROM products WHERE products.id = orders_products.product_id) AS 'id товара',
(SELECT products.name FROM products WHERE products.id = orders_products.product_id) AS 'название товара',
count(*) AS cnt
FROM orders_products 
WHERE orders_products.product_id IN (SELECT products.id FROM products)
GROUP BY `id товара`
ORDER BY cnt DESC;

-- Таже задача, но решение с использованеим JOIN
SELECT
p.id AS 'id товара',
p.name AS 'название товара',
count(*) AS cnt
FROM orders_products op
JOIN products p ON op.product_id = p.id
GROUP BY p.id
ORDER BY cnt DESC;


-- Выводим список пользователей, купивших товары, стоимостью меньше 10 тыс. руб. за единицу
SELECT
u.id,
CONCAT (u.firstname, ' ', u.lastname) AS 'имя пользователя',
p.name AS 'название товара',
p.price AS 'цена'
FROM users u
JOIN orders o ON u.id = o.user_id
JOIN orders_products op ON o.id = op.order_id 
JOIN products p ON op.product_id = p.id 
WHERE p.price < 10000
ORDER BY u.id;

-- Список товаров на которые есть отзывы, отсортированные по средней оценке.
SELECT 
p.name AS 'название товара',
AVG(r.grade) AS 'средняя оценка'
FROM products p 
JOIN reviews r ON r.product_id = p.id 
GROUP BY p.name
ORDER BY `средняя оценка` DESC;

-- Узнать сумму всех товаров на каждом складе
SELECT
s.name AS 'название склада',
SUM(p.price * sp.value) AS 'цена всех товаров'
FROM storehouses s 
JOIN storehouses_products sp ON s.id = sp.storehouse_id 
JOIN products p ON p.id = sp.product_id 
GROUP BY s.name 
ORDER BY `цена всех товаров`;

-- Представление заказа с именем пользователя и названием товара
CREATE OR REPLACE VIEW order_view AS SELECT
u.firstname AS 'имя',
u.lastname AS 'фамилия',
c.name AS 'категория товара',
p.name 'название товара',
op.total AS 'количество',
p.price AS 'цена за единицу',
(p.price * op.total) AS 'общая цена'
FROM orders o
JOIN users u ON o.user_id = u.id 
JOIN orders_products op  ON op.order_id = o.id 
JOIN products p ON p.id = op.product_id
JOIN catalogs c ON c.id = p.catalog_id ;

SELECT * from order_view ;

-- Представление сколько товара в наличии на всех складах
CREATE OR REPLACE VIEW total_products AS SELECT
c.name AS 'категория',
p.name  AS 'товар',
SUM(sp.value) AS 'количество на складах' 
FROM storehouses_products sp 
JOIN products p ON p.id = sp.product_id
JOIN catalogs c ON c.id = p.catalog_id
GROUP BY p.id
ORDER BY c.id;

SELECT * from total_products ;


-- Создаем процедуру, делающую скидки на группу товаров. 
DROP PROCEDURE IF EXISTS pr_sales;
DELIMITER //
CREATE PROCEDURE pr_sales(sales DECIMAL(2,2), cat BIGINT)
BEGIN
	UPDATE products SET price = price * sales WHERE products.catalog_id = cat;
END //
DELIMITER ;

CALL pr_sales(0.9, 1); 


-- Создаем процедуру, которая выводит список заказанных товаров выбранного по ID пользователя
DROP PROCEDURE IF EXISTS pr_orders;
DELIMITER //
CREATE PROCEDURE pr_orders(usr BIGINT)
BEGIN
	SELECT 
	CONCAT (u.firstname, ' ', u.lastname) AS 'имя пользователя',
	p.name AS 'название товара',
	op.created_at AS 'время заказа'
	FROM orders_products op 
	JOIN orders o ON op.order_id = o.id 
	JOIN users u ON u.id = o.user_id
	JOIN products p ON op.product_id = p.id 
	WHERE u.id = usr;
END //
DELIMITER ;

CALL pr_orders(4);


-- Создаем тригер, который при изменении количества товара на складе заносит изменения в каталог products_change_logs
DROP TRIGGER IF EXISTS to_logs_storehouse_products;
DELIMITER //
CREATE TRIGGER to_logs_storehouse_products AFTER UPDATE ON storehouses_products
FOR EACH ROW
BEGIN
INSERT INTO logs_products_change (from_storehouses_id, from_product_id, value_change) VALUES
(NEW.storehouse_id, NEW.product_id, (NEW.value - OLD.value));
END//
DELIMITER ;

-- Проверяем тригер
UPDATE storehouses_products
SET value = 9
WHERE product_id = 12 AND storehouse_id = 1;

-- Создаем тригер, который в случае в отзыве оценки больше 5 исправляет на 5
DROP TRIGGER IF EXISTS to_logs_storehouse_products;
DELIMITER //
CREATE TRIGGER exam_buy BEFORE INSERT ON reviews 
FOR EACH ROW
BEGIN
	IF NEW.grade > 5 THEN 
		SET NEW.grade = 5;
	END IF;
END//
DELIMITER ;

-- Проверяем тригер
INSERT INTO reviews (from_user_id, product_id, body, grade) VALUES
(10, 2, '', 9);



