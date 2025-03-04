use election_files;

-- Data cleaning

update constituency_wise_results_2014
set  state = "Telangana"
where pc_name in ('Adilabad ','Hyderabad','Warangal');

select * from constituency_wise_results_2014;

-- Primary analysis
-- Top 5 and Bottom 5 constitency interms of voter ratio for 2014,2019

select pc_name as Constituency, concat(round(((total_votes/total_electors) * 100),2),'%')as Turnout_ratio
from constituency_wise_results_2014
order by Turnout_ratio desc
limit 5;

select pc_name as Constituency, concat(round(((total_votes/total_electors) * 100),2),'%')as Turnout_ratio
from constituency_wise_results_2014
order by Turnout_ratio 
limit 5;

select pc_name as Constituency, concat(round(((total_votes/total_electors) * 100),2),'%')as Turnout_ratio
from constituency_wise_results_2019
order by Turnout_ratio desc
limit 5;

select pc_name as Constituency, concat(round(((total_votes/total_electors) * 100),2),'%')as Turnout_ratio
from constituency_wise_results_2019
order by Turnout_ratio 
limit 5;

-- Top and Bottom 5 states in erms of turnout ratio

select state, concat(round(((total_votes/total_electors) * 100),2),'%')as Turnout_ratio
from constituency_wise_results_2014
order by Turnout_ratio desc
limit 5;

select state, concat(round(((total_votes/total_electors) * 100),2),'%')as Turnout_ratio
from constituency_wise_results_2014
order by Turnout_ratio 
limit 5;

select state, concat(round(((total_votes/total_electors) * 100),2),'%')as Turnout_ratio
from constituency_wise_results_2019
order by Turnout_ratio desc
limit 5;

select state, concat(round(((total_votes/total_electors) * 100),2),'%')as Turnout_ratio
from constituency_wise_results_2019
order by Turnout_ratio 
limit 5;

-- Constituency have elected same party on both elections

select e1.state,e1.pc_name,e1.party as winning_2014, e2.party as winning_2019
from
( select state, pc_name, party, total_votes, rank() over (partition by state, pc_name order by total_votes desc) as rnk1
from constituency_wise_results_2014) as e1
join
( select state, pc_name, party, total_votes, rank() over (partition by state, pc_name order by total_votes desc) as rnk2
from constituency_wise_results_2019) as e2
on e1.state = e2.state and e1.pc_name = e2.pc_name and e1.party = e2.party
where e1.rnk1 = 1 and e2.rnk2 =1;

-- Constituency elected differnt parties on both elections

select e1.state,e1.pc_name,e1.party as winning_2014, e2.party as winning_2019, e1.total_votes as votes_2014, e2.total_votes as total_2019, abs((e1.total_votes - e2.total_votes)) as diff
from
( select state, pc_name, party, total_votes, rank() over (partition by state, pc_name order by total_votes desc) as rnk1
from constituency_wise_results_2014) as e1
join
( select state, pc_name, party, total_votes, rank() over (partition by state, pc_name order by total_votes desc) as rnk2
from constituency_wise_results_2019) as e2
on e1.state = e2.state and e1.pc_name = e2.pc_name and e1.party <> e2.party
where e1.rnk1 = 1 and e2.rnk2 =1
order by diff desc
limit 10;

-- Top 5 candidates with high margin win in 2014 and 2019

with cte1 as (select pc_name, candidate, max(total_votes) as votes, rank() over (partition by pc_name order by max(total_votes) desc) as rnk
from constituency_wise_results_2014
group by pc_name, candidate) , 
cte2 as (select pc_name, candidate, votes , rnk, (votes - lead(votes,1,0) over (partition by pc_name)) as margin
from cte1)

select pc_name, candidate, votes, margin
from cte2
where rnk = 1
order by margin desc
limit 5;

with cte1 as (select pc_name, candidate, max(total_votes) as votes, rank() over (partition by pc_name order by max(total_votes) desc) as rnk
from constituency_wise_results_2019
group by pc_name, candidate) , 
cte2 as (select pc_name, candidate, votes , rnk, (votes - lead(votes,1,0) over (partition by pc_name)) as margin
from cte1)

select pc_name, candidate, votes, margin
from cte2
where rnk = 1
order by margin desc
limit 5;

-- split of votes of parties between 2014 and 2019 at nationl level

select party , concat(round((sum(total_votes)  /
(select sum(pop) as grand_total from (select distinct state, total_electors as pop from constituency_wise_results_2014) as tab))* 100 ,2),'%') as vote_share_2014
from constituency_wise_results_2014
group by party
order by vote_share_2014 desc;

select party , concat(round((sum(total_votes)  /
(select sum(pop) as grand_total from (select distinct state, total_electors as pop from constituency_wise_results_2019) as tab))* 100 ,2),'%') as vote_share_2019
from constituency_wise_results_2019
group by party
order by vote_share_2019 desc;

-- split of votes of parties between 2014 and 2019 at state level
 
 select state , concat(round((sum(total_votes)  /
(select sum(pop) as grand_total from (select distinct state, total_electors as pop from constituency_wise_results_2014) as tab))* 100 ,2),'%') as vote_share_2014
from constituency_wise_results_2014
group by state
order by vote_share_2014 desc;
 
 select state , concat(round((sum(total_votes)  /
(select sum(pop) as grand_total from (select distinct state, total_electors as pop from constituency_wise_results_2019) as tab))* 100 ,2),'%') as vote_share_2019
from constituency_wise_results_2019
group by state
order by vote_share_2019 desc;
 
 -- constituency with vote gain among two major parties between 2014 and 2019
 
 select c1.pc_name , (sum(c1.total_votes) - sum(c2.total_votes)) as vote_gain
 from constituency_wise_results_2014 c1
 join constituency_wise_results_2019 c2
 on c1.pc_name = c2.pc_name and c1.party = c2.party
 where c1.party = 'BJP'
 group by c1.pc_name
 order by vote_gain desc
 limit 5;
 
 select c1.pc_name , (sum(c1.total_votes) - sum(c2.total_votes)) as vote_gain
 from constituency_wise_results_2014 c1
 join constituency_wise_results_2019 c2
 on c1.pc_name = c2.pc_name and c1.party = c2.party
 where c1.party = 'INC'
 group by c1.pc_name
 order by vote_gain desc
 limit 5;
 
 -- Vote loss among parties
 
 select c1.pc_name , (sum(c1.total_votes) - sum(c2.total_votes)) as vote_gain
 from constituency_wise_results_2014 c1
 join constituency_wise_results_2019 c2
 on c1.pc_name = c2.pc_name and c1.party = c2.party
 where c1.party = 'BJP'
 group by c1.pc_name
 order by vote_gain
 limit 5;
 
 select c1.pc_name , (sum(c1.total_votes) - sum(c2.total_votes)) as vote_gain
 from constituency_wise_results_2014 c1
 join constituency_wise_results_2019 c2
 on c1.pc_name = c2.pc_name and c1.party = c2.party
 where c1.party = 'INC'
 group by c1.pc_name
 order by vote_gain 
 limit 5;
 
 -- CONSTITUENCY VOTE diff top5
 
 select c1.pc_name, (c1.total_electors - c2.total) as nota
 from
 (select distinct pc_name, total_electors
 from constituency_wise_results_2014) as c1
 join
 (select pc_name, sum(total_votes) as total
 from constituency_wise_results_2014
 group by pc_name) as c2
 on c1.pc_name = c2.pc_name
 order by nota desc
 limit 5;
 
 select c1.pc_name, (c1.total_electors - c2.total) as nota
 from
 (select distinct pc_name, total_electors
 from constituency_wise_results_2019) as c1
 join
 (select pc_name, sum(total_votes) as total
 from constituency_wise_results_2019
 group by pc_name) as c2
 on c1.pc_name = c2.pc_name
 order by nota desc
 limit 5;
