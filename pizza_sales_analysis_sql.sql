-- Q1: Retrieve the total number of orders placed
SELECT 
    COUNT(order_id) AS total_orders
FROM orders;

-- Q2: Calculate the total revenue generated from pizza sales
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price), 2) AS total_revenue
FROM order_details
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id;

-- Q3: Identify the most frequently ordered pizza size
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM pizzas
JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

-- Q4: Identify the most common pizza size ordered (duplicate of Q3)
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM pizzas
JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

-- Q5: List the top 5 most ordered pizza types along with their quantities
SELECT 
    pizza_types.name, 
    SUM(order_details.quantity) AS quantity
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

-- Q6: Total quantity of each pizza category ordered
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- Q7: Distribution of orders by hour of the day
SELECT 
    HOUR(order_time) AS hour, 
    COUNT(order_id) AS order_count
FROM orders
GROUP BY HOUR(order_time);

-- Q8: Category-wise distribution of pizzas
SELECT 
    category, 
    COUNT(name)
FROM pizza_types
GROUP BY category;

-- Q9: Average number of pizzas ordered per day
SELECT 
    ROUND(AVG(quantity), 0) AS avg_pizza_ordered_per_day
FROM (
    SELECT 
        orders.order_date, 
        SUM(order_details.quantity) AS quantity
    FROM orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date
) AS order_quantity;

-- Q10: Top 3 most ordered pizza types based on revenue
SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM pizza_types
JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- Q11: Percentage contribution of each pizza category to total revenue
SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (
        SELECT 
            ROUND(SUM(order_details.quantity * pizzas.price), 2)
        FROM order_details
        JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id
    ) * 100, 2) AS revenue
FROM pizza_types
JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;

-- Q12: Cumulative revenue generated over time
SELECT 
    order_date,
    SUM(revenue) OVER (ORDER BY order_date) AS cum_revenue
FROM (
    SELECT 
        orders.order_date,
        SUM(order_details.quantity * pizzas.price) AS revenue
    FROM order_details
    JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
    JOIN orders ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date
) AS sales;

-- Q13: Top 3 most ordered pizza types based on revenue for each pizza category
SELECT 
    name, revenue 
FROM (
    SELECT 
        category, name, revenue,
        RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
    FROM (
        SELECT 
            pizza_types.category, 
            pizza_types.name,
            SUM(order_details.quantity * pizzas.price) AS revenue
        FROM pizza_types
        JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
        GROUP BY pizza_types.category, pizza_types.name
    ) AS a
) AS b
WHERE rn <= 3;
