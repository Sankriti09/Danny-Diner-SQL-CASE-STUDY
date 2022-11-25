

select * from sales;
/*       ------OUTPUT ------
|customer_id |	order_date  | product_id   |
------------ | ------------ | -----------
|A	     |  2021-01-01  |	 1        |
|A	     |  2021-01-01  |	 2        |
|A	     |  2021-01-07  |	 2        |
|A	     |	2021-01-10  |	 3        |
|A	     |	2021-01-11  |	 3        |
|A	     |	2021-01-11  |	 3        |
|B	     |	2021-01-01  |	 2        |
|B	     |	2021-01-02  |	 2        |
|B	     |	2021-01-04  |	 1        |
|B	     |	2021-01-11  |	 1        |
|B	     |	2021-01-16  |	 3        |
|B	     |	2021-02-01  |	 3        |
|C	     |	2021-01-01  |	 3        |
|C	     |	2021-01-01  |	 3        |
|C	     |	2021-01-07  |	 3        |
*/
select * from members;
/*     ------  OUTPUT -------
|customer_id |	order_date  |product_id |
------------ | ------------ | -----------
|A	     |  2021-01-01  |	 1      |
|A	     |  2021-01-01  |	 2      |
|A	     |  2021-01-07  |	 2      |
*/
select * from menu;
/*     ------  OUTPUT -------
|customer_id |	order_date  |product_id |
------------ | ------------ | -----------
|A	     |  2021-01-01  |	 1      |
|A	     |  2021-01-01  |	 2      |
|A	     |  2021-01-07  |	 2      |
*/


-- Q1.What is the total amount each customer spent at the restaurant?*/
/* --------- SOLUTION --------- */
select customer_id, s.product_id,
sum(price) as total_payment
from sales s
join menu m on m.product_id = s.product_id
group by customer_id;

-- Q2. How many days has each customer visited the restaurant?
/* --------- SOLUTION --------- */
select * from sales;
select customer_id,count(distinct order_date) as Visited_days
from sales
group by 1;

-- Q3. What was the first item from the menu purchased by each customer?
/* --------- SOLUTION --------- */
use `dannys_diner`;
select * from menu;
select * from sales;
select customer_id, order_date, product_name as ordered_item
from(select s.customer_id,s.order_date,
			m.product_name,
			dense_rank() over(partition by customer_id order by order_date, product_name asc) as rnk
	from sales s
	INNER join menu m on m.product_id = s.product_id)a
where a.rnk=1
group by 1;

-- Q4. What is the most purchased item on the menu and how many times was it purchased by all customers?
/* --------- SOLUTION --------- */
use `dannys_diner`;
select * from sales;
select product_name, count(product_id) as purchased_count
from(select s.customer_id,
	s.product_id,
	m.product_name,
	s.order_date,
	dense_rank() over(partition by customer_id order by product_id desc ) as rnk
	from sales s
	join menu m on s.product_id = m.product_id)a
where a.rnk=1;

-- Q5. Which item was the most popular for each customer?
/* --------- SOLUTION --------- */
select * from menu;
select * from sales;
use `dannys_diner`;
select customer_id, group_concat(product_name) as ordered_product
from(select s.customer_id,product_name,
	count(s.product_id) as total_count,
    dense_rank() over(partition by customer_id 
    order by count(s.product_id) desc) as rnk
	from sales s
	join menu m on s.product_id = m.product_id
    group by 1,2)a
where rnk=1
group by 1;


-- Q6. Which item was purchased first by the customer after they became a member?
/* --------- SOLUTION --------- */
  --  **ist approach**
select customer_id, product_name
from(select m.customer_id,mn.product_name,min(s.order_date) as `Order_date`
	from members m
	join sales s on m.customer_id = s.customer_id
	join menu mn on s.product_id = mn.product_id 
	where s.order_date>=m.join_date
	group by customer_id
	order by 1)a;
    
  -- **second approach**
select customer_id, product_name
from(select m.customer_id,mn.product_name,s.order_date,m.join_date,
	dense_rank() over(partition by m.customer_id order by order_date asc) as rnk
	from members m
	join sales s on m.customer_id = s.customer_id
	join menu mn on s.product_id = mn.product_id 
	where s.order_date>=m.join_date)a
where a.rnk=1;

-- Q7. Which item was purchased just before the customer became a member?
/* --------- SOLUTION --------- */
SELECT * FROM MENU;
SELECT * FROM SALES;
SELECT * FROM MEMBERS;
select customer_id, group_concat(product_name) as Ordered_food
from(select s.customer_id, order_date, mn.product_name, m.join_date,
	dense_rank() over(partition by m.customer_id order by s.order_date desc) as rnk
	from sales s 
	join members m on m.customer_id = s.customer_id
	join menu mn on mn.product_id = s.product_id
	where s.order_date< m.join_date)a
where rnk=1
group by 1;


-- Q8. What are the total items and amount spent for each member before they became a member?
/* --------- SOLUTION --------- */
WITH CTE AS
	(select s.customer_id, s.order_date,
    m.join_date, mn.product_name, mn.price
	from members m 
	join sales s on m.customer_id = s.customer_id
	join menu mn on mn.product_id = s.product_id
	where order_date<join_date
	order by 1,2)

select customer_id, group_concat(product_name) as ordered_food,
	   count(product_name) as total_items,
	   sum(price) as total_amount
from CTE
group by customer_id
ORDER BY customer_id;


/* Q9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - 
--how many points would each customer have?
In the first week after a customer joins the program (including their join date) 
they earn 2x points on all items, not just sushi - 
how many points do customer A and B have at the end of January?
*/
/* ------ SOLUTION --------- */
select * ,
(case when mn.product_name="sushi" then 
end) as points
from menu mn
join sales s on s.product_id = mn.product_id


/*The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join 
the underlying tables using SQL.

Q10. customer_id	order_date	product_name	     price	     member
A	                2021-01-01	curry			15		N
A	                2021-01-01	sushi			10		N
A	                2021-01-07	curry			15		Y
A			2021-01-10	ramen			12		Y
A			2021-01-11	ramen			12		Y
A			2021-01-11	ramen			12		Y
B			2021-01-01	curry			15		N
B			2021-01-02	curry			15		N
B			2021-01-04	sushi			10		N
B			2021-01-11	sushi			10		Y
B			2021-01-16	ramen			12		Y
B			2021-02-01	ramen			12		Y
C			2021-01-01	ramen			12		N
C			2021-01-01	ramen			12		N
C			2021-01-07	ramen			12		N
*/
/* ------ SOLUTION --------- */
select *
from sales s
left join menu mn on mn.product_id = s.product_id
left join members m on m.customer_id = s.customer_id;

select * from members m;
select s.customer_id,s.order_date, mn.product_name,mn.price,
(case when s.order_date>=m.join_date then 'Y'
	else 'N'
end)as member
from sales s 
left join menu mn on s.product_id = mn.product_id
left join members m on m.customer_id= s.customer_id
ORDER BY 1,2,3;

/*
Q11. Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases 
so he expects null ranking values for the records when customers are not yet part of the loyalty program.
*/
/* -------- SOLUTION --------- */
with cte as
(select s.customer_id, s.order_date, mn.product_name, mn.price,
		  (case when s.order_date>=m.join_date then 'Y' else 'N' end)as member
from sales s 
left join members m on s.customer_id=m.customer_id
left join menu mn on mn.product_id=s.product_id
order by 1)a;
  
select * ,
(case when member='N' then 'null'
	else 'Y'
end) as ranking
from cte;
