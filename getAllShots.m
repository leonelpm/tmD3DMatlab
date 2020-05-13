

allShots2016 = getShots2016;
allShots2017 = getShots2017;
allShots2018 = getShots2018;
allShots2019 = getShots2019;


tm2016 = tmShots('tm_2016.txt');
tm2017 = tmShots('tm_2017.txt');
tm2018 = tmShots('tm_2018.txt');
tm2019 = tmShots('tm_2019.txt');


ntm2016 = nonTMShots(getShots2016,tm2016);
ntm2017 = nonTMShots(getShots2017,tm2017);
ntm2018 = nonTMShots(getShots2018,tm2018);
ntm2019 = nonTMShots(getShots2019,tm2019);

