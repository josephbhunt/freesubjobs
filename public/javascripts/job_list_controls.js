$(document).ready(function(){
  $(".reject_button a.reject").click(function(){
    var reject = confirm("Are you sure you want to reject this job?");
    if (reject){
      $(".district_table[name="+$(this).attr('name')+"]").css("background-color", "red");
      $(".district_table[name="+$(this).attr('name')+"] .spinner").css("display", "block");
    }
  });
});

function toggleJobDetails(jobId){
  if( $(".job_details[name="+jobId+"]").css("display") == "none" )
    $(".job_details[name="+jobId+"]").css("display", "table-row");
  else
    $(".job_details[name="+jobId+"]").css("display", "none");
}

function refreshJobList(userId){
  $.get('/users/'+userId, function(data){
    $("#jobs_list").html(data);
  });
  
  startJobListRefresher(userId)
}

var timer;
function startJobListRefresher(userId){
  clearTimeout(timer);
  timer = setTimeout("refreshJobList("+userId+")", 10000);
}