function StuOLA_student = EADAM(nstudent, nschool, qs, ...
    studentList, schoolList, studentRank, schoolRank, consent)
% INPUT: instance size, qutoa, preference list, and rank list
% OUTPUT: each student's assignment by Kesten's EADAM Mechanism 
%         [When all students consent, the Student Optimal Legal Assignment (StuOLA)
% PROCEDURE: Kesten's Original EADAM
% REFERENCE: Kesten, Onur. "School choice with consent." 
%            The Quarterly Journal of Economics 125.3 (2010): 1297-1348.

while (1)
    % Interatively re-run Gale-Shapley
    [StuOSA_student, interr_pairs] = EADAM_GS(nstudent, ...
        nschool, qs, studentList, schoolList, schoolRank);
    
    % find the last set of interrupting pairs
    last_index = length(interr_pairs);
    some_consented = 0;
    interr_pairs_exhausted = 0;
    while ~some_consented
        while last_index > 0 && isempty(interr_pairs{last_index})
            last_index = last_index - 1;
        end
        if last_index == 0
            interr_pairs_exhausted = 1;
            break;
        end
        last_pairs = interr_pairs{last_index};
        consent_pairs = {};
        count = 1;
        for i = 1:length(last_pairs)
            one_pair = last_pairs{i};
            if consent(one_pair(1))
                some_consented = 1;
                consent_pairs{count} = one_pair;
                count = count + 1;
            end
        end
        last_index = last_index - 1;
    end
    if interr_pairs_exhausted
        break;
    end
    
    % remove these consenting interrupting pairs
    for i = 1:length(consent_pairs)
        last_pair = consent_pairs{i};
        student = last_pair(1);
        school = last_pair(2);
        studentList(student, studentRank(student, school)) = 0;
    end
end

%% OUTPUT
StuOLA_student = StuOSA_student;

end

