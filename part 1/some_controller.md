Some Controller
---

**Question:**

Please take a look at this controller action. Please tell us what you think of this code and how you would make it better.

**Answer:**

The code in this controller action leaves much to be desired. The person who wrote this code very likely has a long background in procedural language (based on the amount of nested `if-else` and `unless` statements present). The code also rarely utilizes many great features of the Ruby language.

Being a very visual thinker, at first glance, all I wanted to do was to refactor this code. Nevertheless, after spending some time trying to grasp the logic flow, it became apparently to me that wihout any tests in place, refactoring is out of the question. And in order to write tests, I would also need further understanding of the related business logic. Once I'm confident that I have a firm grasp of the function of this controller, I would set up tests to verify each conditional statement. After all tests are checked and passed, I could then focus on refactoring.

From a visual standpoint, this code does a poor job of being pleasant to look at. I strongly believe that great code should be not only easy to read but also easy on the eyes. There is a very good reason why Ruby is such a joy to program in, and I'm sure being "good looking" is one of them. This code snippet, however, doesn't align with that value. Therefore, I believe an obvious first step is to reduce the amount of visual noise (repetitive code).


```ruby
if current_user.has_permission?('view_candidates')
    if s_key == "All Candidates"
        @candidates = current_user.organization.candidates.all(:is_deleted => false, :is_completed => true)
    elsif s_key == "Candidates Newest -> Oldest"
        @candidates = current_user.organization.candidates.all(:is_deleted => false, :is_completed => true, :order => [:created_at.desc])
    elsif s_key == "Candidates Oldest -> Newest"
        @candidates = current_user.organization.candidates.all(:is_deleted => false, :is_completed => true, :order => [:created_at.asc])
    elsif s_key == "Candidates A -> Z"
        @candidates = current_user.organization.candidates.all(:is_deleted => false, :is_completed => true, :order => [:created_at.asc]).sort! { |a, b| a.last_name <=> b.last_name }
    elsif s_key == "Candidates Z -> A"
        @candidates = current_user.organization.candidates.all(:is_deleted => false, :is_completed => true, :order => [:created_at.asc]).sort! { |a, b| a.last_name <=> b.last_name }.reverse
    end
else
```

The code above is very similar to the code below:

```ruby
if s_key == "Candidates Newest -> Oldest"
    @candidates = @candidates.sort_by { |c| c.created_at }
elsif s_key == "Candidates Oldest -> Newest"
    @candidates = @candidates.sort_by { |c| c.created_at }.reverse
elsif s_key == "Candidates A -> Z"
    @candidates = @candidates.sort_by { |c| c.created_at }.sort! { |a, b| a.last_name <=> b.last_name }
elsif s_key == "Candidates Z -> A"
    @candidates = @candidates.sort_by { |c| c.created_at }.sort! { |a, b| a.last_name <=> b.last_name }.reverse
end
```

The logic indicates that `s_key` is used to determine the sorting order of `@candidates`. I would however favor the use of `where` or `scope` in place of `all`. Given the fact that it might be a large query, looping through a collection of records from the database (using `all`, for instance) is very inefficient since it will try to instantiate all of the objects at once.

There are also a couple of ways I would like to improve on this (including but not limited to):

+ Use `case-when` instead of `if-else`

+ Use ID to determine the `s_key` value instead of string comparison. If not, create variables to store those keys like below.

```ruby
view_all = "All Candidates"
# etc.
case s_key
when view_all
# etc.
```

+ Create hashes to use as hash conditions.

+ Use `lambda` for block code.

```ruby
view_a_to_z = "Candidates A -> Z"
a_to_z = lambda { |a, b| a.last_name <=> b.last_name }
z_to_a = lambda { |a, b| b.last_name <=> a.last_name } # instead of calling reverse()

all_candidates = {:is_deleted => false, :is_completed => true}
all_candidates_asc = all_candidates.merge( {:order => [:created_at.asc]} )

# etc.
case s_key
# etc.
when view_a_to_z
    @candidates = current_user.organization.candidates.where(all_candidates_asc).sort! { &a_to_z }
```


To address the elephant in the room - I'd also like to pull out the blocks inside of the big `if-else` statement.

```ruby
if current_user.has_permission?('view_candidates')
    if s_key == "All Candidates"
        @candidates = current_user.organization.candidates.all(:is_deleted => false, :is_completed => true)
    elsif s_key == "Candidates Newest -> Oldest"
        @candidates = current_user.organization.candidates.all(:is_deleted => false, :is_completed => true, :order => [:created_at.desc])
    elsif s_key == "Candidates Oldest -> Newest"
        @candidates = current_user.organization.candidates.all(:is_deleted => false, :is_completed => true, :order => [:created_at.asc])
    elsif s_key == "Candidates A -> Z"
        @candidates = current_user.organization.candidates.all(:is_deleted => false, :is_completed => true, :order => [:created_at.asc]).sort! { |a, b| a.last_name <=> b.last_name }
    elsif s_key == "Candidates Z -> A"
        @candidates = current_user.organization.candidates.all(:is_deleted => false, :is_completed => true, :order => [:created_at.asc]).sort! { |a, b| a.last_name <=> b.last_name }.reverse
    end
else
```

```ruby
@job_contacts = JobContact.all(:user_id => current_user.id)
jobs          = []
@candidates   = []
unless @job_contacts.blank?
    @job_contacts.each do |jobs_contacts|
        @job = Job.first(:id => jobs_contacts.job_id, :is_deleted => false)
        jobs << @job
    end
    jobs.each do |job|
        unless job.blank?
            candidate_jobs = CandidateJob.all(:job_id => job.id)
            unless candidate_jobs.blank?
                candidate_jobs.each do |cj|
                    candidate = cj.candidate
                    if candidate.is_deleted == false && candidate.is_completed == true && candidate.organization_id == current_user.organization_id
                        found = false
                        unless @candidates.blank?
                            @candidates.each do |cand|
                                if cand.email_address == candidate.email_address
                                    found = true
                                end
                            end
                        end
                        if found == false
                            @candidates << candidate
                        end
                    end
                    if s_key == "Candidates Newest -> Oldest"
                        @candidates = @candidates.sort_by { |c| c.created_at }
                    elsif s_key == "Candidates Oldest -> Newest"
                        @candidates = @candidates.sort_by { |c| c.created_at }.reverse
                    elsif s_key == "Candidates A -> Z"
                        @candidates = @candidates.sort_by { |c| c.created_at }.sort! { |a, b| a.last_name <=> b.last_name }
                    elsif s_key == "Candidates Z -> A"
                        @candidates = @candidates.sort_by { |c| c.created_at }.sort! { |a, b| a.last_name <=> b.last_name }.reverse
                    end
                end
            end
        end
    end
end
```

These can be our beginning points, and I would keep doing that until my methods are relatively small. Once they are small, I could proceed to name the "leaves" (with the methods acting as the "trees"). The reason I prefer starting at the leaves is because they're mostly built out of primitive items. Items that come from either Ruby or Rails. Therefore, I can give them names that can reasonably reveal their intent. On the other hand, methods (trees) are built based on **ideas** that were introduced by the previous developer(s). With that said, starting at the leaves and going up the trees will allow me to eventually put things in perspective.

My general formula is to take all of the code within an `if`, `else` or `unless` and give them a method name based on their condition. This is of course, only temporary until I can make sense of the code in the "leaves". The `show_candidates` function can now be reduced to this:

```ruby
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
```

Apply this formula recursively, I ended up with a much cleaner controller action. The methods are organized in a chronological order. The rest of the snippet is included below:

```ruby
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

    def sort_for_candidate_jobs(sort_key, a_to_z, z_to_a)
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
            have_job_contacts(jobs)
        end
    end

    def have_job_contacts(jobs)
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
```

Some of the method names are not as meaningful as I would like, but I believe they do a reasonably good job at making the logic easier to follow. Comparing to what we started with, this is much more pleasant to work with. Nevertheless, there is still a lot of room for improvement if this is to become production-ready code. Under the assumptions that my tests are all green, I would further extract some of the left-over conditionals into smaller methods. My primary purpose is to make the code more readable, easier to understand and I only include comments when necessary. I also care a great deal about the visual appeal of my code. It might seem superficial but adhereing to a style structure has allowed me to spot errors simply because they look out of place.