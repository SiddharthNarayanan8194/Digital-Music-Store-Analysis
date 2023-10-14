-- Q1: Who is the senior most employee based on job title?
SELECT * FROM employee
ORDER BY levels DESC
OFFSET 0 ROWS 
FETCH NEXT 3 ROWS ONLY;

-- Q2: Which countries have the most invoices?
SELECT billing_country, COUNT (billing_country) FROM invoice
GROUP BY billing_country
ORDER BY COUNT (billing_country) DESC;

-- Q3: What are the top 3 values of total invoice?
SELECT total FROM invoice
ORDER BY total DESC
OFFSET 0 ROWS
FETCH NEXT 3 ROWS ONLY

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals.Return both the city name & sum of all invoice totals.*/
SELECT billing_city, SUM(total) AS Total_Invoice
FROM invoice
GROUP BY billing_city
ORDER BY Total_Invoice DESC
OFFSET 0 ROWS
FETCH NEXT 1 ROWS ONLY;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer.*/
SELECT c.customer_id,c.first_name, c.last_name, SUM(total) AS Total_Invoice
FROM customer c
JOIN invoice i  ON c.customer_id = i.customer_id
GROUP BY c.first_name,c.last_name,c.customer_id
ORDER BY Total_Invoice DESC
OFFSET 0 ROWS
FETCH NEXT 1 ROWS ONLY;

/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */
SELECT DISTINCT first_name,last_name,email FROM customer
JOIN invoice ON customer.customer_id=invoice.customer_id
JOIN invoice_line ON invoice.invoice_id=invoice_line.invoice_id
JOIN track ON invoice_line.track_id=track.track_id
JOIN genre ON track.genre_id=genre.genre_id
WHERE genre.name='Rock'
ORDER BY email;

/* Q7: Let's invite the artists who have written the most rock music in our dataset.
Write a query that returns the artist name and total songs count of the top 10 rock artists. */
SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS Total_Songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name='Rock'
GROUP BY artist.artist_id,artist.name
ORDER BY Total_Songs DESC
OFFSET 0 ROWS
FETCH NEXT 10 ROWS ONLY;

/* Q8: Return all the track names that have a song duration longer than the average song duration. 
Return the Name and Milliseconds for each track. Order by the song duration with the longest songs listed first. */
SELECT name, milliseconds FROM track
WHERE milliseconds> (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC;

/* Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */
WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id,artist.name AS artist_name,SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY artist.artist_id,artist.name
	ORDER BY total_sales DESC
	OFFSET 0 ROWS
	FETCH NEXT 3 ROWS ONLY 
)
SELECT bsa.artist_name,c.customer_id, c.first_name, c.last_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name,bsa.artist_name
ORDER BY amount_spent DESC;

/* Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres.*/
WITH most_popular_genre AS 
(
    SELECT COUNT(il.quantity) AS purchase_count, c.country, g.name, g.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) AS row_no
    FROM invoice_line il
	JOIN invoice i ON i.invoice_id = il.invoice_id
	JOIN customer c ON c.customer_id = i.customer_id
	JOIN track t ON t.track_id = il.track_id
	JOIN genre g ON g.genre_id = t.genre_id
	GROUP BY c.country,g.name,g.genre_id
	ORDER BY c.country ASC, purchase_count DESC
	OFFSET 0 ROWS
	)
SELECT * FROM most_popular_genre WHERE row_no=1

/* Q11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount.*/
WITH top_customer AS (
		SELECT c.customer_id,c.first_name,c.last_name,i.billing_country, round(SUM(i.total),2) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY i.billing_country ORDER BY SUM(i.total) DESC) AS row_no
		FROM invoice i
		JOIN customer c ON c.customer_id = i.customer_id
		GROUP BY c.customer_id,c.first_name,c.last_name,i.billing_country
		ORDER BY i.billing_country ASC, total_spending DESC
		OFFSET 0 ROWS
		)
SELECT * FROM top_customer WHERE row_no = 1 ;

