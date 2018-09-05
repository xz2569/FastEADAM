function run_batch(iter, consent_percent)

    magic_num = 42;
    nstudents = [500:500:10000];
    nschools = [5:5:100];
    time_rec = zeros(4, length(nstudents));

    fprintf("====== ITERATION #%d ======\n", iter);
    rng(iter*magic_num);
    for i = 1:length(nstudents)
        nstudent = nstudents(i);
        nschool = nschools(i);
        fprintf(" ----- SIZE = %4d %4d -----\n", nstudent, nschool);
        %% Set up the instance
        setup_instance; 
        consent = rand(1, nstudent) <= 0.1*consent_percent; 
            
        %% MOSM [man-optimal stable matching] via GS [Gale-Shapley]
        try
            fprintf("  -- GS --");
            tic;
            [StuOSA_student, ~, StuOSA_school_last] = GS(...
                nstudent, nschool, qs, studentList, schoolList, schoolRank);
            time_MOSM_GS = toc;
        catch e %e is an MException struct
            fprintf(1,'The identifier was:\n%s',e.identifier);
            fprintf(1,'There was an error! The message was:\n%s',e.message);
            fprintf("GS hs an error. This instance skipped :(\n");
            continue;
        end

        %% MOLM by rotate-and-remove
        try
            fprintf("-- RRR --");
            if nstudent > 500
                set(0,'RecursionLimit',nstudent);
            end
            StuOLA_student_RRR = RRR(nstudent, nschool, studentList, ...
                schoolList, studentRank, StuOSA_student, ...
                StuOSA_school_last, consent);
            time_rotation = toc;
        catch e %e is an MException struct
            fprintf(1,'The identifier was:\n%s',e.identifier);
            fprintf(1,'There was an error! The message was:\n%s',e.message);
            fprintf("RRR has an error. This instance skipped :(\n");
            continue;
        end

        %% MOLM by simplified EADAM (need a special GS, defined as helper function)
        try
            fprintf("-- sEADAM --");
            tic;
            StuOLA_student_sEADAM = sEADAM(nstudent, nschool, qs, ...
                studentList, schoolList, studentRank, schoolRank, consent);
            time_sEADAM = toc;
        catch e %e is an MException struct
            fprintf(1,'The identifier was:\n%s',e.identifier);
            fprintf(1,'There was an error! The message was:\n%s',e.message);
            fprintf("sEADAM has an error. This instance skipped :(\n");
            continue;
        end

        %% MOLM by EADAM (need a special GS, defined as helper function)
        try
            fprintf("-- EADAM --\n");
            tic;
            if (nstudent * nschool) <= 5000000
                StuOLA_student_EADAM = EADAM(nstudent, nschool, qs, ...
                    studentList, schoolList, studentRank, schoolRank, consent);
            end
            time_EADAM = toc;
        catch e %e is an MException struct
            fprintf(1,'The identifier was:\n%s',e.identifier);
            fprintf(1,'There was an error! The message was:\n%s',e.message);
            fprintf("EADAM has an error. This instance skipped :(\n");
            continue;
        end

        %% Record timing
        time_rec(:, i) = [time_MOSM_GS; time_rotation; time_sEADAM; time_EADAM];
    end
    
    %% Recording and write to file
    csvwrite(['exp_results_q100_c' num2str(consent_percent) '0/time_' num2str(iter) '.csv'], time_rec);

end
