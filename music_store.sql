--Q1) Who is the senior most employee based on job title?

Select 
	* 
from Employee 
order by levels desc 
limit 1;

--Q2) Which country has the most invoices?

Select
	billing_country,
	count(*) as No_of_Invoices
from Invoice
group by billing_country
order by No_of_Invoices desc
LIMIT 1;

--Q3) What are top 3 values of total invoice?

Select 
	total 
from invoice 
order by total desc 
limit 3;

/*
-- Q4) Which city has the best customers? 
We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name and sum of all invoice totals.
*/
Select 
	billing_city, 
	sum(total) as Revenue_generated 
from invoice 
group by billing_city 
order by Revenue_generated desc 
limit 1;

/* Q5)
Who is the best customer? 
The customer who has spent the most money will be declared the best customer.
Write a query that returns the person who has spent the most money. 
*/
with best_customer as (
    select 
        customer_id, 
        sum(total) as Money_Spent 
    from invoice 
    group by customer_id
)
select
    a.customer_id,
    c.first_name, 
	c.last_name, 
    Money_Spent 
from best_customer a 
join customer c USING (customer_id) 
order by Money_Spent desc
limit 1;

--

/*
Q6) Write query to return the email, first name, last name, & Genre of all Rock Music Listeners.
Return your list ordered alphabetically by email starting with A
*/

WITH genreFetch AS (
    SELECT track_id
    FROM track
    JOIN genre ON genre.genre_id = track.genre_id
    WHERE genre.name LIKE 'Rock'
),
invoiceFetch AS (
    SELECT DISTINCT invoice_id
    FROM invoice_line
    JOIN genreFetch USING (track_id)
)
SELECT distinct first_name, last_name, email
FROM customer
JOIN invoice inv USING (customer_id)
JOIN invoice_line invl ON inv.invoice_id = invl.invoice_id order by email;

/*
Q7) Let's invite the artists who have written the most rock music in our dataset.
Write a query that returns the artist name and total track count of the top 10 rock bands.
*/

With rockTracks as (
SELECT album_id
FROM track t
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name LIKE 'Rock'
),

artistFilter as (
Select artist_id 
from album alb
join rockTracks rt 
on alb.album_id = rt.album_id
)

Select 
art.artist_id,
name,
count(art.artist_id) as no_of_songs 
from artist art 
join artistFilter artf
on art.artist_id = artf.artist_id
group by name,art.artist_id
order by no_of_songs desc
limit 10;

/*
Q8) Return all the track names that have a song length longer than the average song length.
Return the name and milliseconds for each track.
Order by the song length with the longest songs listed first
*/

Select 
name, 
milliseconds 
from track 
where milliseconds > (select avg(milliseconds) from track) 
order by milliseconds desc;

/*
Q9) Find how much amount spent by each customer on artist?
Write a query to return customer name, artist name and total spent.
*/

With artistTracks as (
Select 
track_id,
art.name
from track t
join album a
on a.album_id = t.album_id
join artist art
on art.artist_id = a.artist_id 	
),

artistTotal as (
Select 
art.name, 
SUM(invl.unit_price * invl.quantity) as total, 
customer_id
from invoice inv
join invoice_line invl
on invl.invoice_id = inv.invoice_id
join artistTracks art
on art.track_id = invl.track_id
group by art.name, customer_id
)

Select 
first_name, 
last_name, 
art.name as artist_name, 
art.total as amount_spent
from customer c
join artistTotal art
on art.customer_id = c.customer_id
order by amount_spent desc ;

/*
Q10) We want to find out the most popular music Genre for each country.
We determine the most popular genre with the highest amount of purchases.
Write a query that returns each country along with the top Genre.
For Countries where the maximum number of purchases iis shared return all Genres.
*/

With popular_genre as (
Select 
g.name,
g.genre_id,
c.country,
count(invl.quantity) as purchases,
Row_Number() over(PARTITION BY c.country ORDER BY count(invl.quantity) Desc) as RowNo
from invoice_line invl
join invoice inv
on inv.invoice_id = invl.invoice_id
join customer c
on c.customer_id = inv.customer_id
join track t 
on t.track_id = invl.track_id
join genre g
on g.genre_id = t.genre_id
group by g.name, g.genre_id, c.country
order by  c.country asc
)

Select * from popular_genre where RowNo <= 1;

/*
Q11) Write a query that determines the customer that has spent the most on music for each country.
Write a query that returns the country along with the top customer and how much they spent.
For countries where the top amount is shared, provide all custosmer who spent this amount. 
*/

With countryWiseRank as  
(Select c.country,
c.first_name, 
c.last_name, 
sum(inv.total) as amountspent, 
Rank() over(partition by c.country order by sum(inv.total) desc) as rank 
from customer c join invoice inv on inv.customer_id = c.customer_id
group by c.country, c.first_name, c.last_name
order by c.country)
Select * from countryWiseRank where rank<=1 order by country;