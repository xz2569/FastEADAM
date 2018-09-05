function [studentList, schoolList] = randPreferenceList(nstudent, nschool) 
% INPUT: instance size
% OUTPUT: randomly generated Preference List

ids = 1:nschool;
studentList = zeros(nstudent, nschool);
for i=1:nstudent
    studentList(i,:) = ids(randperm(nschool));
end

ids = 1:nstudent;
schoolList = zeros(nschool, nstudent);
for i=1:nschool
    schoolList(i,:) = ids(randperm(nstudent));
end

end
