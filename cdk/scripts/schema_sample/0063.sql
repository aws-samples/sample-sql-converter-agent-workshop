CREATE TABLE T_0063 (dt date, c1 number)
PARTITION BY RANGE(dt)
(partition p1_2019_q1 values less than (to_date('20190401','yyyymmdd')),
 partition p2_2019_q2 values less than (to_date('20190701','yyyymmdd')));
