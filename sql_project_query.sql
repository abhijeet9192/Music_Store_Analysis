SELECT * FROM album

--Qu 1-- Who is senior most employee?

SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1

--Qu 2--Which country has the most invoices?

SELECT COUNT(*) AS C ,billing_country
FROM invoice
GROUP BY billing_country
ORDER BY C DESC

--Qu 3--What are the top three values of total invoice?

SELECT * FROM invoice
ORDER BY total DESC
LIMIT 3

--Qu 4--Which city has best customer? We want to throw promotional music festival 
       --in city we made most money with.Write a query that returns one city that has 
	   --the highest sum of invoice totals. Return both the city name and sum of all invoice totals?


SELECT billing_city, SUM(total) AS invoice_total
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total DESC

--Qu 5--Who is best customer? The customer who has spent the most money will be declared the
--best customer. Write a query that returns the person who has spent the most money?

SELECT * FROM customer

SELECT customer.customer_id, customer.first_name, customer.last_name, SUM(total) as invoice_total
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY invoice_total DESC
LIMIT 1

--Qu 6--Write a query to return e-mail, first_name, last_name of all rock music listeners.
--Return ypur list orderd alphabetically by email starting with A?

SELECT DISTINCT email, first_name, last_name FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
SELECT track_id FROM track
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name LIKE 'Rock'
)
ORDER BY email;

--Qu 7--Let's invite the artists who have written the most rock music in our dataset.
--Write a query that returns the Artists name and total track countof the top 10 rock bands?

SELECT artist.artist_id, artist.name, COUNT(artist.artist_id) AS no_of_songs
FROM track
JOIN album ON track.album_id = album.album_id 
JOIN artist ON album.artist_id = artist.artist_id
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY no_of_songs DESC
LIMIT 10;


--Qu 8--Return all the track names that have a song length longer than the average song length
--Return the name and milliseconds for each track. Order by song length with the longest songs 
--listed first.

SELECT name, milliseconds FROM track
WHERE milliseconds > (
SELECT AVG(milliseconds) AS avg_track_length
	FROM track

)
ORDER BY milliseconds DESC;


--Qu 9--Find how much amount spent by each customer on artists? Write a query to return 
--customer_name, artist_name and total spent?

WITH best_selling_artist AS (
SELECT artist.artist_id AS artist_id, artist.name AS artist_name, 
	SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales 
	FROM invoice_line
JOIN track ON track.track_id = invoice_line.track_id
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
	)
	
SELECT customer.customer_id,customer.first_name,customer.last_name, bsa.artist_name, SUM (invoice_line.unit_price*invoice_line.quantity)AS 
amount_spent FROM invoice  
JOIN customer ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN album ON album.album_id = track.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = album.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;	
	
--Qu 10--We want to find out most popukar music genre for each country. We determine the 
--most popular genre as the genre with the highest amount of purchases. Write a query that 
--returns each countryalong with the top genre. For countrieswhere the maximum number of 
--purchases is shared return all genres.

WITH popular_genre AS(
SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id,
ROW_NUMBER() OVER (PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity)DESC) AS row_no
FROM invoice_line
JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
JOIN customer ON customer.customer_id = invoice.customer_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE row_no <= 1



--Qu 11--Write a querythat determines the customer that has spent the most on music for
--each country.Write a query that returns the country along with the top customer and 
--how much they spent. For countries where the top amount spent is shared, provide all customers
--who spent this amount.

WITH Customer_with_country AS(
SELECT customer.customer_id,first_name,last_name,billing_country, SUM(total) AS total_spending,
ROW_NUMBER () OVER (PARTITION BY billing_country ORDER BY SUM(total)DESC)AS row_no
FROM invoice
	JOIN customer ON customer.customer_id = invoice.customer_id
	GROUP BY 1,2,3,4
	ORDER BY 4 ASC,5 DESC
)
SELECT * FROM Customer_with_country WHERE row_no <=1











