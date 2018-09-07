%% Instance Size and Quota
quota = floor(nstudent/nschool) + 1;
qs = randi([ceil(quota/2), ceil(quota/2*3)], 1, nschool);

%% Uncomment below for one-to-one case
% qs = ones(1, nschool);

%% Preference List
[studentList, schoolList] = randPreferenceList(nstudent, nschool);

%% Rank List
[studentRank, schoolRank] = preferenceList2rankList(studentList, schoolList);
