% This file illustrate how to use our scripts to obtain assignment
% output of Gale-Shapley, Kesten's EADAM, simiplified EADAM, 
% and our Reverse Rotate-Remove Algorithm

%% Define instance size
nstudent = 100;
nschool = 10;

%% Randomly generate instance. Change this file for customization
setup_instance;

%% Randomly generate consenting student
% consent = ones(1,nstudent)   % uncomment this for all students consenting
% consent = rand(1, nstudent) <= 0.7;   % 70% chance of consenting
consent = rand(1, nstudent) <= 0.3;   % 30% chance of consenting

%% 1. Gale-Shapley
[StuOSA_student, StuOSA_school_bool, StuOSA_school_last] = GS(nstudent, nschool, qs, studentList, schoolList, schoolRank);

%% 2. Reverse Rotate-Remove [!requires output from GS]
if nstudent > 500
    set(0,'RecursionLimit',nstudent);
end
StuOLA_student_RRR = RRR(nstudent, nschool, studentList, schoolList, studentRank, StuOSA_student, StuOSA_school_last, consent);

%% 3. Simplified EADAM
StuOLA_student_sEADAM = sEADAM(nstudent, nschool, qs, studentList, schoolList, studentRank, schoolRank, consent);

%% 4. Kesten's EADAM
StuOLA_student_EADAM = EADAM(nstudent, nschool, qs, studentList, schoolList, studentRank, schoolRank, consent);

%% Equivalence (should be 0)
fprintf('number of discrepancy is: %d\n', sum(StuOLA_student_RRR ~= ...
    StuOLA_student_sEADAM) + sum(StuOLA_student_RRR ~= StuOLA_student_EADAM));

