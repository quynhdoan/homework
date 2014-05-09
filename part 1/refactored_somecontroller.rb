class SomeController < ApplicationController
    def show_candidates
        @open_jobs      = Job.all_open_new(current_user.organization)
        @candidates     = []

        # sort order string to match
        @view_all       = "All Candidates"
        @view_desc      = "Candidates Newest -> Oldest"
        @view_asc       = "Candidates Oldest -> Newest"
        @view_a_to_z    = "Candidates A -> Z"
        @view_z_to_a    = "Candidates Z -> A"

        # blocks for Array#sort
        created_at_asc  = lambda { |c, d| c.created_at <=> d.created_at }
        created_at_desc = lambda { |c, d| d.created_at <=> c.created_at }

        a_to_z = lambda { |a, b| a.last_name <=> b.last_name }
        z_to_a = lambda { |a, b| b.last_name <=> a.last_name }

        # hash conditions for queries
        all_candidates      = {:is_deleted => false, :is_completed => true}
        all_candidates_asc  = all_candidates.merge( {:order => [:created_at.asc]} )
        all_candidates_desc = all_candidates.merge( {:order => [:created_at.desc]} )
        current_candidates  = current_user.organization.candidates

        if current_user.has_permission?('view_candidates')
            @candidates = sort_candidates(sort_order, current_candidates, a_to_z, z_to_a)
        else
            @candidates = view_candidates_by_jobs
            @candidates = sort_for_candidate_jobs(sort_order, a_to_z, z_to_a)
        end

        render :partial => "candidates_list", :locals => { :@candidates => @candidates, :open_jobs => @open_jobs }, :layout => false
    end

    def sort_order
        params[:sort].blank? ? @view_all : params[:sort]
    end

    def sort_candidates(sort_key, current_candidates, a_to_z, z_to_a)
        case sort_key
        when @view_all
            current_candidates.where(all_candidates)
        when @view_desc
            current_candidates.where(all_candidates_desc)
        when @view_asc
            current_candidates.where(all_candidates_asc)
        when @view_a_to_z
            current_candidates.where(all_candidates_asc).sort! { &a_to_z }
        when @view_z_to_a
            current_candidates.where(all_candidates_asc).sort! { &z_to_a }
        end
    end

    def sort_for_candidate_jobs(sort_key, @candidates, a_to_z, z_to_a)
        case sort_key
        when @view_desc
            @candidates.sort_by { &created_at_desc }
        when @view_asc
            @candidates.sort_by { &created_at_asc }
        when @view_a_to_z
            @candidates.sort_by { &created_at_asc }.sort! { &a_to_z }
        when @view_z_to_a
            @candidates.sort_by { &created_at_asc }.sort! { &z_to_a }
        end
    end

    def view_candidates_by_jobs
        @job_contacts   = JobContact.where(:user_id => current_user.id)
        jobs            = []

        unless @job_contacts.blank?
            have_job_contacts(jobs, @job_contacts)
        end
    end

    def have_job_contacts(jobs, @job_contacts)
        @job_contacts.each do |contact|
            job_item = Job.first(:id => contact.job_id, :is_deleted => false)
            jobs << job_item
        end
        jobs.each do |job|
            unless job.blank?
                have_jobs(job)
            end
        end
    end

    def have_jobs(job)
        candidate_jobs = CandidateJob.where(:job_id => job.id)
        unless candidate_jobs.blank?
            have_candidate_jobs(candidate_jobs)
        end
    end

    def have_candidate_jobs(candidate_jobs)
        candidate_jobs.each do |cj|
            candidate = cj.candidate
            found = is_candidate_already_included?(candidate) if is_candidate_available?(candidate)
            @candidates << candidate if found == false
        end
    end

    def is_candidate_available?(candidate)
        candidate.is_deleted == false
            && candidate.is_completed == true
                && candidate.organization_id == current_user.organization_id
    end

    def is_candidate_already_included?(candidate)
        @candidates.any? { |cand| cand.email_address == candidate.email_address }
    end
end