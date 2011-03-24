require "nokogiri"

module HtmlParseHelper
  
  def scrape_district_info(response_body)
    jobs_by_district = {}
    
    # For testing:
    #html = Nokogiri::HTML(File.open("/Users/jobluz/projects/rails/resources/freesubjobs/test/jobs2.html"))
    #html = Nokogiri::HTML(File.open("/Users/jobluz/projects/rails/resources/fsj_1.0/html/job_list.html"))
    #html = Nokogiri::HTML(File.open("/Users/jobluz/projects/rails/resources/fsj_1.0/html/job_list2.html"))
    #html = Nokogiri::HTML(File.open("/Users/jobluz/projects/rails/resources/fsj_1.0/html/job_list_multi.html"))
    
    # For live site use:
    html = Nokogiri::HTML(response_body)
    
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
      assignments = []
      assignments_details.each_with_index do |job, i|
        job.xpath(".//tr").each_with_index do |day, index|
          #if index > 1
          #  #assignments << create_assignment(day)
          #  assign_date = html.xpath("./td[2]").text.strip.slice(/(.*)\s/)
          #  duration = html.xpath("./td[5]").text.strip
          #  assign_school = html.xpath("./td[6]").text.strip
          #  jobs_list[i].Assignment.new(assign_school, duration, assign_date)
          #end
          #jobs_list[i].assignments = assignments
          
          #get the details table html
          details_table = jobs_info.xpath(".//tr[#{next_tr_index(i)}]/td[@colspan='9']/table/tr")
          jobs_list[i].details = scrape_job_details(details_table)
        end
      end
      
    end
    jobs_list
  end
  
  # Compute the index number of the correct tr element for the job details table.
  def next_tr_index(index)
    2*(index+1)+1
  end
  
  #def create_assignment(html)
  #  assign_date = html.xpath("./td[2]").text.strip.slice(/(.*)\s/)
  #  duration = html.xpath("./td[5]").text.strip
  #  assign_school = html.xpath("./td[6]").text.strip
  #  Assignment.new(assign_school, duration, assign_date)
  #end
  
  #loop through all of the top section details, create job objects, add to job_list
  #cannot return nil
  def create_jobs_for_dist(jobs_details)
    jobs_list = []
    jobs_details.each do |job|
        j = Job.new()
        j.date = job.xpath("./td")[0].text.strip #convert to date object
        j.school = job.xpath("./td")[1].text.strip
        j.teacher = job.xpath("./td")[2].text.strip
        j.subject = job.xpath("./td")[3].text.strip
        j.absr_id = job.xpath("./td/a")[0]['href'].slice(/\d+/)
        jobs_list << j
    end
    jobs_list
  end
  
  def scrape_job_details(job_details_from_aesop)
    new_details_table = ""
    job_details_from_aesop.each_with_index do |day, i|
      unless i == 0
        day_details = day.xpath(".//td")
        date = day_details[1].text
        start_time  = day_details[2].text
        end_time = day_details[3].text
        duration = day_details[4].text
        schoole = day_details[5].text
        new_details_table += "<tr>" +
                                "<td>#{date}</td>" +
                                "<td>#{start_time}</td>" +
                                "<td>#{end_time}</td>" +
                                "<td>#{duration}</td" +
                                "<td>#{schoole}</td>" +
                                "</tr>"
      end
    end
    new_details_table 
  end
  
  def has_jobs?(html)
    html.xpath(".//span[@class = 'error']").empty?
  end
  
  def get_details_for_accepet(response_body)
    details = {}
    html = Nokogiri::HTML(response_body)
    details[:hcc] = html.xpath(".//form[@action = 'sub_accept_job.asp']/input[@id = 'hcc']").attr("value").value
    table_rows = html.css("table.tablethinsmoke tr[bgcolor = 'whitesmoke']")
    table_rows.each_with_index do |row, index|
      if ((index+1) > table_rows.count) && (index != (table_rows.count-1))
        details[:teacher] = row.xpath(".//td")[1].text
        details[:title] = row.xpath(".//td")[2].text
        details[:room] = row.xpath(".//td")[3].text
        details[:phone] = row.xpath(".//td")[4].text
        details[:date] = row.xpath(".//td")[5].text
        details[:time] = row.xpath(".//td")[6].text
        details[:duration] = row.xpath(".//td")[7].text
      end
    end
    details[:notes] = table_rows[table_rows.count-1].xpath(".//td")[0].text
    details
  end
  
  def get_details_for_reject(response_body)
    html = Nokogiri::HTML(response_body)
    html.xpath(".//form[@action = 'sub_accept_job.asp']/input[@id = 'hcc']").attr("value").value
    
  end
  
end