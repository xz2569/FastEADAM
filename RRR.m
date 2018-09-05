function StuOLA_student = RRR(nstudent, nschool, studentList, schoolList, ...
    studentRank, StuOSA_student, StuOSA_school_last, consent)
% INPUT: instance size, preference list, rank list, output from GS, consenting list
% OUTPUT: each student's assignment by Kesten's EADAM Mechanism 
%         [When all students consent, the Student Optimal Legal Assignment (StuOLA)
% PROCEDURE: Reverse Rotate-Remove 
% REFERENCE: Yuri Faenza & Xuan Zhang, 
%            "Legal Assignments and fast EADAM with consent via classical theory of stable matchings"

%% Position at preference list when looking for next s_M(school)
pos_sch = StuOSA_school_last;

%% Position of student that schools are currently matched to
match_pos_sch_last = pos_sch;

%% Position of school that students are currently matched to
match_pos_stu = zeros(1, nstudent);
for i = 1:nstudent
    if StuOSA_student(i)==0; continue; end
    match_pos_stu(i) = studentRank(i, StuOSA_student(i));
end

%% Set up double linked list for cycle identification
numNodes = 0;
isSink = zeros(1, nschool);   isSink(StuOSA_school_last==0) = 1;
onPath = zeros(1, nschool);

%% Main Rotate-and-Remove Algorithm [Fast-implementation]
while numNodes > 0 || sum(isSink) < nschool
    %% if linked list empty, add a non-sink node
    if numNodes == 0
        i = 1; while isSink(i); i=i+1; end
        tail = dlnode(i);
        numNodes = 1;
        onPath(i) = 1;
    end
    
    %% Start growing the list - first find s^*_M()
    pos_sch(tail.Data) = pos_sch(tail.Data) + 1;
    while pos_sch(tail.Data) <= nstudent && ...
            (schoolList(tail.Data, pos_sch(tail.Data)) == 0 || ...
            match_pos_stu(schoolList(tail.Data, pos_sch(tail.Data))) ==0 || ...
            isSink(studentList( schoolList(tail.Data, pos_sch(tail.Data)), ...
                match_pos_stu(schoolList(tail.Data, pos_sch(tail.Data)))) ) || ...
            studentRank( schoolList(tail.Data, pos_sch(tail.Data)), tail.Data ) >= ...
                match_pos_stu(schoolList(tail.Data, pos_sch(tail.Data))))
        
        %% Position is 0
        if schoolList(tail.Data, pos_sch(tail.Data)) == 0
            pos_sch(tail.Data) = pos_sch(tail.Data) + 1; 
            continue;
        end
        
        %% s_m(school) is unmatched and not consenting
        if match_pos_stu(schoolList(tail.Data, pos_sch(tail.Data))) == 0 
            if ~consent(schoolList(tail.Data, pos_sch(tail.Data)))
                pos_sch(tail.Data) = nstudent + 1;
            else
                pos_sch(tail.Data) = pos_sch(tail.Data) + 1; 
            end
            continue;
        end
        
        %% Pointing to Sink but not consenting
        if isSink(studentList(schoolList(tail.Data, pos_sch(tail.Data)), ...
                match_pos_stu(schoolList(tail.Data, pos_sch(tail.Data))))) && ...
                ~consent(schoolList(tail.Data, pos_sch(tail.Data))) && ...
                studentRank( schoolList(tail.Data, pos_sch(tail.Data)), tail.Data ) < ...
                match_pos_stu(schoolList(tail.Data, pos_sch(tail.Data)))
            pos_sch(tail.Data) = nstudent + 1;
            continue;
        end
        pos_sch(tail.Data) = pos_sch(tail.Data) + 1; 
    end
    
    %% this is a sink: remove it and mark previous one per consent
    if pos_sch(tail.Data) > nstudent  
        isSink(tail.Data) = 1;
        onPath(tail.Data) = 0;
        numNodes = numNodes - 1;
        tail = tail.Prev;
        if numNodes == 0
            continue;
        end
        if consent(schoolList(tail.Data, pos_sch(tail.Data)))
            continue;
        else
            isSink(tail.Data) = 1;
            pos_sch(tail.Data) = nstudent;
        end
        continue;
    end
    
    %% If pointing to a sink
    student_point_to = schoolList(tail.Data, pos_sch(tail.Data));
    if isSink(studentList(student_point_to, match_pos_stu(student_point_to)))
        if consent(student_point_to)
            continue;
        else
            isSink(tail.Data) = 1;
            pos_sch(tail.Data) = nstudent;
            continue;
        end
    end
    
    %% Add the next node to graph if it is not already on path
    stu = schoolList(tail.Data, pos_sch(tail.Data));
    next_sch = studentList(stu, match_pos_stu(stu));
    if ~onPath(next_sch)
        dlnode(next_sch).insertAfter(tail);
        tail = tail.Next;
        onPath(next_sch) = 1;
        numNodes = numNodes + 1;
        continue;
    end
    
    %% If already on path, it is a cycle, and we need to rotate
    while tail.Data ~= next_sch
        stu = schoolList(tail.Data, pos_sch(tail.Data));
        
        % update match info for the school
        match_pos_sch_last(tail.Data) = pos_sch(tail.Data);
        
        % update match info for the student
        match_pos_stu(stu) = studentRank(stu, tail.Data);
        
        % Update linked list
        onPath(tail.Data) = 0;
        tail = tail.Prev;
        delete(tail.Next);
        numNodes = numNodes - 1;
    end
    
    % Handle the last arc in the cycle
    stu = schoolList(tail.Data, pos_sch(tail.Data));
    match_pos_sch_last(tail.Data) = pos_sch(tail.Data);
    match_pos_stu(stu) = studentRank(stu, tail.Data);
    
    onPath(tail.Data) = 0;
    if isempty(tail.Prev)
        delete(tail);
    else
        tail = tail.Prev;
        delete(tail.Next);
        pos_sch(tail.Data) = pos_sch(tail.Data) - 1;    % special case
    end
    numNodes = numNodes - 1;
end

%% OUTPUT
StuOLA_student = zeros(1, nstudent);
for i = 1:nstudent
    if match_pos_stu(i)==0; continue; end
    StuOLA_student(i) = studentList(i, match_pos_stu(i));
end

end