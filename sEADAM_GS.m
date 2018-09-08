function [StuOSA_student, ess_underdemand] = sEADAM_GS(nstudent, nschool, ...
    qs, studentList, schoolList, schoolRank)
% INPUT: instance size, qutoa, preference list, and rank list
% PROCEDURE: perform student-proposing GS to get student-optimal stable assignment (StuOSA)
%            record essentially underdemanded schools
% RETURN: StuOSA_student is the assignment of each student in StuOSA 
%         ess_underdemand is an array of essentially underdemanded schools
% NOTE: compare to GS
% REFERENCE: Tang, Qianfeng, and Jingsheng Yu. 
%            "A new perspective on Kesten's school choice with consent idea." 
%            Journal of Economic Theory 154 (2014): 543-561.

%% Initialize everybody's partner to be NULL
studentCurAssign = zeros(1, nstudent);      % id
studentLastPropInd = zeros(1, nstudent);    % index
schoolCurAssign_bool = zeros(nschool, nstudent);    % indicator
schoolCurAssign_last = zeros(1, nschool);   % index
schoolCurAssign_num = zeros(1, nschool);    % count
stillCanPropse = true;

%% for sEADAM
school_nproposals = zeros(1, nschool);
school_proposed_by = zeros(nschool, nstudent);

%% GS Steps
studentsNoAssign = 1:nstudent;
while stillCanPropse
    studentsNoAssignRec = [];
    
    for student = studentsNoAssign
        
        %% No school yet, need to propose
        hisList = studentList(student, :);
        while studentLastPropInd(student) < nschool && hisList(studentLastPropInd(student)+1)==0
            studentLastPropInd(student) = studentLastPropInd(student)+1;
        end         % to jump past all zeros
        
        %% No more school to propose to :(
        if studentLastPropInd(student) >= nschool     % proposed to every school on the list
            continue;
        end
        
        %% can still propose
        stillCanPropse = true;
        studentLastPropInd(student) = studentLastPropInd(student)+1;
        school_toProp = hisList(studentLastPropInd(student));
        herRank = schoolRank(school_toProp, :);
        if schoolCurAssign_num(school_toProp) < qs(school_toProp)     
            % school's quota is not filled          
            schoolCurAssign_bool(school_toProp, student) = 1;
            if herRank(student) > schoolCurAssign_last(school_toProp)
                schoolCurAssign_last(school_toProp) = herRank(student);
            end
            studentCurAssign(student) = school_toProp;
            schoolCurAssign_num(school_toProp) = schoolCurAssign_num(school_toProp) + 1;
        elseif schoolCurAssign_last(school_toProp) > herRank(student)
            % school will reject previous
            herLast = schoolList(school_toProp, schoolCurAssign_last(school_toProp));
            studentCurAssign(herLast) = 0;
            schoolCurAssign_bool(school_toProp, herLast) = 0;
            schoolCurAssign_bool(school_toProp, student) = 1;
            last = schoolCurAssign_last(school_toProp);
            while (schoolCurAssign_bool(school_toProp, schoolList(school_toProp, last))==0)
                last = last - 1;
            end
            schoolCurAssign_last(school_toProp) = last;
            studentCurAssign(student) = school_toProp;
            studentsNoAssignRec = [studentsNoAssignRec herLast];
        else
            % school rejects the proposing student
            studentsNoAssignRec = [studentsNoAssignRec student];
        end
        
        %% sEADAM
        school_proposed_by(school_toProp, student) = 1;
        school_nproposals(school_toProp) = school_nproposals(school_toProp) + 1;
    end

    studentsNoAssign = studentsNoAssignRec;
    stillCanPropse = (length(studentsNoAssign) > 0);
end

%% OUTPUT
StuOSA_student = studentCurAssign;
StuOSA_school_bool = schoolCurAssign_bool;
StuOSA_school_last = schoolCurAssign_last;

%% Underdemanded Schools
ess_underdemand = [];
last_tier_num = 1;

while last_tier_num > 0
    last_tier_num = 0;
    for school = 1:nschool
        if school_nproposals(school) > qs(school) || ismember(school,ess_underdemand)
            continue;
        end
        ess_underdemand = [ess_underdemand, school];
        last_tier_num = last_tier_num + 1;
        % remove students matched to underdemanded school from others' lists
        for student = 1:nstudent
            if ~school_proposed_by(school, student)
                continue;
            end
            school_proposed_by_student = school_proposed_by(:, student)==1;
            school_nproposals(school_proposed_by_student) = ...
                school_nproposals(school_proposed_by_student) - 1;
            school_proposed_by(:, student) = zeros(nschool, 1);
        end
    end
end

end
