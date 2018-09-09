function StuOLA_student = sEADAM(nstudent, nschool, qs, ...
    studentList, schoolList, studentRank, schoolRank, consent)
% INPUT: instance size, qutoa, preference list, and rank list
% OUTPUT: each student's assignment by Kesten's EADAM Mechanism 
%         [When all students consent, the Student Optimal Legal Assignment (StuOLA)
% PROCEDURE: simplified EADAM
% REFERENCE: Tang, Qianfeng, and Jingsheng Yu. 
%            "A new perspective on Kesten's school choice with consent idea." 
%            Journal of Economic Theory 154 (2014): 543-561.

while (1)
    % Iteratively re-run Gale-Shapley
    [StuOSA_student, ess_underdemand] = sEADAM_GS(nstudent, ...
        nschool, qs, studentList, schoolList, schoolRank);
    
    if length(ess_underdemand) == nschool 
        break;
    end
    
    % When some students are not assigned
    for student = 1:nstudent
        if StuOSA_student(student) > 0
            continue;
        end
        % consider consenting behaviors
        if ~consent(student)
            for school_preferred = studentList(student, :)
                if school_preferred == 0
                    continue;
                end
                for student_denied = schoolList(school_preferred, ...
                            schoolRank(school_preferred, student)+1:end)
                    studentList(student_denied, studentRank(...
                        student_denied, school_preferred)) = 0;
                end
            end
        end
        studentList(student,:) = 0;
    end
    
    % Loop through underdemanded schools and fix assignments & remove edges
    for school = ess_underdemand
        for student = 1:nstudent
            if StuOSA_student(student)~= school
                continue;
            end
            % consider consenting behaviors
            if ~consent(student)
                for school_preferred = studentList(student, ...
                        1:studentRank(student, school)-1)
                    if school_preferred == 0
                        continue;
                    end
                    for student_denied = schoolList(school_preferred, ...
                                schoolRank(school_preferred, student)+1:end)
                        if studentRank(student_denied, school_preferred)==0
                            continue;
                        end
                        if studentRank(student_denied, school_preferred) == 0
                          continue;
                        end
                        studentList(student_denied, studentRank(...
                            student_denied, school_preferred)) = 0;
                    end
                end
            end
            studentList(student, studentList(student,:)~=school) = 0;
        end
    end
end

%% OUTPUT
StuOLA_student = StuOSA_student;

end

