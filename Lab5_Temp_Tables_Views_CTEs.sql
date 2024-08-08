/*
#Challenge
**Creating a Customer Summary Report**
In this exercise, you will create a customer summary report that summarizes key information about customers in the Sakila database, including their rental history
 and payment details. The report will be generated using a combination of views, CTEs, and temporary tables.
*/
USE sakila;
#- Step 1: Create a View
#First, create a view that summarizes rental information for each customer. 
#The view should include the customer's ID, name, email address, and total number of rentals (rental_count).
#DROP VIEW IF EXISTS view_rental_info;
CREATE VIEW view_rental_info AS
SELECT cust.customer_id AS 'Cust_id', CONCAT(cust.first_name, ' ', cust.last_name) AS 'customer', cust.email AS 'Email', COUNT(rt.rental_id) AS 'Rental_count'
FROM customer AS cust
JOIN rental rt 
ON cust.customer_id = rt.customer_id
GROUP BY cust.customer_id
ORDER BY COUNT(rt.rental_id) DESC;
SELECT * FROM view_rental_info;

#- Step 2: Create a Temporary Table
#Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
#The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.
#DROP TEMPORARY TABLE IF EXISTS temp_total_paid;
CREATE TEMPORARY TABLE temp_total_paid AS
SELECT vri.customer AS 'Customer', SUM(pay.amount) AS 'Total_Paid'
FROM view_rental_info AS vri
JOIN payment AS pay 
ON vri.cust_id = pay.customer_id
GROUP BY vri.customer
ORDER BY SUM(pay.amount) DESC;

SELECT * FROM temp_total_paid;

#- Step 3: Create a CTE and the Customer Summary Report
#Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
#The CTE should include the customer's name, email address, rental count, and total amount paid. 

SELECT ttpaid.Customer, vri.email, vri.rental_count, ttpaid.total_paid
FROM view_rental_info AS vri
JOIN temp_total_paid AS ttpaid ON vri.customer = ttpaid.customer
ORDER BY total_paid DESC;

WITH rental_pay_summary AS(
	SELECT  vri.email, vri.rental_count
	FROM view_rental_info AS vri
)
SELECT ttpaid.Customer, ttpaid.total_paid
FROM temp_total_paid AS ttpaid
WHERE ttpaid.Customer = (SELECT customer FROM rental_pay_summary);
#ORDER BY total_paid DESC;


#Next, using the CTE, create the query to generate the final customer summary report, which should include: 
#customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.
