function [StuOSA_student, interr_pairs] = EADAM_GS(nstudent, nschool, ...
    qs, studentList, schoolList, schoolRank)
% INPUT: instance size, qutoa, preference list, and rank list
% PROCEDURE: perform student-proposing GS to get student-optimal stable assignment (StuOSA)
%            record interrupting pairs in order
% RETURN: StuOSA_student is the assignment of each student in StuOSA 
%         interr_pairs is a list of interrupting pairs in order
% NOTE: compare to GS
% REFERENCE: Kesten, Onur. "School choice with consent." 
%            The Quarterly Journal of Economics 125.3 (2010): 1297-1348.

%% Initialize everybody's partner to be NULL
studentCurAssign = zeros(1, nstudent);      % id
studentLastPropInd = zeros(1, nstudent);    % index
schoolCurAssign_bool = zeros(nschool, nstudent);    % indicator
schoolCurAssign_last = zeros(1, nschool);   % index
schoolCurAssign_num = zeros(1, nschool);    % count
stillCanPropse = true;

%% For EADAM interruption record
interr_pairs = {};
student_interrupting_before = zeros(1,nstudent);
step  = 1;

%% GS Steps
while stillCanPropse
    stillCanPropse = false;
    school_rejects_this_step = cell(1,nschool);
    school_reject_this_step = zeros(1,nschool); % indicator array
    count = 1;
    
    students_can_propose = [];
    for student = 1:nstudent
        %% Already have a school assigned
        if studentCurAssign(student)>0
            continue;
        end    
        students_can_propose = [students_can_propose, student];
    end
    
    for student = students_can_propose
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
            
            school_reject_this_step(school_toProp) = 1;
            school_rejects_this_step{school_toProp} = [...
                school_rejects_this_step{school_toProp}, herLast];
            
        else % school reject the new one
            school_reject_this_step(school_toProp) = 1;
            school_rejects_this_step{school_toProp} = [...
                school_rejects_this_step{school_toProp}, student];
        end
    end
    
    for student_in_school = 1:nstudent
        if studentCurAssign(student_in_school) == 0
            continue;
        end
        if school_reject_this_step(studentCurAssign(student_in_school))
            student_interrupting_before(student_in_school) = studentCurAssign(student_in_school);
        end
    end
    
    % update interrupting pairs and interrupting status
    for school = 1:nschool
        if ~school_reject_this_step(school)
            continue;
        end
        students_rejected_by_school = school_rejects_this_step{school};
        for student = students_rejected_by_school
            if student_interrupting_before(student)
                interr_pairs{step}{count} = [student, student_interrupting_before(student)];
                count = count + 1;
                student_interrupting_before(student) = 0;
            end
        end
    end
    
    step = step + 1;
end

%% OUTPUT
StuOSA_student = studentCurAssign;
end