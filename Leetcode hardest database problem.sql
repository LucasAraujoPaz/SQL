/* Solution:

First SELECT: select all the rows:
a) whose both client and driver are unbanned; and
b) which were requested between 2013-10-01 and 2013-10-03;

Second SELECT: select from the first SELECT the Total number of requests per day;

Third SELECT: select also from the first SELECT only the Cancelled requests per day;

Final SELECT: select from the second and third SELECT's the three days and their rates.

LEFT JOIN was needed because some day may have 0 cancellations, so we must force the table Cancelled to appear every single day through the LEFT JOIN: thus, no day will be missing.

However, the consequence is that if some day has 0 cancellations, a NULL will appear in table Cancelled, so we must handle that NULL.

That is why we use the IF function: if that day had any cancellation, we do the math; else, the rate of that day will equal 0 / total_per_day. As 0 dividided by anything else is 0, we print 0.00.
*/

WITH 
Unbanned_Requests as
(SELECT Trips.Status, Trips.Request_at as `Day` 
FROM Trips JOIN Users as U1 JOIN Users as U2
ON Trips.Client_Id = U1.Users_Id AND Trips.Driver_Id = U2.Users_Id
WHERE U1.Banned = 'No' AND U2.Banned = 'No' AND 
Trips.Request_at BETWEEN '2013-10-01' AND '2013-10-03'),

Totals as 
(SELECT `Day`, COUNT(*) as total_per_day FROM Unbanned_Requests
GROUP BY `Day`),

Cancelled as 
(SELECT `Day`, COUNT(*) cancelled_per_day FROM Unbanned_Requests
WHERE `Status` <> 'completed'
GROUP BY `Day`)

SELECT 
Totals.Day, 
IF(cancelled_per_day IS NOT NULL, ROUND(cancelled_per_day/total_per_day, 2), 0.00) 
as `Cancellation Rate`
FROM Totals LEFT JOIN Cancelled ON Totals.Day = Cancelled.Day
;
