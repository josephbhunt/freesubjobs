function toggleJobDetails(jobId){
  if( $(".job_details[name="+jobId+"]").css("display") == "none" )
    $(".job_details[name="+jobId+"]").css("display", "table-row");
  else
    $(".job_details[name="+jobId+"]").css("display", "none");
}

function refreshJobList(userId){
  //$("#jobs_list").load('/home/'+userId);
  $.get('/users/'+userId, function(data){
    $("#jobs_list").html(data);
  });
  
  startJobListRefresher(userId)
}

var timer;
function startJobListRefresher(userId){
  clearTimeout(timer);
  //timer = setTimeout("refreshJobList("+userId+")", 10000);
}

function accept_job(userId, absrId){
  $.get(userId+'/accept_job', {absr_id : absrId}, function(data){
    $("#accepted_job").html(data);
    $("#accepted_job").dialog("open");
  });
}

function updatePreferences(){
  
}