var openedJobDetailIds = {};

$(document).ready(function(){
  $(".reject_button a.reject").click(function(){
    var reject = confirm("Are you sure you want to reject this job?");
    if (reject){
      $(".district_table[name="+$(this).attr('name')+"]").css("background-color", "red");
      $(".district_table[name="+$(this).attr('name')+"] .spinner").css("display", "block");
    }
  });
  
  $(".rounded_list_item").each(function(){
    openedJobDetailIds[$(this).attr("name")] = false;
  });
  
});

function toggleJobDetails(jobId){
  if( $(".job_details[name="+jobId+"]").css("display") == "none" ){
    $(".job_details[name="+jobId+"]").css("display", "table-row");
    openedJobDetailIds[jobId] = true;
  }
  else{
    $(".job_details[name="+jobId+"]").css("display", "none");
    openedJobDetailIds[jobId] = false;
  }
}

function setOpenedJobDetails(){
  $(".rounded_list_item").each(function(){
    var jobId = $(this).attr("name");
    if (openedJobDetailIds[jobId]){
      $(".job_details[name="+jobId+"]").css("display", "table-row");
    }
  });
}

function refreshJobList(userId){
  $.get('/users/'+userId, function(data){
    $("#jobs_list").html(data);
    setOpenedJobDetails();
  });
  startJobListRefresher(userId);
}

var timer;
function startJobListRefresher(userId){
  clearTimeout(timer);
  timer = setTimeout("refreshJobList("+userId+")", 10000);
}