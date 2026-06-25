CREATE DATABASE food_wastage_analysis;
USE food_wastage_analysis;


CREATE TABLE kitchens (
    kitchen_id INT PRIMARY KEY,
    city VARCHAR(100),
    kitchen_type VARCHAR(50),
    manager_name VARCHAR(100),
    opening_date DATE
);

CREATE TABLE menu_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    item_name VARCHAR(100),
    category VARCHAR(100),
    shelf_life_hours INT,
    ingredient_cost DECIMAL(10,2),
    selling_price DECIMAL(10,2)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date DATETIME,
    kitchen_id INT,
    item_id INT,
    quantity_sold INT,
    selling_price DECIMAL(10,2),
    order_status VARCHAR(30),
    delivery_time_minutes INT,
    customer_rating DECIMAL(3,1),
    
	FOREIGN KEY (kitchen_id) REFERENCES kitchens(kitchen_id),
    FOREIGN KEY (item_id) REFERENCES menu_items(item_id)
);

CREATE TABLE inventory (
    inventory_id INT PRIMARY KEY AUTO_INCREMENT,
    ingredient_name VARCHAR(100),
    purchase_quantity INT,
    used_quantity INT,
    wasted_quantity INT,
    expiry_date DATE,
    kitchen_id INT,

    FOREIGN KEY (kitchen_id) REFERENCES kitchens(kitchen_id)
);

CREATE TABLE wastage_logs (
    waste_id INT PRIMARY KEY AUTO_INCREMENT,
    item_id INT,
	kitchen_id INT,
    waste_quantity INT,
    waste_reason VARCHAR(100),
    waste_cost DECIMAL(10,2),
    waste_date DATETIME,

    FOREIGN KEY (item_id) REFERENCES menu_items(item_id)
);


INSERT INTO kitchens (city, kitchen_type, manager_name)
VALUES
('Mumbai','Cloud Kitchen','Rahul Sharma'),
('Delhi','QSR','Priya Mehta'),
('Bangalore','Cloud Kitchen','Amit Verma'),
('Pune','Cloud Kitchen','Sneha Joshi'),
('Hyderabad','QSR','Rohit Patel'),
('Chennai','Cloud Kitchen','Anjali Nair'),
('Kolkata','Buffet Kitchen','Sourav Das'),
('Ahmedabad','Cloud Kitchen','Karan Shah'),
('Jaipur','QSR','Neha Singh'),
('Lucknow','Cloud Kitchen','Vivek Gupta');


INSERT INTO menu_items
(item_name, category, shelf_life_hours, ingredient_cost, selling_price)
VALUES
('Paneer Wrap','Fast Food',6,80,220),
('Veg Biryani','Main Course',8,120,300),
('Chicken Burger','Fast Food',5,90,250),
('Pasta Alfredo','Italian',4,110,320),
('Chocolate Shake','Beverage',3,60,180),
('Paneer Tikka','Starter',5,100,280),
('Chicken Tikka','Starter',5,130,340),
('Veg Pizza','Italian',6,140,380),
('Chicken Pizza','Italian',6,170,450),
('Hakka Noodles','Chinese',7,90,240),
('Fried Rice','Chinese',7,95,250),
('Manchurian','Chinese',5,85,220),
('Masala Dosa','South Indian',4,40,140),
('Idli Sambar','South Indian',4,35,120),
('Butter Chicken','Main Course',8,180,480),
('Dal Makhani','Main Course',8,90,260),
('Chole Bhature','North Indian',5,60,180),
('Pav Bhaji','Street Food',5,50,170),
('Vada Pav','Street Food',3,20,80),
('Cold Coffee','Beverage',3,45,160),
('Mango Shake','Beverage',3,55,170),
('Brownie','Dessert',4,50,190),
('Gulab Jamun','Dessert',6,25,100),
('Ice Cream Sundae','Dessert',3,45,180),
('Paneer Roll','Fast Food',5,70,210);

INSERT INTO orders
(order_date, kitchen_id, item_id, quantity_sold, selling_price)
VALUES
('2026-05-01 12:30:00', 1, 1, 25, 220),
('2026-05-01 13:00:00', 1, 2, 18, 300),
('2026-05-01 19:15:00', 2, 3, 30, 250),
('2026-05-02 20:00:00', 3, 4, 15, 320),
('2026-05-02 18:45:00', 4, 5, 20, 180);

Insert INTO inventory 
(ingredient_name, purchase_quantity, used_quantity,
wasted_quantity, expiry_date, kitchen_id)
Values
('Panner',100,80,20, '2026-05-05', 1),
('Rice', 200, 170, 30, '2026-05-06', 1),
('Chicken Patty', 150, 120, 30, '2026-05-04', 2),
('Cream', 90, 70, 20, '2026-05-03', 3),
('Milk', 120, 90, 30, '2026-05-02', 4);

Insert into wastage_logs
(item_id, waste_quantity, waste_reason,
waste_cost, waste_date)
Values
(1,10, 'Overstocking', 800, '2026-05-01 22:00:00'),
(2, 8, 'Expired Ingredients', 960, '2026-05-01 23:00:00'),
(3, 12, 'Customer Cancellation', 1080, '2026-05-02 21:30:00'),
(4, 5, 'Cooking Error', 550, '2026-05-02 22:15:00'),
(5, 15, 'Poor Storage', 900, '2026-05-02 23:00:00');


USE food_wastage_analysis;

SELECT COUNT(*) AS kitchens_count FROM kitchens;
SELECT COUNT(*) AS menu_count FROM menu_items;
SELECT COUNT(*) AS orders_count FROM orders;
SELECT COUNT(*) AS inventory_count FROM inventory;



-- Total Sales
select
Sum(quantity_sold * selling_price) AS total_sales
from orders;



-- MOST WASTEFUL ITEMS
Select
    m.item_name,
    sum(w.waste_quantity) AS total_waste,
    sum(w.waste_cost) AS total_waste_cost
From wastage_logs w
join menu_items m
on w.item_id = m.item_id
group by m.item_name 
order by total_waste_cost DESC;


-- PROFIT ANALYSIS
SELECT
    m.item_name,
    SUM(o.quantity_sold * o.selling_price) AS revenue,
    SUM(o.quantity_sold * m.ingredient_cost) AS ingredient_cost,
    SUM(o.quantity_sold * o.selling_price)
      - SUM(o.quantity_sold * m.ingredient_cost) AS gross_profit
FROM orders o
JOIN menu_items m
ON o.item_id = m.item_id
GROUP BY m.item_name
ORDER BY gross_profit DESC;


-- Kitchen Wise Wastage
SELECT
k.city,
SUM(i.wasted_quantity) AS total_waste
FROM inventory i
JOIN kitchens k
ON i.kitchen_id = k.kitchen_id
GROUP BY k.city
ORDER BY total_waste DESC;


-- Profit Generated Per Item
SELECT
    m.item_name,
    SUM(o.quantity_sold * o.selling_price) AS revenue,
    SUM(o.quantity_sold * m.ingredient_cost) AS ingredient_cost,
    SUM(o.quantity_sold * o.selling_price)
      - SUM(o.quantity_sold * m.ingredient_cost) AS gross_profit
FROM orders o
JOIN menu_items m
ON o.item_id = m.item_id
GROUP BY m.item_name
ORDER BY gross_profit DESC;


-- Wastage Percentage
SELECT
    ingredient_name,
    purchase_quantity,
    wasted_quantity,

    ROUND(
        (wasted_quantity / purchase_quantity) * 100,
        2
    ) AS wastage_percentage
FROM inventory
ORDER BY wastage_percentage DESC;


-- Peak Wastage Hours
SELECT
    HOUR(waste_date) AS waste_hour,
    SUM(waste_cost) AS total_loss
FROM wastage_logs
GROUP BY waste_hour
ORDER BY total_loss DESC;


-- Top Selling Food Item
SELECT
m.item_name,
SUM(o.quantity_sold) AS total_sold
FROM orders o
JOIN menu_items m
ON o.item_id=m.item_id
GROUP BY m.item_name
ORDER BY total_sold DESC;


-- Profit Calculation
SELECT
item_name,
selling_price,
ingredient_cost,
(selling_price - ingredient_cost) AS profit_per_item
FROM menu_items;


-- Profit vs Wastage
SELECT
m.item_name,
SUM(o.quantity_sold * o.selling_price) AS revenue,
SUM(w.waste_cost) AS wastage
FROM menu_items m
JOIN orders o
ON m.item_id=o.item_id
JOIN wastage_logs w
ON m.item_id=w.item_id
GROUP BY m.item_name;


-- Rank Kitchens
SELECT
city,
SUM(wasted_quantity) AS total_waste,

RANK() OVER(
ORDER BY SUM(wasted_quantity) DESC
) AS waste_rank

FROM inventory i
JOIN kitchens k
ON i.kitchen_id=k.kitchen_id
GROUP BY city;


-- CTE Example
WITH item_sales AS
(
SELECT
item_id,
SUM(quantity_sold) total_sales
FROM orders
GROUP BY item_id
)

SELECT *
FROM item_sales;


-- Dense Rank
SELECT
item_name,
selling_price,

DENSE_RANK() OVER(
ORDER BY selling_price DESC
) AS price_rank

FROM menu_items;




