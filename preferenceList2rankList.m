function [studentRank, schoolRank] = preferenceList2rankList(studentList, schoolList)
% INPUT: preference list
% OUTPUT: rank list (position on preference list)
% EXAMPLE: m's preference list is [1 4 2 5 3]; his rank list is [1 3 5 2 4]
%          incomplete preference list [1 4 2 0 0]; rank List is [1 3 0 2 0]

nstudent = size(studentList, 1);
nschool = size(studentList, 2);

%% For Students (Students's rank of Schools)
studentRank = zeros(nstudent, nschool);
for r = 1:nstudent
    m = sum(studentList(r, :)>0);
    studentRank(r, studentList(r, studentList(r, :)~=0)) = 1:m;
end

%% For Schools
schoolRank = zeros(nschool, nstudent);
for r = 1:nschool
    m = sum(schoolList(r, :)>0);
    schoolRank(r, schoolList(r, schoolList(r, :)~=0)) = 1:m;
end

end