require "nokogiri"

module HtmlParseHelper
  
  def scrape_district_info(response_body)
    jobs_by_district = {}
    
    # For testing:
    #html = Nokogiri::HTML(File.open("/Users/jobluz/projects/rails/resources/freesubjobs/test/jobs2.html"))
    #html = Nokogiri::HTML(File.open("/Users/jobluz/projects/rails/resources/fsj_1.0/html/job_list.html"))
    #html = Nokogiri::HTML(File.open("/Users/jobluz/projects/rails/resources/fsj_1.0/html/job_list2.html"))
    #html = Nokogiri::HTML(File.open("/Users/jobluz/projects/rails/resources/fsj_1.0/html/job_list_multi.html"))
    html = Nokogiri::HTML(File.open('/Users/jobluz/projects/rails/resources/freesubjobs/test/jobs2_multi.html'))
    
    # For live site use:
    #html = Nokogiri::HTML(response_body)
    
    district_sections = html.css(".showjobs.homeMenuText")
    district_sections.each do |dist_html|
      district = create_district(dist_html)
      jobs_list = prefered_jobs(dist_html, district)
      jobs_by_district[district] = jobs_list unless jobs_list.empty?
    end
    jobs_by_district
  end
  
  
  def create_district(html)
    dist_info = html.css('.homemenutext').text.gsub("(Hide Jobs)", "")
    district = District.new
    district.state = dist_info.slice(/[A-Z]{2}/)
    district.county = dist_info.slice(/-\s(.*)\s-/).gsub("-", "").strip
    district.name = dist_info.slice(/-\s([^-]*)\Z/)
    district
  end
  
  #TODO: return array of prefered jobs only
  # currently returns all jobs in the district
  def prefered_jobs(dist_html, district)
    jobs_info = dist_html.xpath(".//td[@bgcolor = '#ffffff']/table") #array of jobs tables
    jobs_list = []
    
    if has_jobs?(jobs_info)
      jobs_details = jobs_info.xpath(".//tr[@bgcolor = 'gainsboro'][@align = 'center'] | .//tr[@bgcolor = 'whitesmoke'][@align = 'center']")
      jobs_list = create_jobs_for_dist(jobs_details)
      assignments_details = jobs_info.xpath(".//tr[@bgcolor = 'gainsboro']/td/table | .//tr[@bgcolor = 'whitesmoke']/td/table")
      
      #loop through all of the top section details and add to the job objects
      assignments_details.each_with_index do |job, i|
        job.xpath(".//tr").each_with_index do |day, index|
          
          #get the details table html
          details_table = jobs_info.xpath(".//tr[#{next_tr_index(i)}]/td[@colspan='9']/table/tr")
          jobs_list[i] = scrape_job_details(details_table, jobs_list[i])
        end
      end
    end
    jobs_list
  end
  
  # Compute the index number of the correct tr element for the job details table.
  def next_tr_index(index)
    2*(index+1)+1
  end
  
  #loop through all of the top section details, create job objects, add to job_list
  #cannot return nil
  def create_jobs_for_dist(jobs_details)
    job_list = []
    jobs_details.each do |job|
      j = Job.new
      assignment = Assignment.new
      assignment.school = job.xpath("./td")[1].text.strip
      assignment.teacher = job.xpath("./td")[2].text.strip
      assignment.subject = job.xpath("./td")[3].text.strip
      j.absr_id = job.xpath("./td/a")[0]['href'].slice(/\d+/)
      j.assignments << assignment
      job_list << j
    end
    job_list
  end
  
  def scrape_job_details(job_details, job)
    original_assignment = job.assignments[0]
    job_details.each_with_index do |day, i|
      unless i == 0
        assignment = Assignment.new
        day_details = day.xpath(".//td")
        assignment.date = day_details[1].text
        assignment.start_time  = day_details[2].text
        assignment.end_time = day_details[3].text
        assignment.duration = day_details[4].text
        assignment.school = original_assignment.school
        assignment.subject = original_assignment.subject
        assignment.teacher = original_assignment.teacher
        job.assignments[i-1] = assignment
      end
    end
    job
  end
  
  def has_jobs?(html)
    html.xpath(".//span[@class = 'error']").empty?
  end
  
  def get_details_for_accept(response_body)
    html = Nokogiri::HTML(response_body)
    job = Job.new
    job.hcc = html.xpath(".//form[@action = 'sub_accept_job.asp']/input[@id = 'hcc']").attr("value").value
    table_rows = html.css("table.tablethinsmoke tr")
    table_rows.each_with_index do |row, index|
      if ((index+1) < table_rows.count) && (index != (table_rows.count-1) && (index > 1))
        assignment = Assignment.new
        assignment.teacher = row.xpath(".//td")[1].text
        assignment.subject = row.xpath(".//td")[2].text
        assignment.room = row.xpath(".//td")[3].text
        assignment.phone_number = row.xpath(".//td")[4].text
        assignment.date = row.xpath(".//td")[5].text
        assignment.time = row.xpath(".//td")[6].text
        assignment.duration = row.xpath(".//td")[7].text
        job.assignments << assignment
      end
    end
    job.notes = table_rows[table_rows.count-1].xpath(".//td")[0].text
    job
  end
  
  def get_details_for_reject(response_body)
    html = Nokogiri::HTML(response_body)
    html.xpath(".//form[@action = 'sub_accept_job.asp']/input[@id = 'hcc']").attr("value").value
  end
  
end