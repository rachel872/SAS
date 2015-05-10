Options 
symbolgen 
/*mlogic mprint */
/*mprintnest */
/*mlogicnest */
/*MAUTOLOCDISPLAY */
sysrputsync=yes;

%let libdrop=ddatav;
LIBNAME &libdrop. ' C:\Users\rachel\Documents\Masters\Kaggle';
libname kag 'C:\Users\rachel\Documents\Masters\Kaggle';


proc printto log='C:\Users\rachel\Documents\Masters\Kaggle\galog1.log';
 run;



%let parmsoutput = finalparms;		*writes a permanent file of the model pool to the library above;

%let dependent=y;					* dependent variable;
%let popfile=PurchasedBefore_rn;  		* population file that has candidate variables and dependent variable;

						
%let pctrandommodels=0.08;			* for random models: percent of the candidate variables you want in each model;
							 		* 1000 variables , pctrandommodels=.04, # variables in model ~ 40;
%let pctflip=.35;					* for generation builiding: fliping percentage;
%let pctmute=.1;					* for generation builiding: mutation percentage ~ allow two or so variables to come in;
							 		* 1000 variables , pctmute=.002, ~ 2;
%let maxpredictors=15;	     		* maximum # of predictors allowed in a given model;
%let minruns=500;	 				* minimum # of iterations;
%let numbervals=12;					* the number of validation datasets;


%let intialmodelvarsnum=3;  		* the # of intial model variables that are in the "intialmodelvars" string;

* the initial model variables you would like to feed into algorithm;
%let intialmodelvars=%str(
v87
, v88
, v114


); 

* the # of candidate model variables that are in the "candidate" string;
%let candidatenum=157;
* a list of all potential model predictors;
%let candidate=%str(
, v131
, v132
, v89
, v96
, v51
, v52
, v97
, v81
, v82
, v50
, v140
, v45
, v90
, v125
, v86
, v98
, v41
, v93
, v137
, v83
, v85
, v141
, v44
, v79
, v84
, v130
, v126
, v94
, v99
, v46
, v95
, v80
, v66
, v65
, v139
, v11
, v6
, v40
, v124
, v133
, v12
, v7
, v71
, v134
, v129
, v142
, v127
, v123
, v49
, v138
, v143
, v128
, v70
, v74
, v43
, v8
, v75
, v13
, v59
, v67
, v64
, v60
, v10
, v5
, v73
, v58
, v76
, v61
, v113
, v92
, v53
, v136
, v106
, v48
, v100
, v101
, v121
, v116
, v69
, v120
, v161
, v166
, v118
, v144
, v115
, v47
, v103
, v119
, v105
, v117
, v109
, v108
, v102
, v135
, v42
, v104
, v91
, v63
, v110
, v39
, v68
, v14
, v145
, v9
, v122
, v78
, v153
, v155
, v156
, v157
, v158
, v77
, v154
, v107
, v62
, v147
, v112
, v27
, v148
, v72
, v168
, v111
, v16
, v152
, v165
, v159
, v167
, v160
, v149
, v151
, v38
, v57
, v25
, v34
, v28
, v164
, v150
, v26
, v162
, v21
, v33
, v17
, v163
, v24
, v35
, v15
, v19
, v20
, v29
, v22
, v37
, v30
, v36
, v18
, v31
, v23
, v32



);


data &popfile._val0 &popfile._val1 &popfile._val2 &popfile._val3 &popfile._val4 &popfile._val5 &popfile._val6 &popfile._val7
     &popfile._val8 &popfile._val9 &popfile._val10 &popfile._val11 &popfile._val12 ;
  set kag.&popfile ;
q=ranuni(-1);
/*mn=month(driver_dt);*/

if q<=.077 then output &popfile._val0;
else if q<=.154 then output &popfile._val1;
else if q<=.231 then output &popfile._val2;
else if q<=.308 then output &popfile._val3;
else if q<=.385 then output &popfile._val4;
else if q<=.462 then output &popfile._val5;
else if q<=.538 then output &popfile._val6;
else if q<=.615 then output &popfile._val7;
else if q<=.692 then output &popfile._val8;
else if q<=.769 then output &popfile._val9;
else if q<=.846 then output &popfile._val10;
else if q<=.923 then output &popfile._val11;
else output &popfile._val12;
drop q ;
run; 



%macro pregen;
data vardata1;
%do i=1 %to &candidatenum.;
%SCAN(&candidate.,&i.,',')=.;
%end;
run;
proc transpose data=vardata1 out=vardata2a;
run;

data vardata2a;
set vardata2a;
%do i=1 %to 39;
x&i.=RANBIN(-1,1,&pctrandommodels.);
%end;
run;
proc sort data=vardata2a;
by _name_;
run;
data vardata1_intial;
%do i=1 %to &intialmodelvarsnum.;
%SCAN(&intialmodelvars.,&i.,',')=.;
%end;
run;
proc transpose data=vardata1_intial out=vardata2b;
run;

data vardata2b;
set vardata2b;
x40=1;
%do i=41 %to 50;
x&i.=RANBIN(-1,1,.75);
%end;
run;

proc sort data=vardata2b;
by _name_;
run;

data vardata3;
/*set vardata2a;*/
merge vardata2a vardata2b;
by _name_;
run;

proc sql noprint;
%do i=1 %to 50;
select _name_ into: model&i. separated by '*'
from vardata3
where x&i. = 1;
select count(_name_) into: modelnum&i.
from vardata3
where x&i. = 1;
%end;
quit;


proc reg data=&popfile._val0 outest=intialparms noprint;
%do j=1 %to 50;
model &dependent. = %do i=1 %to &&modelnum&j.; %SCAN(&&model&j..,&i.,'*') %end;/ADJRSQ press;
%end;
run;

proc sql noprint;
select distinct _name_ into: scorevars separated by '*'
from vardata3
where 
%do i=1 %to 49;
x&i. = 1 or
%end; x50 = 1;
select count(distinct _name_) into: scorevarsnum
from vardata3
where %do i=1 %to 49;
x&i. = 1 or
%end; x50 = 1;
quit;

%do s=0 %to &numbervals.;
	proc score data=&popfile._val&s. score=intialparms out=regout&s.(keep= &dependent. 
		%do i=1 %to 50;
		model&i.
		%end;
		) predict type=parms;
	var 
		%do i=1 %to &scorevarsnum.;
		%SCAN(&scorevars.,&i.,'*')
		%end;
		;
	run;

%end;

%do s=0 %to &numbervals.;
	data regout0;
	set regout&s.;
	%do p=1 %to 50;
		resid&p.=abs((&dependent. - (model&p.+ranuni(-1)/100000)));
	%end;
	run;
						
%do p=1 %to 50;
	proc means data=regout0 sum noprint;					
	var resid&p.;
	output out=regoutb&p. sum=;
	run;
						
	data Range_val&p.;
	set regoutb&p.;
	_MODEL_ = "MODEL&p.";
	Range_val&s.=resid&p./_freq_;
	keep _MODEL_ Range_val&s.;
	run;
%end;


data Range_val_stack&s.;
length _model_ $32.;
set %do i=1 %to 50;
	Range_val&i. 
%end;
;	
run;

proc sort data=intialparms;
by _model_;
run;

proc sort data=Range_val_stack&s.;
by _model_;
run;
%end;


data intialparms;
merge %do s=0 %to &numbervals.; Range_val_stack&s.  %end; intialparms;
by _model_;
range_mean = mean( %do s=0 %to &numbervals.; Range_val&s. , %end; 0);
range_std = std(%do s=0 %to &numbervals.; Range_val&s. , %end; 0);
fitness=range_mean;
run;


proc datasets library=work nolist;
delete
	range:
	regout:
	vardata2:
	vardata3;
run;

data finalparms;
set intialparms;
run;

proc sort data=finalparms;
by fitness;
run;

data finalparms;
set finalparms;
by  fitness;
if first.fitness then flag=1;
run;

data finalparms;
set finalparms;
if flag=1;
run;


data finalparms;
set finalparms
	vardata1;
run;

options obs=50;
data finalparms;
set finalparms;
run;
options obs=max;

proc rank data=finalparms out=finalparms descending;
var Fitness;
ranks r1;
run;

data finalparms;
set finalparms;
if fitness ne .;
p=r1/1275;
run;
				
%mend pregen;
%pregen;







/*this is the genetic part of the macro*/
%macro genetic;

PROC SURVEYSELECT DATA=finalparms
	OUT=samp
	METHOD=PPS
	N=8
	NOPRINT
	;
	size p;
	id _all_;
	run;
proc datasets library=work nolist;
delete sortsize;
run;

proc transpose data=samp out=samp1;
var %do i=1 %to &candidatenum.;
%SCAN(&candidate.,&i.,',')
%end;
;
run;

data samp1;
set samp1;
col1=(col1 ne .);
col2=(col2 ne .);
col3=(col3 ne .);
col4=(col4 ne .);
col5=(col5 ne .);
col6=(col6 ne .);
col7=(col7 ne .);
col8=(col8 ne .);

flip1=(ranuni(-1)<&pctflip.);
flip2=(ranuni(-1)<&pctflip.);
mute1=RANBIN(-1,1,&pctmute.);
mute2=RANBIN(-1,1,&pctmute.);

if flip1 =1 then do;
	if col1=col2 then do;
		newcol1=col1;
		newcol2=col2;
	end;
	if col1 ne col2 then do;
		newcol1=(col1=0);
		newcol2=(col2=0);
	end;
end;

if flip1=0 then do;
	newcol1=col1;
	newcol2=col2;
end;
/*/*/*/*/*/**/*/*/*/*/*/;
if flip2 =1 then do;
	if col5=col6 then do;
		newcol5=col5;
		newcol6=col6;
	end;
	if col5 ne col6 then do;
		newcol5=(col5=0);
		newcol6=(col6=0);
	end;
end;

if flip2=0 then do;
	newcol5=col5;
	newcol6=col6;
end;
/*/*/*/*/*/**/*/*/*/*/*/;

if mute1 = 1 then do;
	if col3=1 then do;
		newcol3=0;
	end;
	if col3=0 then do;
		newcol3=1;
	end;
	if col4=1 then do;
		newcol4=0;
	end;
	if col4=0 then do;
		newcol4=1;
	end;
end;
if mute1 = 0 then do;
	newcol3=col3;
	newcol4=col4;
end;
/*/*/*/*/*/**/*/*/*/*/*/;
if mute2 = 1 then do;
	if col7=1 then do;
		newcol7=0;
	end;
	if col7=0 then do;
		newcol7=1;
	end;
	if col8=1 then do;
		newcol8=0;
	end;
	if col8=0 then do;
		newcol8=1;
	end;
end;
if mute2 = 0 then do;
	newcol7=col7;
	newcol8=col8;
end;
run;


proc sql noprint;
%do i=1 %to 8;
select _name_ into: nmodel&i. separated by '*'
from samp1
where newcol&i. = 1;
select count(_name_) into: nmodel&i._count
from samp1
where newcol&i. = 1;
%end;
quit;


proc reg data=&popfile._val0 outest=parms noprint;
%do j=1 %to 8;
model &dependent. = %do i=1 %to &&nmodel&j._count.; %SCAN(&&nmodel&j..,&i.,'*') %end;/ADJRSQ press;
%end;
run;

proc sql noprint;
select distinct _model_ into: modelname separated by '*'
from parms;
quit;


data parms;
set parms;
%do i=1 %to 8;
	if _model_ = "%SCAN(&modelname.,&i.,'*')" then _model_ = "NewModel&z.&i.";
%end;
run;

proc sql noprint;
select distinct _name_ into: scorevars separated by '*'
from samp1
where newcol1 = 1 or newcol2=1 or newcol3=1 or newcol4=1  or
	newcol5 = 1 or newcol6=1 or newcol7=1 or newcol8=1;
select count(distinct _name_) into: scorevarsnum
from samp1
where newcol1 = 1 or newcol2=1 or newcol3=1 or newcol4=1 or
	newcol5 = 1 or newcol6=1 or newcol7=1 or newcol8=1;
quit;



%do s=0 %to &numbervals.;
	proc score data=&popfile._val&s. score=parms out=regout&s.(keep= &dependent. 
	%do i=1 %to 8;
	NewModel&z.&i.
	%end;
	) predict type=parms;
	var 
	%do i=1 %to &scorevarsnum.;
		%SCAN(&scorevars.,&i.,'*')
	%end;
	;
	run;
%end;


%do s=0 %to &numbervals.;
	data regout0;
	set regout&s.;
	%do p=1 %to 8;
		resid&p.=abs((&dependent. - (NewModel&z.&p.+ranuni(-1)/100000)));
	%end;
	run;
						
	%do p=1 %to 8;
		proc means data=regout0 sum noprint;					
		var resid&p.;
		output out=regoutb&p. sum=;
		run;
						
		data Range_val&p.;
		set regoutb&p.;
		_MODEL_ = "NewModel&z.&p.";
		Range_val&s.=resid&p./_freq_;
		keep _MODEL_ Range_val&s.;
		run;
	%end;
					

	data Range_val_stack&s.;
	length _model_ $32.;
	set %do i=1 %to 8;
		Range_val&i. 
	%end;
	;	
	run;

	proc sort data=intialparms;
	by _model_;
	run;
	proc sort data=Range_val_stack&s.;
	by _model_;
	run;
%end;



data parms;
merge %do s=0 %to &numbervals.; Range_val_stack&s.  %end; parms;
by _model_;
range_mean = mean( %do s=0 %to &numbervals.; Range_val&s. , %end; 0);
range_std = std(%do s=0 %to &numbervals.; Range_val&s. , %end; 0);
fitness=range_mean;
run;


proc datasets library=work nolist;
delete
	range:
	regout:;
run;


data finalparms;
set finalparms
	parms;
run;

proc sort data=finalparms;
by  fitness;
run;

data finalparms;
set finalparms;
by  fitness;
if first.fitness then flag=1;
run;

data finalparms;
set finalparms;
if flag=1;
if fitness ne .;
if _in_ <=&maxpredictors.;
run;

options obs=50;
data finalparms;
set finalparms;
run;
options obs=max;

proc rank data=finalparms(drop=r1) out=finalparms descending ;
var fitness;
ranks r1;
run;

data finalparms;
set finalparms;
p=r1/1275;
run;
%mend genetic;



/*this is the looping controller*/

%let iter=10; *this is set initially at 10 ~ dont need to chage;
%macro loop;
%do z=&iter. %to %sysevalf(&minruns. + (&iter.-1));
%genetic;

/*proc sql noprint;*/
/*select range into: r0*/
/*from current_ranges*/
/*where group='dev_';*/
/*%do i=1 %to &numbervals.;*/
/*select range into: r&i.*/
/*from current_ranges*/
/*where group="val_&i.";*/
/*%end*/
/*quit;*/

data &libdrop..&parmsoutput.;
	set finalparms;
/*	Current_Model_Range_Dev=&r0.;*/
/*	%do i=1 %to &numbervals.;*/
/*	Current_Model_Range_Val&i.=&&r&i..;*/
/*	%end;*/
	run;

%let iter = %sysevalf(&z. + 1);
%end;


%mend loop;
%loop;


/*proc print data=finalparms;*/
/*var _model_ _in_ _adjrsq_*/
/*fitness*/
/*range_mean*/
/*range_std;*/
/*Range_dev */
/*Current_Model_Range_Dev*/
/*Range_val1*/
/*Current_Model_Range_Val1*/
/*Range_val2*/
/*Current_Model_Range_Val2*/
/*Range_val3*/
/*Current_Model_Range_Val3;*/
run;

proc printto;
run;
