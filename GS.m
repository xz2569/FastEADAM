function [StuOSA_student, StuOSA_school_bool, StuOSA_school_last] = GS(nstudent, ...
    nschool, qs, studentList, schoolList, schoolRank)
% INPUT: instance size, qutoa, preference list, and rank list
% PROCEDURE: perform student-proposing GS to get student-optimal stable assignment (StuOSA)
% RETURN: StuOSA_student is the assignment of each student in StuOSA 
%         StuOSA_school_bool is an Boolean matrix recording the assignment of each school in StuOSA
%         StuOSA_school_last is the least preferred student of each school in StuOSA
% NOTE: if man m has incomplete preference list, there could be 0s in his list
%       **** 0s could be anywhere on his list ****

%% Initialize everybody's partner to be NULL
studentCurAssign = zeros(1, nstudent);      % id
studentLastPropInd = zeros(1, nstudent);    % index
schoolCurAssign_bool = zeros(nschool, nstudent);    % indicator
schoolCurAssign_last = zeros(1, nschool);   % index
schoolCurAssign_num = zeros(1, nschool);    % count
stillCanPropse = true;

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
        schoolCurAssign_num(school_toProp);
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
    end
    studentsNoAssign = studentsNoAssignRec;
    stillCanPropse = (length(studentsNoAssign) > 0);
end

%% OUTPUT
StuOSA_student = studentCurAssign;
StuOSA_school_bool = schoolCurAssign_bool;
StuOSA_school_last = schoolCurAssign_last;

end
